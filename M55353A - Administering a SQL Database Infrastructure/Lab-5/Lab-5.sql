/*
===============================================================================
MODULE 5 : RECOVERY MODELS AND BACKUP STRATEGIES
===============================================================================
*/

CREATE DATABASE BackupLab;
GO


/* STEP 1 */

SELECT name,
recovery_model_desc
FROM sys.databases
WHERE name='BackupLab';
GO


/* STEP 2 */

ALTER DATABASE BackupLab
SET RECOVERY FULL;
GO


/* VERIFY */

SELECT name,
recovery_model_desc
FROM sys.databases
WHERE name='BackupLab';
GO


/* STEP 3 */

ALTER DATABASE BackupLab
SET RECOVERY BULK_LOGGED;
GO


/* STEP 4 */

ALTER DATABASE BackupLab
SET RECOVERY SIMPLE;
GO


/* VERIFY */

SELECT recovery_model_desc
FROM sys.databases
WHERE name='BackupLab';
GO


/* STEP 5 */

BACKUP DATABASE BackupLab
TO DISK='C:\SQLBackups\BackupLab.bak'
WITH INIT;
GO


/* VERIFY */

RESTORE HEADERONLY
FROM DISK='C:\SQLBackups\BackupLab.bak';
GO


/* CLEANUP */

USE master;
GO

DROP DATABASE BackupLab;
GO