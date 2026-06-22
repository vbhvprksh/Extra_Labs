/*
============================================================
🔐 MODULE 1 : SQL SERVER SECURITY
PART 1 : AUTHENTICATION, LOGINS, USERS AND PERMISSIONS

Topics Covered

1. Authenticating Connections to SQL Server
2. Viewing Existing Logins
3. Creating SQL Server Logins
4. Creating Database Users
5. Granting Permissions
6. Verifying Effective Permissions

Execute entire script as SysAdmin
============================================================
*/


/*
============================================================
STEP 1 : VERIFY SQL SERVER INFORMATION

Authentication Mode can be verified from

SSMS
→ Right Click SQL Server Instance
→ Properties
→ Security
============================================================
*/

SELECT SERVERPROPERTY('MachineName') AS MachineName,
       SERVERPROPERTY('ServerName') AS ServerName,
       SERVERPROPERTY('Edition') AS Edition,
       SERVERPROPERTY('ProductVersion') AS ProductVersion;
GO

/*
EXPECTED RESULT

MachineName    ServerName            Edition
-----------    -------------------   ----------------
DESKTOP01      DESKTOP01\SQL2022     Developer Edition

UI Verification

SSMS
→ Right Click SQL Server Instance
→ Properties
→ General
*/
GO


/*
============================================================
STEP 2 : VIEW EXISTING SERVER LOGINS

S = SQL Login
U = Windows Login
G = Windows Group
============================================================
*/

SELECT name,type_desc,is_disabled
FROM sys.server_principals
WHERE type IN ('S','U')
ORDER BY name;
GO


/*
EXPECTED RESULT

Examples

sa
NT SERVICE\MSSQLSERVER
BUILTIN\Administrators

UI Verification

SSMS
→ Security
   → Logins
*/
GO

/*
============================================================
STEP 3 : CREATE SQL SERVER LOGIN
============================================================
*/

CREATE LOGIN VaibhavLogin
WITH PASSWORD='StrongPassword@123';
GO


/*
VERIFY LOGIN CREATION
*/

SELECT name,type_desc,create_date
FROM sys.server_principals
WHERE name='VaibhavLogin';
GO
/*
EXPECTED RESULT name
-------------
VaibhavLogin
type_desc
-------------
SQL_LOGIN
UI Verification
SSMS
→ Security
   → Logins
      → VaibhavLogin
*/
GO

/*
============================================================
STEP 4 : CREATE DEMO DATABASE
============================================================
*/
CREATE DATABASE SecurityDemoDB;
GO

USE SecurityDemoDB;
GO

/*
VERIFY DATABASE CREATION
*/

SELECT name,create_date
FROM sys.databases
WHERE name='SecurityDemoDB';
GO

/*
EXPECTED RESULT
SecurityDemoDB
UI Verification
SSMS
→ Databases
   → SecurityDemoDB
*/
GO
/*
============================================================
STEP 5 : CREATE DATABASE USER
Login  : VaibhavLogin
User   : VaibhavUser
============================================================
*/
CREATE USER VaibhavUser
FOR LOGIN VaibhavLogin;
GO
/*
VERIFY DATABASE USER
*/
SELECT name,
       type_desc,
       authentication_type_desc
FROM sys.database_principals
WHERE name='VaibhavUser';
GO
/*
EXPECTED RESULT name
--------------
VaibhavUser
type_desc
--------------
SQL_USER
authentication_type_desc
------------------------
INSTANCE
UI Verification
SSMS
→ Databases
   → SecurityDemoDB
      → Security
         → Users
            → VaibhavUser
*/
GO
/*
============================================================
STEP 6 : CREATE SAMPLE TABLE
============================================================
*/
CREATE TABLE dbo.VaibhavEmployees
(
EmployeeID INT PRIMARY KEY,
EmployeeName VARCHAR(100),
Salary MONEY
);
GO
INSERT INTO dbo.VaibhavEmployees
VALUES
(1,'Vaibhav',75000),
(2,'Niharika',68000);
GO
SELECT *
FROM dbo.VaibhavEmployees;
GO
/*
EXPECTED RESULT
EmployeeID    EmployeeName    Salary
----------    ------------    -------
1             Vaibhav         75000
2             Niharika        68000
UI Verification
SSMS
→ SecurityDemoDB
   → Tables
      → dbo.VaibhavEmployees
Right Click
Select Top 1000 Rows
*/
GO
/*
============================================================
STEP 7 : GRANT OBJECT LEVEL PERMISSION

Grant SELECT permission
to VaibhavUser
============================================================
*/

