-- ============================================
-- Step 1: Create Base Table
-- ============================================
CREATE TABLE Sales_WF (
    SaleID INT,
    EmployeeName VARCHAR(100),
    Department VARCHAR(50),
    SaleAmount INT,
    SaleDate DATE
);

-- Insert Sample Data
INSERT INTO Sales_WF VALUES
(1, 'Vaibhav', 'IT', 5000, '2024-01-01'),
(2, 'Niharika', 'IT', 7000, '2024-01-02'),
(3, 'Rahul', 'HR', 4000, '2024-01-01'),
(4, 'Amit', 'HR', 6000, '2024-01-03'),
(5, 'Sneha', 'IT', 7000, '2024-01-04');

SELECT * FROM Sales_WF;



-- ============================================
-- Step 2: Ranking Functions
-- ============================================

-- ROW_NUMBER → Unique sequential number
SELECT 
    EmployeeName,
    Department,
    SaleAmount,
    ROW_NUMBER() OVER (ORDER BY SaleAmount DESC) AS RowNum
    -- Assigns unique rank even if values are same
FROM Sales_WF;


-- RANK → Same rank for ties, skips numbers
SELECT 
    EmployeeName,
    SaleAmount,
    RANK() OVER (ORDER BY SaleAmount DESC) AS RankVal
    -- Example: 7000,7000 → both rank 1 → next rank = 3
FROM Sales_WF;


-- DENSE_RANK → Same rank for ties, NO gaps
SELECT 
    EmployeeName,
    SaleAmount,
    DENSE_RANK() OVER (ORDER BY SaleAmount DESC) AS DenseRankVal
    -- Example: 7000,7000 → both rank 1 → next rank = 2
FROM Sales_WF;


-- NTILE → Divide rows into groups
SELECT 
    EmployeeName,
    SaleAmount,
    NTILE(2) OVER (ORDER BY SaleAmount DESC) AS Bucket
    -- Divides data into 2 equal groups
FROM Sales_WF;



-- ============================================
-- Step 3: PARTITION BY (Per Group Calculation)
-- ============================================

SELECT 
    EmployeeName,
    Department,
    SaleAmount,
    ROW_NUMBER() OVER (
        PARTITION BY Department 
        ORDER BY SaleAmount DESC
    ) AS DeptRank
    -- Ranking resets for each department
FROM Sales_WF;



-- ============================================
-- Step 4: Aggregate Window Functions
-- ============================================

-- Running Total
SELECT 
    EmployeeName,
    SaleDate,
    SaleAmount,
    SUM(SaleAmount) OVER (
        ORDER BY SaleDate
    ) AS RunningTotal
    -- Cumulative sum till current row
FROM Sales_WF;


-- Average per department
SELECT 
    EmployeeName,
    Department,
    SaleAmount,
    AVG(SaleAmount) OVER (
        PARTITION BY Department
    ) AS AvgDeptSale
    -- Same average shown for each row in department
FROM Sales_WF;



-- ============================================
-- Step 5: Frame Clause (ROWS BETWEEN)
-- ============================================

SELECT 
    EmployeeName,
    SaleDate,
    SaleAmount,
    SUM(SaleAmount) OVER (
        ORDER BY SaleDate
        ROWS BETWEEN 1 PRECEDING AND CURRENT ROW
    ) AS MovingSum
    -- Current row + previous row only
FROM Sales_WF;



-- ============================================
-- Step 6: Analytical Functions (Offset Access)
-- ============================================

-- LAG → Previous row value
SELECT 
    EmployeeName,
    SaleDate,
    SaleAmount,
    LAG(SaleAmount) OVER (ORDER BY SaleDate) AS PrevSale
    -- Gets previous row value
FROM Sales_WF;


-- LEAD → Next row value
SELECT 
    EmployeeName,
    SaleDate,
    SaleAmount,
    LEAD(SaleAmount) OVER (ORDER BY SaleDate) AS NextSale
    -- Gets next row value
FROM Sales_WF;


-- FIRST_VALUE → First value in window
SELECT 
    EmployeeName,
    SaleAmount,
    FIRST_VALUE(SaleAmount) OVER (
        ORDER BY SaleAmount DESC
    ) AS HighestSale
    -- Returns highest sale for all rows
FROM Sales_WF;


-- LAST_VALUE → Last value in window
SELECT 
    EmployeeName,
    SaleAmount,
    LAST_VALUE(SaleAmount) OVER (
        ORDER BY SaleAmount
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS LowestSale
    -- Need frame to get true last value
FROM Sales_WF;



-- ============================================
-- Step 7: Combined Example (Real Scenario)
-- ============================================

SELECT 
    EmployeeName,
    Department,
    SaleAmount,

    -- Ranking per department
    RANK() OVER (PARTITION BY Department ORDER BY SaleAmount DESC) AS DeptRank,

    -- Running total per department
    SUM(SaleAmount) OVER (
        PARTITION BY Department 
        ORDER BY SaleDate
    ) AS DeptRunningTotal,

    -- Previous sale
    LAG(SaleAmount) OVER (PARTITION BY Department ORDER BY SaleDate) AS PrevSale

FROM Sales_WF;



-- ============================================
-- Step 8: View Final Data
-- ============================================
SELECT * FROM Sales_WF;



-- ============================================
-- Step 9: Cleanup
-- ============================================
DROP TABLE Sales_WF;