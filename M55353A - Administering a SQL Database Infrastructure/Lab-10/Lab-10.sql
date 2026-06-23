/*
===============================================================================
MODULE 10 : MONITORING SQL SERVER WITH ALERTS
AND NOTIFICATIONS
===============================================================================

Topics Covered

1. Monitoring Errors
2. Database Mail
3. Operators
4. Alerts
5. Notifications
6. Testing Alerts



Prerequisites


SQL Server Agent

must be running



Database Mail XPs

must be enabled



SMTP Server

must be accessible




Execute entire script as SysAdmin



===============================================================================
*/


USE master;
GO



/*
===============================================================================
STEP 1 : ENABLE DATABASE MAIL
===============================================================================


Database Mail


is used by SQL Server


to send email notifications.



Examples


Job Failures


Backup Failures


Alert Messages


Daily Reports




Equivalent SSMS UI


Management


Database Mail


Configure Database Mail




===============================================================================
*/


EXEC sp_configure

'show advanced options',

1;

GO


RECONFIGURE;
GO



EXEC sp_configure

'Database Mail XPs',

1;

GO


RECONFIGURE;

GO





/******************************************************************************
VERIFY CONFIGURATION


Expected Result



config_value


1




******************************************************************************/

SELECT

name,

value_in_use

FROM sys.configurations

WHERE name='Database Mail XPs';

GO






/*
===============================================================================
STEP 2 : CREATE DATABASE MAIL ACCOUNT
===============================================================================


Mail Account


stores


SMTP Server


Email Address


Display Name




Equivalent UI


Management


Database Mail


Manage Accounts


New Account




Account Name


LabMail




SMTP Server


smtp.company.com




===============================================================================
*/


USE msdb;
GO



EXEC sysmail_add_account_sp


@account_name='LabMail',


@email_address='dba@company.com',


@display_name='SQL Mail',


@mailserver_name='smtp.company.com';

GO






/******************************************************************************
VERIFY ACCOUNT



Expected Result


LabMail




******************************************************************************/

SELECT

name

FROM msdb.dbo.sysmail_account;

GO






/*
===============================================================================
STEP 3 : CREATE MAIL PROFILE
===============================================================================


Profile


is a collection


of Mail Accounts.




Multiple accounts


can belong


to one profile.




Equivalent UI


Management


Database Mail


Manage Profiles




Profile Name


LabProfile




===============================================================================
*/


EXEC sysmail_add_profile_sp


@profile_name='LabProfile';

GO






/******************************************************************************
VERIFY PROFILE


Expected Result


LabProfile




******************************************************************************/

SELECT

name

FROM msdb.dbo.sysmail_profile;

GO






/*
===============================================================================
STEP 4 : ASSOCIATE ACCOUNT TO PROFILE
===============================================================================


sequence_number


defines order


for mail delivery.




Equivalent UI


Database Mail


Profiles


LabProfile


Add Account




===============================================================================
*/


EXEC sysmail_add_profileaccount_sp


@profile_name='LabProfile',


@account_name='LabMail',


@sequence_number=1;

GO






/******************************************************************************
VERIFY ASSOCIATION



Expected Result



LabProfile


LabMail




******************************************************************************/

SELECT


p.name,


a.name


FROM msdb.dbo.sysmail_profile p


INNER JOIN msdb.dbo.sysmail_profileaccount pa


ON p.profile_id=pa.profile_id


INNER JOIN msdb.dbo.sysmail_account a


ON pa.account_id=a.account_id;

GO






/*
===============================================================================
STEP 5 : CREATE OPERATOR
===============================================================================


Operator


represents


DBA Team


Support Team


Administrator




Equivalent UI


SQL Server Agent


Operators


New Operator




Name


DBAOperator




Email


dba@company.com




===============================================================================
*/


EXEC sp_add_operator


@name='DBAOperator',


@email_address='dba@company.com';

GO





/******************************************************************************
VERIFY OPERATOR



Expected Result


DBAOperator




******************************************************************************/

SELECT *

FROM msdb.dbo.sysoperators;

GO






/*
===============================================================================
STEP 6 : CREATE ALERT
===============================================================================


Alert Type


Severity Based




Severity Level


17




Severity 17


Resource Problems




Examples


Insufficient Disk Space


Memory Errors




Equivalent UI


SQL Server Agent


Alerts


New Alert




Alert Name


Severity17Alert




Severity


17




===============================================================================
*/


EXEC sp_add_alert


@name='Severity17Alert',


@severity=17,


@enabled=1;

GO





/******************************************************************************
VERIFY ALERT



Expected Result


Severity17Alert




******************************************************************************/

SELECT *

FROM msdb.dbo.sysalerts;

GO
/*
===============================================================================
STEP 7 : ATTACH OPERATOR TO ALERT
===============================================================================


What is Notification?


Notifications tell SQL Server


who should be informed


when an Alert occurs.




Notification Methods


1 = Email


2 = Pager


4 = Net Send


7 = All Methods




Equivalent SSMS UI


SQL Server Agent


Alerts


Severity17Alert


Properties


Response


Notify Operators




Operator


DBAOperator




Method


Email




===============================================================================
*/


