/*
============================================================
🔐 MODULE 6 : BACKING UP AND RESTORING DATABASES

PART 1 : BACKING UP DATABASES

Exercise 1 : Backing Up Databases

Topics Covered

1. Creating a Sample Database
2. Creating Tables and Inserting Data
3. Performing a Full Backup
4. Verifying Backup Integrity
5. Viewing Backup Header Information
6. Viewing Backup File Contents
7. Checking Backup History
8. Best Practices
9. Troubleshooting
10. Mini Lab Exercises

Execute entire script as SysAdmin

============================================================
*/

USE master;
GO


/*
============================================================
STEP 1 : CREATE SAMPLE DATABASE

A Full Backup copies

• Data Pages

• System Metadata

• Objects

• Security Information


We need a database before taking backups.

============================================================
*/

CREATE DATABASE BackupLabDB;
GO


/*
VERIFY DATABASE
*/

SELECT name,
       create_date
FROM sys.databases
WHERE name='BackupLabDB';
GO


/*
EXPECTED RESULT


name
----------------
BackupLabDB



UI Verification


SSMS

Databases

Refresh

BackupLabDB

should appear.

*/
GO



/*
============================================================
STEP 2 : CREATE TABLE

AND INSERT SAMPLE DATA


This data will be included

inside the backup.


============================================================
*/

USE BackupLabDB;
GO


CREATE TABLE dbo.Employees
(
EmployeeID INT PRIMARY KEY,
EmployeeName VARCHAR(100),
Department VARCHAR(50)
);
GO


INSERT INTO dbo.Employees
VALUES

(1,'Raj','IT'),

(2,'Amit','HR'),

(3,'Neha','Finance');

GO



/*
VERIFY TABLE DATA
*/


SELECT *
FROM dbo.Employees;
GO



/*
EXPECTED RESULT


EmployeeID   EmployeeName   Department

---------------------------------------

1            Raj            IT

2            Amit           HR

3            Neha           Finance




UI Verification


SSMS


BackupLabDB

Tables


dbo.Employees


Right Click


Select Top 1000 Rows


*/
GO





/*
============================================================
STEP 3 : PERFORM FULL DATABASE BACKUP


A Full Backup stores


Entire Database


to a backup file.


Backup File


BackupLabDB_Full.bak



Change the path if needed.


============================================================
*/


BACKUP DATABASE BackupLabDB

TO DISK='D:\Certifications\001___Koenig_Extras\Vaibhav_labs\Extra_Labs\M55353A - Administering a SQL Database Infrastructure\Lab-6\BackupLabDB_Full.bak'

WITH

INIT,

NAME='BackupLabDB Full Backup',

STATS=10;

GO




/*
EXPECTED RESULT


10 Percent Processed


20 Percent Processed


...


100 Percent Processed



Backup completed successfully.




UI Verification


Windows Explorer


C:\SQLBackups



BackupLabDB_Full.bak


should exist.


*/
GO





/*
============================================================
STEP 4 : VERIFY BACKUP


RESTORE VERIFYONLY


checks


Backup readability


without restoring.


============================================================
*/


RESTORE VERIFYONLY

FROM DISK='D:\Certifications\001___Koenig_Extras\Vaibhav_labs\Extra_Labs\M55353A - Administering a SQL Database Infrastructure\Lab-6\BackupLabDB_Full.bak';

GO




/*
EXPECTED RESULT


The backup set on file 1
is valid.



No rows returned.



Verification successful.



*/
GO





/*
============================================================
STEP 5 : VIEW BACKUP HEADER INFORMATION


RESTORE HEADERONLY


shows


Backup Metadata


such as


Backup Type


Database Name


Backup Start Date



============================================================
*/


RESTORE HEADERONLY

FROM DISK='D:\Certifications\001___Koenig_Extras\Vaibhav_labs\Extra_Labs\M55353A - Administering a SQL Database Infrastructure\Lab-6\BackupLabDB_Full.bak';

GO




/*
EXPECTED RESULT


BackupName

----------------------------

BackupLabDB Full Backup



DatabaseName

----------------------------

BackupLabDB



BackupType

----------------------------

1



BackupStartDate

----------------------------

Current Date/Time




BackupType Meaning


1 = Database Backup


2 = Transaction Log Backup


5 = Differential Backup



*/
GO

