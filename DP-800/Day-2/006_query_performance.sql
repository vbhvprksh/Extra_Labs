/* 
============================================================
⚡ QUERY PERFORMANCE EVALUATION IN SQL SERVER (SINGLE SCRIPT)
Covers:
1. Identify Slow Queries (DMVs)
2. Analyze Execution Plans
3. Discover Missing Indexes
4. Apply Optimization
============================================================
*/


/* 
============================================================
⚡ 1. CREATE SAMPLE DATA (PERFORMANCE TEST SETUP)
- Large dataset to simulate real workload
============================================================
*/

-- Step 1: Create Table
CREATE TABLE SalesData (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerName VARCHAR(100),
    Product VARCHAR(100),
    Amount DECIMAL(10,2),
    OrderDate DATE
);
GO

-- Step 2: Insert Large Data (simulate heavy workload)
INSERT INTO SalesData (CustomerName, Product, Amount, OrderDate)
SELECT 
    'Customer_' + CAST(ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS VARCHAR),
    'Product_' + CAST((ABS(CHECKSUM(NEWID())) % 50) AS VARCHAR),
    (ABS(CHECKSUM(NEWID())) % 10000) + 100,
    DATEADD(DAY, -(ABS(CHECKSUM(NEWID())) % 365), GETDATE())
FROM sys.objects a
CROSS JOIN sys.objects b;
GO

-- Step 3: Validate Data Volume
SELECT COUNT(*) AS TotalRows FROM SalesData;
GO



/* 
============================================================
⚡ 2. IDENTIFY SLOW QUERIES (DMV ANALYSIS)
- Uses sys.dm_exec_query_stats
- Sort by CPU / Reads / Execution Count
============================================================
*/

SELECT TOP 10
    qs.total_worker_time / qs.execution_count AS Avg_CPU_Time,
    qs.total_logical_reads / qs.execution_count AS Avg_Logical_Reads,
    qs.execution_count,
    SUBSTRING(qt.text, (qs.statement_start_offset/2)+1,
        ((CASE qs.statement_end_offset
            WHEN -1 THEN DATALENGTH(qt.text)
            ELSE qs.statement_end_offset END
        - qs.statement_start_offset)/2)+1) AS Query_Text
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt
ORDER BY Avg_CPU_Time DESC;
GO



/* 
============================================================
⚡ 3. EXECUTION PLAN ANALYSIS
- Compare Estimated vs Actual Execution Plans
- Look for Key Lookups, Scans, Warnings
============================================================
*/

-- Enable Actual Execution Plan in SSMS (Ctrl + M)

-- Sample slow query (no index → table scan)
SELECT * 
FROM SalesData
WHERE Product = 'Product_10';
GO



/* 
============================================================
⚡ 4. DISCOVER MISSING INDEXES
- Uses sys.dm_db_missing_index_details
============================================================
*/

SELECT 
    migs.avg_total_user_cost * migs.avg_user_impact AS Improvement_Measure,
    mid.statement AS TableName,
    mid.equality_columns,
    mid.inequality_columns,
    mid.included_columns
FROM sys.dm_db_missing_index_groups mig
JOIN sys.dm_db_missing_index_group_stats migs
    ON mig.index_group_handle = migs.group_handle
JOIN sys.dm_db_missing_index_details mid
    ON mig.index_handle = mid.index_handle
ORDER BY Improvement_Measure DESC;
GO



/* 
============================================================
⚡ 5. APPLY OPTIMIZATION (CREATE INDEX)
- Covering index to eliminate scans/lookups
============================================================
*/

CREATE NONCLUSTERED INDEX IX_SalesData_Product
ON SalesData(Product)
INCLUDE (CustomerName, Amount, OrderDate);
GO



/* 
============================================================
⚡ 6. RE-RUN QUERY (OPTIMIZED)
- Expect Index Seek instead of Scan
============================================================
*/

SELECT * 
FROM SalesData
WHERE Product = 'Product_10';
GO



/* 
============================================================
⚡ 7. UPDATE STATISTICS (BEST PRACTICE)
- Ensures optimizer uses correct data distribution
============================================================
*/

UPDATE STATISTICS SalesData;
GO



/* 
============================================================
⚡ 8. VALIDATE PERFORMANCE IMPROVEMENT
============================================================
*/

SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT * 
FROM SalesData
WHERE Product = 'Product_10';

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO



/* 
============================================================
🧹 CLEANUP (MANDATORY)
============================================================
*/

-- Step 1: Drop Index
DROP INDEX IX_SalesData_Product ON SalesData;
GO

-- Step 2: Drop Table
DROP TABLE SalesData;
GO