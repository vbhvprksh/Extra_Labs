/*
============================================================
🔐 MODULE 3 : AUTHORIZING USERS TO ACCESS RESOURCES

PART 1 : OBJECT LEVEL PERMISSIONS,
LOGIN CREATION AND ACCESS VERIFICATION

Topics Covered

1. Creating Databases
2. Creating Tables
3. Creating SQL Logins
4. Creating Database Users
5. Granting Permissions
6. Verifying Effective Permissions
7. Testing Access Using EXECUTE AS

Execute entire script as SysAdmin

============================================================
*/


/*
============================================================
STEP 1 : CREATE DEMO DATABASE

PermissionLab will be used
for authorization exercises.

============================================================
*/

CREATE DATABASE PermissionLab;
GO

USE PermissionLab;
GO


/*
VERIFY DATABASE CREATION
*/

SELECT name,create_date
FROM sys.databases
WHERE name='PermissionLab';
GO


/*
EXPECTED RESULT


PermissionLab



UI Verification


SSMS


Databases


Refresh


PermissionLab


should appear.
*/
GO




/*
============================================================
STEP 2 : CREATE SAMPLE TABLE

Employees table will be used
for permission demonstrations.

============================================================
*/

CREATE TABLE dbo.Employees
(
EmployeeID INT PRIMARY KEY,
EmployeeName VARCHAR(100)
);
GO


/*
VERIFY TABLE CREATION
*/

SELECT name
FROM sys.tables
WHERE name='Employees';
GO



/*
EXPECTED RESULT


Employees



UI Verification


SSMS


PermissionLab


Tables


dbo.Employees


should appear.
*/
GO





/*
============================================================
STEP 3 : INSERT SAMPLE DATA

Sample rows are required
to verify SELECT access.

============================================================
*/

INSERT INTO dbo.Employees
VALUES
(1,'Raj'),
(2,'Amit');
GO



SELECT *
FROM dbo.Employees;
GO




/*
EXPECTED RESULT


EmployeeID    EmployeeName
----------    ------------
1             Raj
2             Amit



UI Verification


SSMS


PermissionLab


Tables


dbo.Employees


Right Click


Select Top 1000 Rows
*/
GO





/*
============================================================
STEP 4 : CREATE SQL SERVER LOGIN

Login Name


EmployeeLogin


Login is stored in


master.sys.server_principals


============================================================
*/

CREATE LOGIN EmployeeLogin
WITH PASSWORD='P@ssword123!';
GO




/*
VERIFY LOGIN
*/

SELECT name,
type_desc,
create_date
FROM sys.server_principals
WHERE name='EmployeeLogin';
GO




/*
EXPECTED RESULT


name
----------------
EmployeeLogin



type_desc
----------------
SQL_LOGIN



UI Verification


SSMS


Security


Logins


Refresh


EmployeeLogin


should appear.
*/
GO






/*
============================================================
STEP 5 : CREATE DATABASE USER

Login


EmployeeLogin



Database User


EmployeeUser


============================================================
*/

CREATE USER EmployeeUser
FOR LOGIN EmployeeLogin;
GO




/*
VERIFY DATABASE USER
*/

SELECT name,
type_desc,
authentication_type_desc
FROM sys.database_principals
WHERE name='EmployeeUser';
GO




/*
EXPECTED RESULT


name
----------------
EmployeeUser



type_desc
----------------
SQL_USER



authentication_type_desc
------------------------
INSTANCE




UI Verification


SSMS


PermissionLab


Security


Users


Refresh


EmployeeUser


should appear.
*/
GO






/*
============================================================
STEP 6 : GRANT OBJECT LEVEL PERMISSION

Grant SELECT access

on Employees table.

============================================================
*/

GRANT SELECT
ON dbo.Employees
TO EmployeeUser;
GO




/*
VERIFY PERMISSIONS
*/

SELECT permission_name,
state_desc,
class_desc
FROM sys.database_permissions
WHERE grantee_principal_id=
USER_ID('EmployeeUser');
GO




