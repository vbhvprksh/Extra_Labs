/* 
============================================================
🔐 PERMISSIONS & AUTHENTICATION IN SQL SERVER (SINGLE SCRIPT)
Covers:
1. Role-Based Access Control (RBAC)
2. GRANT / REVOKE / DENY hierarchy
3. Schema-Based Security
============================================================
*/


/* 
============================================================
🔐 1. CREATE SAMPLE SCHEMA & TABLES
- Demonstrates schema-based access control
============================================================
*/

-- Step 1: Create Schemas (department-wise separation)
CREATE SCHEMA Sales;
GO

CREATE SCHEMA HR;
GO

-- Step 2: Create Tables in Schemas
CREATE TABLE Sales.Orders (
    OrderID INT PRIMARY KEY,
    Customer VARCHAR(100),
    Amount DECIMAL(10,2)
);
GO

CREATE TABLE HR.Employees (
    EmpID INT PRIMARY KEY,
    Name VARCHAR(100),
    Salary DECIMAL(10,2)
);
GO

-- Step 3: Insert Sample Data
INSERT INTO Sales.Orders VALUES
(1, 'Contoso', 5000),
(2, 'Fabrikam', 7000);

INSERT INTO HR.Employees VALUES
(1, 'Vaibhav', 80000),
(2, 'Niharika', 90000);
GO



/* 
============================================================
🔐 2. CREATE USERS (AUTHENTICATION SIMULATION)
- WITHOUT LOGIN used for demo/testing
============================================================
*/

CREATE USER SalesUser WITHOUT LOGIN;
GO

CREATE USER HRUser WITHOUT LOGIN;
GO



/* 
============================================================
🔐 3. ROLE-BASED ACCESS CONTROL (RBAC)
- Create roles per job function
============================================================
*/

-- Step 1: Create Roles
CREATE ROLE SalesRole;
GO

CREATE ROLE HRRole;
GO

-- Step 2: Assign Users to Roles
ALTER ROLE SalesRole ADD MEMBER SalesUser;
GO

ALTER ROLE HRRole ADD MEMBER HRUser;
GO



/* 
============================================================
🔐 4. GRANT PERMISSIONS (ROLE LEVEL)
- GRANT gives access
============================================================
*/

-- SalesRole can read Sales schema
GRANT SELECT ON SCHEMA::Sales TO SalesRole;
GO

-- HRRole can read HR schema
GRANT SELECT ON SCHEMA::HR TO HRRole;
GO



/* 
============================================================
🔐 5. TEST ACCESS (ROLE-BASED)
============================================================
*/

-- Test SalesUser
EXECUTE AS USER = 'SalesUser';

SELECT * FROM Sales.Orders;   -- Allowed
SELECT * FROM HR.Employees;   -- Denied

REVERT;
GO

-- Test HRUser
EXECUTE AS USER = 'HRUser';

SELECT * FROM HR.Employees;   -- Allowed
SELECT * FROM Sales.Orders;   -- Denied

REVERT;
GO



/* 
============================================================
🔐 6. DENY OVERRIDES GRANT
- Even if granted via role, DENY blocks access
============================================================
*/

-- Deny access to specific table
DENY SELECT ON Sales.Orders TO SalesUser;
GO

EXECUTE AS USER = 'SalesUser';

SELECT * FROM Sales.Orders;   -- Denied due to DENY

REVERT;
GO



/* 
============================================================
🔐 7. REVOKE PERMISSION
- Removes granted/denied permission
============================================================
*/

REVOKE SELECT ON Sales.Orders FROM SalesUser;
GO

EXECUTE AS USER = 'SalesUser';

SELECT * FROM Sales.Orders;   -- Works again (inherits from role)

REVERT;
GO



/* 
============================================================
🔐 8. SCHEMA-LEVEL CONTROL
- CONTROL = full ownership on schema
- Auto-applies to future objects
============================================================
*/

-- Grant full control on schema
GRANT CONTROL ON SCHEMA::Sales TO SalesUser;
GO

-- Create new table (auto accessible due to schema permission)
CREATE TABLE Sales.NewOrders (
    ID INT,
    Product VARCHAR(50)
);
GO

EXECUTE AS USER = 'SalesUser';

SELECT * FROM Sales.NewOrders;  -- Accessible without new GRANT

REVERT;
GO



/* 
============================================================
🔐 9. VALIDATE PERMISSIONS (SYSTEM VIEWS)
============================================================
*/

SELECT 
    pr.name AS Principal,
    pe.permission_name,
    pe.state_desc,
    OBJECT_NAME(pe.major_id) AS ObjectName
FROM sys.database_permissions pe
JOIN sys.database_principals pr
ON pe.grantee_principal_id = pr.principal_id;
GO



/* 
============================================================
🧹 CLEANUP (MANDATORY)
============================================================
*/

-- Step 1: Drop Tables
DROP TABLE Sales.NewOrders;
GO

DROP TABLE Sales.Orders;
GO

DROP TABLE HR.Employees;
GO

-- Step 2: Drop Schemas
DROP SCHEMA Sales;
GO

DROP SCHEMA HR;
GO

-- Step 3: Drop Roles
DROP ROLE SalesRole;
GO

DROP ROLE HRRole;
GO

-- Step 4: Drop Users
DROP USER SalesUser;
GO

DROP USER HRUser;
GO