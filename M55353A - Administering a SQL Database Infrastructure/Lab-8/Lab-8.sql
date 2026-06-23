/*
===============================================================================
MODULE 8 : AUTOMATING SQL SERVER MANAGEMENT
===============================================================================

Topics Covered

1. SQL Server Agent
2. SQL Server Jobs
3. Scheduling Jobs
4. Multi Server Administration
5. Job Categories
6. Job Execution
7. Job Monitoring


Execute entire script as SysAdmin


Prerequisites


SQL Server Agent Service

must be running.



To verify


SQL Server Configuration Manager


SQL Server Services


SQL Server Agent


Status


Running




Backup Folder


C:\SQLBackups\


SQL Server Service Account

should have Read and Write permissions



===============================================================================
*/


USE msdb;
GO



/*
===============================================================================
STEP 1 : UNDERSTANDING SQL SERVER AGENT
===============================================================================


SQL Server Agent


is a background Windows service


used for


Scheduled Backups


Maintenance Plans


ETL Jobs


Monitoring


Alerts




Equivalent SSMS UI


Object Explorer


SQL Server Agent


Expand




Green Arrow


Agent Running



Red Square


Agent Stopped



===============================================================================
*/


SELECT

servicename,

status_desc

FROM sys.dm_server_services

WHERE servicename LIKE '%Agent%';

GO





/*
===============================================================================
STEP 2 : CREATE SQL SERVER JOB
===============================================================================


Job Name


DailyBackupJob




Purpose


Backup Master Database


every night




Equivalent UI


SQL Server Agent


Jobs


Right Click


New Job



Name


DailyBackupJob




===============================================================================
*/


EXEC sp_add_job

@job_name='DailyBackupJob';

GO






/******************************************************************************
VERIFY JOB


Expected Result



DailyBackupJob




UI Verification


SQL Server Agent


Jobs


Refresh




DailyBackupJob




******************************************************************************/

SELECT

name

FROM msdb.dbo.sysjobs

WHERE name='DailyBackupJob';

GO






/*
===============================================================================
STEP 3 : ADD JOB STEP
===============================================================================


A Job consists of


one or more Steps.




Subsystem


TSQL




Command


BACKUP DATABASE




Equivalent UI


DailyBackupJob


Properties


Steps


New




Step Name


Backup Master




Type


Transact SQL Script




===============================================================================
*/


EXEC sp_add_jobstep


@job_name='DailyBackupJob',


@step_name='Backup Master',


@subsystem='TSQL',


@command='

BACKUP DATABASE master

TO DISK=''C:\SQLBackups\master.bak''


WITH INIT,

CHECKSUM,

STATS=10

';

GO





/******************************************************************************
VERIFY JOB STEP


Expected Result



Backup Master




******************************************************************************/

SELECT

step_name

FROM msdb.dbo.sysjobsteps

WHERE job_id=

(

SELECT job_id

FROM msdb.dbo.sysjobs

WHERE name='DailyBackupJob'

);

GO
/*
===============================================================================
STEP 4 : CREATE JOB SCHEDULE
===============================================================================


What is a Schedule ?


A Schedule determines


When a Job should execute.




SQL Server Agent supports


One Time Execution


Daily Jobs


Weekly Jobs


Monthly Jobs


CPU Idle Jobs




Schedule Details


Name


DailySchedule



Frequency


Daily



Time


22:00:00


(10 PM)




Equivalent SSMS UI


SQL Server Agent


Jobs


DailyBackupJob


Properties


Schedules


New




Schedule Name


DailySchedule



Occurs


Daily



Time


10:00 PM




===============================================================================
*/


EXEC sp_add_schedule


@schedule_name='DailySchedule',


@freq_type=4,


@freq_interval=1,


@active_start_time=220000;

GO






/******************************************************************************
VERIFY SCHEDULE


Expected Result



DailySchedule




******************************************************************************/

SELECT

name

FROM msdb.dbo.sysschedules

WHERE name='DailySchedule';

GO







/*
===============================================================================
STEP 5 : ATTACH SCHEDULE TO JOB
===============================================================================


A Job can have


Multiple Schedules.




A Schedule can also


be shared


among multiple jobs.




Equivalent UI


DailyBackupJob


Properties


Schedules


Select


DailySchedule




===============================================================================
*/


EXEC sp_attach_schedule


@job_name='DailyBackupJob',


@schedule_name='DailySchedule';

GO






/******************************************************************************
VERIFY ATTACHMENT


Expected Result



DailyBackupJob



DailySchedule




******************************************************************************/

