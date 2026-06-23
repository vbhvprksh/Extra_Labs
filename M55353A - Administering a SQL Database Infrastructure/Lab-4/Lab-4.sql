/*
===============================================================================
MODULE 4 : PROTECTING DATA WITH ENCRYPTION AND AUDITING

PART 1 : SQL SERVER AUDITING

Exercise 1 : Working with SQL Server Audit


Topics Covered

1. Creating Server Audits
2. Enabling Audits
3. Server Audit Specifications
4. Capturing Failed Login Attempts
5. Verifying Audit Configuration
6. Reading Audit Files
7. Viewing Audit Logs
8. Troubleshooting


Execute entire script as SysAdmin


Prerequisites


SQL Server Service Account must have Write permissions on


D:\Certifications\001___Koenig_Extras\Vaibhav_labs\Extra_Labs\
M55353A - Administering a SQL Database Infrastructure\Lab-4



If folder does not exist


Create manually before executing.


===============================================================================
*/

USE master;
GO


/*
===============================================================================
STEP 1 : CREATE SERVER AUDIT


What is Server Audit?


SQL Server Audit tracks and records activities
occurring inside SQL Server.


Examples


Login failures


Permission changes


Database access


Schema modifications


Audit Targets


FILE


APPLICATION_LOG


SECURITY_LOG



In this lab


Audit records will be stored inside


D:\Certifications\001___Koenig_Extras\Vaibhav_labs\Extra_Labs\
M55353A - Administering a SQL Database Infrastructure\Lab-4



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


D:\Certifications\001___Koenig_Extras\Vaibhav_labs\
Extra_Labs\M55353A - Administering a SQL Database Infrastructure\Lab-4


===============================================================================
*/

CREATE SERVER AUDIT AuditLab

TO FILE
(
FILEPATH='D:\Certifications\001___Koenig_Extras\Vaibhav_labs\Extra_Labs\M55353A - Administering a SQL Database Infrastructure\Lab-4'
);
GO



/*
===============================================================================
ENABLE AUDIT


Newly created audits remain disabled.


STATE = ON


Starts collecting events.



Equivalent UI


Security


Server Audits


AuditLab


Right Click


Enable


===============================================================================
*/

ALTER SERVER AUDIT AuditLab

WITH
(
STATE=ON
);
GO




/*
===============================================================================
VERIFY AUDIT


Catalog View


sys.server_audits



Expected Result


name


AuditLab



status_desc


STARTED



type_desc


FILE




UI Verification


SSMS


Security


Server Audits


Refresh



AuditLab



Green Arrow icon should appear.


===============================================================================
*/

SELECT

name,

status_desc,

type_desc

FROM sys.server_audits;
GO




/*
===============================================================================
STEP 2 : CREATE AUDIT SPECIFICATION


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




/*
===============================================================================
VERIFY SPECIFICATION


Catalog Views


sys.server_audit_specifications


sys.server_audit_specification_details




Expected Result


name


AuditSpec



is_state_enabled


1




audit_action_name


FAILED_LOGIN_GROUP




audited_result


FAILURE




UI Verification


SSMS



Security



Server Audit Specifications



Refresh



AuditSpec



Green Arrow icon should appear.




Right Click



AuditSpec



Properties




Audit


AuditLab




Action Groups


FAILED_LOGIN_GROUP



===============================================================================
*/


SELECT

name,

is_state_enabled

FROM sys.server_audit_specifications;
GO



SELECT

s.name AS AuditSpecification,

d.audit_action_name,

d.audited_result

FROM sys.server_audit_specifications s

INNER JOIN sys.server_audit_specification_details d

ON s.server_specification_id=d.server_specification_id;
GO




/*
===============================================================================
STEP 3 : VERIFY AUDIT FILE CREATION


Audit files are stored with extension


.sqlaudit




Equivalent UI


Windows Explorer



Browse to



D:\Certifications\001___Koenig_Extras\Vaibhav_labs\
Extra_Labs\M55353A - Administering a SQL Database Infrastructure\Lab-4




Expected Result


AuditLab_*.sqlaudit




One or more files should appear.



===============================================================================
*/




/*
===============================================================================
STEP 4 : GENERATE FAILED LOGIN EVENT



Attempt to connect using


Wrong Password



OR



Disabled Login



OR



Unknown Login




Example


Login Name


sa




Password


WrongPassword123




Expected Result



Login failed message.




Audit event generated.



===============================================================================
*/




