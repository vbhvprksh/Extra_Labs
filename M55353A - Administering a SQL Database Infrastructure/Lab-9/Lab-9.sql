/*
===============================================================================
MODULE 9 : CONFIGURING SECURITY FOR SQL SERVER AGENT

Topics Covered
1. SQL Agent Security
2. Credentials
3. Proxy Accounts
===============================================================================
*/

USE master;
GO


/* STEP 1 */

CREATE CREDENTIAL BackupCredential

WITH IDENTITY='Administrator',

SECRET='Password123!';
GO



/* VERIFY */

SELECT *

FROM sys.credentials;
GO



/* STEP 2 */

USE msdb;
GO



EXEC sp_add_proxy

@proxy_name='BackupProxy',

@credential_name='BackupCredential';
GO




/* STEP 3 */

EXEC sp_grant_proxy_to_subsystem

@proxy_name='BackupProxy',

@subsystem_id=3;
GO




/* STEP 4 */

EXEC sp_enum_proxy_for_subsystem

@subsystem_id=3;
GO




/* VERIFY */

SELECT *

FROM msdb.dbo.sysproxies;
GO




/* CLEANUP */

EXEC sp_delete_proxy

@proxy_name='BackupProxy';
GO


USE master;
GO


DROP CREDENTIAL BackupCredential;
GO