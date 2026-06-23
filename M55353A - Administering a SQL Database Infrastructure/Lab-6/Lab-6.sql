/*
===============================================================================
MODULE 6 : BACKING UP SQL SERVER DATABASES
===============================================================================

Topics Covered

1. Backing Up Databases
2. Differential Backups
3. Transaction Log Backups
4. Managing Backup Files
5. Partial Backups
6. Secondary Filegroups
7. Backup Verification
8. Advanced Backup Options


Execute entire script as SysAdmin


Prerequisites


Create folders manually


C:\SQLBackups\

C:\SQLData\



SQL Server Service Account should have

Read / Write permissions



===============================================================================
*/


USE master;
GO


/*
===============================================================================
STEP 1 : CREATE LAB DATABASE
===============================================================================


Purpose


This database will be used for demonstrating


Full Backup


Differential Backup


Transaction Log Backup


Partial Backup




Equivalent SSMS UI


Databases

Right Click

New Database


Database Name


BackupDemoDB


Click OK



===============================================================================
*/


CREATE DATABASE BackupDemoDB;
GO




/******************************************************************************

VERIFY DATABASE



Expected Result


BackupDemoDB


should appear




UI Verification


Databases


Refresh


BackupDemoDB



******************************************************************************/

SELECT name
FROM sys.databases
WHERE name='BackupDemoDB';
GO





/*
===============================================================================
STEP 2 : CREATE SECONDARY FILEGROUP
===============================================================================


What is Filegroup?


A filegroup is a logical container

that contains one or more data files.




Benefits


Partial Backup


Partitioning


Improved Performance


Archival Storage




Equivalent UI


BackupDemoDB


Properties


Filegroups


Add


FG_Sales



===============================================================================
*/


ALTER DATABASE BackupDemoDB
ADD FILEGROUP FG_Sales;
GO





/*
===============================================================================
STEP 3 : ADD SECONDARY DATA FILE
===============================================================================


File Extension


.ndf




Physical Location


C:\SQLData\SalesData.ndf




Equivalent UI


BackupDemoDB


Properties


Files


Add


File Name


SalesData




===============================================================================
*/


ALTER DATABASE BackupDemoDB

ADD FILE
(
NAME='SalesData',

FILENAME='C:\SQLData\SalesData.ndf',

SIZE=10MB,

FILEGROWTH=5MB

)

TO FILEGROUP FG_Sales;

GO





/******************************************************************************

VERIFY FILEGROUPS


Expected Result



PRIMARY


FG_Sales




******************************************************************************/

SELECT

name,

type_desc

FROM sys.filegroups;

GO





/*
===============================================================================
STEP 4 : CREATE SAMPLE TABLES
===============================================================================


Employees


Stored in PRIMARY



SalesOrders


Stored in FG_Sales




===============================================================================
*/


USE BackupDemoDB;
GO



CREATE TABLE Employees
(

EmployeeID INT IDENTITY(1,1),

EmployeeName VARCHAR(100)

);
GO





CREATE TABLE SalesOrders
(

OrderID INT,

OrderAmount MONEY

)

ON FG_Sales;

GO





INSERT INTO Employees(EmployeeName)

VALUES

('John'),

('Mary'),

('David');

GO




INSERT INTO SalesOrders

VALUES

(1001,2500),

(1002,1800),

(1003,3200);

GO






/******************************************************************************

VERIFY DATA



Expected Result


Employees


1 John

2 Mary

3 David




SalesOrders


1001 2500


1002 1800


1003 3200




******************************************************************************/

SELECT * FROM Employees;
GO


SELECT * FROM SalesOrders;
GO






/*
===============================================================================
STEP 5 : PERFORM FULL DATABASE BACKUP
===============================================================================


Full Backup contains


Data


Indexes


Stored Procedures


Metadata





Backup File


BackupDemoDB_Full.bak





Equivalent SSMS UI



BackupDemoDB


Tasks


Back Up


Backup Type


Full


Destination


Disk




===============================================================================
*/


BACKUP DATABASE BackupDemoDB

TO DISK='C:\SQLBackups\BackupDemoDB_Full.bak'

WITH

INIT,

CHECKSUM,

STATS=10,

NAME='Full Backup';

GO






/******************************************************************************

VERIFY BACKUP



RESTORE HEADERONLY


Displays backup metadata




Expected Result


Backup Name


Full Backup




BackupType


1




******************************************************************************/

