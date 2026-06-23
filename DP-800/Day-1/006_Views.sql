-- ============================================
-- Step 1: Create Base Tables
-- ============================================
CREATE TABLE Department (
    DeptID INT PRIMARY KEY,
    DeptName VARCHAR(50)
);

CREATE TABLE Employee (
    EmpID INT PRIMARY KEY,
    Name VARCHAR(100),
    Salary DECIMAL(10,2),
    DeptID INT,
    CONSTRAINT FK_Dept FOREIGN KEY (DeptID)
    REFERENCES Department(DeptID)
);

-- Insert Sample Data
INSERT INTO Department VALUES (1, 'IT'), (2, 'HR');

INSERT INTO Employee VALUES
(101, 'Vaibhav', 50000, 1),
(102, 'Niharika', 60000, 2),
(103, 'Rahul', 45000, 1);

SELECT * FROM Employee;



-- ============================================
-- Step 2: Create Basic View (Virtual Table)
-- ============================================
-- View = Stored SELECT query (no physical data storage)
CREATE VIEW VW_EmployeeDetails
AS
SELECT 
    EmpID,
    Name,
    Salary
FROM Employee;

-- ✔ Usage
SELECT * FROM VW_EmployeeDetails;



-- ============================================
-- Step 3: View as Security Layer
-- ============================================
-- Hide Salary column from users
CREATE VIEW VW_Employee_Public
AS
SELECT 
    EmpID,
    Name
FROM Employee;

-- ✔ Users can access limited data
SELECT * FROM VW_Employee_Public;



-- ============================================
-- Step 4: View with JOIN (Business Logic)
-- ============================================
CREATE VIEW VW_Employee_Department
AS
SELECT 
    E.EmpID,
    E.Name,
    D.DeptName
FROM Employee E
JOIN Department D
ON E.DeptID = D.DeptID;

SELECT * FROM VW_Employee_Department;



-- ============================================
-- Step 5: WITH CHECK OPTION
-- ============================================
-- Only allow IT department data through view
CREATE VIEW VW_IT_Employees
AS
SELECT *
FROM Employee
WHERE DeptID = 1
WITH CHECK OPTION;

-- ✔ Valid Insert
INSERT INTO VW_IT_Employees VALUES (104, 'Amit', 40000, 1);

-- ❌ Invalid Insert (DeptID != 1)
INSERT INTO VW_IT_Employees VALUES (105, 'TestUser', 30000, 2);
-- Error: violates CHECK OPTION (row not visible in view)



-- ============================================
-- Step 6: Explicit Columns vs SELECT *
-- ============================================
-- ❌ Bad Practice
CREATE VIEW VW_BadPractice
AS
SELECT * FROM Employee;

-- Problem:
-- If table structure changes → view may break

-- ✔ Good Practice
CREATE VIEW VW_GoodPractice
AS
SELECT EmpID, Name, Salary
FROM Employee;



-- ============================================
-- Step 7: Update Data via View
-- ============================================
-- ✔ Update through view (allowed if simple)
UPDATE VW_EmployeeDetails
SET Salary = 55000
WHERE EmpID = 101;

-- ❌ Complex view update may fail
-- (JOIN views are not always updatable)



-- ============================================
-- Step 8: Indexed View (Materialized View)
-- ============================================
-- Required settings
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;

-- Create view with SCHEMABINDING
CREATE VIEW VW_TotalSalary
WITH SCHEMABINDING
AS
SELECT 
    DeptID,
    COUNT_BIG(*) AS TotalEmployees,
    SUM(Salary) AS TotalSalary
FROM dbo.Employee
GROUP BY DeptID;

-- Create unique clustered index
CREATE UNIQUE CLUSTERED INDEX IX_VW_TotalSalary
ON VW_TotalSalary (DeptID);

-- ✔ Faster read performance
SELECT * FROM VW_TotalSalary;



-- ============================================
-- Step 9: Indexed View Trade-off
-- ============================================
-- ❗ Insert will be slower due to index maintenance

INSERT INTO Employee VALUES (106, 'NewUser', 70000, 1);

-- Explanation:
-- Write operations slower
-- Read operations faster (pre-aggregated data)



-- ============================================
-- Step 10: View Final Data
-- ============================================
SELECT * FROM VW_EmployeeDetails;
SELECT * FROM VW_Employee_Department;
SELECT * FROM VW_TotalSalary;



-- ============================================
-- Step 11: Cleanup
-- ============================================
DROP VIEW VW_TotalSalary;
DROP VIEW VW_IT_Employees;
DROP VIEW VW_Employee_Department;
DROP VIEW VW_Employee_Public;
DROP VIEW VW_EmployeeDetails;
DROP VIEW VW_GoodPractice;
DROP VIEW VW_BadPractice;

DROP TABLE Employee;
DROP TABLE Department;