/*
===============================================================================
MODULE 13 : MONITORING SQL SERVER

Topics Covered
1. Monitoring Activity
2. Capturing Performance Data
3. SQL Server Utility

Lab : Monitoring SQL Server
===============================================================================
*/

USE master;
GO


-- STEP 1

EXEC sp_who2;
GO


-- STEP 2

SELECT
session_id,

login_name,

host_name,

program_name

FROM sys.dm_exec_sessions;
GO


-- STEP 3

SELECT *

FROM sys.dm_exec_requests;
GO


-- STEP 4

SELECT *

FROM sys.dm_os_wait_stats;
GO


-- STEP 5

SELECT

cntr_value

FROM sys.dm_os_performance_counters

WHERE counter_name='User Connections';
GO



-- STEP 6

SELECT TOP 20

creation_time,

execution_count,

total_worker_time

FROM sys.dm_exec_query_stats
ORDER BY total_worker_time DESC;
GO