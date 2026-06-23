-- ============================================
-- Step 1: Create Base Table (Sales Table)
-- ============================================
CREATE TABLE Sales_Data (
    SaleID INT PRIMARY KEY,                 -- Primary Key (will become clustered by default)

    ProductName VARCHAR(100) NOT NULL,      -- NOT NULL

    Category VARCHAR(50),

    SaleAmount DECIMAL(10,2) CHECK (SaleAmount > 0), -- CHECK constraint

    SaleDate DATE,

    CustomerID INT
);



-- ============================================
-- Step 2: Insert Sample Data
-- ============================================
INSERT INTO Sales_Data VALUES (1, 'Laptop', 'Electronics', 75000, '2024-01-01', 101);
INSERT INTO Sales_Data VALUES (2, 'Phone', 'Electronics', 30000, '2024-01-02', 102);
INSERT INTO Sales_Data VALUES (3, 'Shoes', 'Fashion', 5000, '2024-01-03', 103);
INSERT INTO Sales_Data VALUES (4, 'Watch', 'Accessories', 8000, '2024-01-04', 104);

SELECT * FROM Sales_Data;



-- ============================================
-- Step 3: CLUSTERED INDEX (Rowstore)
-- ============================================
-- Already created via PRIMARY KEY on SaleID
-- Data is physically sorted based on SaleID

-- ✔ Best for range queries
SELECT * 
FROM Sales_Data
WHERE SaleID BETWEEN 1 AND 3;



-- ============================================
-- Step 4: NONCLUSTERED INDEX
-- ============================================
-- Created on Category for faster filtering
CREATE NONCLUSTERED INDEX IX_Category
ON Sales_Data (Category);

-- ✔ Query using index
SELECT * 
FROM Sales_Data
WHERE Category = 'Electronics';



-- ============================================
-- Step 5: NONCLUSTERED INDEX WITH INCLUDE
-- ============================================
-- Avoid key lookup by including extra columns
CREATE NONCLUSTERED INDEX IX_Category_Include
ON Sales_Data (Category)
INCLUDE (SaleAmount, SaleDate);

-- ✔ Covered query (no lookup needed)
SELECT Category, SaleAmount, SaleDate
FROM Sales_Data
WHERE Category = 'Electronics';



-- ============================================
-- Step 6: COLUMNSTORE INDEX (CCI)
-- ============================================
-- Drop clustered PK first to create CCI
ALTER TABLE Sales_Data DROP CONSTRAINT PK__Sales_Da__SaleID;

-- Create Clustered Columnstore Index
CREATE CLUSTERED COLUMNSTORE INDEX CCI_Sales
ON Sales_Data;

-- ✔ Best for analytics (aggregation queries)
SELECT Category, SUM(SaleAmount) AS TotalSales
FROM Sales_Data
GROUP BY Category;



-- ============================================
-- Step 7: NONCLUSTERED COLUMNSTORE INDEX
-- ============================================
-- Hybrid scenario: OLTP + Analytics
-- (Recreate table for demo clarity)

DROP TABLE Sales_Data;

CREATE TABLE Sales_Data (
    SaleID INT PRIMARY KEY,
    ProductName VARCHAR(100),
    Category VARCHAR(50),
    SaleAmount DECIMAL(10,2),
    SaleDate DATE
);

INSERT INTO Sales_Data VALUES (1, 'Laptop', 'Electronics', 75000, '2024-01-01');
INSERT INTO Sales_Data VALUES (2, 'Phone', 'Electronics', 30000, '2024-01-02');
INSERT INTO Sales_Data VALUES (3, 'Shoes', 'Fashion', 5000, '2024-01-03');

-- Create Nonclustered Columnstore Index
CREATE NONCLUSTERED COLUMNSTORE INDEX NCCS_Sales
ON Sales_Data (Category, SaleAmount);

-- ✔ Analytical query works efficiently
SELECT Category, SUM(SaleAmount)
FROM Sales_Data
GROUP BY Category;



-- ============================================
-- Step 8: INSERT PERFORMANCE TRADE-OFF
-- ============================================
-- ❗ Columnstore slows down writes compared to rowstore

INSERT INTO Sales_Data VALUES (4, 'Bag', 'Fashion', 2000, '2024-01-05');

-- Explanation:
-- Rowstore → Faster inserts/updates
-- Columnstore → Faster reads (analytics)



-- ============================================
-- Step 9: Constraint Violation Demo
-- ============================================
-- ❌ CHECK violation
INSERT INTO Sales_Data VALUES (5, 'Invalid', 'Test', -100, '2024-01-06');
-- Error: SaleAmount must be > 0



-- ============================================
-- Step 10: View Final Data
-- ============================================
SELECT * FROM Sales_Data;



-- ============================================
-- Step 11: Cleanup
-- ============================================
DROP TABLE Sales_Data;