/*
===============================================================================
STEP 5 : READ AUDIT RECORDS



Audit files can be read using



sys.fn_get_audit_file()




Equivalent UI



SSMS



Security



Audits



AuditLab




Right Click



View Audit Logs




===============================================================================
*/


SELECT

event_time,

action_id,

succeeded,

session_server_principal_name

FROM sys.fn_get_audit_file
(
'D:\Certifications\001___Koenig_Extras\Vaibhav_labs\Extra_Labs\M55353A - Administering a SQL Database Infrastructure\Lab-4\*.sqlaudit',

DEFAULT,

DEFAULT
);
GO




/*
===============================================================================
EXPECTED RESULT



event_time


2026-06-23 20:30:15




action_id


LGIF




succeeded


0




session_server_principal_name


sa




LGIF


means


Login Failed




===============================================================================
*/




/*
===============================================================================
STEP 6 : BEST PRACTICES



Store audit files on dedicated drives.



Monitor audit growth periodically.



Use FAILED_LOGIN_GROUP


to detect brute force attacks.



Protect audit files from modification.



Backup audit files regularly.




===============================================================================
*/
GO




/*
===============================================================================
STEP 7 : TROUBLESHOOTING



Common Error



Cannot create audit.




Cause



Folder does not exist.




Fix



Create folder manually.




Another Common Error



Access is denied.




Cause



SQL Server service account


does not have Write permission.




Fix



Grant Full Control


to SQL Server Service Account.




===============================================================================
*/
GO




/*
===============================================================================
STEP 8 : MINI LAB EXERCISES



Exercise 1



Create another audit


LoginAudit




Exercise 2



Capture


SUCCESSFUL_LOGIN_GROUP




Exercise 3



Read audit records




Exercise 4



View audit logs


using SSMS




Exercise 5



Disable AuditSpec




Exercise 6



Disable AuditLab




===============================================================================
*/
GO

# /*

MODULE 4 : PROTECTING DATA WITH ENCRYPTION AND AUDITING

PART 2 : ALWAYS ENCRYPTED

Exercise 2 : Encrypt a Column with Always Encrypted

Topics Covered

1. Creating Sample Database

2. Creating Tables

3. Creating Sample Data

4. Always Encrypted Wizard

5. Column Master Key

6. Column Encryption Key

7. Deterministic Encryption

8. Verifying Encryption

9. Querying Encrypted Data

Execute entire script as SysAdmin

===============================================================================
*/

USE master;
GO

# /*

STEP 1 : CREATE DATABASE

Always Encrypted protects sensitive columns.

Examples

Credit Card Number

Passport Number

Social Security Number

Bank Account Number

Equivalent UI

Databases

Right Click

New Database

Database Name

AlwaysEncryptedLab

===============================================================================
*/

CREATE DATABASE AlwaysEncryptedLab;
GO

USE AlwaysEncryptedLab;
GO

# /*

VERIFY DATABASE

Expected Result

AlwaysEncryptedLab

UI Verification

SSMS

Databases

Refresh

AlwaysEncryptedLab

should appear.

===============================================================================
*/

SELECT name
FROM sys.databases
WHERE name='AlwaysEncryptedLab';
GO

# /*

STEP 2 : CREATE TABLE

SSN column will be encrypted.

Equivalent UI

AlwaysEncryptedLab

Tables

New Table

===============================================================================
*/

CREATE TABLE dbo.Employee
(

EmployeeID INT PRIMARY KEY,

EmployeeName VARCHAR(100),

SSN CHAR(11)

);
GO

# /*

VERIFY TABLE

Expected Result

Employee

UI Verification

AlwaysEncryptedLab

Tables

Refresh

dbo.Employee

should appear.

===============================================================================
*/

SELECT name
FROM sys.tables
WHERE name='Employee';
GO

# /*

STEP 3 : INSERT SAMPLE DATA

===============================================================================
*/

INSERT INTO dbo.Employee
VALUES

(1,'Raj','123-45-6789'),

(2,'Amit','987-65-4321');
GO

SELECT *
FROM dbo.Employee;
GO

# /*

EXPECTED RESULT

1   Raj    123-45-6789

2   Amit   987-65-4321

===============================================================================
*/

# /*

STEP 4 : CONFIGURE ALWAYS ENCRYPTED

Always Encrypted is configured through SSMS Wizard.

Equivalent UI

SSMS

AlwaysEncryptedLab

Tables

dbo.Employee

Right Click

Encrypt Columns

Wizard Steps

Select Column

SSN

Encryption Type

Deterministic

Column Master Key

Auto Generate

Column Encryption Key

Auto Generate

Certificate Store

Current User

Finish Wizard

