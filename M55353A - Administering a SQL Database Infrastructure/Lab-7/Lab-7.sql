/*
===============================================================================
MODULE 7 : RESTORING SQL SERVER DATABASES

Topics Covered
1. Understanding Restore Process
2. Restoring Databases
3. Point in Time Recovery
4. Advanced Restore Scenarios
===============================================================================
*/

USE master;
GO


/* STEP 1 */

CREATE DATABASE RestoreLabDB;
GO


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
(1,GETDATE());
GO


/* STEP 2 */

BACKUP DATABASE RestoreLabDB
TO DISK='C:\SQLBackups\RestoreLabDB.bak'
WITH INIT;
GO



/* STEP 3 */

INSERT INTO Orders
VALUES
(2,GETDATE());
GO


BACKUP LOG RestoreLabDB
TO DISK='C:\SQLBackups\RestoreLabDB_Log.trn'
WITH INIT;
GO



/* STEP 4 */

USE master;
GO


RESTORE DATABASE RestoreLabDB
FROM DISK='C:\SQLBackups\RestoreLabDB.bak'
WITH NORECOVERY;
GO



/* STEP 5 */

RESTORE LOG RestoreLabDB
FROM DISK='C:\SQLBackups\RestoreLabDB_Log.trn'
WITH RECOVERY;
GO



/* VERIFY */

USE RestoreLabDB;
GO

SELECT *
FROM Orders;
GO



/* STEP 6 */

RESTORE VERIFYONLY
FROM DISK='C:\SQLBackups\RestoreLabDB.bak';
GO



/* STEP 7 */

RESTORE FILELISTONLY
FROM DISK='C:\SQLBackups\RestoreLabDB.bak';
GO



/* CLEANUP */

USE master;
GO

DROP DATABASE RestoreLabDB;
GO