RESTORE HEADERONLY

FROM DISK='C:\SQLBackups\BackupDemoDB_Full.bak';

GO

/*
===============================================================================
STEP 6 : PERFORM DIFFERENTIAL BACKUP
===============================================================================


What is Differential Backup ?


A Differential Backup stores only the data pages
that have changed since the last Full Backup.


Advantages


Smaller backup size


Faster backup operation


Faster restore compared to restoring
multiple transaction log backups




Equivalent SSMS UI


BackupDemoDB


Tasks


Back Up


Backup Type


Differential



===============================================================================
*/


INSERT INTO Employees(EmployeeName)

VALUES

('Robert');

GO



INSERT INTO SalesOrders

VALUES

(1004,4200);

GO




/******************************************************************************

VERIFY DATA CHANGES


Expected Result


Employees


1 John

2 Mary

3 David

4 Robert




SalesOrders


1001 2500

1002 1800

1003 3200

1004 4200



******************************************************************************/

SELECT *
FROM Employees;
GO


SELECT *
FROM SalesOrders;
GO




BACKUP DATABASE BackupDemoDB

TO DISK='C:\SQLBackups\BackupDemoDB_Diff.bak'

WITH

DIFFERENTIAL,

INIT,

CHECKSUM,

STATS=10,

NAME='Differential Backup';

GO





/******************************************************************************

VERIFY DIFFERENTIAL BACKUP


BackupType


5 = Differential Backup



******************************************************************************/

RESTORE HEADERONLY

FROM DISK='C:\SQLBackups\BackupDemoDB_Diff.bak';

GO





/*
===============================================================================
STEP 7 : CONFIGURE FULL RECOVERY MODEL
===============================================================================


FULL Recovery Model


Supports


Transaction Log Backup


Point In Time Recovery


Tail Log Backup




Production databases usually use


FULL Recovery




Equivalent SSMS UI


BackupDemoDB


Properties


Options


Recovery Model


FULL




===============================================================================
*/


ALTER DATABASE BackupDemoDB

SET RECOVERY FULL;

GO





/******************************************************************************

VERIFY RECOVERY MODEL



Expected Result


FULL



******************************************************************************/

SELECT

name,

recovery_model_desc

FROM sys.databases

WHERE name='BackupDemoDB';

GO






/*
===============================================================================
STEP 8 : ESTABLISH LOG CHAIN
===============================================================================


Important


After switching to FULL Recovery


A Full Backup must be taken


before Log Backups become possible.




Without this backup


SQL Server returns



BACKUP LOG cannot be performed

because there is no current database backup.




===============================================================================
*/


BACKUP DATABASE BackupDemoDB

TO DISK='C:\SQLBackups\BackupDemoDB_Full2.bak'

WITH

INIT,

CHECKSUM,

NAME='Full Backup After Recovery Change';

GO






/*
===============================================================================
STEP 9 : TRANSACTION LOG BACKUP
===============================================================================


Transaction Log Backup


Captures


Committed Transactions


Deleted Records


Inserted Rows


Updated Rows




Benefits


Point In Time Recovery


Smaller Backup Files


Reduced Data Loss





Equivalent SSMS UI


BackupDemoDB


Tasks


Back Up


Backup Type


Transaction Log




===============================================================================
*/


BACKUP LOG BackupDemoDB

TO DISK='C:\SQLBackups\BackupDemoDB_Log.trn'

WITH

INIT,

CHECKSUM,

STATS=10;

GO





/******************************************************************************

VERIFY LOG BACKUP



BackupType


2 = Transaction Log Backup




******************************************************************************/

RESTORE HEADERONLY

FROM DISK='C:\SQLBackups\BackupDemoDB_Log.trn';

GO






/*
===============================================================================
STEP 10 : PARTIAL BACKUP
===============================================================================


Partial Backup


Backs up


PRIMARY Filegroup


Read Write Filegroups




Useful for


VLDB


Archival Databases


Large Enterprise Systems




Current Filegroups


PRIMARY


FG_Sales




Equivalent SSMS UI


No direct GUI available


Execute TSQL




===============================================================================
*/


BACKUP DATABASE BackupDemoDB

READ_WRITE_FILEGROUPS

TO DISK='C:\SQLBackups\BackupDemoDB_Partial.bak'

