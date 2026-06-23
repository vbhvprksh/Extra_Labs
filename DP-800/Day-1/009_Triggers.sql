-- ============================================
-- Step 1: Create Base Tables
-- ============================================
CREATE TABLE Employee_TRG (
    EmpID INT PRIMARY KEY,
    Name VARCHAR(100),
    Salary DECIMAL(10,2),
    DeptID INT
);

CREATE TABLE Audit_Log (
    LogID INT IDENTITY(1,1),
    EmpID INT,
    ActionType VARCHAR(50),
    ActionDate DATETIME DEFAULT GETDATE()
);

-- Insert Sample Data
INSERT INTO Employee_TRG VALUES
(101, 'Vaibhav', 50000, 1),
(102, 'Niharika', 60000, 2);

SELECT * FROM Employee_TRG;



-- ============================================
-- Step 2: AFTER INSERT Trigger
-- ============================================
-- Executes AFTER insert completes
CREATE TRIGGER TRG_AfterInsert
ON Employee_TRG
AFTER INSERT
AS
BEGIN
    INSERT INTO Audit_Log (EmpID, ActionType)
    SELECT EmpID, 'INSERT'
    FROM inserted;   -- pseudo table
END;

-- ✔ Test
INSERT INTO Employee_TRG VALUES (103, 'Rahul', 45000, 1);

SELECT * FROM Audit_Log;



-- ============================================
-- Step 3: AFTER UPDATE Trigger
-- ============================================
CREATE TRIGGER TRG_AfterUpdate
ON Employee_TRG
AFTER UPDATE
AS
BEGIN
    INSERT INTO Audit_Log (EmpID, ActionType)
    SELECT EmpID, 'UPDATE'
    FROM inserted;
END;

-- ✔ Test
UPDATE Employee_TRG
SET Salary = 55000
WHERE EmpID = 101;



-- ============================================
-- Step 4: AFTER DELETE Trigger
-- ============================================
CREATE TRIGGER TRG_AfterDelete
ON Employee_TRG
AFTER DELETE
AS
BEGIN
    INSERT INTO Audit_Log (EmpID, ActionType)
    SELECT EmpID, 'DELETE'
    FROM deleted;   -- old data
END;

-- ✔ Test
DELETE FROM Employee_TRG WHERE EmpID = 102;



-- ============================================
-- Step 5: INSERTED vs DELETED (Important)
-- ============================================
-- inserted → new data (INSERT/UPDATE)
-- deleted → old data (DELETE/UPDATE)

SELECT * FROM inserted; -- inside trigger only
SELECT * FROM deleted;  -- inside trigger only



-- ============================================
-- Step 6: INSTEAD OF Trigger
-- ============================================
-- Replaces actual operation
CREATE TABLE Employee_View_Table (
    EmpID INT,
    Name VARCHAR(100)
);

CREATE TRIGGER TRG_InsteadOfInsert
ON Employee_View_Table
INSTEAD OF INSERT
AS
BEGIN
    -- Custom logic
    INSERT INTO Employee_TRG (EmpID, Name, Salary, DeptID)
    SELECT EmpID, Name, 30000, 1
    FROM inserted;
END;

-- ✔ Test
INSERT INTO Employee_View_Table VALUES (104, 'Amit');

SELECT * FROM Employee_TRG;



-- ============================================
-- Step 7: UPDATE() Function (Column Check)
-- ============================================
CREATE TRIGGER TRG_CheckSalaryUpdate
ON Employee_TRG
AFTER UPDATE
AS
BEGIN
    IF UPDATE(Salary)
    BEGIN
        PRINT 'Salary column updated';
    END
END;

-- ✔ Test
UPDATE Employee_TRG
SET Salary = 70000
WHERE EmpID = 101;



-- ============================================
-- Step 8: DDL Trigger (Schema Level)
-- ============================================
-- Prevent table drop
CREATE TRIGGER TRG_PreventDrop
ON DATABASE
FOR DROP_TABLE
AS
BEGIN
    PRINT 'Table drop not allowed!';
    ROLLBACK;
END;

-- ❌ Test
DROP TABLE Employee_TRG;
-- Output: Table drop not allowed!



-- ============================================
-- Step 9: Trigger Best Practices
-- ============================================
-- ✔ Keep logic simple
-- ✔ Avoid heavy operations
-- ✔ Use triggers for auditing/validation
-- ❌ Avoid business logic overload



-- ============================================
-- Step 10: View Final Data
-- ============================================
SELECT * FROM Employee_TRG;
SELECT * FROM Audit_Log;



-- ============================================
-- Step 11: Cleanup
-- ============================================
DROP TRIGGER TRG_AfterInsert;
DROP TRIGGER TRG_AfterUpdate;
DROP TRIGGER TRG_AfterDelete;
DROP TRIGGER TRG_InsteadOfInsert;
DROP TRIGGER TRG_CheckSalaryUpdate;
DROP TRIGGER TRG_PreventDrop;

DROP TABLE Employee_View_Table;
DROP TABLE Audit_Log;
DROP TABLE Employee_TRG;