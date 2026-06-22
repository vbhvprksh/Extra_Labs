/*
============================================================
🔐 MODULE 2 : ASSIGNING SERVER AND DATABASE ROLES

PART 1 : SERVER ROLES, FIXED DATABASE ROLES
AND USER DEFINED ROLES

Topics Covered

1. Working with Server Roles
2. Working with Fixed Database Roles
3. Assigning User Defined Roles
4. EXECUTE AS LOGIN
5. Effective Permissions
6. Role Membership Verification

Execute entire script as SysAdmin

============================================================
*/

USE master;
GO

/*
============================================================
STEP 1 : CREATE LOGIN

Login is a Server Level Principal.

Stored in

master.sys.server_principals

============================================================
*/

CREATE LOGIN LabUser1 WITH PASSWORD='P@ssw0rd123!';
GO

/*
VERIFY LOGIN
*/

SELECT name,type_desc FROM sys.server_principals WHERE name='LabUser1';
GO

/*
EXPECTED RESULT

name
--------------
LabUser1


type_desc
--------------
SQL_LOGIN


UI Verification

SSMS

Security

→ Logins

Refresh

LabUser1

should appear.
*/
GO


/*
============================================================
STEP 2 : ASSIGN SERVER ROLE

securityadmin allows

Managing Logins

Resetting Passwords

Granting Server Permissions

============================================================
*/

ALTER SERVER ROLE securityadmin ADD MEMBER LabUser1;
GO

/*
VERIFY ROLE MEMBERSHIP
*/

SELECT r.name AS ServerRole,m.name AS MemberName
FROM sys.server_role_members rm
INNER JOIN sys.server_principals r
ON rm.role_principal_id=r.principal_id
INNER JOIN sys.server_principals m
ON rm.member_principal_id=m.principal_id
WHERE m.name='LabUser1';
GO


/*
EXPECTED RESULT


ServerRole
--------------
securityadmin


MemberName
--------------
LabUser1



UI Verification


SSMS


Security

Server Roles

securityadmin


Properties

Members


LabUser1
*/
GO



/*
============================================================
STEP 3 : CREATE DATABASE
============================================================
*/

CREATE DATABASE RoleLabDB;
GO

USE RoleLabDB;
GO


/*
VERIFY DATABASE
*/

SELECT name,create_date FROM sys.databases WHERE name='RoleLabDB';
GO


/*
EXPECTED RESULT


RoleLabDB



UI Verification


SSMS


Databases


Refresh


RoleLabDB


should appear.
*/
GO



/*
============================================================
STEP 4 : CREATE DATABASE USER

Login : LabUser1

User : LabUser1

============================================================
*/

CREATE USER LabUser1 FOR LOGIN LabUser1;
GO


/*
VERIFY USER
*/

SELECT name,type_desc,authentication_type_desc
FROM sys.database_principals
WHERE name='LabUser1';
GO


/*
EXPECTED RESULT


name
--------------
LabUser1


type_desc
--------------
SQL_USER


authentication_type_desc
------------------------
INSTANCE



UI Verification


SSMS


RoleLabDB

Security

Users


Refresh


LabUser1
*/
GO




/*
============================================================
STEP 5 : ASSIGN FIXED DATABASE ROLE

db_datareader grants
SELECT access on all tables.

============================================================
*/

ALTER ROLE db_datareader ADD MEMBER LabUser1;
GO


/*
VERIFY MEMBERSHIP
*/

SELECT DP1.name AS DatabaseRole,DP2.name AS DatabaseUser
FROM sys.database_role_members DRM
INNER JOIN sys.database_principals DP1
ON DRM.role_principal_id=DP1.principal_id
INNER JOIN sys.database_principals DP2
ON DRM.member_principal_id=DP2.principal_id
WHERE DP2.name='LabUser1';
GO



/*
EXPECTED RESULT


DatabaseRole
----------------
db_datareader


DatabaseUser
----------------
LabUser1
*/
GO




/*
============================================================
STEP 6 : CREATE USER DEFINED ROLE

Custom Roles implement
Least Privilege Principle.

============================================================
*/

CREATE ROLE SalesRole;
GO


/*
VERIFY ROLE
*/

SELECT name,type_desc
FROM sys.database_principals
WHERE name='SalesRole';
GO


/*
EXPECTED RESULT


SalesRole


DATABASE_ROLE
*/
GO




/*
============================================================
STEP 7 : ASSIGN USER TO ROLE
============================================================
*/

ALTER ROLE SalesRole ADD MEMBER LabUser1;
GO


/*
VERIFY ROLE MEMBERSHIP
*/

