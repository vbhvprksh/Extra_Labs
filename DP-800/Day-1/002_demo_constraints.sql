-- ============================================
-- Step 1: Create SEQUENCE (Custom ID Generator)
-- ============================================
CREATE SEQUENCE Seq_EmpID
START WITH 1001
INCREMENT BY 1;


-- ============================================
-- Step 2: Create Department Table (Parent)
-- ============================================
CREATE TABLE Department_Master (
    DeptID INT PRIMARY KEY,                      -- PK: No duplicates, NOT NULL
    DeptName VARCHAR(50) UNIQUE                  -- UNIQUE: No duplicate department names
);

-- Valid Inserts
INSERT INTO Department_Master VALUES (1, 'IT');
INSERT INTO Department_Master VALUES (2, 'HR');
--- Check Table ---

Select * from Department_Master


-- ❌ Possible Violation:
INSERT INTO Department_Master VALUES (1, 'Finance');
-- Error: PRIMARY KEY violation (duplicate DeptID)

-- ❌ Possible Violation:
INSERT INTO Department_Master VALUES (3, 'IT');
-- Error: UNIQUE constraint violation (duplicate DeptName)



-- ============================================
-- Step 3: Create Employee Table (All Constraints)
-- ============================================
CREATE TABLE Employee_Master (
    EmpID INT PRIMARY KEY 
        DEFAULT NEXT VALUE FOR Seq_EmpID,       -- PK + SEQUENCE (auto ID)

    Name VARCHAR(100) NOT NULL,                -- NOT NULL constraint

    Email VARCHAR(100) UNIQUE,                 -- UNIQUE constraint

    Salary DECIMAL(10,2) 
        CHECK (Salary > 0),                    -- CHECK constraint

    DeptID INT,                                -- FK column

    CreatedDate DATETIME 
        DEFAULT GETDATE(),                     -- DEFAULT constraint

    CONSTRAINT FK_Dept FOREIGN KEY (DeptID)
    REFERENCES Department_Master(DeptID)       -- FOREIGN KEY
);



-- ============================================
-- Step 4: Valid Insert (All Good)
-- ============================================
INSERT INTO Employee_Master (Name, Email, Salary, DeptID)
VALUES ('Vaibhav', 'vaibhav@gmail.com', 50000, 1);

Select * from Employee_Master

-- ============================================
-- Step 5: PRIMARY KEY Violation
-- ============================================
-- ❌ Duplicate EmpID
INSERT INTO Employee_Master (EmpID, Name, Email, Salary, DeptID)
VALUES (1001, 'TestUser', 'test@gmail.com', 40000, 1);
-- Error: Cannot insert duplicate key (PRIMARY KEY violation)



-- ============================================
-- Step 6: UNIQUE Constraint Violation
-- ============================================
-- ❌ Duplicate Email
INSERT INTO Employee_Master (Name, Email, Salary, DeptID)
VALUES ('User2', 'vaibhav@gmail.com', 45000, 1);
-- Error: Duplicate value violates UNIQUE constraint



-- ============================================
-- Step 7: CHECK Constraint Violation
-- ============================================
-- ❌ Invalid Salary
INSERT INTO Employee_Master (Name, Email, Salary, DeptID)
VALUES ('User3', 'user3@gmail.com', -1000, 1);
-- Error: CHECK constraint failed (Salary > 0)



-- ============================================
-- Step 8: FOREIGN KEY Violation
-- ============================================
-- ❌ DeptID does not exist in Department_Master
INSERT INTO Employee_Master (Name, Email, Salary, DeptID)
VALUES ('User4', 'user4@gmail.com', 30000, 99);
-- Error: FOREIGN KEY constraint violation



-- ============================================
-- Step 9: NOT NULL Violation
-- ============================================
-- ❌ Name cannot be NULL
INSERT INTO Employee_Master (Name, Email, Salary, DeptID)
VALUES (NULL, 'user5@gmail.com', 30000, 1);
-- Error: Cannot insert NULL into NOT NULL column



-- ============================================
-- Step 10: DEFAULT Constraint Demo
-- ============================================
INSERT INTO Employee_Master (Name, Email, Salary, DeptID)
VALUES ('Niharika', 'niharika@gmail.com', 60000, 2);

-- ✔ EmpID auto-generated from SEQUENCE
-- ✔ CreatedDate auto-filled using GETDATE()



-- ============================================
-- Step 11: View Final Data
-- ============================================
SELECT * FROM Employee_Master;


----Dropping All Tables used above ---

Drop table Department_Master 
Drop table Employee_Master