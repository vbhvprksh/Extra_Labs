-- ============================================
-- Step 1: Create Base Table (Employee Hierarchy)
-- ============================================
CREATE TABLE Employees_CTE (
    EmployeeID INT PRIMARY KEY,
    Name VARCHAR(100),
    ManagerID INT NULL
);

-- Insert Hierarchy Data (Org Chart)
INSERT INTO Employees_CTE VALUES
(1, 'CEO', NULL),
(2, 'VP Eng', 1),
(3, 'VP Mkt', 1),
(4, 'VP Sales', 1),
(5, 'Dev Lead', 2),
(6, 'QA Lead', 3);

SELECT * FROM Employees_CTE;



-- ============================================
-- Step 2: Non-Recursive CTE
-- ============================================
-- Used for simplifying complex queries
WITH CTE_Employees AS (
    SELECT EmployeeID, Name
    FROM Employees_CTE
    WHERE ManagerID = 1
)
SELECT * FROM CTE_Employees;

-- ✔ Simplifies subqueries / joins



-- ============================================
-- Step 3: Multiple CTEs
-- ============================================
WITH CTE_Level1 AS (
    SELECT * FROM Employees_CTE WHERE ManagerID = 1
),
CTE_Level2 AS (
    SELECT E.*
    FROM Employees_CTE E
    JOIN CTE_Level1 L
        ON E.ManagerID = L.EmployeeID
)
SELECT * FROM CTE_Level2;

-- ✔ Later CTEs can reference earlier ones



-- ============================================
-- Step 4: Recursive CTE (Hierarchy Traversal)
-- ============================================
-- Structure: Anchor + UNION ALL + Recursive Part

WITH OrgChart AS (

    -- 🔹 Anchor Query (Level 0)
    SELECT 
        EmployeeID,
        Name,
        ManagerID,
        0 AS Level
    FROM Employees_CTE
    WHERE ManagerID IS NULL

    UNION ALL

    -- 🔹 Recursive Member
    SELECT 
        E.EmployeeID,
        E.Name,
        E.ManagerID,
        OC.Level + 1
    FROM Employees_CTE E
    JOIN OrgChart OC
        ON E.ManagerID = OC.EmployeeID
)

SELECT * FROM OrgChart;

-- ✔ Output:
-- Level 0 → CEO
-- Level 1 → VP Eng, VP Mkt, VP Sales
-- Level 2 → Dev Lead, QA Lead



-- ============================================
-- Step 5: Recursion Working (Concept)
-- ============================================
-- Pass 1 → CEO
-- Pass 2 → VP level
-- Pass 3 → Leads
-- Stops when no more rows



-- ============================================
-- Step 6: Sequence Generation using CTE
-- ============================================
-- Generate numbers from 1 to 5

WITH Numbers AS (
    SELECT 1 AS Num
    UNION ALL
    SELECT Num + 1
    FROM Numbers
    WHERE Num < 5
)
SELECT * FROM Numbers;

-- ✔ Useful for date ranges, loops



-- ============================================
-- Step 7: Recursive CTE Limitation
-- ============================================
-- Default max recursion = 100

-- Override using OPTION
WITH Numbers AS (
    SELECT 1 AS Num
    UNION ALL
    SELECT Num + 1
    FROM Numbers
    WHERE Num < 200
)
SELECT * FROM Numbers
OPTION (MAXRECURSION 200);



-- ============================================
-- Step 8: CTE vs Temp Table
-- ============================================
-- CTE:
-- ✔ Readable
-- ✔ No storage
-- ❌ Not reusable across queries

-- Temp Table:
-- ✔ Reusable
-- ✔ Indexed
-- ❌ More overhead



-- ============================================
-- Step 9: View Final Data
-- ============================================
SELECT * FROM Employees_CTE;



-- ============================================
-- Step 10: Cleanup
-- ============================================
DROP TABLE Employees_CTE;