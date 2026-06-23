-- ============================================
-- Step 1: Create Base Table
-- ============================================
CREATE TABLE Employee_SP (
    EmpID INT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Salary DECIMAL(10,2) CHECK (Salary > 0),
    DeptID INT
);

-- Insert Sample Data
INSERT INTO Employee_SP VALUES
(101, 'Vaibhav', 50000, 1),
(102, 'Niharika', 60000, 2);

SELECT * FROM Employee_SP;



-- ============================================
-- Step 2: Create Stored Procedure (INPUT Params)
-- ============================================
-- Input Parameter Example
CREATE PROCEDURE GetEmployeeByDept
    @DeptID INT
AS
BEGIN
    SELECT EmpID, Name, Salary
    FROM Employee_SP
    WHERE DeptID = @DeptID;
END;

-- ✔ Execute (Named Parameter)
EXEC GetEmployeeByDept @DeptID = 1;

-- ✔ Execute (Positional Parameter)
EXEC GetEmployeeByDept 2;



-- ============================================
-- Step 3: Stored Procedure with OUTPUT Param
-- ============================================
CREATE PROCEDURE GetEmployeeCount
    @DeptID INT,
    @EmpCount INT OUTPUT
AS
BEGIN
    SELECT @EmpCount = COUNT(*)
    FROM Employee_SP
    WHERE DeptID = @DeptID;
END;

-- ✔ Execute OUTPUT
DECLARE @Result INT;

EXEC GetEmployeeCount 
    @DeptID = 1,
    @EmpCount = @Result OUTPUT;

SELECT @Result AS EmployeeCount;



-- ============================================
-- Step 4: INSERT Procedure with Validation
-- ============================================
CREATE PROCEDURE InsertEmployee
    @EmpID INT,
    @Name VARCHAR(100),
    @Salary DECIMAL(10,2),
    @DeptID INT
AS
BEGIN
    -- Validation (Best Practice: Fail Fast)
    IF @Name IS NULL OR @Salary <= 0
    BEGIN
        PRINT 'Invalid Input Data';
        RETURN;
    END;

    INSERT INTO Employee_SP
    VALUES (@EmpID, @Name, @Salary, @DeptID);
END;

-- ✔ Valid Insert
EXEC InsertEmployee 103, 'Rahul', 45000, 1;

-- ❌ Invalid Insert
EXEC InsertEmployee 104, NULL, -1000, 1;
-- Output: Invalid Input Data



-- ============================================
-- Step 5: Transactions + TRY CATCH
-- ============================================
CREATE PROCEDURE InsertEmployee_WithTransaction
    @EmpID INT,
    @Name VARCHAR(100),
    @Salary DECIMAL(10,2),
    @DeptID INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Employee_SP
        VALUES (@EmpID, @Name, @Salary, @DeptID);

        COMMIT TRANSACTION;
    END TRY

    BEGIN CATCH
        -- Rollback if error
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Error Info
        SELECT 
            ERROR_MESSAGE() AS ErrorMessage,
            ERROR_SEVERITY() AS Severity;
    END CATCH
END;

-- ✔ Valid Insert
EXEC InsertEmployee_WithTransaction 105, 'Amit', 40000, 2;

-- ❌ Error (Duplicate PK)
EXEC InsertEmployee_WithTransaction 101, 'Duplicate', 30000, 1;



-- ============================================
-- Step 6: Avoid SELECT * (Best Practice)
-- ============================================
-- ❌ Bad Practice
CREATE PROCEDURE BadProcedure
AS
BEGIN
    SELECT * FROM Employee_SP;
END;

-- ✔ Good Practice
CREATE PROCEDURE GoodProcedure
AS
BEGIN
    SELECT EmpID, Name, Salary
    FROM Employee_SP;
END;



-- ============================================
-- Step 7: Plan Caching Demo
-- ============================================
-- Stored procedures are compiled once and reused
EXEC GetEmployeeByDept 1;
EXEC GetEmployeeByDept 2;

-- Explanation:
-- Execution plan reused → better performance



-- ============================================
-- Step 8: Error Handling Demo
-- ============================================
-- ❌ Insert invalid salary (CHECK constraint)
EXEC InsertEmployee_WithTransaction 106, 'TestUser', -500, 1;

-- Output:
-- Error message returned via CATCH block



-- ============================================
-- Step 9: View Final Data
-- ============================================
SELECT * FROM Employee_SP;



-- ============================================
-- Step 10: Cleanup
-- ============================================
DROP PROCEDURE GetEmployeeByDept;
DROP PROCEDURE GetEmployeeCount;
DROP PROCEDURE InsertEmployee;
DROP PROCEDURE InsertEmployee_WithTransaction;
DROP PROCEDURE BadProcedure;
DROP PROCEDURE GoodProcedure;

DROP TABLE Employee_SP;