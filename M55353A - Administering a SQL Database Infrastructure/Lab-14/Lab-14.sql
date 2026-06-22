/*
===============================================================================
MODULE 14 : TROUBLESHOOTING SQL SERVER

Topics Covered
1. Troubleshooting Methodology
2. Service Related Issues
3. Connectivity Issues

Lab : Troubleshooting Common Issues
===============================================================================
*/

USE master;
GO


-- STEP 1

CREATE LOGIN TestLogin
WITH PASSWORD='P@ssword123!';
GO


-- STEP 2

ALTER LOGIN TestLogin
DISABLE;
GO


-- VERIFY

SELECT name,

is_disabled

FROM sys.sql_logins

WHERE name='TestLogin';
GO


-- STEP 3

ALTER LOGIN TestLogin
ENABLE;
GO


-- STEP 4

SELECT *

FROM sys.dm_exec_connections;
GO


-- STEP 5

SELECT *

FROM sys.dm_exec_sessions;
GO


-- STEP 6

SELECT *

FROM sys.dm_os_ring_buffers;
GO



-- CLEANUP

DROP LOGIN TestLogin;
GO