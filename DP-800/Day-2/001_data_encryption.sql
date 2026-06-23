/* 
============================================================
🔐 DATA ENCRYPTION LAYERS IN SQL SERVER (SINGLE SCRIPT)
Covers:
1. Transparent Data Encryption (TDE)
2. Column-Level Encryption
3. Always Encrypted
============================================================
*/


/* 
============================================================
🔐 1. TRANSPARENT DATA ENCRYPTION (TDE)
- Encrypts entire database (data + log + backups)
- Works at storage layer (no app changes required)
============================================================
*/

-- Step 1: Create Demo Database
CREATE DATABASE Demo_TDE_DB;
GO

USE Demo_TDE_DB;
GO

-- Step 2: Create Master Key (required for certificate protection)
CREATE MASTER KEY 
ENCRYPTION BY PASSWORD = 'StrongPassword@123';
GO

-- Step 3: Create Certificate (protects DEK)
CREATE CERTIFICATE TDE_Cert
WITH SUBJECT = 'TDE Certificate';
GO

-- Step 4: Create Database Encryption Key (DEK)
CREATE DATABASE ENCRYPTION KEY
WITH ALGORITHM = AES_256
ENCRYPTION BY SERVER CERTIFICATE TDE_Cert;
GO

-- Step 5: Enable Encryption
ALTER DATABASE Demo_TDE_DB
SET ENCRYPTION ON;
GO

-- Step 6: Validate Encryption Status
SELECT 
    db.name,
    dm.encryption_state,
    dm.percent_complete,
    dm.key_algorithm
FROM sys.dm_database_encryption_keys dm
JOIN sys.databases db
ON dm.database_id = db.database_id;
GO



/* 
============================================================
🔐 2. COLUMN-LEVEL ENCRYPTION
- Encrypts specific columns
- Uses symmetric key + certificate
- Requires manual OPEN/CLOSE key
============================================================
*/

USE Demo_TDE_DB;
GO

-- Step 1: Create Table
CREATE TABLE Employee_Encrypted (
    ID INT PRIMARY KEY,
    Name VARCHAR(100),
    SSN VARBINARY(256)  -- Encrypted column
);
GO

-- Step 2: Create Certificate (if not already exists)
CREATE CERTIFICATE Emp_Cert
WITH SUBJECT = 'Employee Data Protection';
GO

-- Step 3: Create Symmetric Key
CREATE SYMMETRIC KEY Emp_SymKey
WITH ALGORITHM = AES_256
ENCRYPTION BY CERTIFICATE Emp_Cert;
GO

-- Step 4: Insert Encrypted Data
OPEN SYMMETRIC KEY Emp_SymKey
DECRYPTION BY CERTIFICATE Emp_Cert;

INSERT INTO Employee_Encrypted (ID, Name, SSN)
VALUES 
(1, 'Vaibhav', EncryptByKey(Key_GUID('Emp_SymKey'), '123-45-6789')),
(2, 'Niharika', EncryptByKey(Key_GUID('Emp_SymKey'), '987-65-4321'));

CLOSE SYMMETRIC KEY Emp_SymKey;
GO

-- Step 5: Read Decrypted Data
OPEN SYMMETRIC KEY Emp_SymKey
DECRYPTION BY CERTIFICATE Emp_Cert;

SELECT 
    ID,
    Name,
    CONVERT(VARCHAR, DecryptByKey(SSN)) AS Decrypted_SSN
FROM Employee_Encrypted;

CLOSE SYMMETRIC KEY Emp_SymKey;
GO

-- Step 6: Check Raw Encrypted Data
SELECT * FROM Employee_Encrypted;
GO



/* 
============================================================
🔐 3. ALWAYS ENCRYPTED (CLIENT-SIDE ENCRYPTION)
- Keys never stored in SQL Server
- Encryption/Decryption happens at client side
- Even DBA cannot see plaintext
============================================================
*/

USE Demo_TDE_DB;
GO

-- Step 1: Create Column Master Key (CMK)
-- NOTE: Replace KEY_PATH with actual certificate thumbprint
CREATE COLUMN MASTER KEY CMK_Auto
WITH (
    KEY_STORE_PROVIDER_NAME = 'MSSQL_CERTIFICATE_STORE',
    KEY_PATH = 'CurrentUser/My/YourCertificateThumbprint'
);
GO

-- Step 2: Create Column Encryption Key (CEK)
-- NOTE: ENCRYPTED_VALUE is generated via SSMS / client driver
CREATE COLUMN ENCRYPTION KEY CEK_Auto
WITH VALUES (
    COLUMN_MASTER_KEY = CMK_Auto,
    ALGORITHM = 'RSA_OAEP',
    ENCRYPTED_VALUE = 0x123456  -- Placeholder value
);
GO

-- Step 3: Create Table with Encrypted Column
CREATE TABLE Employee_AE (
    ID INT PRIMARY KEY,
    Name VARCHAR(100),

    SSN VARCHAR(50) 
    COLLATE Latin1_General_BIN2
    ENCRYPTED WITH (
        COLUMN_ENCRYPTION_KEY = CEK_Auto,
        ENCRYPTION_TYPE = DETERMINISTIC,
        ALGORITHM = 'AEAD_AES_256_CBC_HMAC_SHA_256'
    )
);
GO

-- Step 4: Insert Data (requires Always Encrypted enabled in client)
INSERT INTO Employee_AE (ID, Name, SSN)
VALUES 
(1, 'Vaibhav', '123-45-6789'),
(2, 'Niharika', '987-65-4321');
GO

-- Step 5: Query Data
SELECT * FROM Employee_AE;
GO



/* 
============================================================
🧹 CLEANUP (MANDATORY)
============================================================
*/

-- Step 1: Drop Tables
DROP TABLE Employee_AE;
GO

DROP TABLE Employee_Encrypted;
GO

-- Step 2: Disable TDE before dropping DB
ALTER DATABASE Demo_TDE_DB
SET ENCRYPTION OFF;
GO

-- Step 3: Drop Database
USE master;
GO

DROP DATABASE Demo_TDE_DB;
GO

-- Step 4: Drop Keys & Certificates from master (if created there)
-- (Run only if needed depending on environment)
DROP CERTIFICATE TDE_Cert;
GO

DROP CERTIFICATE Emp_Cert;
GO

DROP MASTER KEY;
GO