GRANT SELECT
ON dbo.VaibhavEmployees
TO VaibhavUser;
GO
/*
VERIFY PERMISSIONS
*/

SELECT permission_name,
       state_desc
FROM sys.database_permissions
WHERE grantee_principal_id=
USER_ID('VaibhavUser');
GO


/*
EXPECTED RESULT
permission_name
---------------
SELECT
state_desc
---------------
GRANT
UI Verification
SSMS
→ SecurityDemoDB
   → Security
      → Users
         → VaibhavUser

Right Click

Properties

→ Securables
*/
GO
/*
============================================================
STEP 8 : VERIFY EFFECTIVE PERMISSIONS
============================================================
*/

SELECT *
FROM fn_my_permissions
('dbo.VaibhavEmployees','OBJECT');
GO
/*
EXPECTED RESULT
SELECT
VIEW DEFINITION
REFERENCES
UI Verification
SSMS
SecurityDemoDB
→ Security
→ Users
→ VaibhavUser
Properties
→ Securables
→ Permissions
*/
GO
/*
============================================================
🔐 MODULE 1 : SQL SERVER SECURITY
PART 2 : DATABASE ROLES, IMPERSONATION
AND APPLICATION LOGIN TROUBLESHOOTING

Topics Covered

1. Database Roles
2. db_owner Membership
3. EXECUTE AS LOGIN
4. Testing Access as Another User
5. Application Login Troubleshooting

Prerequisite

Part 1 should already be executed.
============================================================
*/
USE SecurityDemoDB;
GO
/*
============================================================
STEP 9 : VIEW EXISTING DATABASE ROLES
============================================================
*/

SELECT name,type_desc
FROM sys.database_principals
WHERE type='R'
ORDER BY name;
GO


/*
EXPECTED RESULT
Examples
db_owner
db_datareader
db_datawriter
db_ddladmin
UI Verification
SSMS
SecurityDemoDB
→ Security
→ Roles
→ Database Roles
*/
GO

/*
============================================================
STEP 10 : ADD USER TO DB_OWNER ROLE

db_owner provides full control
inside the database.

Recommended for training labs.
============================================================
*/

ALTER ROLE db_owner
ADD MEMBER VaibhavUser;
GO
/*
VERIFY ROLE MEMBERSHIP
*/

SELECT DP1.name AS DatabaseRole,
       DP2.name AS DatabaseUser
FROM sys.database_role_members DRM
INNER JOIN sys.database_principals DP1
ON DRM.role_principal_id=DP1.principal_id
INNER JOIN sys.database_principals DP2
ON DRM.member_principal_id=DP2.principal_id
WHERE DP2.name='VaibhavUser';
GO
/*
EXPECTED RESULT
DatabaseRole     DatabaseUser
-------------    -------------
db_owner         VaibhavUser
UI Verification
SSMS
SecurityDemoDB
→ Security
→ Roles
→ Database Roles
→ db_owner
Right Click
Properties
Members
VaibhavUser
should be visible.
*/
GO
/*
============================================================
STEP 11 : IMPERSONATE LOGIN

EXECUTE AS LOGIN simulates
a separate login session.
No new connection
is created.
The current session
acts as VaibhavLogin.
============================================================
*/


EXECUTE AS LOGIN='VaibhavLogin';

SELECT SUSER_NAME() AS CurrentLogin;
SELECT USER_NAME() AS CurrentUser;
SELECT DB_NAME() AS CurrentDatabase;
REVERT;
GO
/*
EXPECTED RESULT

CurrentLogin
------------
VaibhavLogin
CurrentUser
------------
VaibhavUser
CurrentDatabase
----------------
SecurityDemoDB
UI Verification
Open another SSMS window
Authentication Type
SQL Server Authentication
Login
VaibhavLogin
Password
StrongPassword@123
Execute
SELECT SUSER_NAME();
SELECT USER_NAME();
SELECT DB_NAME();
*/
GO
/*
============================================================
STEP 12 : VERIFY READ ACCESS

VaibhavLogin should be able
to read data from table.
============================================================
*/
EXECUTE AS LOGIN='VaibhavLogin';
SELECT *
FROM dbo.VaibhavEmployees;
REVERT;
GO
/*
EXPECTED RESULT
EmployeeID    EmployeeName    Salary
----------    ------------    -------
1             Vaibhav         75000
2             Niharika        68000


This proves that Login
VaibhavLogin and User VaibhavUser


are correctly mapped.
*/
GO






/*
============================================================
STEP 13 : CREATE OBJECTS AS LOGIN

Since VaibhavUser belongs
to db_owner role,


object creation should succeed.
============================================================
*/


EXECUTE AS LOGIN='VaibhavLogin';