EXEC sp_add_notification


@alert_name='Severity17Alert',


@operator_name='DBAOperator',


@notification_method=1;

GO





/******************************************************************************
VERIFY NOTIFICATION


Expected Result



Severity17Alert



DBAOperator




******************************************************************************/

SELECT


a.name AS AlertName,


o.name AS OperatorName


FROM msdb.dbo.sysnotifications n


INNER JOIN msdb.dbo.sysalerts a


ON n.alert_id=a.id


INNER JOIN msdb.dbo.sysoperators o


ON n.operator_id=o.id;


GO







/*
===============================================================================
STEP 8 : VERIFY OPERATOR
===============================================================================


Catalog View


msdb.dbo.sysoperators




Contains


Operator Name


Email Address


Pager Information




Equivalent UI


SQL Server Agent


Operators


Refresh


DBAOperator




===============================================================================
*/


SELECT *

FROM msdb.dbo.sysoperators;

GO






/******************************************************************************
EXPECTED RESULT



name
----------------


DBAOperator




email_address
----------------


dba@company.com




******************************************************************************/




/*
===============================================================================
STEP 9 : VERIFY ALERT
===============================================================================


Catalog View


msdb.dbo.sysalerts




Contains


Alert Name


Severity


Enabled Status




Equivalent UI


SQL Server Agent


Alerts


Refresh




Severity17Alert




===============================================================================
*/


SELECT *

FROM msdb.dbo.sysalerts;

GO






/******************************************************************************
EXPECTED RESULT



name
----------------


Severity17Alert




severity
----------------


17




enabled
----------------


1




******************************************************************************/




/*
===============================================================================
STEP 10 : TEST ALERT
===============================================================================


RAISERROR


Generates


Custom SQL Errors




Severity Level


17




WITH LOG


writes message


to SQL Server Error Log




Equivalent UI


Management


SQL Server Logs




===============================================================================
*/


RAISERROR

(

'Test Alert',

17,

1

)

WITH LOG;

GO






/******************************************************************************
EXPECTED RESULT



Msg 50000


Level 17


State 1




Alert Fired




Operator notified




Email sent


(if SMTP configured correctly)




******************************************************************************/




/*
===============================================================================
STEP 11 : VERIFY DATABASE MAIL STATUS
===============================================================================


Database Mail Queue


stores outgoing messages




Catalog Views


sysmail_allitems


sysmail_sentitems


sysmail_faileditems




Equivalent UI


Management


Database Mail


View Database Mail Log




===============================================================================
*/


SELECT

sent_status,

subject,

recipients,

send_request_date

FROM msdb.dbo.sysmail_allitems;

GO






/******************************************************************************
EXPECTED RESULT



sent_status


sent




or




unsent




or




failed




******************************************************************************/




/*
===============================================================================
STEP 12 : BEST PRACTICES
===============================================================================


Enable Database Mail


only when required




Use Distribution Lists


instead of personal email ids




Monitor Mail Queue regularly




Create Alerts


for Severity 17 through 25




Use descriptive names




Periodically review


Operators




Document SMTP Settings




===============================================================================
*/

GO






/*
===============================================================================
STEP 13 : TROUBLESHOOTING
===============================================================================


Common Error


Database Mail XPs disabled




Fix



EXEC sp_configure


'Database Mail XPs',1;


RECONFIGURE;




----------------------------------------------------



Common Error


Mail not delivered




Cause


Incorrect SMTP Server




Fix


Use valid SMTP Server




Examples


smtp.gmail.com


smtp.office365.com




----------------------------------------------------



Common Error


SQL Server Agent not running




Fix


Start SQL Server Agent




----------------------------------------------------



Common Error


Alert never triggers




Cause


Severity mismatch




Fix


Verify severity level




Severity17Alert


listens only


for severity 17




===============================================================================
*/

GO







/*
===============================================================================
STEP 14 : MINI LAB EXERCISES
===============================================================================


Exercise 1


Create Severity20Alert




Exercise 2


Create another Operator




Exercise 3


Configure Gmail SMTP




Exercise 4


Send Test Email




Exercise 5


Create Job Failure Alert




Exercise 6


View Mail Queue




Exercise 7


Delete Alert




Exercise 8


Delete Operator




===============================================================================
*/

GO






/*
===============================================================================
STEP 15 : CLEANUP

Run only if cleanup is required


===============================================================================
*/


EXEC sp_delete_alert


@name='Severity17Alert';

GO




EXEC sp_delete_operator


@name='DBAOperator';

GO





/******************************************************************************

VERIFY CLEANUP


Expected Result


No rows returned




******************************************************************************/

SELECT *

FROM msdb.dbo.sysalerts

WHERE name='Severity17Alert';

GO



SELECT *

FROM msdb.dbo.sysoperators

WHERE name='DBAOperator';

GO






/******************************************************************************

UI Verification


SQL Server Agent


Alerts


Refresh




Severity17Alert


disappears




SQL Server Agent


Operators


Refresh




DBAOperator


disappears




******************************************************************************/

GO