/*
============================================================
🔐 MODULE 6 : BACKING UP AND RESTORING DATABASES

PART 2 : PERFORMING DATABASE, DIFFERENTIAL
AND TRANSACTION LOG BACKUPS

Exercise 2 : Performing Database,
Differential and Transaction Log Backups


Topics Covered

1. Recovery Models
2. Full Database Backup
3. Differential Backup
4. Transaction Log Backup
5. Backup Chain Verification
6. Restore Sequence
7. Backup History
8. Best Practices
9. Troubleshooting
10. Mini Lab Exercises


Prerequisite

Exercise 1 should be completed.

Database Used

BackupLabDB


Backup Folder

C:\SQLBackups\


Execute entire script as SysAdmin


============================================================
*/


USE master;
GO



/*
============================================================
STEP 1 : VERIFY DATABASE EXISTS

BackupLabDB should already exist.

============================================================
*/

SELECT name,
       state_desc
FROM sys.databases
WHERE name='BackupLabDB';
GO


/*
EXPECTED RESULT


name
--------------
BackupLabDB


state_desc
--------------
ONLINE



UI Verification


SSMS

Databases

Refresh

BackupLabDB

should appear.

*/
GO





/*
============================================================
STEP 2 : CHECK RECOVERY MODEL


Transaction Log Backups

require


FULL


or


BULK_LOGGED


Recovery Model


============================================================
*/


SELECT name,
       recovery_model_desc
FROM sys.databases
WHERE name='BackupLabDB';
GO



/*
EXPECTED RESULT


BackupLabDB


SIMPLE


or


FULL



If recovery model is SIMPLE

change it in next step.


*/
GO






/*
============================================================
STEP 3 : CHANGE RECOVERY MODEL


Set Recovery Model


to FULL


Required for

Transaction Log Backups.


============================================================
*/


ALTER DATABASE BackupLabDB

SET RECOVERY FULL;
GO




/*
VERIFY RECOVERY MODEL
*/


SELECT name,
       recovery_model_desc
FROM sys.databases
WHERE name='BackupLabDB';
GO




/*
EXPECTED RESULT



name
----------------
BackupLabDB



recovery_model_desc
---------------------
FULL




UI Verification


SSMS


BackupLabDB


Right Click


Properties


Options



Recovery Model


FULL




*/
GO







/*
============================================================
STEP 4 : TAKE FULL DATABASE BACKUP


This Full Backup

starts a new backup chain.



Backup File


BackupLabDB_Full2.bak


============================================================
*/


BACKUP DATABASE BackupLabDB

TO DISK='D:\Certifications\001___Koenig_Extras\Vaibhav_labs\Extra_Labs\M55353A - Administering a SQL Database Infrastructure\Lab-6\BackupLabDB_Full2.bak'

WITH

INIT,

NAME='BackupLabDB Full Backup 2',

STATS=10;
GO





/*
EXPECTED RESULT


10 Percent Processed


20 Percent Processed


...


100 Percent Processed



BACKUP DATABASE successfully processed.



*/
GO






/*
============================================================
STEP 5 : VERIFY FULL BACKUP


RESTORE VERIFYONLY


checks backup integrity.



============================================================
*/


RESTORE VERIFYONLY

FROM DISK='D:\Certifications\001___Koenig_Extras\Vaibhav_labs\Extra_Labs\M55353A - Administering a SQL Database Infrastructure\Lab-6\BackupLabDB_Full2.bak';
GO





/*
EXPECTED RESULT


The backup set on file 1

is valid.


*/
GO






/*
============================================================
STEP 6 : MODIFY DATA


Differential Backup

captures changes

since last Full Backup.


============================================================
*/


USE BackupLabDB;
GO

Select * from dbo.Employees;


INSERT INTO dbo.Employees
VALUES

(4,'Karan','Sales'),

(5,'Rohit','Marketing');
GO




/*
VERIFY DATA
*/


SELECT *
FROM dbo.Employees;
GO




/*
EXPECTED RESULT



EmployeeID


1


2


3


4


5




Five rows visible.



*/
GO







/*
============================================================
STEP 7 : TAKE DIFFERENTIAL BACKUP


Contains only changed extents


since Full Backup.



Backup File


BackupLabDB_Diff.bak



============================================================
*/


BACKUP DATABASE BackupLabDB

TO DISK='D:\Certifications\001___Koenig_Extras\Vaibhav_labs\Extra_Labs\M55353A - Administering a SQL Database Infrastructure\Lab-6\BackupLabDB_Diff.bak'

