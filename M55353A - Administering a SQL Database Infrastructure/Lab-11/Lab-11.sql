/*
===============================================================================
MODULE 11 : INTRODUCTION TO MANAGING SQL SERVER BY USING POWERSHELL

Topics Covered
1. Getting Started with Windows PowerShell
2. Configure SQL Server using PowerShell
3. Administer and Maintain SQL Server with PowerShell

Lab : Using PowerShell to Manage SQL Server
===============================================================================
*/

-- STEP 1 : ENABLE XPCMDSHELL

EXEC sp_configure 'show advanced options',1;
RECONFIGURE;

EXEC sp_configure 'xp_cmdshell',1;
RECONFIGURE;
GO


-- STEP 2 : VERIFY CONFIGURATION

SELECT name,
       value_in_use
FROM sys.configurations
WHERE name='xp_cmdshell';
GO


-- STEP 3 : EXECUTE POWERSHELL COMMAND

EXEC xp_cmdshell 'powershell.exe Get-Service MSSQLSERVER';
GO


-- STEP 4 : VIEW SQL SERVICES

EXEC xp_cmdshell 'powershell.exe Get-Service *SQL*';
GO


-- STEP 5 : DISABLE XPCMDSHELL

EXEC sp_configure 'xp_cmdshell',0;
RECONFIGURE;
GO


-- VERIFY

SELECT name,
       value_in_use
FROM sys.configurations
WHERE name='xp_cmdshell';
GO