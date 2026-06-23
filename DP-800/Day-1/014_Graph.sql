-- ============================================
-- Step 1: Create NODE Tables
-- ============================================
-- Node = Entity (like Person, Post)

CREATE TABLE Person_Node (
    PersonID INT PRIMARY KEY,
    Name VARCHAR(100)
) AS NODE;

CREATE TABLE Post_Node (
    PostID INT PRIMARY KEY,
    Content VARCHAR(200)
) AS NODE;



-- ============================================
-- Step 2: Create EDGE Tables
-- ============================================
-- Edge = Relationship between nodes

CREATE TABLE Follows AS EDGE;   -- Person → Person
CREATE TABLE Likes AS EDGE;     -- Person → Post



-- ============================================
-- Step 3: Insert Sample Data
-- ============================================
INSERT INTO Person_Node VALUES
(1, 'Alex'),
(2, 'Jamie'),
(3, 'Morgan'),
(4, 'Taylor'),
(5, 'Jordan');

INSERT INTO Post_Node VALUES
(101, 'Post A'),
(102, 'Post B');

-- Relationships (Edges)
INSERT INTO Follows ($from_id, $to_id)
SELECT P1.$node_id, P2.$node_id
FROM Person_Node P1, Person_Node P2
WHERE P1.Name = 'Alex' AND P2.Name = 'Jamie';

INSERT INTO Follows ($from_id, $to_id)
SELECT P1.$node_id, P2.$node_id
FROM Person_Node P1, Person_Node P2
WHERE P1.Name = 'Jamie' AND P2.Name = 'Morgan';

-- Likes
INSERT INTO Likes ($from_id, $to_id)
SELECT P.$node_id, Post.$node_id
FROM Person_Node P, Post_Node Post
WHERE P.Name = 'Morgan' AND Post.PostID = 101;



-- ============================================
-- Step 4: Basic MATCH Query
-- ============================================
-- Find who follows whom

SELECT 
    P1.Name AS Follower,
    P2.Name AS Following
FROM Person_Node P1, Follows, Person_Node P2
WHERE MATCH(P1-(Follows)->P2);

-- ✔ Traverses graph using edge



-- ============================================
-- Step 5: Multi-hop Traversal (Friends of Friends)
-- ============================================
-- Alex → Jamie → Morgan

SELECT 
    P1.Name AS Person,
    P3.Name AS FriendOfFriend
FROM Person_Node P1,
     Follows F1,
     Person_Node P2,
     Follows F2,
     Person_Node P3
WHERE MATCH(P1-(F1)->P2-(F2)->P3)
AND P1.Name = 'Alex';

-- ✔ Multi-level traversal (2 hops)



-- ============================================
-- Step 6: Graph + Post (Real Use Case)
-- ============================================
-- Find posts liked by friends of Alex

SELECT 
    P1.Name AS Person,
    P3.Name AS Friend,
    Post.Content
FROM Person_Node P1,
     Follows F1,
     Person_Node P2,
     Follows F2,
     Person_Node P3,
     Likes L,
     Post_Node Post
WHERE MATCH(P1-(F1)->P2-(F2)->P3-(L)->Post)
AND P1.Name = 'Alex';

-- ✔ Combines multiple edges (Follows + Likes)



-- ============================================
-- Step 7: EXISTS (Correlated Subquery Style)
-- ============================================
-- Find people who follow someone who liked a post

SELECT P.Name
FROM Person_Node P
WHERE EXISTS (
    SELECT 1
    FROM Follows F, Person_Node P2, Likes L, Post_Node Post
    WHERE MATCH(P-(F)->P2-(L)->Post)
);

-- ✔ Correlated logic using graph traversal



-- ============================================
-- Step 8: Filtering + Graph Traversal
-- ============================================
-- Find posts liked by people whose name starts with 'M'

SELECT 
    P.Name,
    Post.Content
FROM Person_Node P,
     Likes L,
     Post_Node Post
WHERE MATCH(P-(L)->Post)
AND P.Name LIKE 'M%';



-- ============================================
-- Step 9: Another Real Example (Recommendation)
-- ============================================
-- Suggest new friends (friends of friends NOT already followed)

SELECT DISTINCT P3.Name AS SuggestedFriend
FROM Person_Node P1,
     Follows F1,
     Person_Node P2,
     Follows F2,
     Person_Node P3
WHERE MATCH(P1-(F1)->P2-(F2)->P3)
AND P1.Name = 'Alex'
AND P3.Name <> 'Alex';

-- ✔ Recommendation system logic



-- ============================================
-- Step 10: Key Concepts Explanation
-- ============================================

-- NODE:
-- Represents entities (Person, Post)

-- EDGE:
-- Represents relationships (Follows, Likes)

-- MATCH:
-- Used for pattern traversal in graph

-- Multi-hop:
-- Chain traversal across multiple edges

-- EXISTS:
-- Used for per-row graph condition checking



-- ============================================
-- Step 11: Cleanup
-- ============================================
DROP TABLE Likes;
DROP TABLE Follows;
DROP TABLE Post_Node;
DROP TABLE Person_Node;