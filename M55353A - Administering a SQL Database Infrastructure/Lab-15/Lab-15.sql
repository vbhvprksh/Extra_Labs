/*
===============================================================================
MODULE 15 : IMPORTING AND EXPORTING DATA

Topics Covered
1. Importing Table Data
2. Using BCP
3. BULK INSERT
4. Data Tier Applications

Lab : Importing and Exporting Data
===============================================================================
*/

CREATE DATABASE ImportExportDB;
GO


USE ImportExportDB;
GO



-- STEP 1

CREATE TABLE EmployeeData
(

EmployeeID INT,

EmployeeName VARCHAR(100),

Department VARCHAR(50)

);
GO



-- STEP 2

INSERT INTO EmployeeData
VALUES

(1,'John','IT'),

(2,'Mary','HR'),

(3,'David','Finance');
GO



-- STEP 3

SELECT *
FROM EmployeeData;
GO



-- STEP 4

EXEC xp_cmdshell
'bcp ImportExportDB.dbo.EmployeeData out C:\Data\EmployeeData.txt -c -T';
GO



-- STEP 5

TRUNCATE TABLE EmployeeData;
GO



-- STEP 6

BULK INSERT EmployeeData

FROM 'C:\Data\EmployeeData.txt'

WITH
(

FIELDTERMINATOR = ',',

ROWTERMINATOR = '\n',

FIRSTROW=1

);
GO



-- VERIFY

SELECT *
FROM EmployeeData;
GO



-- STEP 7

BACKUP DATABASE ImportExportDB

TO DISK='C:\SQLBackups\ImportExportDB.bak'

WITH INIT;
GO



-- CLEANUP

USE master;
GO

DROP DATABASE ImportExportDB;
GO
