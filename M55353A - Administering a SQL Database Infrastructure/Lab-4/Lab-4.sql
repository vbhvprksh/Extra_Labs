/*
===============================================================================
MODULE 4 : PROTECTING DATA WITH ENCRYPTION AND AUDITING
===============================================================================
*/

USE master;
GO


/* STEP 1 : CREATE AUDIT */

CREATE SERVER AUDIT AuditLab
TO FILE
(
FILEPATH='C:\AuditLogs\'
);
GO


ALTER SERVER AUDIT AuditLab
WITH (STATE=ON);
GO


/* VERIFY */

SELECT *
FROM sys.server_audits;
GO


/* STEP 2 */

CREATE SERVER AUDIT SPECIFICATION AuditSpec
FOR SERVER AUDIT AuditLab
ADD (FAILED_LOGIN_GROUP);
GO


ALTER SERVER AUDIT SPECIFICATION AuditSpec
WITH (STATE=ON);
GO


/* STEP 3 : TDE */

CREATE DATABASE EncryptionDB;
GO


USE EncryptionDB;
GO


CREATE MASTER KEY
ENCRYPTION BY PASSWORD='StrongPass123!';
GO


CREATE CERTIFICATE TDECert
WITH SUBJECT='TDE Certificate';
GO


USE master;
GO


CREATE DATABASE ENCRYPTION KEY
WITH ALGORITHM=AES_256
ENCRYPTION BY SERVER CERTIFICATE TDECert;
GO


ALTER DATABASE EncryptionDB
SET ENCRYPTION ON;
GO


/* VERIFY */

SELECT db_name(database_id),
encryption_state
FROM sys.dm_database_encryption_keys;
GO