SELECT


j.name AS JobName,


s.name AS ScheduleName


FROM msdb.dbo.sysjobs j


INNER JOIN msdb.dbo.sysjobschedules js


ON j.job_id=js.job_id


INNER JOIN msdb.dbo.sysschedules s


ON js.schedule_id=s.schedule_id


WHERE j.name='DailyBackupJob';

GO







/*
===============================================================================
STEP 6 : ASSIGN JOB TO SERVER
===============================================================================


Jobs execute


on SQL Server Agent.




sp_add_jobserver


binds job


to local server.




Equivalent UI


DailyBackupJob


Properties


Targets




Local Server




===============================================================================
*/


EXEC sp_add_jobserver


@job_name='DailyBackupJob';

GO






/******************************************************************************
VERIFY SERVER ASSOCIATION


Expected Result


DailyBackupJob


(Server Name)




******************************************************************************/

SELECT


j.name,


s.server_id


FROM msdb.dbo.sysjobs j


INNER JOIN msdb.dbo.sysjobservers s


ON j.job_id=s.job_id


WHERE j.name='DailyBackupJob';

GO







/*
===============================================================================
STEP 7 : VERIFY JOB EXISTS
===============================================================================


Expected Result



DailyBackupJob




UI Verification


SQL Server Agent


Jobs


Refresh




DailyBackupJob




===============================================================================
*/


SELECT

name

FROM msdb.dbo.sysjobs

WHERE name='DailyBackupJob';

GO







/*
===============================================================================
STEP 8 : START JOB MANUALLY
===============================================================================


Jobs can execute


Automatically


or


Manually.




Equivalent UI


SQL Server Agent


Jobs


DailyBackupJob


Right Click


Start Job




===============================================================================
*/


EXEC msdb.dbo.sp_start_job


@job_name='DailyBackupJob';

GO






/******************************************************************************
VERIFY JOB EXECUTION



Expected Result


Command completed successfully.




Backup File


master.bak


created




C:\SQLBackups\master.bak




******************************************************************************/




/*
===============================================================================
STEP 9 : VIEW JOB HISTORY
===============================================================================


Job History stores


Execution Date


Execution Time


Status


Messages




Equivalent UI


SQL Server Agent


Jobs


DailyBackupJob


View History




===============================================================================
*/


SELECT


j.name AS JobName,


h.run_date,


h.run_time,


h.run_status,


h.message


FROM msdb.dbo.sysjobs j


INNER JOIN msdb.dbo.sysjobhistory h


ON j.job_id=h.job_id


WHERE j.name='DailyBackupJob';


GO






/******************************************************************************
RUN STATUS VALUES



0 = Failed


1 = Succeeded


2 = Retry


3 = Canceled


4 = In Progress




******************************************************************************/




/*
===============================================================================
STEP 10 : BEST PRACTICES
===============================================================================


Use descriptive job names



Enable Job Notifications



Monitor Job Failures



Keep Backup Jobs


during non business hours



Use Operators


for email alerts



Document Schedules



Review Job History regularly




===============================================================================
*/

GO







/*
===============================================================================
STEP 11 : TROUBLESHOOTING
===============================================================================


Error


SQLServerAgent is not currently running




Cause


SQL Server Agent Service stopped




Fix


Start SQL Server Agent




---------------------------------------------------


Error


Cannot open backup device




Cause


Folder missing




Fix


Create



C:\SQLBackups\




---------------------------------------------------


Error


Access Denied




Cause


SQL Service lacks permissions




Fix


Grant Full Control




---------------------------------------------------


Error


Job Failed




Cause


Incorrect TSQL Command




Fix


Review Job History




===============================================================================
*/

GO








/*
===============================================================================
STEP 12 : MINI LAB EXERCISES
===============================================================================


Exercise 1


Create Weekly Schedule




Exercise 2


Backup tempdb




Exercise 3


Create Cleanup Job




Exercise 4


Create Job with


two steps




Exercise 5


Create Job Category




Exercise 6


View Job History




Exercise 7


Disable Job




===============================================================================
*/

GO








/*
===============================================================================
STEP 13 : CLEANUP

Run only if cleanup is required


===============================================================================
*/


EXEC sp_delete_job


@job_name='DailyBackupJob';

GO






/******************************************************************************
EXPECTED RESULT



DailyBackupJob


Removed




UI Verification


SQL Server Agent


Jobs


Refresh




DailyBackupJob


disappears




******************************************************************************/

GO