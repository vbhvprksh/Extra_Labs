/*
===============================================================================
MODULE 7 : RESTORING SQL SERVER DATABASES
===============================================================================

Topics Covered

1. Understanding Restore Process
2. Restoring Databases
3. Point in Time Recovery
4. Advanced Restore Scenarios
5. Recovery States
6. Backup Verification
7. Restore Sequence


Prerequisites


Create Folder


C:\SQLBackups\


SQL Server Service Account

must have Read and Write permissions


Execute entire script as SysAdmin


===============================================================================
*/


USE master;
GO


/*
===============================================================================
STEP 1 : CREATE LAB DATABASE
===============================================================================


Purpose


This database will be used to demonstrate


Full Backup


Transaction Log Backup


Restore Database


Point In Time Recovery




Equivalent SSMS UI


Databases


Right Click


New Database


Database Name


RestoreLabDB


Click OK



===============================================================================
*/


CREATE DATABASE RestoreLabDB;
GO





/******************************************************************************

VERIFY DATABASE


Expected Result


RestoreLabDB




UI Verification


Databases


Refresh


RestoreLabDB




******************************************************************************/

SELECT

name,

recovery_model_desc

FROM sys.databases

WHERE name='RestoreLabDB';

GO






/*
===============================================================================
STEP 2 : CONFIGURE FULL RECOVERY MODEL
===============================================================================


New databases are created in


SIMPLE Recovery Model


by default.



Transaction Log Backups


require


FULL Recovery Model




Equivalent UI


RestoreLabDB


Properties


Options


Recovery Model


FULL




===============================================================================
*/


ALTER DATABASE RestoreLabDB

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

WHERE name='RestoreLabDB';

GO






/*
===============================================================================
STEP 3 : CREATE SAMPLE TABLE
===============================================================================


Orders table


simulates order transactions.




Equivalent UI


RestoreLabDB


Tables


New Table




===============================================================================
*/


USE RestoreLabDB;
GO




CREATE TABLE Orders
(

OrderID INT,

OrderDate DATE

);

GO





INSERT INTO Orders

VALUES

(

1,

GETDATE()

);

GO






/******************************************************************************

VERIFY DATA



Expected Result


OrderID


1




******************************************************************************/

SELECT *

FROM Orders;

GO






/*
===============================================================================
STEP 4 : ESTABLISH LOG CHAIN
===============================================================================


Important


After switching to FULL


A Full Backup must be taken


before Transaction Log Backup


becomes possible.




This backup initializes


the Log Chain.




===============================================================================
*/


BACKUP DATABASE RestoreLabDB

TO DISK='C:\SQLBackups\RestoreLabDB.bak'

WITH

INIT,

CHECKSUM,

NAME='Initial Full Backup',

STATS=10;

GO






/******************************************************************************

VERIFY BACKUP



BackupType


1




******************************************************************************/

RESTORE HEADERONLY

FROM DISK='C:\SQLBackups\RestoreLabDB.bak';

GO






/*
===============================================================================
STEP 5 : GENERATE ADDITIONAL TRANSACTION
===============================================================================


Insert another order


after Full Backup


to simulate


new transaction activity.




===============================================================================
*/


INSERT INTO Orders

VALUES

(

2,

GETDATE()

);

GO






/******************************************************************************

VERIFY DATA



Expected Result


1


2




******************************************************************************/

SELECT *

FROM Orders;

GO






/*
===============================================================================
STEP 6 : TAKE TRANSACTION LOG BACKUP
===============================================================================


Transaction Log Backup


contains


Inserted Records


Updated Records


Deleted Records




Supports


Point In Time Recovery




Equivalent UI


RestoreLabDB


Tasks


Back Up


Backup Type


Transaction Log




===============================================================================
*/


BACKUP LOG RestoreLabDB

TO DISK='C:\SQLBackups\RestoreLabDB_Log.trn'

WITH

INIT,

CHECKSUM,

STATS=10;

GO






/******************************************************************************

VERIFY LOG BACKUP


BackupType


2



******************************************************************************/

RESTORE HEADERONLY

FROM DISK='C:\SQLBackups\RestoreLabDB_Log.trn';

GO






/*
===============================================================================
STEP 7 : VIEW CURRENT DATA
===============================================================================


Expected Result



OrderID


1


2




At this point


Database contains


both records.




Soon we will restore


the Full Backup


and Log Backup


to recover database.




===============================================================================
*/


SELECT *

FROM Orders;

GO
/*
===============================================================================
STEP 8 : RESTORE FULL DATABASE BACKUP
===============================================================================

What is NORECOVERY ?


NORECOVERY keeps database unavailable
after restore operation.


Purpose


Allows additional backups

such as


Differential Backup


Transaction Log Backup


to be restored.




Database State


RESTORING




Equivalent SSMS UI


Databases


Right Click


Restore Database


Device


Select Backup File


Restore Options


Leave Database Non Operational


(NORECOVERY)



===============================================================================
*/


USE master;
GO



RESTORE DATABASE RestoreLabDB

FROM DISK='C:\SQLBackups\RestoreLabDB.bak'

WITH

REPLACE,

NORECOVERY;

GO




/******************************************************************************
VERIFY DATABASE STATE


Expected Result


name
----------------
RestoreLabDB


state_desc
----------------
RESTORING




******************************************************************************/

SELECT

name,

state_desc

FROM sys.databases

WHERE name='RestoreLabDB';

GO