===============================================================================
*/

# /*

STEP 5 : VERIFY COLUMN MASTER KEY

Catalog View

sys.column_master_keys

Expected Result

CMK_Auto1

UI Verification

AlwaysEncryptedLab

Security

Always Encrypted Keys

Column Master Keys

===============================================================================
*/

SELECT

name,

key_store_provider_name

FROM sys.column_master_keys;
GO

# /*

STEP 6 : VERIFY COLUMN ENCRYPTION KEY

Catalog View

sys.column_encryption_keys

Expected Result

CEK_Auto1

UI Verification

AlwaysEncryptedLab

Security

Always Encrypted Keys

Column Encryption Keys

===============================================================================
*/

SELECT

name

FROM sys.column_encryption_keys;
GO

# /*

STEP 7 : VERIFY ENCRYPTED COLUMN

Catalog View

sys.columns

Expected Result

SSN

encryption_type

1

encryption_algorithm_name

AEAD_AES_256_CBC_HMAC_SHA_256

===============================================================================
*/

SELECT

c.name,

c.encryption_type,

c.encryption_algorithm_name

FROM sys.columns c

WHERE OBJECT_NAME(c.object_id)='Employee';
GO

# /*

STEP 8 : VIEW ENCRYPTED DATA

Connect WITHOUT

Column Encryption Setting=Enabled

Query

SELECT * FROM dbo.Employee;

Expected Result

Encrypted Binary Values

===============================================================================
*/

SELECT *
FROM dbo.Employee;
GO

# /*

STEP 9 : CONNECT WITH COLUMN ENCRYPTION ENABLED

SSMS

Connect

Options

Additional Connection Parameters

Column Encryption Setting=Enabled

Reconnect

Execute

SELECT * FROM dbo.Employee;

Expected Result

1   Raj    123-45-6789

2   Amit   987-65-4321

===============================================================================
*/

# /*

STEP 10 : BEST PRACTICES

Use Deterministic Encryption

for equality searches.

Use Randomized Encryption

for maximum security.

Store CMK backups safely.

Prefer certificate expiration monitoring.

===============================================================================
*/
GO

# /*

STEP 11 : TROUBLESHOOTING

Common Error

Encryption scheme mismatch

Cause

Connection not configured

Fix

Column Encryption Setting=Enabled

Another Common Error

Certificate not found

Cause

CMK certificate missing

Fix

Import certificate into

Current User

Personal Store

===============================================================================
*/
GO

# /*

STEP 12 : MINI LAB EXERCISES

Exercise 1

Encrypt PassportNumber

Exercise 2

Create Customer table

Exercise 3

Use Randomized Encryption

Exercise 4

Verify Column Encryption Keys

Exercise 5

Connect with encryption disabled

===============================================================================
*/
GO

/*
===============================================================================
MODULE 4 : PROTECTING DATA WITH ENCRYPTION AND AUDITING

PART 3 : TRANSPARENT DATA ENCRYPTION (TDE)

Exercise 3 : Encrypt a Database Using TDE


Topics Covered

1. Creating a Database
2. Database Master Key
3. Certificates
4. Backing up Certificates
5. Database Encryption Key
6. Enabling TDE
7. Verifying Encryption Status
8. Best Practices
9. Troubleshooting
10. Cleanup


Execute entire script as SysAdmin

===============================================================================
*/

USE master;
GO


/*
===============================================================================
STEP 1 : CREATE DATABASE


Transparent Data Encryption (TDE)


Encrypts


Data Files


Log Files


Backups



Protects


Data At Rest



Does NOT Encrypt


Data in Memory


Network Traffic



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


/*
===============================================================================
VERIFY DATABASE


Expected Result


EncryptionDB



UI Verification


SSMS


Databases


Refresh



EncryptionDB


should appear.


===============================================================================
*/

SELECT

name,

create_date

FROM sys.databases

WHERE name='EncryptionDB';
GO




/*
===============================================================================
STEP 2 : CREATE DATABASE MASTER KEY


Database Master Key protects


Certificates


Symmetric Keys




Important


Store password securely.




Equivalent UI


No GUI Available



Execute T-SQL



Note


Master Key for TDE must be created
inside master database.


===============================================================================
*/

USE master;
GO


CREATE MASTER KEY

ENCRYPTION BY PASSWORD='StrongPass123!';
GO




/*
===============================================================================
VERIFY MASTER KEY


Catalog View


sys.symmetric_keys



Expected Result


##MS_DatabaseMasterKey##




UI Verification


master


Security


Keys



Refresh



Master Key


should appear.



===============================================================================
*/