WITH

DIFFERENTIAL,

INIT,

NAME='BackupLabDB Differential Backup',

STATS=10;
GO






/*
EXPECTED RESULT


100 Percent Processed


Backup completed successfully.



*/
GO






/*
============================================================
STEP 8 : VERIFY DIFFERENTIAL BACKUP


RESTORE HEADERONLY


BackupType


5 = Differential Backup



============================================================
*/


RESTORE HEADERONLY

FROM DISK='D:\Certifications\001___Koenig_Extras\Vaibhav_labs\Extra_Labs\M55353A - Administering a SQL Database Infrastructure\Lab-6\BackupLabDB_Diff.bak';
GO




/*
EXPECTED RESULT


BackupType


--------------
5



DatabaseName


--------------
BackupLabDB




BackupName


--------------
BackupLabDB Differential Backup



*/
GO






/*
============================================================
STEP 9 : MODIFY DATA AGAIN


Transaction Log Backup

captures these transactions.



============================================================
*/


INSERT INTO dbo.Employees

VALUES

(6,'Priya','Finance'),

(7,'Ankit','IT');
GO





/*
VERIFY DATA
*/


SELECT *
FROM dbo.Employees;
GO





/*
EXPECTED RESULT


Seven Rows


should appear.



*/
GO






/*
============================================================
STEP 10 : TAKE TRANSACTION LOG BACKUP


Log Backup stores


only committed transactions.


Backup File


BackupLabDB_Log.trn



============================================================
*/


BACKUP LOG BackupLabDB

TO DISK='D:\Certifications\001___Koenig_Extras\Vaibhav_labs\Extra_Labs\M55353A - Administering a SQL Database Infrastructure\Lab-6\BackupLabDB_Log.trn'

WITH

INIT,

NAME='BackupLabDB Transaction Log Backup',

STATS=10;
GO





/*
EXPECTED RESULT


100 Percent Processed


BACKUP LOG

successfully processed.



*/
GO








/*
============================================================
STEP 11 : VERIFY LOG BACKUP


BackupType


2


means


Transaction Log Backup.



============================================================
*/


RESTORE HEADERONLY

FROM DISK='D:\Certifications\001___Koenig_Extras\Vaibhav_labs\Extra_Labs\M55353A - Administering a SQL Database Infrastructure\Lab-6\BackupLabDB_Log.trn';
GO




/*
EXPECTED RESULT


BackupType


-------------
2



DatabaseName


-------------
BackupLabDB




BackupName


-------------
BackupLabDB Transaction Log Backup



*/
GO








/*
============================================================
STEP 12 : VERIFY BACKUP HISTORY


Backup history

stored in


msdb



============================================================
*/


USE msdb;
GO


SELECT

database_name,

backup_start_date,

backup_finish_date,

type


FROM backupset


WHERE database_name='BackupLabDB'

ORDER BY backup_finish_date DESC;
GO





/*
EXPECTED RESULT


database_name


BackupLabDB




type


D = Full Backup


I = Differential Backup


L = Log Backup




Several rows returned.



*/
GO









/*
============================================================
STEP 13 : UNDERSTANDING RESTORE SEQUENCE


To recover database completely


Restore Order


1 Full Backup


2 Differential Backup


3 Transaction Log Backup




Example


RESTORE DATABASE BackupLabDB

FROM DISK='C:\SQLBackups\BackupLabDB_Full2.bak'

WITH NORECOVERY;



RESTORE DATABASE BackupLabDB

FROM DISK='C:\SQLBackups\BackupLabDB_Diff.bak'

WITH NORECOVERY;



RESTORE LOG BackupLabDB

FROM DISK='C:\SQLBackups\BackupLabDB_Log.trn'

WITH RECOVERY;



Do NOT execute now.



============================================================
*/
GO









/*
============================================================
STEP 14 : BEST PRACTICES


Take


Full Backup


Daily




Differential Backup


Every 4 Hours




Transaction Log Backup


Every 15 Minutes




Always Verify Backups



Use Separate Disk


for backup files.



============================================================
*/
GO










/*
============================================================
STEP 15 : TROUBLESHOOTING


Common Error



BACKUP LOG cannot be performed


because there is no current


database backup.




Cause


No Full Backup Exists




Fix


Take Full Backup First




------------------------------------------------



Common Error


BACKUP LOG is not allowed


while recovery model is SIMPLE.




Fix


ALTER DATABASE BackupLabDB


SET RECOVERY FULL;




Take another Full Backup.




============================================================
*/
GO










