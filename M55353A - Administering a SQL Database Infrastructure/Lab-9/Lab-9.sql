/*
===============================================================================
MODULE 9 : CONFIGURING SECURITY FOR SQL SERVER AGENT
===============================================================================

Topics Covered

1. SQL Agent Security
2. Credentials
3. Proxy Accounts
4. SQL Agent Subsystems
5. Proxy Permissions


Execute entire script as SysAdmin


Prerequisites


SQL Server Agent Service

must be running.



Credential Identity


should be an existing


Windows Account



Example


DOMAIN\SQLServiceAccount




===============================================================================
*/


USE master;
GO



/*
===============================================================================
STEP 1 : UNDERSTANDING CREDENTIALS
===============================================================================


What is a Credential ?


Credential stores


User Name


Password


Authentication Information




Used by


SQL Server Agent


Backup Utilities


SSIS


PowerShell


CmdExec Jobs




Equivalent SSMS UI


Security


Credentials


Right Click


New Credential




Credential Name


BackupCredential




Identity


DOMAIN\SQLServiceAccount




===============================================================================
*/


CREATE CREDENTIAL BackupCredential


WITH


IDENTITY='DOMAIN\SQLServiceAccount',


SECRET='Password123!';

GO





/******************************************************************************
VERIFY CREDENTIAL


Expected Result



BackupCredential




UI Verification


Security


Credentials


Refresh




BackupCredential




******************************************************************************/

SELECT


name,


credential_identity


FROM sys.credentials;


GO






/*
===============================================================================
STEP 2 : CREATE SQL AGENT PROXY
===============================================================================


What is Proxy Account ?


Proxy allows SQL Server Agent


to execute tasks


using another security context.




Examples


SSIS Packages


PowerShell Scripts


CmdExec Commands




Equivalent UI


SQL Server Agent


Proxies


Right Click


New Proxy




Proxy Name


BackupProxy




Credential


BackupCredential




===============================================================================
*/


USE msdb;
GO



EXEC sp_add_proxy


@proxy_name='BackupProxy',


@credential_name='BackupCredential';

GO






/******************************************************************************
VERIFY PROXY


Expected Result



BackupProxy




******************************************************************************/

SELECT

name

FROM msdb.dbo.sysproxies;


GO






/*
===============================================================================
STEP 3 : UNDERSTANDING SUBSYSTEMS
===============================================================================


SQL Server Agent


supports multiple subsystems.




Common Values


2 = ActiveX Script


3 = CmdExec


11 = SSIS


12 = PowerShell




CmdExec


allows execution of


Operating System Commands.




===============================================================================
*/


EXEC sp_grant_proxy_to_subsystem


@proxy_name='BackupProxy',


@subsystem_id=3;

GO
/*
===============================================================================
STEP 4 : ENUMERATE PROXY SUBSYSTEM MAPPING
===============================================================================


What does this procedure do ?


sp_enum_proxy_for_subsystem


Displays all Proxy Accounts

that can execute jobs

for a specific subsystem.



Subsystem Used


3 = CmdExec



Equivalent SSMS UI


SQL Server Agent


Proxies


BackupProxy


Properties


Principals


Subsystems



===============================================================================
*/


EXEC sp_enum_proxy_for_subsystem

@subsystem_id=3;

GO




/******************************************************************************
VERIFY OUTPUT


Expected Result


proxy_name
-----------------

BackupProxy



subsystem_id
----------------

3



subsystem_name
----------------

CmdExec




******************************************************************************/




/*
===============================================================================
STEP 5 : VERIFY PROXY CONFIGURATION
===============================================================================


Catalog View


msdb.dbo.sysproxies



Contains


Proxy Name


Credential ID


Proxy ID




Equivalent UI


SQL Server Agent


Proxies


Refresh


BackupProxy




===============================================================================
*/


SELECT

proxy_id,

name,

credential_id

FROM msdb.dbo.sysproxies;

GO





/******************************************************************************
EXPECTED RESULT


proxy_id
-------------

1




name
-------------

BackupProxy




credential_id
----------------

65536




******************************************************************************/




/*
===============================================================================
STEP 6 : USING PROXY IN SQL SERVER AGENT JOBS
===============================================================================


Proxy Accounts are assigned


to Job Steps



Example


Job Step Type


Operating System (CmdExec)



Run As


BackupProxy




Equivalent UI


SQL Server Agent


Jobs


New Job


Steps


New



Type


Operating System (CmdExec)



Run As


BackupProxy




Command


DIR C:\




Example TSQL



EXEC sp_add_jobstep


@job_name='CmdJob',


@step_name='Directory Listing',


@subsystem='CMDEXEC',


@proxy_name='BackupProxy',


@command='DIR C:\';


GO




Note


This example is for demonstration


and is not executed in this lab.




===============================================================================
*/

GO






/*
===============================================================================
STEP 7 : BEST PRACTICES
===============================================================================


Use dedicated service accounts


for Credentials



Avoid using Administrator



Grant Proxy access


only to required subsystems



Rotate passwords regularly



Document Proxy usage



Review permissions periodically



Apply Least Privilege Principle




===============================================================================
*/

GO






/*
===============================================================================
STEP 8 : TROUBLESHOOTING
===============================================================================


Common Error


Credential identity does not exist




Cause


Windows account missing




Fix


Use existing account




Example


DOMAIN\SQLServiceAccount




------------------------------------------------------



Common Error


Proxy already exists




Fix



EXEC sp_delete_proxy


@proxy_name='BackupProxy';




------------------------------------------------------



Common Error


Access denied




Cause


Credential account lacks


Operating System permissions




Fix


Grant required NTFS rights




------------------------------------------------------



Common Error


SQL Server Agent not running




Fix


Start SQL Server Agent Service




Equivalent UI


SQL Server Configuration Manager


SQL Server Services


SQL Server Agent


Start




===============================================================================
*/

GO






/*
===============================================================================
STEP 9 : MINI LAB EXERCISES
===============================================================================


Exercise 1


Create another Credential



ETLCredential




Exercise 2


Create ETLProxy




Exercise 3


Grant access


to PowerShell subsystem




Subsystem ID


12




Exercise 4


Create Job Step


using ETLProxy




Exercise 5


Enumerate all proxies




Exercise 6


Delete Proxy




Exercise 7


Delete Credential




===============================================================================
*/

GO






/*
===============================================================================
STEP 10 : CLEANUP

Run only if cleanup is required


===============================================================================
*/


USE msdb;
GO


EXEC sp_delete_proxy


@proxy_name='BackupProxy';

GO





/******************************************************************************
VERIFY PROXY REMOVAL



Expected Result


No rows returned




******************************************************************************/

SELECT *

FROM msdb.dbo.sysproxies

WHERE name='BackupProxy';

GO






USE master;
GO


DROP CREDENTIAL BackupCredential;

GO





/******************************************************************************
VERIFY CREDENTIAL REMOVAL


Expected Result


No rows returned




UI Verification


Security


Credentials


Refresh




BackupCredential


disappears




******************************************************************************/

SELECT *

FROM sys.credentials

WHERE name='BackupCredential';

GO