/*
===============================================================================
MODULE 12 : TRACING ACCESS TO SQL SERVER WITH EXTENDED EVENTS

Topics Covered
1. Extended Events Core Concepts
2. Working with Extended Events

Lab : Extended Events
===============================================================================
*/

USE master;
GO


-- STEP 1

CREATE EVENT SESSION PageSplitSession
ON SERVER

ADD EVENT sqlserver.page_split

ADD TARGET package0.event_file
(
SET filename='C:\XELogs\PageSplitSession.xel'
);
GO


-- STEP 2

ALTER EVENT SESSION PageSplitSession
ON SERVER
STATE=START;
GO


-- VERIFY

SELECT name
FROM sys.server_event_sessions;
GO


-- STEP 3

SELECT *
FROM sys.dm_xe_sessions;
GO


-- STEP 4

ALTER EVENT SESSION PageSplitSession
ON SERVER
STATE=STOP;
GO


-- STEP 5

DROP EVENT SESSION PageSplitSession
ON SERVER;
GO