WITH

INIT,

CHECKSUM,

NAME='Partial Backup';

GO






/******************************************************************************

VERIFY PARTIAL BACKUP



Expected Result


Backup Name


Partial Backup



BackupType


1




******************************************************************************/

RESTORE HEADERONLY

FROM DISK='C:\SQLBackups\BackupDemoDB_Partial.bak';

GO






/*
===============================================================================
STEP 11 : VERIFY DATABASE FILES
===============================================================================


Catalog Views


sys.database_files



Expected Result



BackupDemoDB.mdf



SalesData.ndf



BackupDemoDB_log.ldf




===============================================================================
*/


SELECT

name,

physical_name,

type_desc

FROM sys.database_files;

GO






/*
===============================================================================
STEP 12 : VERIFY FILEGROUPS
===============================================================================
*/


SELECT

name,

type_desc

FROM sys.filegroups;

GO







/*
===============================================================================
STEP 13 : BEST PRACTICES
===============================================================================


Always keep backups on separate drives


Test restores regularly


Use CHECKSUM


Enable STATS option


Keep multiple generations


Backup Certificates if TDE enabled


Take Log Backups every 15 minutes


Periodically verify backup files



===============================================================================
*/

GO






/*
===============================================================================
STEP 14 : TROUBLESHOOTING
===============================================================================


Error


Cannot open backup device




Cause


Folder missing




Fix


Create



C:\SQLBackups\





---------------------------------------------------


Error


Operating system error 5



Cause


SQL Service lacks permissions




Fix


Grant Full Control


to SQL Server Service Account





---------------------------------------------------


Error


BACKUP LOG cannot be performed




Cause


No Full Backup after switching
to FULL Recovery




Fix


Take another Full Backup





---------------------------------------------------


Error


Unable to create SalesData.ndf




Cause


Folder missing




Fix


Create



C:\SQLData\




===============================================================================
*/

GO







/*
===============================================================================
STEP 15 : MINI LAB EXERCISES
===============================================================================


Exercise 1


Create another filegroup


FG_HR




Exercise 2


Add HRData.ndf




Exercise 3


Create HR table


on FG_HR




Exercise 4


Take COPY_ONLY Backup




Exercise 5


Take another Differential Backup




Exercise 6


Verify Backup Headers




Exercise 7


Perform Restore VerifyOnly




RESTORE VERIFYONLY

FROM DISK='C:\SQLBackups\BackupDemoDB_Full.bak';




===============================================================================
*/

GO







/*
===============================================================================
STEP 16 : CLEANUP

Run only if cleanup is required

===============================================================================
*/


USE master;
GO


ALTER DATABASE BackupDemoDB

SET SINGLE_USER

WITH ROLLBACK IMMEDIATE;

GO


DROP DATABASE BackupDemoDB;

GO






/******************************************************************************

EXPECTED RESULT



BackupDemoDB


Removed




UI Verification


SSMS


Databases


Refresh




BackupDemoDB disappears




Note


Backup files remain on disk


Delete manually if needed




C:\SQLBackups\BackupDemoDB_Full.bak


C:\SQLBackups\BackupDemoDB_Diff.bak


C:\SQLBackups\BackupDemoDB_Log.trn


C:\SQLBackups\BackupDemoDB_Partial.bak




******************************************************************************/

GO

/*
===============================================================================
STEP 17 : BACKUP STRATEGY COMPARISON
===============================================================================


Backup Types Supported by SQL Server


+---------------------------------------------------------------+
| Backup Type     | BackupType | Point In Time | Size | Speed  |
+---------------------------------------------------------------+
| Full            | 1          | No            | High | Slow   |
| Differential    | 5          | No            | Med  | Fast   |
| Transaction Log | 2          | Yes           | Low  | Fast   |
| Partial         | 1          | Depends       | Med  | Medium |
+---------------------------------------------------------------+



Typical Production Schedule


Sunday

Full Backup



Monday - Saturday

Differential Backup



Every 15 Minutes

Transaction Log Backup




Example Strategy


12:00 AM

Full Backup



06:00 AM

Differential Backup



06:15 AM

Log Backup



06:30 AM

Log Backup



06:45 AM

Log Backup




Benefits


Reduced Backup Time


Reduced Storage Usage


Supports Point In Time Recovery


Improves Disaster Recovery Objectives



===============================================================================
*/
GO