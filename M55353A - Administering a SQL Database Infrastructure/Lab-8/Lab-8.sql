/*
===============================================================================
MODULE 8 : AUTOMATING SQL SERVER MANAGEMENT

Topics Covered
1. SQL Server Agent
2. SQL Server Jobs
3. Scheduling Jobs
4. Multi Server Administration
===============================================================================
*/

USE msdb;
GO


/* STEP 1 */

EXEC sp_add_job

@job_name='DailyBackupJob';
GO



/* STEP 2 */

EXEC sp_add_jobstep

@job_name='DailyBackupJob',

@step_name='Backup Master',

@subsystem='TSQL',

@command='BACKUP DATABASE master
TO DISK=''C:\SQLBackups\master.bak''

WITH INIT';
GO




/* STEP 3 */

EXEC sp_add_schedule

@schedule_name='DailySchedule',

@freq_type=4,

@freq_interval=1,

@active_start_time=220000;
GO




/* STEP 4 */

EXEC sp_attach_schedule

@job_name='DailyBackupJob',

@schedule_name='DailySchedule';
GO




/* STEP 5 */

EXEC sp_add_jobserver

@job_name='DailyBackupJob';
GO




/* VERIFY */

SELECT name

FROM msdb.dbo.sysjobs

WHERE name='DailyBackupJob';
GO




/* STEP 6 */

EXEC msdb.dbo.sp_start_job

@job_name='DailyBackupJob';
GO




/* CLEANUP */

EXEC sp_delete_job

@job_name='DailyBackupJob';
GO