/*
EXPECTED RESULT


permission_name
----------------
SELECT



state_desc
----------------
GRANT



class_desc
----------------
OBJECT_OR_COLUMN




UI Verification


SSMS


PermissionLab


Security


Users


EmployeeUser


Right Click


Properties


Securables


Permissions
*/
GO






/*
============================================================
STEP 7 : VERIFY EFFECTIVE PERMISSIONS

fn_my_permissions returns
permissions available
to current execution context.

============================================================
*/

EXECUTE AS USER='EmployeeUser';

SELECT *
FROM fn_my_permissions
('dbo.Employees','OBJECT');

REVERT;
GO




/*
EXPECTED RESULT


SELECT


VIEW DEFINITION


REFERENCES



Additional permissions
may appear.



UI Verification


SSMS


PermissionLab


Security


Users


EmployeeUser


Properties


Securables
*/
GO






/*
============================================================
STEP 8 : TEST READ ACCESS

EmployeeUser should be able
to read data from Employees.

============================================================
*/

EXECUTE AS USER='EmployeeUser';

SELECT *
FROM dbo.Employees;

REVERT;
GO




/*
EXPECTED RESULT


EmployeeID    EmployeeName
----------    ------------
1             Raj
2             Amit



This confirms that


EmployeeLogin


and


EmployeeUser


are correctly mapped.
*/
GO





/*
============================================================
STEP 9 : IMPERSONATE USER

EXECUTE AS USER changes
execution context inside
the current session.

============================================================
*/

EXECUTE AS USER='EmployeeUser';

SELECT USER_NAME()
AS CurrentUser;

SELECT DB_NAME()
AS CurrentDatabase;

REVERT;
GO




/*
EXPECTED RESULT


CurrentUser
--------------
EmployeeUser



CurrentDatabase
----------------
PermissionLab




UI Verification


Open another SSMS Window


Connect using


SQL Authentication



Login


EmployeeLogin



Execute


SELECT USER_NAME();


SELECT DB_NAME();
*/
GO





/*
============================================================
STEP 10 : VERIFY CURRENT SESSION

Useful diagnostic queries.

============================================================
*/

SELECT USER_NAME()
AS CurrentUser;


SELECT ORIGINAL_LOGIN()
AS OriginalLogin;


SELECT SUSER_NAME()
AS ServerLogin;


SELECT DB_NAME()
AS CurrentDatabase;
GO




/*
EXPECTED RESULT


CurrentUser
------------
dbo



OriginalLogin
--------------
sa



ServerLogin
------------
sa



CurrentDatabase
----------------
PermissionLab



Values may vary
depending upon
your environment.
*/
GO

/*
============================================================
STEP 11 : DENY INSERT PERMISSION

DENY overrides GRANT.

EmployeeUser should not
be able to insert data.

============================================================
*/

DENY INSERT
ON dbo.Employees
TO EmployeeUser;
GO


/*
VERIFY PERMISSION
*/

SELECT permission_name,
state_desc
FROM sys.database_permissions
WHERE grantee_principal_id=
USER_ID('EmployeeUser');
GO


/*
EXPECTED RESULT


permission_name
---------------
SELECT


INSERT



state_desc
---------------
GRANT


DENY




UI Verification


SSMS


PermissionLab


Security


Users


EmployeeUser


Properties


Securables


Permissions


INSERT


should show


DENY
*/
GO




/*
============================================================
STEP 12 : VERIFY DENY PRECEDENCE

EmployeeUser should fail
to insert records.

============================================================
*/


EXECUTE AS USER='EmployeeUser';


INSERT INTO dbo.Employees
VALUES
(3,'Vikas');


REVERT;
GO




/*
EXPECTED RESULT


Msg 229


INSERT permission denied
on object Employees.



This proves


DENY


takes precedence over


GRANT.



*/
GO





/*
============================================================
STEP 13 : CREATE SCHEMA

Schemas provide
logical grouping
of objects.


Examples


HR


Sales


Finance


============================================================
*/


CREATE SCHEMA HR;
GO




/*
VERIFY SCHEMA
*/


