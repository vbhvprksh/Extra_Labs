# /*

# MODULE 4 : PROTECTING DATA WITH ENCRYPTION AND AUDITING

PART 1 : SQL SERVER AUDITING AND TRANSPARENT DATA ENCRYPTION

Topics Covered

1. Creating Server Audits
2. Enabling Auditing
3. Audit Specifications
4. Capturing Failed Login Attempts
5. Transparent Data Encryption (TDE)
6. Database Master Key
7. Certificates
8. Database Encryption Keys
9. Verifying Encryption Status

Execute entire script as SysAdmin

Prerequisites

SQL Server Service Account must have write permissions on

C:\AuditLogs\

If folder does not exist

Create manually before executing.

===============================================================================
*/

USE master;
GO

# /*

# STEP 1 : CREATE SERVER AUDIT

What is Server Audit?

SQL Server Audit allows tracking activities
occurring inside SQL Server.

Examples

Login failures

Permission changes

Database access

Schema modifications

Audit Target

File

Application Log

Security Log

In this lab

Audit records will be stored in

C:\AuditLogs\

Equivalent SSMS Navigation

Object Explorer

Security

Server Audits

Right Click

New Audit

Specify

Name

AuditLab

Destination

File

Path

C:\AuditLogs\

===============================================================================
*/

CREATE SERVER AUDIT AuditLab
TO FILE
(
FILEPATH='C:\AuditLogs'
);
GO

/******************************************************************************

Enable Audit

Newly created audits remain disabled.

STATE = ON

starts collecting events.

Equivalent UI

Security

Server Audits

AuditLab

Right Click

Enable

******************************************************************************/

ALTER SERVER AUDIT AuditLab
WITH
(
STATE=ON
);
GO

/******************************************************************************

VERIFY AUDIT

Catalog View

sys.server_audits

Expected Result

## name

AuditLab

## status_desc

STARTED

UI Verification

SSMS

Security

Server Audits

Refresh

AuditLab

Green Arrow icon should appear

******************************************************************************/

SELECT *
FROM sys.server_audits;
GO

# /*

# STEP 2 : CREATE AUDIT SPECIFICATION

Audit alone captures nothing.

Audit Specification tells SQL Server

"What events should be captured"

FAILED_LOGIN_GROUP

Captures

Incorrect password

Disabled login

Unknown login attempts

Equivalent UI

Security

Server Audit Specifications

Right Click

New Server Audit Specification

Name

AuditSpec

Audit

AuditLab

Actions

FAILED_LOGIN_GROUP

===============================================================================
*/

CREATE SERVER AUDIT SPECIFICATION AuditSpec
FOR SERVER AUDIT AuditLab
ADD
(
FAILED_LOGIN_GROUP
);
GO

ALTER SERVER AUDIT SPECIFICATION AuditSpec
WITH
(
STATE=ON
);
GO

/******************************************************************************

VERIFY SPECIFICATION

Expected Result

AuditSpec

Enabled

UI Verification

Security

Server Audit Specifications

Refresh

AuditSpec

Green Arrow icon

******************************************************************************/

SELECT *
FROM sys.server_audit_specifications;
GO

# /*

# STEP 3 : CREATE DATABASE FOR ENCRYPTION

Transparent Data Encryption (TDE)

Encrypts

Data files

Log files

Backups

Protects data at rest

TDE does NOT encrypt

Data in memory

Network traffic

Equivalent UI

Databases

Right Click

New Database

Database Name

EncryptionDB

===============================================================================
*/

CREATE DATABASE EncryptionDB;
GO

USE EncryptionDB;
GO

/******************************************************************************

STEP 4 : CREATE DATABASE MASTER KEY

Master Key

Protects certificates

Protects symmetric keys

Password Requirement

Strong password

Store securely

Equivalent UI

Not available directly in SSMS

Execute TSQL only

******************************************************************************/

CREATE MASTER KEY
ENCRYPTION BY PASSWORD='StrongPass123!';
GO

/******************************************************************************

STEP 5 : CREATE CERTIFICATE

Certificate stores encryption metadata.

Certificate is required for TDE.

Important

Backup certificate immediately.

BACKUP CERTIFICATE TDECert
TO FILE='C:\Backup\TDECert.cer'

WITH PRIVATE KEY

(
FILE='C:\Backup\TDECertKey.pvk',
ENCRYPTION BY PASSWORD='Password123!'
);

******************************************************************************/

CREATE CERTIFICATE TDECert

WITH SUBJECT='TDE Certificate';
GO

# /*

# STEP 6 : CREATE DATABASE ENCRYPTION KEY

Database Encryption Key

DEK

Actual key used to encrypt pages.

AES_256

Industry standard encryption algorithm

Equivalent UI

No GUI available

Execute TSQL

===============================================================================
*/

CREATE DATABASE ENCRYPTION KEY

WITH ALGORITHM=AES_256

ENCRYPTION BY SERVER CERTIFICATE TDECert;
GO

ALTER DATABASE EncryptionDB

SET ENCRYPTION ON;
GO

/******************************************************************************

STEP 7 : VERIFY ENCRYPTION

Dynamic Management View

sys.dm_database_encryption_keys

Encryption State Values

0 = No Encryption Key

1 = Unencrypted

2 = Encryption In Progress

3 = Encrypted

4 = Key Change

5 = Decryption In Progress

6 = Protection Change

Expected Result

## DatabaseName

EncryptionDB

encryption_state

---

3

UI Verification

SSMS

Databases

EncryptionDB

Tasks

Manage Database Encryption

Encryption Enabled

******************************************************************************/

SELECT

DB_NAME(database_id) AS DatabaseName,

encryption_state

FROM sys.dm_database_encryption_keys;
GO

/******************************************************************************

BEST PRACTICES

Always backup certificates

Store certificate backups outside server

Monitor audit files periodically

Use AES_256

Enable TDE only on databases requiring protection

Avoid deleting certificates used by TDE

******************************************************************************/

GO