/*
============================================================
STEP 16 : MINI LAB EXERCISES



Exercise 1


Insert three more rows



Take another


Differential Backup





Exercise 2


Take second


Transaction Log Backup





Exercise 3


Run


RESTORE VERIFYONLY


on all backup files.





Exercise 4


Query


msdb.dbo.backupmediafamily





Exercise 5


Find size of backup files


using Windows Explorer.




============================================================
*/
GO
```sql
/*
============================================================
🔐 MODULE 6 : BACKING UP AND RESTORING DATABASES

PART 3A : PERFORMING A PARTIAL BACKUP

Exercise 3 : Performing a Partial Backup

Topics Covered

1. Create Database
2. Create Secondary Filegroup
3. Add Secondary Data File
4. Create Tables on Different Filegroups
5. Insert Sample Data
6. Verify Filegroups
7. Mark Filegroup as Read Only
8. Verify Read Only Status

Prerequisites

Create the following folders before running:

C:\SQLData\
C:\SQLBackups\

Execute entire script as SysAdmin

============================================================
*/

USE master;
GO


/*
============================================================
STEP 1 : CREATE DATABASE

Partial Backup requires
multiple filegroups.

============================================================
*/

CREATE DATABASE PartialBackupDB;
GO


/*
VERIFY DATABASE
*/

SELECT
name,
state_desc
FROM sys.databases
WHERE name='PartialBackupDB';
GO


/*
EXPECTED RESULT

name
----------------
PartialBackupDB

state_desc
----------------
ONLINE


UI Verification

SSMS

Databases

Refresh

PartialBackupDB

should appear.
*/
GO




/*
============================================================
STEP 2 : ADD SECONDARY FILEGROUP

Filegroup Name

ArchiveFG

============================================================
*/

ALTER DATABASE PartialBackupDB
ADD FILEGROUP ArchiveFG;
GO


/*
VERIFY FILEGROUP
*/

USE PartialBackupDB;
GO

SELECT
name,
type_desc
FROM sys.filegroups;
GO


/*
EXPECTED RESULT

name
----------------
PRIMARY

ArchiveFG


type_desc
----------------
ROWS_FILEGROUP


UI Verification

SSMS

PartialBackupDB

Storage

Filegroups

ArchiveFG should appear.
*/
GO





/*
============================================================
STEP 3 : ADD SECONDARY DATA FILE

Logical Name

ArchiveData

Physical File

C:\SQLData\ArchiveData.ndf

============================================================
*/

USE master;
GO

ALTER DATABASE PartialBackupDB
ADD FILE
(
NAME='ArchiveData',

FILENAME='C:\SQLData\ArchiveData.ndf',

SIZE=5MB,

FILEGROWTH=5MB
)
TO FILEGROUP ArchiveFG;
GO


/*
VERIFY FILE
*/

USE PartialBackupDB;
GO

SELECT
name,
physical_name,
size
FROM sys.database_files;
GO


/*
EXPECTED RESULT

name
----------------
PartialBackupDB

ArchiveData


physical_name
----------------
C:\SQLData\ArchiveData.ndf


UI Verification

SSMS

PartialBackupDB

Properties

Files

ArchiveData should appear.
*/
GO





/*
============================================================
STEP 4 : CREATE TABLE ON PRIMARY FILEGROUP

By default tables are created
on PRIMARY filegroup.

============================================================
*/

CREATE TABLE dbo.CurrentOrders
(
OrderID INT PRIMARY KEY,
CustomerName VARCHAR(100)
);
GO


/*
VERIFY TABLE
*/

SELECT
name
FROM sys.tables
WHERE name='CurrentOrders';
GO


/*
EXPECTED RESULT

CurrentOrders

should appear.
*/
GO





/*
============================================================
STEP 5 : CREATE TABLE ON ARCHIVEFG

Table will be stored inside
secondary filegroup.

============================================================
*/

CREATE TABLE dbo.HistoryOrders
(
OrderID INT PRIMARY KEY,
CustomerName VARCHAR(100)
)
ON ArchiveFG;
GO


/*
VERIFY TABLE
*/

SELECT
name
FROM sys.tables
WHERE name='HistoryOrders';
GO


/*
EXPECTED RESULT

HistoryOrders

should appear.
*/
GO





/*
============================================================
STEP 6 : VERIFY TABLE FILEGROUPS

Shows where tables are stored.

============================================================
*/

SELECT
t.name AS TableName,
fg.name AS FileGroupName
FROM sys.tables t
INNER JOIN sys.indexes i
ON t.object_id=i.object_id
INNER JOIN sys.filegroups fg
ON i.data_space_id=fg.data_space_id
WHERE i.index_id IN (0,1);
GO


/*
EXPECTED RESULT

TableName        FileGroupName
--------------------------------

CurrentOrders    PRIMARY

HistoryOrders    ArchiveFG


Verification

CurrentOrders stored on PRIMARY

HistoryOrders stored on ArchiveFG
*/
GO





/*
============================================================
STEP 7 : INSERT SAMPLE DATA

============================================================
*/

INSERT INTO dbo.CurrentOrders
VALUES
(1,'Raj'),
(2,'Amit'),
(3,'Neha');
GO


INSERT INTO dbo.HistoryOrders
VALUES
(101,'Ravi'),
(102,'Karan'),
(103,'Rohit');
GO


/*
VERIFY DATA
*/

SELECT * FROM dbo.CurrentOrders;
GO

SELECT * FROM dbo.HistoryOrders;
GO


/*
EXPECTED RESULT

CurrentOrders

1 Raj
2 Amit
3 Neha


HistoryOrders

101 Ravi
102 Karan
103 Rohit
*/
GO






/*
============================================================
STEP 8 : VERIFY ROW COUNTS

============================================================
*/

SELECT
'CurrentOrders' AS TableName,
COUNT(*) AS TotalRows
FROM dbo.CurrentOrders

UNION ALL

SELECT
'HistoryOrders',
COUNT(*)
FROM dbo.HistoryOrders;
GO


/*
EXPECTED RESULT

TableName         TotalRows
---------------------------
CurrentOrders     3

HistoryOrders     3
*/
GO






/*
============================================================
STEP 9 : MARK ARCHIVEFG READ ONLY

Partial Backup typically includes

PRIMARY

READ_WRITE FILEGROUPS

and excludes data that does not
need frequent backups.

============================================================
*/

USE master;
GO

ALTER DATABASE PartialBackupDB
MODIFY FILEGROUP ArchiveFG READONLY;
GO


/*
EXPECTED RESULT

Command completed successfully.
*/
GO






/*
============================================================
STEP 10 : VERIFY READ ONLY STATUS

============================================================
*/

USE PartialBackupDB;
GO

SELECT
name,
is_read_only
FROM sys.filegroups;
GO


/*
EXPECTED RESULT

name          is_read_only
--------------------------

PRIMARY       0

ArchiveFG     1


Meaning

0 = READ WRITE

1 = READ ONLY


UI Verification

SSMS

PartialBackupDB

Storage

Filegroups

ArchiveFG

Read Only = True
*/
GO
```