SELECT name
FROM sys.schemas
WHERE name='HR';
GO




/*
EXPECTED RESULT


HR




UI Verification


SSMS


PermissionLab


Security


Schemas


Refresh


HR


should appear.
*/
GO






/*
============================================================
STEP 14 : CREATE TABLE
INSIDE HR SCHEMA

============================================================
*/


CREATE TABLE HR.Payroll
(
EmployeeID INT,
Salary MONEY
);
GO




INSERT INTO HR.Payroll
VALUES
(1,75000),
(2,68000);
GO




SELECT *
FROM HR.Payroll;
GO




/*
EXPECTED RESULT


EmployeeID     Salary
-----------    -------
1              75000


2              68000




UI Verification


SSMS


PermissionLab


Tables


HR.Payroll


Right Click


Select Top 1000 Rows
*/
GO






/*
============================================================
STEP 15 : GRANT SCHEMA LEVEL
PERMISSION

EmployeeUser receives
SELECT access on all
objects inside HR schema.

============================================================
*/


GRANT SELECT
ON SCHEMA::HR
TO EmployeeUser;
GO




/*
VERIFY SCHEMA PERMISSION
*/


SELECT permission_name,
state_desc
FROM sys.database_permissions
WHERE grantee_principal_id=
USER_ID('EmployeeUser');
GO




/*
EXPECTED RESULT


SELECT


GRANT




Additional permissions
may appear.


*/
GO






/*
============================================================
STEP 16 : VERIFY SCHEMA ACCESS

EmployeeUser should
be able to read
Payroll table.

============================================================
*/


EXECUTE AS USER='EmployeeUser';


SELECT *
FROM HR.Payroll;


REVERT;
GO




/*
EXPECTED RESULT


EmployeeID     Salary
-----------    -------


1              75000


2              68000




Schema permission
works correctly.


*/
GO






/*
============================================================
STEP 17 : VERIFY EFFECTIVE
PERMISSIONS

============================================================
*/


EXECUTE AS USER='EmployeeUser';


SELECT *
FROM fn_my_permissions
(NULL,'DATABASE');


REVERT;
GO




/*
EXPECTED RESULT


CONNECT


SELECT


VIEW DEFINITION



Additional permissions
may appear.


*/
GO






/*
============================================================
STEP 18 : TROUBLESHOOTING


Common Error


SELECT permission denied
on object Payroll.




Cause


Schema permission
missing.




Fix


GRANT SELECT

ON SCHEMA::HR

TO EmployeeUser;





Another Common Error


Cannot execute as user.




Cause


User missing.




Fix


CREATE USER EmployeeUser

FOR LOGIN EmployeeLogin;





Another Common Error


Login failed for user.




Cause


Wrong password


Disabled Login


Database Offline



============================================================
*/
GO






/*
============================================================
STEP 19 : BEST PRACTICES


Prefer


Schema level permissions




Avoid granting
permissions directly
on every object.




Use


Custom Roles




Follow


Least Privilege Principle




Avoid


db_owner


sysadmin



unless required.


============================================================
*/
GO






/*
============================================================
STEP 20 : MINI LAB EXERCISES


Exercise 1


Grant UPDATE
permission.




Exercise 2


Create Finance schema.




Exercise 3


Create Finance table.




Exercise 4


Grant schema access.




Exercise 5


Grant SELECT
on Payroll only.




Exercise 6


Revoke SELECT.




============================================================
*/
GO






/*
============================================================
STEP 21 : CLEANUP

Run only if cleanup
is required.

============================================================
*/


USE master;
GO


ALTER DATABASE PermissionLab
SET SINGLE_USER
WITH ROLLBACK IMMEDIATE;
GO


DROP DATABASE PermissionLab;
GO


DROP LOGIN EmployeeLogin;
GO




/*
EXPECTED RESULT


PermissionLab


Removed




EmployeeLogin


Removed




UI Verification


SSMS


Databases


Refresh



PermissionLab


will disappear.




SSMS


Security


Logins


Refresh



EmployeeLogin


will disappear.


============================================================
*/
GO