CREATE TABLE dbo.VaibhavTestTable
(
ID INT
);


INSERT INTO dbo.VaibhavTestTable
VALUES
(100);


SELECT *
FROM dbo.VaibhavTestTable;



DROP TABLE dbo.VaibhavTestTable;



REVERT;
GO






/*
EXPECTED RESULT


ID
---
100



No errors should occur.



UI Verification


SSMS

SecurityDemoDB

→ Tables


Refresh


VaibhavTestTable


will briefly appear
and disappear after DROP.
*/
GO






/*
============================================================
STEP 14 : VERIFY EFFECTIVE ROLES
============================================================
*/


EXECUTE AS LOGIN='VaibhavLogin';


SELECT USER_NAME() AS CurrentUser;


SELECT IS_MEMBER('db_owner')
AS IsDBOwner;


REVERT;
GO





/*
EXPECTED RESULT


CurrentUser
------------
VaibhavUser



IsDBOwner
-----------
1



1 indicates membership.


0 indicates not a member.


NULL indicates role
does not exist.
*/
GO






/*
============================================================
STEP 15 : APPLICATION LOGIN TROUBLESHOOTING


Applications usually connect using


.NET


Java


Python


Power BI


SSMS


SQLCMD




Common Error


Cannot open database
requested by login.



Cause


Login exists


Database User missing



Fix


CREATE USER VaibhavUser
FOR LOGIN VaibhavLogin;



Another Common Error


Login failed for user.



Possible Causes


Wrong Password


Disabled Login


Database Offline
============================================================
*/


SELECT name,
is_disabled
FROM sys.server_principals
WHERE name='VaibhavLogin';
GO




/*
EXPECTED RESULT


name
---------------
VaibhavLogin



is_disabled
------------
0



0 means enabled


1 means disabled



UI Verification


SSMS


Security


→ Logins


→ VaibhavLogin


Right Click


Properties


Status


Login Enabled


should be selected.
*/
GO






/*
============================================================
STEP 16 : DISABLE LOGIN
(OPTIONAL DEMO)
============================================================
*/


--ALTER LOGIN VaibhavLogin DISABLE;
--GO


--ALTER LOGIN VaibhavLogin ENABLE;
--GO




/*
UI Verification


SSMS


Security


→ Logins


→ VaibhavLogin


Properties


Status


Enabled


Disabled
*/
GO

/*
============================================================
🔐 MODULE 1 : SQL SERVER SECURITY
PART 3 : PARTIALLY CONTAINED DATABASES
AND AUTHORIZATION ACROSS SERVERS

Topics Covered

1. Partially Contained Databases
2. Contained Database Users
3. Authorization Across Servers
4. Linked Servers
5. Least Privilege Principle

Prerequisite

Part 1 and Part 2 should already
be executed successfully.
============================================================
*/


USE master;
GO


/*
============================================================
STEP 17 : VERIFY DATABASE CONTAINMENT

Containment Status

0 = NONE

1 = PARTIAL
============================================================
*/

SELECT name,containment_desc
FROM sys.databases
WHERE name='SecurityDemoDB';
GO


/*
EXPECTED RESULT


name               containment_desc
----------------   ----------------
SecurityDemoDB     NONE


UI Verification


SSMS

Databases

→ SecurityDemoDB

Right Click

Properties

Options

Containment Type


None
*/
GO





/*
============================================================
STEP 18 : ENABLE PARTIAL CONTAINMENT

Contained Users store authentication
inside the database.

Benefits


Easy Migration


Reduced dependency on master


Database Portability
============================================================
*/

ALTER DATABASE SecurityDemoDB
SET CONTAINMENT=PARTIAL;
GO




/*
VERIFY CONTAINMENT
*/

SELECT name,containment_desc
FROM sys.databases
WHERE name='SecurityDemoDB';
GO




/*
EXPECTED RESULT


SecurityDemoDB


PARTIAL



UI Verification


SSMS

Databases

→ SecurityDemoDB

Properties

Options

Containment Type


Partial
*/
GO





USE SecurityDemoDB;
GO



/*
============================================================
STEP 19 : CREATE CONTAINED USER

Contained Users do not require
a SQL Login.


Authentication information is
stored inside the database.
============================================================
*/


CREATE USER VaibhavContainedUser
WITH PASSWORD='Contained@123';
GO




/*
VERIFY CONTAINED USER
*/

SELECT name,
authentication_type_desc
FROM sys.database_principals
WHERE name='VaibhavContainedUser';
GO




