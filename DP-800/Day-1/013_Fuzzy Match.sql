-- ============================================
-- Step 1: Create Base Table (Customer Names)
-- ============================================
CREATE TABLE Customers_Fuzzy (
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(100)
);

-- Insert Sample Data (with variations / typos)
INSERT INTO Customers_Fuzzy VALUES
(1, 'John'),
(2, 'Jon'),
(3, 'Johan'),
(4, 'Johnny'),
(5, 'Jane'),
(6, 'Joan');

SELECT * FROM Customers_Fuzzy;



-- ============================================
-- Step 2: Basic Filtering (Pre-filter using LIKE)
-- ============================================
-- Always reduce dataset before fuzzy matching (performance)

SELECT *
FROM Customers_Fuzzy
WHERE CustomerName LIKE 'Jo%';

-- ✔ Only similar prefix names considered
-- Improves performance before applying expensive fuzzy logic



-- ============================================
-- Step 3: Levenshtein Distance (Edit Distance)
-- ============================================
-- Measures number of edits needed to convert one string to another

-- Example logic (manual comparison for demo)
-- John vs Jon → distance = 1 (remove 'h')
-- John vs Johan → distance = 1 (add 'a')

-- SQL Server doesn't have built-in function → simulate via logic or UDF
-- Below is simplified comparison using DIFFERENCE + SOUNDEX

SELECT 
    A.CustomerName AS Name1,
    B.CustomerName AS Name2,
    DIFFERENCE(A.CustomerName, B.CustomerName) AS SimilarityScore
    -- Range: 0 (different) to 4 (very similar)
FROM Customers_Fuzzy A
CROSS JOIN Customers_Fuzzy B
WHERE A.CustomerID < B.CustomerID;



-- ============================================
-- Step 4: Similarity Filtering
-- ============================================
-- Get only close matches

SELECT 
    A.CustomerName,
    B.CustomerName,
    DIFFERENCE(A.CustomerName, B.CustomerName) AS Score
FROM Customers_Fuzzy A
JOIN Customers_Fuzzy B
    ON A.CustomerID < B.CustomerID
WHERE DIFFERENCE(A.CustomerName, B.CustomerName) >= 3;

-- ✔ High score = similar names
-- Example: John ~ Jon, John ~ Johnny



-- ============================================
-- Step 5: Ranking Best Matches
-- ============================================
-- Find closest match for each name

SELECT 
    A.CustomerName,
    B.CustomerName,
    DIFFERENCE(A.CustomerName, B.CustomerName) AS Score,
    ROW_NUMBER() OVER (
        PARTITION BY A.CustomerName 
        ORDER BY DIFFERENCE(A.CustomerName, B.CustomerName) DESC
    ) AS RankMatch
FROM Customers_Fuzzy A
JOIN Customers_Fuzzy B
    ON A.CustomerID <> B.CustomerID;

-- ✔ Rank 1 = best match



-- ============================================
-- Step 6: Real Use Case (Duplicate Detection)
-- ============================================
-- Identify possible duplicate names

SELECT 
    A.CustomerName AS OriginalName,
    B.CustomerName AS PossibleDuplicate,
    DIFFERENCE(A.CustomerName, B.CustomerName) AS Similarity
FROM Customers_Fuzzy A
JOIN Customers_Fuzzy B
    ON A.CustomerID < B.CustomerID
WHERE DIFFERENCE(A.CustomerName, B.CustomerName) >= 3;

-- ✔ Helps in data cleaning



-- ============================================
-- Step 7: Advanced Concept (Custom Levenshtein UDF)
-- ============================================
-- For real projects → create UDF for edit distance
-- (Pseudo representation)

-- CREATE FUNCTION FN_Levenshtein(@s1, @s2)
-- RETURNS INT
-- BEGIN
--     -- Logic to calculate edit distance
--     RETURN distance;
-- END

-- Then use:
-- SELECT dbo.FN_Levenshtein('John','Jon')



-- ============================================
-- Step 8: Best Practice Summary
-- ============================================
-- ✔ Always pre-filter using LIKE
-- ✔ Use fuzzy only on reduced dataset
-- ✔ Combine with ranking
-- ✔ Use proper algorithms (Levenshtein, Jaro-Winkler)



-- ============================================
-- Step 9: Cleanup
-- ============================================
DROP TABLE Customers_Fuzzy;