/*
===============================================================================
MODULE 5 : BACKUP AND RESTORE STRATEGIES

PART 1 : PLAN A BACKUP STRATEGY

Exercise 1 : Plan a Backup Strategy


Topics Covered


1. Full Backup

2. Differential Backup

3. Transaction Log Backup

4. Backup Compression

5. Verify Backup Files

6. Verify Backup History

7. Restore Verification



Execute entire script as SysAdmin



Prerequisites


Create folder


D:\SQLBackups\



SQL Server Service Account

must have Write permissions


===============================================================================
*/

USE master;
GO


/*
===============================================================================
STEP 1 : CREATE DATABASE


Database Name


BackupLabDB



Equivalent UI


Databases


Right Click


New Database



BackupLabDB



===============================================================================
*/


CREATE DATABASE BackupLabDB;
GO



/*
VERIFY DATABASE


Expected Result


BackupLabDB




UI Verification


SSMS


Databases


Refresh



BackupLabDB


should appear.


===============================================================================
*/


SELECT

name,

create_date

FROM sys.databases

WHERE name='BackupLabDB';

GO



/*
===============================================================================
STEP 2 : CREATE SAMPLE TABLE


Business Requirement


Daily Full Backup


Hourly Log Backup



===============================================================================
*/


USE BackupLabDB;
GO


CREATE TABLE Orders
(

OrderID INT PRIMARY KEY,

OrderDate DATE,

Amount MONEY

);

GO


INSERT INTO Orders

VALUES

(1,GETDATE(),1000),

(2,GETDATE(),2000);

GO




/*
VERIFY TABLE DATA


Expected Result



1


1000




2


2000




UI Verification


SSMS


BackupLabDB


Tables


dbo.Orders



Right Click



Select Top 1000 Rows



===============================================================================
*/


SELECT *

FROM Orders;

GO



/*
===============================================================================
STEP 3 : PERFORM FULL BACKUP


Full Backup captures


Entire Database




Equivalent UI



BackupLabDB



Right CLick>>Tasks



Back Up




Backup Type



Full




Destination



Disk



File Name



BackupLabDB_Full.bak



===============================================================================
*/


BACKUP DATABASE BackupLabDB


TO DISK='D:\Certifications\001___Koenig_Extras\Vaibhav_labs\Extra_Labs\M55353A - Administering a SQL Database Infrastructure\Lab-5\BackupLabDB_Full.bak'


WITH INIT;


GO




/*
===============================================================================
VERIFY FULL BACKUP


Catalog Views


msdb.dbo.backupset




Expected Result



database_name


BackupLabDB




type


D




D means


Database Backup




UI Verification



Windows Explorer




D:\SQLBackups




BackupLabDB_Full.bak




should appear




===============================================================================
*/


SELECT

database_name,

backup_start_date,

backup_finish_date,

type

FROM msdb.dbo.backupset

WHERE database_name='BackupLabDB';

GO




/*
===============================================================================
STEP 4 : VERIFY BACKUP FILE


RESTORE HEADERONLY


Displays metadata stored
inside backup file.



===============================================================================
*/


RESTORE HEADERONLY


FROM DISK='D:\Certifications\001___Koenig_Extras\Vaibhav_labs\Extra_Labs\M55353A - Administering a SQL Database Infrastructure\Lab-5\BackupLabDB_Full.bak';


GO




/*
EXPECTED RESULT



DatabaseName


BackupLabDB




BackupType


1




Compressed


0




===============================================================================
*/



/*
===============================================================================
STEP 5 : VERIFY BACKUP INTEGRITY


RESTORE VERIFYONLY



Checks backup readability.


Does NOT restore database.



===============================================================================
*/


RESTORE VERIFYONLY


FROM DISK='D:\SQLBackups\BackupLabDB_Full.bak';


GO




/*
EXPECTED RESULT



The backup set on file 1 is valid.



===============================================================================
*/


/*
===============================================================================
STEP 6 : DIFFERENTIAL BACKUP



Insert additional rows



===============================================================================
*/

Select * from Orders
INSERT INTO Orders


VALUES


(3,GETDATE(),5000);

GO