SELECT

name,

key_length

FROM sys.symmetric_keys

WHERE name='##MS_DatabaseMasterKey##';
GO





/*
===============================================================================
STEP 3 : CREATE CERTIFICATE


Certificate stores encryption metadata.



Certificate required for TDE.




Equivalent UI



master



Security



Certificates



Right Click



New Certificate



Certificate Name


TDECert



===============================================================================
*/


CREATE CERTIFICATE TDECert

WITH SUBJECT='TDE Certificate';
GO




/*
===============================================================================
VERIFY CERTIFICATE


Catalog View


sys.certificates



Expected Result


TDECert




UI Verification



master


Security


Certificates



Refresh



TDECert


should appear.



===============================================================================
*/


SELECT

name,

subject

FROM sys.certificates

WHERE name='TDECert';
GO





/*
===============================================================================
STEP 4 : BACKUP CERTIFICATE


Certificates should always be backed up.



Failure to backup certificates may
result in permanent data loss.



Example



BACKUP CERTIFICATE TDECert


TO FILE='C:\Backup\TDECert.cer'



WITH PRIVATE KEY


(


FILE='C:\Backup\TDECertKey.pvk',


ENCRYPTION BY PASSWORD='Password123!'


);



Expected Result



Certificate backup files created.




===============================================================================
*/




/*
===============================================================================
STEP 5 : CREATE DATABASE ENCRYPTION KEY


Database Encryption Key


(DEK)



Actual key used to encrypt pages.



AES_256


Industry Standard Encryption Algorithm.




Equivalent UI


No GUI Available



Execute T-SQL



===============================================================================
*/


USE EncryptionDB;
GO


CREATE DATABASE ENCRYPTION KEY


WITH ALGORITHM=AES_256


ENCRYPTION BY SERVER CERTIFICATE TDECert;
GO




/*
===============================================================================
VERIFY DATABASE ENCRYPTION KEY


Catalog View


sys.dm_database_encryption_keys



Expected Result


EncryptionDB




encryption_state



1



Means


Unencrypted


Encryption not enabled yet.




===============================================================================
*/


SELECT

DB_NAME(database_id) AS DatabaseName,

encryption_state

FROM sys.dm_database_encryption_keys;
GO





/*
===============================================================================
STEP 6 : ENABLE ENCRYPTION


STATE = ON


Starts database encryption.



Equivalent UI


Databases


EncryptionDB


Tasks


Manage Database Encryption



Check


Set Database Encryption On



===============================================================================
*/


ALTER DATABASE EncryptionDB

SET ENCRYPTION ON;
GO





/*
===============================================================================
STEP 7 : VERIFY ENCRYPTION STATUS


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



DatabaseName


EncryptionDB




encryption_state


3




UI Verification



SSMS


Databases


EncryptionDB


Tasks


Manage Database Encryption




Encryption Enabled




===============================================================================
*/


SELECT

DB_NAME(database_id) AS DatabaseName,

encryption_state

FROM sys.dm_database_encryption_keys;
GO





/*
===============================================================================
STEP 8 : BEST PRACTICES


Always backup certificates.



Store backups outside SQL Server.



Use AES_256 encryption.



Monitor encryption status regularly.



Do not delete certificates used by TDE.



Enable TDE only on databases
requiring protection.



===============================================================================
*/
GO





/*
===============================================================================
STEP 9 : TROUBLESHOOTING


Common Error


Cannot find server certificate.



Cause


Certificate created in user database.



Fix


Create certificate inside master.




Another Common Error


Cannot create encryption key.



Cause


Master Key missing.




Fix



USE master


CREATE MASTER KEY



ENCRYPTION BY PASSWORD='StrongPassword!';




===============================================================================
*/
GO





/*
===============================================================================
STEP 10 : MINI LAB EXERCISES


Exercise 1


Create database


FinanceDB




Exercise 2


Enable TDE on FinanceDB




Exercise 3


Verify encryption status




Exercise 4


Backup certificate




Exercise 5


Disable TDE



ALTER DATABASE EncryptionDB


SET ENCRYPTION OFF;




===============================================================================
*/
GO





/*
===============================================================================
STEP 11 : CLEANUP


Run only if cleanup
is required.



===============================================================================
*/


USE master;
GO


DROP DATABASE EncryptionDB;
GO


DROP CERTIFICATE TDECert;
GO


DROP MASTER KEY;
GO



/*
EXPECTED RESULT



EncryptionDB


Removed



TDECert


Removed



Master Key


Removed



===============================================================================
*/
GO