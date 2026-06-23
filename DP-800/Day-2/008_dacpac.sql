/* 
============================================================
📦 SQL DATABASE PROJECTS & DACPAC (SINGLE SCRIPT)
Covers:
1. Declarative Database Objects (Project Style)
2. Build Concept (Validation)
3. Deployment Simulation (Schema Compare)
4. Preview Changes (Drift Detection)
============================================================
*/


/* 
============================================================
📦 1. PROJECT-STYLE DATABASE OBJECTS
- Each object defined independently (like .sql files in project)
- Declarative approach (desired state defined)
============================================================
*/

-- Step 1: Create Schema
CREATE SCHEMA ProjectDemo;
GO

-- Step 2: Create Table (as if separate .sql file)
CREATE TABLE ProjectDemo.Employees (
    EmpID INT PRIMARY KEY,
    Name VARCHAR(100),
    Role VARCHAR(50),
    Salary DECIMAL(10,2)
);
GO

-- Step 3: Create View (another file in project)
CREATE VIEW ProjectDemo.vw_EmployeeSummary
AS
SELECT 
    Name,
    Role,
    Salary
FROM ProjectDemo.Employees;
GO

-- Step 4: Create Stored Procedure (separate file)
CREATE PROCEDURE ProjectDemo.GetEmployees
AS
BEGIN
    SELECT * FROM ProjectDemo.Employees;
END;
GO



/* 
============================================================
📦 2. BUILD (VALIDATION PHASE SIMULATION)
- In real DACPAC: dotnet build validates schema & dependencies
- Here: simulate validation via execution
============================================================
*/

-- Validate objects compile and work
EXEC ProjectDemo.GetEmployees;
GO

SELECT * FROM ProjectDemo.vw_EmployeeSummary;
GO



/* 
============================================================
📦 3. DEPLOYMENT SIMULATION (SCHEMA CHANGE)
- DACPAC compares source vs target and applies only diff
- Here: simulate ALTER instead of DROP/CREATE
============================================================
*/

-- Step 1: Modify Table (simulate schema change)
ALTER TABLE ProjectDemo.Employees
ADD Department VARCHAR(50);
GO

-- Step 2: Insert Data after change
INSERT INTO ProjectDemo.Employees
VALUES
(1, 'Vaibhav', 'Data Engineer', 85000, 'IT'),
(2, 'Niharika', 'Data Analyst', 75000, 'Analytics');
GO

-- Step 3: Validate Updated Schema
SELECT * FROM ProjectDemo.Employees;
GO



/* 
============================================================
📦 4. PREVIEW CHANGES (DRIFT DETECTION SIMULATION)
- In DACPAC: Deploy Report shows changes before applying
- Here: use metadata comparison
============================================================
*/

SELECT 
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'ProjectDemo'
ORDER BY TABLE_NAME;
GO



/* 
============================================================
📦 5. BEST PRACTICE NOTES (INLINE)
- Always use ALTER (not DROP) to preserve data
- Keep objects modular (1 file = 1 object)
- Use schema-based organization
============================================================
*/



/* 
============================================================
🧹 CLEANUP (MANDATORY)
============================================================
*/

-- Step 1: Drop Procedure
DROP PROCEDURE ProjectDemo.GetEmployees;
GO

-- Step 2: Drop View
DROP VIEW ProjectDemo.vw_EmployeeSummary;
GO

-- Step 3: Drop Table
DROP TABLE ProjectDemo.Employees;
GO

-- Step 4: Drop Schema
DROP SCHEMA ProjectDemo;
GO