BACKUP DATABASE BackupLabDB


TO DISK='D:\Certifications\001___Koenig_Extras\Vaibhav_labs\Extra_Labs\M55353A - Administering a SQL Database Infrastructure\Lab-5\BackupLabDB_Diff.bak'


WITH DIFFERENTIAL;


GO




/*
===============================================================================
VERIFY DIFFERENTIAL BACKUP


Expected Result



type


I




I means


Differential Backup



===============================================================================
*/


SELECT

database_name,

backup_start_date,

type

FROM msdb.dbo.backupset

WHERE database_name='BackupLabDB';

GO
/*
===============================================================================
MODULE 5 : BACKUP AND RESTORE STRATEGIES

PART 2 : CONFIGURE DATABASE RECOVERY MODELS

Exercise 2 : Configure Database Recovery Models


Topics Covered


1. Viewing Recovery Models

2. SIMPLE Recovery Model

3. FULL Recovery Model

4. BULK_LOGGED Recovery Model

5. Verifying Recovery Models

6. Recovery Model Comparison

7. Best Practices

8. Troubleshooting

9. Mini Lab Exercises


Execute entire script as SysAdmin

===============================================================================
*/

USE master;
GO



/*
===============================================================================
STEP 1 : VERIFY CURRENT RECOVERY MODEL


Recovery Model determines


How transactions are logged


Whether Transaction Log Backups
can be performed


How much data can be recovered




Recovery Models


SIMPLE


FULL


BULK_LOGGED




Catalog View


sys.databases




Expected Result


BackupLabDB


FULL



New databases inherit
Recovery Model from model database.




UI Verification


SSMS


Databases


BackupLabDB


Right Click


Properties


Options


Recovery Model




===============================================================================
*/


SELECT

name,

recovery_model_desc

FROM sys.databases

WHERE name='BackupLabDB';

GO




/*
===============================================================================
STEP 2 : CONFIGURE SIMPLE RECOVERY MODEL


SIMPLE Recovery Model


Automatically truncates
inactive transaction log records.




Supports


Full Backup


Differential Backup




Does NOT Support


Transaction Log Backup




Recommended For


Development Databases


Test Databases


Reporting Databases




Equivalent UI


BackupLabDB


Properties


Options


Recovery Model


Simple



===============================================================================
*/


ALTER DATABASE BackupLabDB

SET RECOVERY SIMPLE;

GO




/*
===============================================================================
VERIFY SIMPLE RECOVERY MODEL


Catalog View


sys.databases




Expected Result



name


BackupLabDB




recovery_model_desc


SIMPLE




UI Verification


BackupLabDB


Properties


Options


Recovery Model


Simple



===============================================================================
*/


SELECT

name,

recovery_model_desc

FROM sys.databases

WHERE name='BackupLabDB';

GO





/*
===============================================================================
STEP 3 : VERIFY LOG BACKUP FAILURE


Transaction Log Backups
cannot be taken under
SIMPLE Recovery Model.




Expected Result


Error Message


BACKUP LOG cannot be performed because
there is no current database backup.




===============================================================================
*/


BACKUP LOG BackupLabDB

TO DISK='D:\Certifications\001___Koenig_Extras\Vaibhav_labs\Extra_Labs\M55353A - Administering a SQL Database Infrastructure\Lab-5\TestLogBackup.trn';

GO





/*
===============================================================================
STEP 4 : CONFIGURE FULL RECOVERY MODEL


FULL Recovery Model


Preserves all transaction log records.




Supports


Full Backup


Differential Backup


Transaction Log Backup




Recommended For


Production Systems


Banking Applications


E-Commerce Systems




Equivalent UI


BackupLabDB


Properties


Options


Recovery Model


Full



===============================================================================
*/


ALTER DATABASE BackupLabDB

SET RECOVERY FULL;

GO





/*
===============================================================================
VERIFY FULL RECOVERY MODEL


Expected Result


BackupLabDB




recovery_model_desc


FULL




UI Verification


BackupLabDB


Properties


Options


Recovery Model


Full



===============================================================================
*/


SELECT

name,

recovery_model_desc

FROM sys.databases

WHERE name='BackupLabDB';