SELECT USER_NAME(member_principal_id) MemberName,
USER_NAME(role_principal_id) RoleName
FROM sys.database_role_members;
GO


/*
EXPECTED RESULT


MemberName
------------
LabUser1


RoleName
------------
SalesRole
*/
GO





/*
============================================================
STEP 8 : CREATE SAMPLE TABLE
============================================================
*/

CREATE TABLE dbo.Customers(CustomerID INT PRIMARY KEY,CustomerName VARCHAR(100),City VARCHAR(50));
GO


INSERT INTO dbo.Customers VALUES
(1,'Raj','Delhi'),
(2,'Amit','Mumbai');
GO


SELECT * FROM dbo.Customers;
GO


/*
EXPECTED RESULT


1 Raj Delhi


2 Amit Mumbai



UI Verification


SSMS


RoleLabDB

Tables

dbo.Customers


Right Click

Select Top 1000 Rows
*/
GO





/*
============================================================
STEP 9 : VERIFY READ ACCESS
============================================================
*/

EXECUTE AS LOGIN='LabUser1';

SELECT * FROM dbo.Customers;

REVERT;
GO



/*
EXPECTED RESULT


Customer data visible.



This confirms
db_datareader access.

*/
GO





/*
============================================================
STEP 10 : VERIFY EFFECTIVE PERMISSIONS
============================================================
*/

EXECUTE AS LOGIN='LabUser1';

SELECT *
FROM fn_my_permissions(NULL,'DATABASE');

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
STEP 11 : IMPERSONATE LOGIN
============================================================
*/

EXECUTE AS LOGIN='LabUser1';

SELECT SUSER_NAME() AS CurrentLogin;

SELECT USER_NAME() AS CurrentUser;

SELECT DB_NAME() AS CurrentDatabase;

REVERT;
GO




/*
EXPECTED RESULT


CurrentLogin
-------------
LabUser1



CurrentUser
-------------
LabUser1



CurrentDatabase
----------------
RoleLabDB
*/
GO






/*
============================================================
STEP 12 : VERIFY SALESROLE MEMBERSHIP
============================================================
*/

EXECUTE AS USER='LabUser1';

SELECT USER_NAME() AS CurrentUser;

SELECT IS_MEMBER('SalesRole') AS IsSalesRoleMember;

REVERT;
GO



/*
EXPECTED RESULT


CurrentUser
-------------
LabUser1



IsSalesRoleMember
------------------
1



1 = Member


0 = Not Member
*/
GO






/*
============================================================
STEP 13 : REMOVE USER FROM ROLE
============================================================
*/

ALTER ROLE SalesRole DROP MEMBER LabUser1;
GO


/*
VERIFY MEMBERSHIP
*/

SELECT USER_NAME(member_principal_id) MemberName,
USER_NAME(role_principal_id) RoleName
FROM sys.database_role_members
WHERE USER_NAME(role_principal_id)='SalesRole';
GO



/*
EXPECTED RESULT


No rows returned.


LabUser1 removed.
*/
GO





/*
============================================================
STEP 14 : BEST PRACTICES
============================================================


Prefer Custom Roles


Grant permissions
to roles


Assign users
to roles



Avoid


db_owner


securityadmin


unless required.


Follow


Least Privilege Principle

============================================================
*/
GO






/*
============================================================
STEP 15 : TROUBLESHOOTING
============================================================


Common Error


Cannot execute
as login.



Cause


Login Disabled



Fix


ALTER LOGIN LabUser1 ENABLE;




Another Common Error


Permission denied.



Cause


Role missing



Fix


ALTER ROLE db_datareader
ADD MEMBER LabUser1;



============================================================
*/
GO






/*
============================================================
STEP 16 : MINI LAB EXERCISES
============================================================


Exercise 1


Assign db_datawriter




Exercise 2


Create HRRole




Exercise 3


Grant INSERT




Exercise 4


Create Login


LabUser2




Exercise 5


Verify Permissions




Exercise 6


Remove User
from SalesRole



============================================================
*/
GO






/*
============================================================
STEP 17 : CLEANUP

Run only if cleanup
is required.

============================================================
*/

USE master;
GO

ALTER DATABASE RoleLabDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO

DROP DATABASE RoleLabDB;
GO

DROP LOGIN LabUser1;
GO


/*
EXPECTED RESULT


RoleLabDB


Removed



LabUser1


Removed



UI Verification


SSMS


Databases


Refresh



RoleLabDB


disappears.




SSMS


Security


Logins


Refresh



LabUser1


disappears.


============================================================
*/
GO