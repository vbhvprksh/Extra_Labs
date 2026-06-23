/* 
============================================================
🚀 CI/CD IMPLEMENTATION FOR SQL SERVER (SINGLE SCRIPT)
Covers:
1. Source Control Ready Objects
2. Build Validation (Pre-Deployment Checks)
3. Deployment (Incremental Changes)
4. Post-Deployment Validation
5. Rollback Strategy
============================================================

📌 NOTE:
- CI/CD is orchestrated using tools (Azure DevOps / GitHub Actions)
- SQL script represents what runs inside pipeline stages
- Comments explain pipeline steps in detail
============================================================
*/


/* 
============================================================
🚀 1. SOURCE CONTROL (CI STAGE - CODE COMMIT)
- Each object stored as separate .sql file in repo
- Example:
    /Tables/Employees.sql
    /Procedures/GetEmployees.sql
- Pipeline triggers on Git commit
============================================================
*/

-- Step 1: Create Schema (idempotent script → safe for repeated deployments)
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'CICD')
    EXEC('CREATE SCHEMA CICD');
GO

-- Step 2: Create Table (use IF NOT EXISTS pattern)
IF NOT EXISTS (
    SELECT * FROM sys.tables 
    WHERE name = 'Employees' AND schema_id = SCHEMA_ID('CICD')
)
CREATE TABLE CICD.Employees (
    EmpID INT PRIMARY KEY,
    Name VARCHAR(100),
    Role VARCHAR(50),
    Salary DECIMAL(10,2)
);
GO

-- Step 3: Create Stored Procedure (CREATE OR ALTER → CI/CD safe)
CREATE OR ALTER PROCEDURE CICD.GetEmployees
AS
BEGIN
    SELECT * FROM CICD.Employees;
END;
GO



/* 
============================================================
🚀 2. BUILD STAGE (CI PIPELINE)
- Validates SQL before deployment
- Equivalent to: dotnet build (DACPAC)
============================================================
*/

-- Step 1: Syntax Validation (compile objects)
-- If error occurs → pipeline fails
EXEC CICD.GetEmployees;
GO

-- Step 2: Dependency Check
-- Ensure all referenced objects exist
SELECT 
    OBJECT_NAME(referencing_id) AS ReferencingObject,
    referenced_entity_name
FROM sys.sql_expression_dependencies;
GO

-- Step 3: Static Checks (Best Practice)
-- Example: Avoid SELECT *
SELECT 
    OBJECT_NAME(object_id) AS ObjectName,
    definition
FROM sys.sql_modules
WHERE definition LIKE '%SELECT *%';
GO



/* 
============================================================
🚀 3. DEPLOYMENT STAGE (CD PIPELINE)
- Incremental deployment (only changes applied)
- Equivalent to SqlPackage / DACPAC deployment
============================================================
*/

-- Step 1: Schema Change (simulate new release)
IF COL_LENGTH('CICD.Employees', 'Department') IS NULL
BEGIN
    ALTER TABLE CICD.Employees
    ADD Department VARCHAR(50);
END
GO

-- Step 2: Insert/Update Data (idempotent logic)
MERGE CICD.Employees AS target
USING (
    SELECT 1 AS EmpID, 'Vaibhav' AS Name, 'Data Engineer' AS Role, 85000 AS Salary, 'IT' AS Department
    UNION ALL
    SELECT 2, 'Niharika', 'Data Analyst', 75000, 'Analytics'
) AS source
ON target.EmpID = source.EmpID
WHEN MATCHED THEN
    UPDATE SET 
        Name = source.Name,
        Role = source.Role,
        Salary = source.Salary,
        Department = source.Department
WHEN NOT MATCHED THEN
    INSERT (EmpID, Name, Role, Salary, Department)
    VALUES (source.EmpID, source.Name, source.Role, source.Salary, source.Department);
GO



/* 
============================================================
🚀 4. POST-DEPLOYMENT VALIDATION
- Ensures deployment success
============================================================
*/

-- Step 1: Validate Data
SELECT * FROM CICD.Employees;
GO

-- Step 2: Validate Schema
SELECT 
    COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'CICD';
GO

-- Step 3: Performance Check (basic)
SET STATISTICS IO ON;
SELECT * FROM CICD.Employees WHERE EmpID = 1;
SET STATISTICS IO OFF;
GO



/* 
============================================================
🚀 5. ROLLBACK STRATEGY (IMPORTANT IN CI/CD)
- Always keep rollback script ready
============================================================
*/

-- Example Rollback: Remove added column safely
IF COL_LENGTH('CICD.Employees', 'Department') IS NOT NULL
BEGIN
    ALTER TABLE CICD.Employees
    DROP COLUMN Department;
END
GO



/* 
============================================================
🚀 6. PIPELINE FLOW (IMPORTANT - THEORY INSIDE COMMENTS)

CI PIPELINE:
1. Developer commits SQL files → Git
2. Pipeline triggers
3. Run Build:
   - Syntax validation
   - Dependency check
   - Static code analysis
4. Generate artifact (DACPAC)

CD PIPELINE:
1. Deploy DACPAC using SqlPackage
2. Preview changes (DeployReport)
3. Apply incremental changes
4. Run post-deployment scripts
5. Validate results
6. Rollback if failure

TOOLS USED:
- Azure DevOps Pipelines
- GitHub Actions
- SqlPackage.exe
- Microsoft.Build.Sql
============================================================
*/



/* 
============================================================
🧹 CLEANUP (MANDATORY)
============================================================
*/

-- Step 1: Drop Procedure
DROP PROCEDURE CICD.GetEmployees;
GO

-- Step 2: Drop Table
DROP TABLE CICD.Employees;
GO

-- Step 3: Drop Schema
DROP SCHEMA CICD;
GO