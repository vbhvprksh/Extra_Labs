-- ============================================
-- Step 1: Create Base Table
-- ============================================
CREATE TABLE Employee_ERR (
    EmpID INT PRIMARY KEY,
    Name VARCHAR(100),
    Salary INT CHECK (Salary > 0)
);

-- Insert Sample Data
INSERT INTO Employee_ERR VALUES (1, 'Vaibhav', 50000);

SELECT * FROM Employee_ERR;



-- ============================================
-- Step 2: Basic TRY...CATCH
-- ============================================
BEGIN TRY
    -- ❌ This will fail (duplicate PK)
    INSERT INTO Employee_ERR VALUES (1, 'Duplicate', 40000);

END TRY

BEGIN CATCH
    PRINT 'Error occurred in TRY block';
END CATCH;

-- ✔ Control moves to CATCH when error happens



-- ============================================
-- Step 3: Error Details Functions
-- ============================================
BEGIN TRY
    -- ❌ Invalid insert (CHECK constraint)
    INSERT INTO Employee_ERR VALUES (2, 'Test', -100);

END TRY

BEGIN CATCH
    SELECT 
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_MESSAGE() AS ErrorMessage,
        ERROR_SEVERITY() AS Severity,
        ERROR_STATE() AS State,
        ERROR_LINE() AS LineNumber,
        ERROR_PROCEDURE() AS ProcedureName;
END CATCH;

-- ✔ Gives complete error diagnostics



-- ============================================
-- Step 4: Transactions with TRY...CATCH
-- ============================================
BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO Employee_ERR VALUES (3, 'Rahul', 30000);

    -- ❌ This will fail
    INSERT INTO Employee_ERR VALUES (3, 'Duplicate', 40000);

    COMMIT TRANSACTION;

END TRY

BEGIN CATCH
    -- Important: Check transaction before rollback
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT 'Transaction rolled back due to error';
END CATCH;

-- ✔ Ensures data consistency



-- ============================================
-- Step 5: THROW (Re-raise Error)
-- ============================================
BEGIN TRY
    -- ❌ Force error
    INSERT INTO Employee_ERR VALUES (4, 'Test', -500);

END TRY

BEGIN CATCH
    -- Re-throw same error
    THROW;
END CATCH;

-- ✔ Preserves original error info



-- ============================================
-- Step 6: Custom Error using THROW
-- ============================================
BEGIN TRY
    DECLARE @Salary INT = -100;

    IF @Salary < 0
        THROW 50001, 'Salary cannot be negative', 1;

END TRY

BEGIN CATCH
    SELECT ERROR_MESSAGE() AS CustomError;
END CATCH;

-- ✔ Custom business rule validation



-- ============================================
-- Step 7: XACT_ABORT (Auto Rollback)
-- ============================================
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO Employee_ERR VALUES (5, 'Amit', 20000);

    -- ❌ Error → auto rollback entire transaction
    INSERT INTO Employee_ERR VALUES (5, 'Duplicate', 30000);

    COMMIT TRANSACTION;

END TRY

BEGIN CATCH
    PRINT 'Auto rollback triggered due to XACT_ABORT';
END CATCH;

-- ✔ No need to manually rollback



-- ============================================
-- Step 8: Combined Best Practice Pattern
-- ============================================
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO Employee_ERR VALUES (6, 'Sneha', 45000);

    COMMIT TRANSACTION;

END TRY

BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    -- Log error details
    SELECT 
        ERROR_MESSAGE() AS ErrorMsg;

    THROW;  -- rethrow for debugging
END CATCH;

-- ✔ Industry standard pattern



-- ============================================
-- Step 9: View Final Data
-- ============================================
SELECT * FROM Employee_ERR;



-- ============================================
-- Step 10: Cleanup
-- ============================================
DROP TABLE Employee_ERR;