/*
EXPECTED RESULT


name
----------------------
VaibhavContainedUser



authentication_type_desc
------------------------
DATABASE




UI Verification


SSMS


SecurityDemoDB

Security

Users


VaibhavContainedUser


Right Click


Properties
*/
GO





/*
============================================================
STEP 20 : GRANT ROLE MEMBERSHIP

Contained User will receive
db_datareader permissions.
============================================================
*/


ALTER ROLE db_datareader
ADD MEMBER VaibhavContainedUser;
GO




/*
VERIFY ROLE MEMBERSHIP
*/

SELECT DP1.name AS DatabaseRole,
DP2.name AS DatabaseUser
FROM sys.database_role_members DRM

INNER JOIN sys.database_principals DP1
ON DRM.role_principal_id=
DP1.principal_id

INNER JOIN sys.database_principals DP2
ON DRM.member_principal_id=
DP2.principal_id

WHERE DP2.name='VaibhavContainedUser';
GO




/*
EXPECTED RESULT


DatabaseRole
-------------
db_datareader



DatabaseUser
----------------------
VaibhavContainedUser




UI Verification


SSMS


SecurityDemoDB

Security

Roles

Database Roles

db_datareader


Properties


Members
*/
GO





/*
============================================================
STEP 21 : IMPERSONATE CONTAINED USER
============================================================
*/


EXECUTE AS USER='VaibhavContainedUser';


SELECT USER_NAME()
AS CurrentUser;



SELECT DB_NAME()
AS CurrentDatabase;



REVERT;
GO




/*
EXPECTED RESULT


CurrentUser
----------------------
VaibhavContainedUser



CurrentDatabase
------------------
SecurityDemoDB
*/
GO






/*
============================================================
STEP 22 : AUTHORIZATION ACROSS SERVERS

Linked Servers allow access
to objects stored on another
SQL Server instance.

This section is demonstration only.

No Linked Server will be created.
============================================================
*/


SELECT *
FROM sys.servers;
GO




/*
EXPECTED RESULT


Server entries will appear.


Local SQL Server instance
will always be visible.



UI Verification


SSMS


Server Objects


Linked Servers
*/
GO





/*
============================================================
STEP 23 : CREATE LINKED SERVER

Demonstration Only


Do not execute
unless another SQL Server
instance is available.
============================================================
*/


/*

EXEC sp_addlinkedserver

@server='SQLSERVER02';


GO

*/


/*
UI Verification


SSMS


Server Objects


Linked Servers


Refresh


SQLSERVER02


will appear.
*/
GO






/*
============================================================
STEP 24 : QUERY DATA
FROM LINKED SERVER

Demonstration Only
============================================================
*/


/*

SELECT *
FROM SQLSERVER02
.AdventureWorks2022
.dbo.Employee;


*/


GO





/*
============================================================
STEP 25 : LEAST PRIVILEGE PRINCIPLE


Users should receive only
permissions required to
perform their work.


Recommended Roles


db_datareader


db_datawriter



Avoid


db_owner


sysadmin


unless absolutely necessary.
============================================================
*/


SELECT name,type_desc
FROM sys.database_principals
WHERE type='R';
GO




/*
EXPECTED RESULT


Examples


db_datareader


db_datawriter


db_owner


db_ddladmin




UI Verification


SSMS


SecurityDemoDB


Security


Roles


Database Roles
*/
GO






/*
============================================================
STEP 26 : VERIFY CURRENT USER
============================================================
*/


SELECT USER_NAME()
AS CurrentUser;



SELECT ORIGINAL_LOGIN()
AS OriginalLogin;



SELECT SUSER_NAME()
AS ServerLogin;
GO




/*
EXPECTED RESULT


CurrentUser
-----------
dbo



OriginalLogin
---------------
sa



ServerLogin
------------
sa



Values may vary
depending upon
your environment.
*/
GO

/*
============================================================
🔐 MODULE 1 : SQL SERVER SECURITY
PART 4 : ORPHAN USERS, RESTORED DATABASES
AND CLEANUP

Topics Covered

1. Orphan Users
2. SID Mismatch
3. Fixing Orphan Users
4. Current Session Diagnostics
5. Cleanup

Prerequisite

Part 1, Part 2 and Part 3 should
already be executed successfully.
============================================================
*/


USE SecurityDemoDB;
GO


/*
============================================================
STEP 27 : IDENTIFY ORPHAN USERS

Orphan Users occur when

Database User Exists

but

Matching SQL Login does not exist.


Common Scenario


Database restored from
another SQL Server.
============================================================
*/


SELECT DP.name,
       DP.authentication_type_desc