GO





/*
===============================================================================
STEP 5 : TAKE FULL BACKUP


After switching from SIMPLE
to FULL Recovery Model


A Full Backup must be taken
before Transaction Log Backups
can be performed.




===============================================================================
*/


BACKUP DATABASE BackupLabDB

TO DISK='D:\SQLBackups\BackupLabDB_AfterFull.bak'

WITH INIT;

GO





/*
===============================================================================
VERIFY FULL BACKUP


Catalog Views


msdb.dbo.backupset




Expected Result



database_name


BackupLabDB




type


D




D means


Database Backup




===============================================================================
*/


SELECT

database_name,

backup_start_date,

type

FROM msdb.dbo.backupset

WHERE database_name='BackupLabDB';

GO





/*
===============================================================================
STEP 6 : VERIFY LOG BACKUP


Under FULL Recovery Model


Transaction Log Backup
is supported.




===============================================================================
*/


BACKUP LOG BackupLabDB

TO DISK='D:\SQLBackups\BackupLabDB_Log.trn';

GO





/*
===============================================================================
VERIFY LOG BACKUP


Catalog Views


msdb.dbo.backupset




Expected Result



database_name


BackupLabDB




type


L




L means


Transaction Log Backup




UI Verification


Windows Explorer


D:\SQLBackups




BackupLabDB_Log.trn




should appear.




===============================================================================
*/


SELECT

database_name,

backup_start_date,

type

FROM msdb.dbo.backupset

WHERE database_name='BackupLabDB';

GO






/*
===============================================================================
STEP 7 : CONFIGURE BULK_LOGGED RECOVERY MODEL


BULK_LOGGED minimizes logging
for bulk operations.




Examples


Bulk Insert


BCP


SELECT INTO


Index Rebuild




Supports


Transaction Log Backup




Reduces


Transaction Log Growth




Equivalent UI


BackupLabDB


Properties


Options


Recovery Model


Bulk Logged




===============================================================================
*/


ALTER DATABASE BackupLabDB

SET RECOVERY BULK_LOGGED;

GO





/*
===============================================================================
VERIFY BULK_LOGGED RECOVERY MODEL


Expected Result


BackupLabDB




recovery_model_desc


BULK_LOGGED




UI Verification


BackupLabDB


Properties


Options


Recovery Model


Bulk Logged




===============================================================================
*/


SELECT

name,

recovery_model_desc

FROM sys.databases

WHERE name='BackupLabDB';

GO






/*
===============================================================================
STEP 8 : RECOVERY MODEL COMPARISON


Recovery Model        Log Backup      Point In Time Recovery


SIMPLE                No              No


FULL                  Yes             Yes


BULK_LOGGED           Yes             Limited




===============================================================================
*/
GO





/*
===============================================================================
STEP 9 : BEST PRACTICES


Use SIMPLE


For Development Systems




Use FULL


For Mission Critical Systems




Use BULK_LOGGED


During Bulk Imports




Take Full Backup


Immediately after switching
from SIMPLE to FULL.




Monitor


Transaction Log Growth




===============================================================================
*/
GO






/*
===============================================================================
STEP 10 : TROUBLESHOOTING


Common Error


BACKUP LOG cannot be performed.




Cause


Database is in SIMPLE
Recovery Model.




Fix



ALTER DATABASE BackupLabDB


SET RECOVERY FULL;




Take Full Backup.




Retry Transaction Log Backup.




Another Common Error


Transaction Log file
becomes very large.




Cause


No Transaction Log Backups




Fix


Schedule regular
Log Backups.




===============================================================================
*/
GO






/*
===============================================================================
STEP 11 : MINI LAB EXERCISES


Exercise 1


Switch database
to SIMPLE.




Exercise 2


Switch database
to BULK_LOGGED.




Exercise 3


Take Full Backup.




Exercise 4


Take Log Backup.




Exercise 5


Identify Recovery Models
for all databases.




===============================================================================
*/
GO






/*
===============================================================================
STEP 12 : CHALLENGE QUERY


Display Recovery Models
for all databases.




===============================================================================
*/


SELECT

name,

recovery_model_desc

FROM sys.databases;

GO