```sql
/*
============================================================
🔐 MODULE 6 : BACKING UP AND RESTORING DATABASES

PART 3B : PERFORMING A PARTIAL BACKUP

Exercise 3 : Performing a Partial Backup

Topics Covered

1. Performing Partial Backup
2. Verifying Backup Integrity
3. Viewing Backup Header Information
4. Viewing Backup File List
5. Viewing Backup History
6. Best Practices
7. Troubleshooting
8. Mini Lab Exercises
9. Cleanup

Prerequisite

Part 3A should be completed successfully.

Folders Required

C:\SQLBackups\

Execute entire script as SysAdmin

============================================================
*/

USE master;
GO


/*
============================================================
STEP 11 : PERFORM PARTIAL BACKUP

READ_WRITE_FILEGROUPS

Backs up

PRIMARY Filegroup

and

all READ WRITE filegroups


READ ONLY filegroups are not backed up.


Backup File

C:\SQLBackups\PartialBackupDB_Partial.bak

============================================================
*/

BACKUP DATABASE PartialBackupDB

READ_WRITE_FILEGROUPS

TO DISK='C:\SQLBackups\PartialBackupDB_Partial.bak'

WITH

INIT,

NAME='PartialBackupDB Partial Backup',

STATS=10;
GO


/*
EXPECTED RESULT


10 Percent Processed


20 Percent Processed


...


100 Percent Processed



BACKUP DATABASE successfully processed.



UI Verification


Windows Explorer


C:\SQLBackups


PartialBackupDB_Partial.bak


should appear.

*/
GO





/*
============================================================
STEP 12 : VERIFY BACKUP

RESTORE VERIFYONLY

checks backup readability

without restoring.

============================================================
*/

RESTORE VERIFYONLY

FROM DISK='C:\SQLBackups\PartialBackupDB_Partial.bak';
GO


/*
EXPECTED RESULT


The backup set on file 1

is valid.



Verification successful.


*/
GO





/*
============================================================
STEP 13 : VIEW BACKUP HEADER

RESTORE HEADERONLY

shows metadata


Backup Name

Database Name

Backup Type

Backup Start Date


============================================================
*/

RESTORE HEADERONLY

FROM DISK='C:\SQLBackups\PartialBackupDB_Partial.bak';
GO


/*
EXPECTED RESULT


BackupName

-----------------------------

PartialBackupDB Partial Backup



DatabaseName

-----------------------------

PartialBackupDB



BackupType

-----------------------------

1




BackupType Meaning


1 = Database Backup


2 = Log Backup


5 = Differential Backup



*/
GO






/*
============================================================
STEP 14 : VIEW FILE LIST

RESTORE FILELISTONLY

shows logical files included

inside backup.

============================================================
*/

RESTORE FILELISTONLY

FROM DISK='C:\SQLBackups\PartialBackupDB_Partial.bak';
GO



/*
EXPECTED RESULT


LogicalName

----------------------

PartialBackupDB




ArchiveData


may not appear because

ArchiveFG is READ ONLY.



Verification


Observe files included

inside backup.



*/
GO






/*
============================================================
STEP 15 : CHECK BACKUP HISTORY

Backup history stored in

msdb database.

============================================================
*/

USE msdb;
GO


SELECT

database_name,

backup_start_date,

backup_finish_date,

type


FROM backupset


WHERE database_name='PartialBackupDB'

ORDER BY backup_finish_date DESC;
GO




/*
EXPECTED RESULT


database_name


PartialBackupDB




type


D


means


Database Backup




Several rows returned.



*/
GO







/*
============================================================
STEP 16 : VERIFY FILEGROUP STATUS

Confirms ArchiveFG

is still READ ONLY.


============================================================
*/

USE PartialBackupDB;
GO


SELECT

name,

is_read_only


FROM sys.filegroups;
GO




/*
EXPECTED RESULT


name


PRIMARY


ArchiveFG




is_read_only


0


1




Meaning


0 = READ WRITE


1 = READ ONLY


*/
GO








/*
============================================================
STEP 17 : BEST PRACTICES


Use Partial Backup


for very large databases.



Store archive data


inside READ ONLY filegroups.



Verify backups regularly.



Keep backup files


on separate disks.



============================================================
*/
GO







/*
============================================================
STEP 18 : TROUBLESHOOTING


Common Error


Cannot open backup device




Cause


Folder does not exist.




Fix


Create folder


C:\SQLBackups\




------------------------------------------------



Common Error



BACKUP DATABASE

WITH PARTIAL

is not permitted.



Cause


No READ ONLY filegroup exists.




Fix


ALTER DATABASE PartialBackupDB


MODIFY FILEGROUP ArchiveFG


READONLY;




------------------------------------------------



Common Error



Operating System Error 5



Cause


SQL Server service account

does not have permissions.



Fix


Grant Write Permission


on


C:\SQLBackups\



============================================================
*/
GO








/*
============================================================
STEP 19 : MINI LAB EXERCISES


Exercise 1


Create another filegroup



Exercise 2


Add another .ndf file




Exercise 3


Make filegroup READ ONLY




Exercise 4


Take another Partial Backup




Exercise 5


Query backupmediafamily




Exercise 6


Compare Full Backup

and Partial Backup sizes



============================================================
*/
GO








/*
============================================================
STEP 20 : CLEANUP

Run only if cleanup

is required.


============================================================
*/

USE master;
GO


ALTER DATABASE PartialBackupDB

SET SINGLE_USER

WITH ROLLBACK IMMEDIATE;
GO



DROP DATABASE PartialBackupDB;
GO



/*
EXPECTED RESULT



PartialBackupDB



Removed



UI Verification


SSMS


Databases


Refresh



PartialBackupDB


disappears.



============================================================
*/
GO
```