FROM sys.database_principals DP
LEFT JOIN sys.server_principals SP
ON DP.sid=SP.sid
WHERE SP.sid IS NULL
AND DP.authentication_type_desc='INSTANCE';
GO


/*
EXPECTED RESULT


No rows should appear.



If rows appear


those users are orphan users.




UI Verification


No direct SSMS option exists.


Microsoft recommends
using this query.
*/
GO





/*
============================================================
STEP 28 : CREATE SAMPLE ORPHAN USER

Demo Only


Do not execute on Production.
============================================================
*/


CREATE LOGIN TempLogin
WITH PASSWORD='Password@123';
GO


CREATE USER TempUser
FOR LOGIN TempLogin;
GO


DROP LOGIN TempLogin;
GO




/*
VERIFY ORPHAN USER
*/


SELECT DP.name,
DP.authentication_type_desc
FROM sys.database_principals DP

LEFT JOIN sys.server_principals SP
ON DP.sid=SP.sid

WHERE SP.sid IS NULL

AND DP.authentication_type_desc='INSTANCE';
GO




/*
EXPECTED RESULT


name
----------
TempUser




authentication_type_desc
------------------------
INSTANCE




TempUser is now orphaned.
*/
GO





/*
============================================================
STEP 29 : FIX ORPHAN USER

Method 1


Create Login Again


Method 2


Map User to Existing Login


Recommended Method


ALTER USER
============================================================
*/


ALTER USER TempUser
WITH LOGIN=VaibhavLogin;
GO




/*
VERIFY USER MAPPING
*/


SELECT DP.name,
SP.name
FROM sys.database_principals DP

INNER JOIN sys.server_principals SP

ON DP.sid=SP.sid

WHERE DP.name='TempUser';
GO




/*
EXPECTED RESULT


Database User     SQL Login
-------------     -------------
TempUser          VaibhavLogin




UI Verification


SSMS


SecurityDemoDB


Security


Users


TempUser


Properties
*/
GO






/*
============================================================
STEP 30 : VERIFY CURRENT SESSION
============================================================
*/


SELECT SUSER_NAME()
AS ServerLogin;



SELECT USER_NAME()
AS DatabaseUser;



SELECT ORIGINAL_LOGIN()
AS OriginalLogin;



SELECT DB_NAME()
AS CurrentDatabase;
GO





/*
EXPECTED RESULT


ServerLogin
------------
sa



DatabaseUser
-------------
dbo



OriginalLogin
--------------
sa



CurrentDatabase
----------------
SecurityDemoDB




Values may vary
depending upon
your environment.
*/
GO






/*
============================================================
STEP 31 : VERIFY LOGIN STATUS
============================================================
*/


SELECT name,
is_disabled
FROM sys.server_principals
WHERE name='VaibhavLogin';
GO




/*
EXPECTED RESULT


name
---------------
VaibhavLogin



is_disabled
------------
0




0 = Enabled


1 = Disabled




UI Verification


SSMS


Security


Logins


VaibhavLogin


Properties


Status


Login Enabled
*/
GO






/*
============================================================
STEP 32 : VERIFY DATABASE USERS
============================================================
*/


SELECT name,
authentication_type_desc
FROM sys.database_principals
WHERE principal_id>4
ORDER BY name;
GO




/*
EXPECTED RESULT


Examples


VaibhavUser


INSTANCE



VaibhavContainedUser


DATABASE



TempUser


INSTANCE




UI Verification


SSMS


SecurityDemoDB


Security


Users
*/
GO






/*
============================================================
STEP 33 : MINI LAB EXERCISES


Exercise 1


Disable VaibhavLogin


Enable it again



Exercise 2


Create another Login


Create another User



Exercise 3


Grant INSERT Permission



Exercise 4


Create another contained user



Exercise 5


Create a Linked Server


(if another SQL Server
instance is available)
============================================================
*/
GO






/*
============================================================
STEP 34 : CLEANUP

Run only if cleanup
is required.
============================================================
*/


USE master;
GO



ALTER DATABASE SecurityDemoDB
SET SINGLE_USER
WITH ROLLBACK IMMEDIATE;
GO



DROP DATABASE SecurityDemoDB;
GO



DROP LOGIN VaibhavLogin;
GO





/*
Drop TempLogin only if it exists
*/


IF EXISTS
(
SELECT *
FROM sys.server_principals
WHERE name='TempLogin'
)

DROP LOGIN TempLogin;
GO





/*
EXPECTED RESULT


SecurityDemoDB


Removed



VaibhavLogin


Removed




UI Verification


SSMS


Databases


Refresh


SecurityDemoDB


will disappear




SSMS


Security


Logins


Refresh


VaibhavLogin


will disappear.
*/
GO