/*
===============================================================================
MODULE 10 : MONITORING SQL SERVER WITH ALERTS
AND NOTIFICATIONS

Topics Covered
1. Monitoring Errors
2. Database Mail
3. Operators
4. Alerts
===============================================================================
*/

USE msdb;
GO



/* STEP 1 */

EXEC sysmail_add_account_sp

@account_name='LabMail',

@email_address='dba@company.com',

@display_name='SQL Mail',

@mailserver_name='smtp.company.com';
GO




/* STEP 2 */

EXEC sysmail_add_profile_sp

@profile_name='LabProfile';
GO




/* STEP 3 */

EXEC sysmail_add_profileaccount_sp

@profile_name='LabProfile',

@account_name='LabMail',

@sequence_number=1;
GO




/* STEP 4 */

EXEC sp_add_operator

@name='DBAOperator',

@email_address='dba@company.com';
GO




/* STEP 5 */

EXEC sp_add_alert

@name='Severity17Alert',

@severity=17,

@enabled=1;
GO




/* STEP 6 */

EXEC sp_add_notification

@alert_name='Severity17Alert',

@operator_name='DBAOperator',

@notification_method=1;
GO




/* VERIFY */

SELECT *

FROM msdb.dbo.sysoperators;
GO



SELECT *

FROM msdb.dbo.sysalerts;
GO




/* TEST ALERT */

RAISERROR('Test Alert',

17,

1)

WITH LOG;
GO




/* CLEANUP */

EXEC sp_delete_alert

@name='Severity17Alert';
GO


EXEC sp_delete_operator

@name='DBAOperator';
GO