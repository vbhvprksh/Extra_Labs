/*
===============================================================================
MODULE 6 : BACKING UP SQL SERVER DATABASES

Topics Covered
1. Backing Up Databases and Transaction Logs
2. Managing Database Backups
3. Advanced Database Backup Options

Lab : Backing Up Databases
===============================================================================
*/

USE master;
GO

/* STEP 1 : CREATE LAB DATABASE */

CREATE DATABASE BackupDemoDB;
GO

USE BackupDemoDB;
GO

CREATE TABLE Employees
(
EmployeeID INT IDENTITY(1,1),
EmployeeName VARCHAR(100)
);
GO

INSERT INTO Employees(EmployeeName)
VALUES
('John'),
('Mary'),
('David');
GO


/* STEP 2 : PERFORM FULL DATABASE BACKUP */

BACKUP DATABASE BackupDemoDB
TO DISK='C:\SQLBackups\BackupDemoDB_Full.bak'
WITH INIT,
NAME='Full Backup';
GO


/* VERIFY */

RESTORE HEADERONLY
FROM DISK='C:\SQLBackups\BackupDemoDB_Full.bak';
GO


/* STEP 3 : DIFFERENTIAL BACKUP */

INSERT INTO Employees(EmployeeName)
VALUES('Robert');
GO


BACKUP DATABASE BackupDemoDB
TO DISK='C:\SQLBackups\BackupDemoDB_Diff.bak'
WITH DIFFERENTIAL,
INIT;
GO


/* VERIFY */

RESTORE HEADERONLY
FROM DISK='C:\SQLBackups\BackupDemoDB_Diff.bak';
GO


/* STEP 4 : CONFIGURE FULL RECOVERY */

ALTER DATABASE BackupDemoDB
SET RECOVERY FULL;
GO


/* STEP 5 : TRANSACTION LOG BACKUP */

BACKUP LOG BackupDemoDB
TO DISK='C:\SQLBackups\BackupDemoDB_Log.trn'
WITH INIT;
GO


/* VERIFY */

RESTORE HEADERONLY
FROM DISK='C:\SQLBackups\BackupDemoDB_Log.trn';
GO


/* STEP 6 : PARTIAL BACKUP */

BACKUP DATABASE BackupDemoDB
READ_WRITE_FILEGROUPS
TO DISK='C:\SQLBackups\BackupDemoDB_Partial.bak';
GO


/* CLEANUP */

USE master;
GO

DROP DATABASE BackupDemoDB;
GO