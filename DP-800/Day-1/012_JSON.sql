-- ============================================
-- Step 1: Create Base Table with JSON Column
-- ============================================
CREATE TABLE Orders_JSON (
    OrderID INT PRIMARY KEY,
    CustomerName VARCHAR(100),
    OrderDetails NVARCHAR(MAX)   -- JSON column
);

-- Insert Sample JSON Data
INSERT INTO Orders_JSON VALUES
(1, 'Vaibhav', '{"Product":"Laptop","Price":50000,"Items":[{"Item":"Mouse","Qty":1},{"Item":"Bag","Qty":2}]}'),
(2, 'Niharika', '{"Product":"Phone","Price":30000,"Items":[{"Item":"Charger","Qty":1}]}');

SELECT * FROM Orders_JSON;



-- ============================================
-- Step 2: JSON_VALUE (Extract Scalar Value)
-- ============================================
SELECT 
    CustomerName,
    JSON_VALUE(OrderDetails, '$.Product') AS Product,
    JSON_VALUE(OrderDetails, '$.Price') AS Price
    -- Extracts scalar values (single value)
FROM Orders_JSON;



-- ============================================
-- Step 3: JSON_QUERY (Extract Object / Array)
-- ============================================
SELECT 
    CustomerName,
    JSON_QUERY(OrderDetails, '$.Items') AS Items
    -- Returns JSON array/object (not scalar)
FROM Orders_JSON;



-- ============================================
-- Step 4: OPENJSON (Parse JSON to Rows)
-- ============================================
-- Convert JSON array into tabular format

SELECT 
    O.CustomerName,
    J.Item,
    J.Qty
FROM Orders_JSON O
CROSS APPLY OPENJSON(O.OrderDetails, '$.Items')
WITH (
    Item VARCHAR(50) '$.Item',
    Qty INT '$.Qty'
) AS J;

-- ✔ Converts JSON array into relational rows



-- ============================================
-- Step 5: JSON_OBJECT (Create JSON Object)
-- ============================================
SELECT 
    JSON_OBJECT(
        'Name': CustomerName,
        'OrderID': OrderID
    ) AS JSON_Output
    -- Creates JSON from key-value pairs
FROM Orders_JSON;



-- ============================================
-- Step 6: JSON_ARRAYAGG (Aggregate to JSON Array)
-- ============================================
SELECT 
    JSON_ARRAYAGG(CustomerName) AS CustomerList
    -- Combines multiple rows into JSON array
FROM Orders_JSON;



-- ============================================
-- Step 7: FOR JSON PATH (Relational → JSON)
-- ============================================
SELECT 
    OrderID,
    CustomerName
FROM Orders_JSON
FOR JSON PATH;

-- ✔ Converts entire result set into JSON array



-- ============================================
-- Step 8: Nested JSON using FOR JSON PATH
-- ============================================
SELECT 
    CustomerName,
    (
        SELECT OrderID
        FROM Orders_JSON O2
        WHERE O2.CustomerName = O1.CustomerName
        FOR JSON PATH
    ) AS Orders
FROM Orders_JSON O1;

-- ✔ Creates nested JSON structure



-- ============================================
-- Step 9: Combined Real Scenario
-- ============================================
-- Extract + Parse + Transform JSON

SELECT 
    CustomerName,
    JSON_VALUE(OrderDetails, '$.Product') AS Product,
    J.Item,
    J.Qty
FROM Orders_JSON O
CROSS APPLY OPENJSON(O.OrderDetails, '$.Items')
WITH (
    Item VARCHAR(50) '$.Item',
    Qty INT '$.Qty'
) J;



-- ============================================
-- Step 10: View Final Data
-- ============================================
SELECT * FROM Orders_JSON;



-- ============================================
-- Step 11: Cleanup
-- ============================================
DROP TABLE Orders_JSON;