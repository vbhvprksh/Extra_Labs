-- ============================================
-- Step 1: Create Base Table
-- ============================================
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerName VARCHAR(100),
    Quantity INT,
    Price DECIMAL(10,2)
);

-- Insert Sample Data
INSERT INTO Orders VALUES
(1, 'Vaibhav', 2, 1000),
(2, 'Niharika', 1, 2000),
(3, 'Rahul', 5, 500);

SELECT * FROM Orders;



-- ============================================
-- Step 2: Scalar Function
-- ============================================
-- Returns total amount (Quantity * Price)
CREATE FUNCTION FN_TotalAmount (
    @Quantity INT,
    @Price DECIMAL(10,2)
)
RETURNS DECIMAL(10,2)
AS
BEGIN
    RETURN (@Quantity * @Price);
END;

-- ✔ Usage
SELECT 
    OrderID,
    dbo.FN_TotalAmount(Quantity, Price) AS TotalAmount
FROM Orders;



-- ============================================
-- Step 3: Scalar Function Performance Issue
-- ============================================
-- ❗ Used in WHERE (Bad for large tables)
SELECT *
FROM Orders
WHERE dbo.FN_TotalAmount(Quantity, Price) > 2000;

-- Explanation:
-- Scalar functions execute row-by-row → slow



-- ============================================
-- Step 4: Inline Table-Valued Function (Best Performance)
-- ============================================
CREATE FUNCTION FN_OrderSummary_Inline()
RETURNS TABLE
AS
RETURN
(
    SELECT 
        OrderID,
        CustomerName,
        Quantity * Price AS TotalAmount
    FROM Orders
);

-- ✔ Usage (Optimized, gets merged into query plan)
SELECT * FROM dbo.FN_OrderSummary_Inline();



-- ============================================
-- Step 5: Multi-Statement Table-Valued Function
-- ============================================
CREATE FUNCTION FN_OrderSummary_Multi()
RETURNS @Result TABLE (
    OrderID INT,
    CustomerName VARCHAR(100),
    TotalAmount DECIMAL(10,2)
)
AS
BEGIN
    INSERT INTO @Result
    SELECT 
        OrderID,
        CustomerName,
        Quantity * Price
    FROM Orders;

    RETURN;
END;

-- ✔ Usage
SELECT * FROM dbo.FN_OrderSummary_Multi();

-- ❗ Note:
-- Treated as black box → less optimization



-- ============================================
-- Step 6: CROSS APPLY (Important Concept)
-- ============================================
-- Call TVF for each row
SELECT O.OrderID, O.CustomerName, T.TotalAmount
FROM Orders O
CROSS APPLY (
    SELECT O.Quantity * O.Price AS TotalAmount
) T;

-- OR using inline TVF
SELECT O.OrderID, O.CustomerName, T.TotalAmount
FROM Orders O
CROSS APPLY dbo.FN_OrderSummary_Inline() T
WHERE O.OrderID = T.OrderID;



-- ============================================
-- Step 7: Best Practices Demo
-- ============================================
-- ✔ Deterministic function (same input → same output)
-- ✔ No side effects (no INSERT/UPDATE inside scalar UDF)

-- ❌ Bad Practice Example
-- Functions should NOT modify data
-- (SQL Server restricts this)



-- ============================================
-- Step 8: Comparison Summary (Query Behavior)
-- ============================================
-- Scalar → row-by-row execution
SELECT dbo.FN_TotalAmount(Quantity, Price) FROM Orders;

-- Inline TVF → optimized like normal query
SELECT * FROM dbo.FN_OrderSummary_Inline();

-- Multi TVF → slower (no optimization pushdown)
SELECT * FROM dbo.FN_OrderSummary_Multi();



-- ============================================
-- Step 9: View Final Data
-- ============================================
SELECT * FROM Orders;



-- ============================================
-- Step 10: Cleanup
-- ============================================
DROP FUNCTION FN_TotalAmount;
DROP FUNCTION FN_OrderSummary_Inline;
DROP FUNCTION FN_OrderSummary_Multi;

DROP TABLE Orders;