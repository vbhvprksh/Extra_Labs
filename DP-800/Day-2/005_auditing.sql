/* 
============================================================
🔍 IMPLEMENT AUDITING IN SQL SERVER (SINGLE SCRIPT)
Covers:
- Server Audit
- Database Audit Specification
- Query Audit Logs
- Configuration Best Practices
============================================================
*/


/* 
============================================================
🔍 1. CREATE SERVER AUDIT
- Defines where audit logs will be stored
- FILE target used (can also use APPLICATION_LOG / SECURITY_LOG)
============================================================
*/

-- Step 1: Create Server Audit
CREATE SERVER AUDIT Demo_Server_Audit
TO FILE (
    FILEPATH = 'C:\AuditLogs\',   -- Ensure folder exists
    MAXSIZE = 10 MB,
    MAX_ROLLOVER_FILES = 5
)
WITH (
    QUEUE_DELAY = 1000,   -- Buffer delay (ms)
    ON_FAILURE = CONTINUE -- Use SHUTDOWN for strict compliance
);
GO

-- Step 2: Enable Server Audit
ALTER SERVER AUDIT Demo_Server_Audit
WITH (STATE = ON);
GO



/* 
============================================================
🔍 2. CREATE DATABASE AUDIT SPECIFICATION
- Defines what actions to audit inside database
============================================================
*/

USE master;
GO

CREATE DATABASE Audit_Demo_DB;
GO

USE Audit_Demo_DB;
GO

-- Step 1: Create Sample Table
CREATE TABLE Employees (
    ID INT PRIMARY KEY,
    Name VARCHAR(100),
    Salary DECIMAL(10,2)
);
GO

INSERT INTO Employees VALUES
(1, 'Vaibhav', 80000),
(2, 'Niharika', 90000);
GO

-- Step 2: Create Database Audit Specification
CREATE DATABASE AUDIT SPECIFICATION Demo_DB_Audit
FOR SERVER AUDIT Demo_Server_Audit
ADD (SELECT ON OBJECT::dbo.Employees BY PUBLIC),
ADD (INSERT ON OBJECT::dbo.Employees BY PUBLIC),
ADD (UPDATE ON OBJECT::dbo.Employees BY PUBLIC),
ADD (DELETE ON OBJECT::dbo.Employees BY PUBLIC)
WITH (STATE = ON);
GO



/* 
============================================================
🔍 3. GENERATE AUDIT EVENTS
- Perform operations to capture logs
============================================================
*/

SELECT * FROM Employees;
GO

INSERT INTO Employees VALUES (3, 'TestUser', 50000);
GO

UPDATE Employees SET Salary = 85000 WHERE ID = 1;
GO

DELETE FROM Employees WHERE ID = 3;
GO



/* 
============================================================
🔍 4. QUERY AUDIT LOGS
- Read audit logs using fn_get_audit_file
============================================================
*/

SELECT 
    event_time,
    action_id,
    succeeded,
    server_principal_name,
    database_name,
    object_name,
    statement
FROM sys.fn_get_audit_file (
    'C:\AuditLogs\*.sqlaudit', 
    DEFAULT, 
    DEFAULT
);
GO



/* 
============================================================
🔍 5. VALIDATE AUDIT CONFIGURATION
============================================================
*/

-- Check Server Audit
SELECT * FROM sys.server_audits;
GO

-- Check Database Audit Specification
SELECT * FROM sys.database_audit_specifications;
GO



/* 
============================================================
🧹 CLEANUP (MANDATORY)
============================================================
*/

-- Step 1: Disable Database Audit Specification
ALTER DATABASE AUDIT SPECIFICATION Demo_DB_Audit
WITH (STATE = OFF);
GO

-- Step 2: Drop Database Audit Specification
DROP DATABASE AUDIT SPECIFICATION Demo_DB_Audit;
GO

-- Step 3: Disable Server Audit
ALTER SERVER AUDIT Demo_Server_Audit
WITH (STATE = OFF);
GO

-- Step 4: Drop Server Audit
DROP SERVER AUDIT Demo_Server_Audit;
GO

-- Step 5: Drop Database
USE master;
GO

DROP DATABASE Audit_Demo_DB;
GO