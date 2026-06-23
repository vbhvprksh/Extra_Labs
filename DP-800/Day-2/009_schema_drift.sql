/* 
============================================================
🔍 DETECT & RESOLVE SCHEMA DRIFT IN SQL SERVER (SINGLE SCRIPT)
Covers:
1. Simulate Schema Drift
2. Detect Drift (Metadata Comparison)
3. Generate Fix Script (Like DeployReport)
4. Resolve Drift Safely
============================================================
*/


/* 
============================================================
🔍 1. BASELINE SCHEMA (SOURCE OF TRUTH)
- Represents project / DACPAC expected structure
============================================================
*/

-- Step 1: Create Schema
CREATE SCHEMA DriftDemo;
GO

-- Step 2: Create Baseline Table
CREATE TABLE DriftDemo.Employees (
    EmpID INT PRIMARY KEY,
    Name VARCHAR(100),
    Role VARCHAR(50)
);
GO

-- Step 3: Insert Baseline Data
INSERT INTO DriftDemo.Employees VALUES
(1, 'Vaibhav', 'Data Engineer'),
(2, 'Niharika', 'Data Analyst');
GO

SELECT * FROM DriftDemo.Employees;
GO



/* 
============================================================
🔍 2. SIMULATE SCHEMA DRIFT (PRODUCTION CHANGE)
- Unauthorized/manual change outside project
============================================================
*/

-- Drift: Add new column directly in DB (not in project)
ALTER TABLE DriftDemo.Employees
ADD Salary DECIMAL(10,2);
GO

-- Drift: Create new table not tracked in project
CREATE TABLE DriftDemo.TempAudit (
    ID INT,
    Info VARCHAR(100)
);
GO



/* 
============================================================
🔍 3. DETECT DRIFT (SCHEMA COMPARISON)
- Compare expected vs actual schema using metadata
============================================================
*/

-- Step 1: Check unexpected columns
SELECT 
    TABLE_NAME,
    COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'DriftDemo'
AND COLUMN_NAME NOT IN ('EmpID', 'Name', 'Role');
GO

-- Step 2: Check unexpected tables
SELECT 
    TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'DriftDemo'
AND TABLE_NAME NOT IN ('Employees');
GO



/* 
============================================================
🔍 4. GENERATE FIX SCRIPT (LIKE DEPLOY REPORT)
- Identify changes before applying fix
============================================================
*/

-- Show full schema for review
SELECT 
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'DriftDemo'
ORDER BY TABLE_NAME;
GO



/* 
============================================================
🔍 5. RESOLVE DRIFT (SAFE CORRECTION)
- Align database with baseline (project)
============================================================
*/

-- Step 1: Remove unexpected column
ALTER TABLE DriftDemo.Employees
DROP COLUMN Salary;
GO

-- Step 2: Drop untracked table
DROP TABLE DriftDemo.TempAudit;
GO

-- Step 3: Validate Schema Matches Baseline
SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'DriftDemo';
GO



/* 
============================================================
🔍 6. BEST PRACTICES (INLINE)
- Never apply direct changes in production
- Always compare before deploy (DeployReport)
- Use source control for schema tracking
- Block destructive changes (data loss protection)
============================================================
*/



/* 
============================================================
🧹 CLEANUP (MANDATORY)
============================================================
*/

-- Step 1: Drop Table
DROP TABLE DriftDemo.Employees;
GO

-- Step 2: Drop Schema
DROP SCHEMA DriftDemo;
GO