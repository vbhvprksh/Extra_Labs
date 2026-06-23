/* 
============================================================
⚠️ IDENTIFY & RESOLVE BLOCKING AND DEADLOCKS (SINGLE SCRIPT)
Covers:
1. Blocking Detection (DMVs)
2. Deadlock Simulation
3. Capture Deadlocks (Extended Events)
4. Resolution Techniques
============================================================
*/


/* 
============================================================
⚠️ 1. CREATE SAMPLE TABLE (FOR LOCKING SCENARIO)
============================================================
*/

-- Step 1: Create Table
CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100),
    Price DECIMAL(10,2)
);
GO

-- Step 2: Insert Sample Data
INSERT INTO Products VALUES
(1, 'Laptop', 80000),
(2, 'Mobile', 30000);
GO

SELECT * FROM Products;
GO



/* 
============================================================
⚠️ 2. BLOCKING DEMONSTRATION
- Run below queries in TWO DIFFERENT SESSIONS
============================================================
*/

-- Session A
BEGIN TRAN;

UPDATE Products 
SET Price = 85000 
WHERE ProductID = 1;

-- (Do NOT commit yet → holds exclusive lock)


-- Session B (will get blocked)
SELECT * FROM Products WHERE ProductID = 1;
GO



/* 
============================================================
⚠️ 3. IDENTIFY BLOCKING (DMVs)
- Find blocking chain and head blocker
============================================================
*/

SELECT 
    r.session_id,
    r.blocking_session_id,
    r.status,
    r.wait_type,
    r.wait_time,
    r.command,
    t.text AS QueryText
FROM sys.dm_exec_requests r
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) t
WHERE r.blocking_session_id <> 0;
GO



/* 
============================================================
⚠️ 4. RESOLVE BLOCKING
============================================================
*/

-- Option 1: Commit transaction (best practice)
COMMIT;
GO

-- Option 2: Kill blocking session (if required)
-- KILL <session_id>;
GO



/* 
============================================================
⚠️ 5. DEADLOCK DEMONSTRATION
- Run in TWO SESSIONS simultaneously
============================================================
*/

-- Session A
BEGIN TRAN;

UPDATE Products SET Price = 90000 WHERE ProductID = 1;

WAITFOR DELAY '00:00:05';

UPDATE Products SET Price = 35000 WHERE ProductID = 2;

COMMIT;
GO


-- Session B
BEGIN TRAN;

UPDATE Products SET Price = 35000 WHERE ProductID = 2;

WAITFOR DELAY '00:00:05';

UPDATE Products SET Price = 90000 WHERE ProductID = 1;

COMMIT;
GO



/* 
============================================================
⚠️ 6. CAPTURE DEADLOCK (EXTENDED EVENTS)
============================================================
*/

-- Step 1: Create Extended Event Session
CREATE EVENT SESSION Deadlock_Capture
ON SERVER
ADD EVENT sqlserver.xml_deadlock_report
ADD TARGET package0.ring_buffer;
GO

-- Step 2: Start Session
ALTER EVENT SESSION Deadlock_Capture
ON SERVER STATE = START;
GO

-- Step 3: View Deadlock Graph
SELECT 
    XEventData.XEvent.value('(event/data/value)[1]', 'XML') AS DeadlockGraph
FROM (
    SELECT CAST(target_data AS XML) AS TargetData
    FROM sys.dm_xe_sessions s
    JOIN sys.dm_xe_session_targets t
    ON s.address = t.event_session_address
    WHERE s.name = 'Deadlock_Capture'
) AS Data
CROSS APPLY TargetData.nodes('RingBufferTarget/event') AS XEventData(XEvent);
GO



/* 
============================================================
⚠️ 7. PREVENTION STRATEGIES
============================================================
*/

-- 1. Consistent Access Order (avoid circular dependency)
-- Always access tables in same sequence

-- 2. Keep Transactions Short
-- Commit early to release locks

-- 3. Enable Auto Rollback on Error
SET XACT_ABORT ON;
GO

-- 4. Retry Logic for Deadlock (Error 1205)
BEGIN TRY
    BEGIN TRAN;

    UPDATE Products SET Price = 95000 WHERE ProductID = 1;

    COMMIT;
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() = 1205
    BEGIN
        PRINT 'Deadlock detected. Retry transaction';
        ROLLBACK;
    END
END CATCH;
GO



/* 
============================================================
🧹 CLEANUP (MANDATORY)
============================================================
*/

-- Step 1: Stop Extended Event Session
ALTER EVENT SESSION Deadlock_Capture
ON SERVER STATE = STOP;
GO

-- Step 2: Drop Event Session
DROP EVENT SESSION Deadlock_Capture ON SERVER;
GO

-- Step 3: Drop Table
DROP TABLE Products;
GO