/*
===============================================================================
STEP 9 : RESTORE TRANSACTION LOG BACKUP
===============================================================================


Transaction Log Restore


Applies changes that occurred

after Full Backup.




WITH RECOVERY


Brings database online




Database State


ONLINE




Equivalent SSMS UI


Restore Database


Transaction Log


Restore With Recovery



===============================================================================
*/


RESTORE LOG RestoreLabDB

FROM DISK='C:\SQLBackups\RestoreLabDB_Log.trn'

WITH RECOVERY;

GO






/******************************************************************************
VERIFY DATABASE STATE


Expected Result


ONLINE



******************************************************************************/

SELECT

name,

state_desc

FROM sys.databases

WHERE name='RestoreLabDB';

GO






/*
===============================================================================
STEP 10 : VERIFY RESTORED DATA
===============================================================================


Expected Result


OrderID      OrderDate
-------      ----------

1            2026-06-23

2            2026-06-23



This confirms


Full Backup restored


Log Backup restored


Database recovered successfully



===============================================================================
*/


USE RestoreLabDB;
GO


SELECT *

FROM Orders;

GO






/*
===============================================================================
STEP 11 : VERIFY BACKUP FILE
===============================================================================


RESTORE VERIFYONLY


Checks


Backup readability


Backup completeness


Backup header consistency




It does NOT restore data.




Equivalent UI


No GUI available


Execute TSQL




===============================================================================
*/


RESTORE VERIFYONLY

FROM DISK='C:\SQLBackups\RestoreLabDB.bak';

GO






/******************************************************************************
EXPECTED RESULT



The backup set on file 1
is valid.



******************************************************************************/




/*
===============================================================================
STEP 12 : VIEW FILES INSIDE BACKUP
===============================================================================


RESTORE FILELISTONLY


Displays


Logical File Name


Physical File Name


Data File


Log File




Useful when restoring

database to another server.




===============================================================================
*/


RESTORE FILELISTONLY

FROM DISK='C:\SQLBackups\RestoreLabDB.bak';

GO





/******************************************************************************
EXPECTED RESULT



LogicalName
------------------

RestoreLabDB




Type
--------

D



LogicalName
------------------

RestoreLabDB_log




Type
--------

L




******************************************************************************/




/*
===============================================================================
STEP 13 : VIEW BACKUP HEADER INFORMATION
===============================================================================


RESTORE HEADERONLY


Displays metadata


Backup Type


Backup Start Date


Backup Size


Recovery Model




BackupType Values


1 = Full Backup


2 = Log Backup


5 = Differential Backup




===============================================================================
*/


RESTORE HEADERONLY

FROM DISK='C:\SQLBackups\RestoreLabDB.bak';

GO






/*
===============================================================================
STEP 14 : POINT IN TIME RECOVERY
===============================================================================


Point In Time Restore


Allows restoring database


to an exact timestamp.




Example


Restore database


to 10 minutes earlier.




Note


Timestamp should exist


inside transaction log.




Example Syntax



RESTORE LOG RestoreLabDB


FROM DISK='C:\SQLBackups\RestoreLabDB_Log.trn'


WITH


STOPAT='2026-06-23T15:30:00',


RECOVERY;




===============================================================================
*/

GO







/*
===============================================================================
STEP 15 : BEST PRACTICES
===============================================================================


Always verify backups


using VERIFYONLY



Use CHECKSUM option



Test restores periodically



Keep backups

on separate drives



Document restore sequence



Backup Tail Log

before disaster recovery




===============================================================================
*/

GO






/*
===============================================================================
STEP 16 : TROUBLESHOOTING
===============================================================================


Error


Exclusive access could not be obtained




Cause


Users connected to database




Fix



ALTER DATABASE RestoreLabDB


SET SINGLE_USER


WITH ROLLBACK IMMEDIATE;




--------------------------------------------------



Error


Cannot restore because database
is in use




Fix


Close all connections




--------------------------------------------------



Error


Backup log cannot be performed




Cause


Recovery Model is SIMPLE




Fix



ALTER DATABASE RestoreLabDB


SET RECOVERY FULL;




Take Full Backup




--------------------------------------------------



Error


RESTORE LOG cannot operate




Cause


Database not in RESTORING state




Fix


Restore Full Backup


WITH NORECOVERY




===============================================================================
*/

GO







/*
===============================================================================
STEP 17 : MINI LAB EXERCISES
===============================================================================


Exercise 1


Take Differential Backup




Exercise 2


Restore Differential Backup




Exercise 3


Perform Point In Time Recovery




Exercise 4


Execute


RESTORE HEADERONLY




Exercise 5


Execute


RESTORE FILELISTONLY




Exercise 6


Observe database states




ONLINE



RESTORING



RECOVERING




===============================================================================
*/

GO







/*
===============================================================================
STEP 18 : CLEANUP

Run only if cleanup is required


===============================================================================
*/


USE master;
GO


ALTER DATABASE RestoreLabDB

SET SINGLE_USER

WITH ROLLBACK IMMEDIATE;

GO


DROP DATABASE RestoreLabDB;

GO





/******************************************************************************
EXPECTED RESULT



RestoreLabDB


Removed




UI Verification


SSMS


Databases


Refresh



RestoreLabDB


disappears




Backup Files


remain on disk



C:\SQLBackups\RestoreLabDB.bak



C:\SQLBackups\RestoreLabDB_Log.trn




Delete manually if required.



******************************************************************************/

GO