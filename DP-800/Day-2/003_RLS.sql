/* 
============================================================
🔐 ROW-LEVEL SECURITY (RLS) IN SQL SERVER (SINGLE SCRIPT)
Covers:
- Filter Predicate (Row filtering for SELECT)
- Block Predicate (Restrict INSERT/UPDATE/DELETE)
- SESSION_CONTEXT (Multi-tenant filtering)
============================================================
*/


/* 
============================================================
🔐 1. CREATE SAMPLE TABLE (MULTI-TENANT DATA)
- Same table shared across multiple tenants
============================================================
*/

-- Step 1: Create Orders Table
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    TenantID VARCHAR(50),
    Customer VARCHAR(100),
    Amount DECIMAL(10,2)
);
GO

-- Step 2: Insert Sample Data (Multiple Tenants)
INSERT INTO Orders (OrderID, TenantID, Customer, Amount)
VALUES
(1001, 'TenantA', 'Contoso', 4200),
(1002, 'TenantB', 'Northwind', 3100),
(1003, 'TenantC', 'AdventureWorks', 7300),
(1004, 'TenantA', 'Fabrikam', 2800),
(1005, 'TenantB', 'Litware', 5600),
(1006, 'TenantC', 'Tailspin', 1900);
GO

-- Step 3: Validate Data
SELECT * FROM Orders;
GO



/* 
============================================================
🔐 2. CREATE INLINE TABLE-VALUED FUNCTION (FILTER PREDICATE)
- Returns 1 only for rows user is allowed to see
- Uses SESSION_CONTEXT for dynamic filtering
============================================================
*/

CREATE FUNCTION fn_RLS_Filter(@TenantID AS VARCHAR(50))
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
(
    SELECT 1 AS fn_result
    WHERE @TenantID = CAST(SESSION_CONTEXT(N'TenantID') AS VARCHAR(50))
);
GO



/* 
============================================================
🔐 3. CREATE SECURITY POLICY (FILTER PREDICATE)
- Automatically filters rows during SELECT
============================================================
*/

CREATE SECURITY POLICY RLS_Filter_Policy
ADD FILTER PREDICATE dbo.fn_RLS_Filter(TenantID)
ON dbo.Orders
WITH (STATE = ON);
GO



/* 
============================================================
🔐 4. TEST FILTER PREDICATE (MULTI-TENANT VIEW)
============================================================
*/

-- Set Tenant A context
EXEC sp_set_session_context @key = N'TenantID', @value = 'TenantA';

SELECT * FROM Orders;  -- Only TenantA rows visible
GO

-- Set Tenant B context
EXEC sp_set_session_context @key = N'TenantID', @value = 'TenantB';

SELECT * FROM Orders;  -- Only TenantB rows visible
GO



/* 
============================================================
🔐 5. CREATE BLOCK PREDICATE FUNCTION
- Prevent unauthorized INSERT/UPDATE/DELETE
============================================================
*/

CREATE FUNCTION fn_RLS_Block(@TenantID AS VARCHAR(50))
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
(
    SELECT 1 AS fn_result
    WHERE @TenantID = CAST(SESSION_CONTEXT(N'TenantID') AS VARCHAR(50))
);
GO



/* 
============================================================
🔐 6. ALTER SECURITY POLICY (ADD BLOCK PREDICATE)
- Prevents invalid data modification
============================================================
*/

ALTER SECURITY POLICY RLS_Filter_Policy
ADD BLOCK PREDICATE dbo.fn_RLS_Block(TenantID)
ON dbo.Orders
AFTER INSERT, UPDATE;
GO



/* 
============================================================
🔐 7. TEST BLOCK PREDICATE
============================================================
*/

-- Set Tenant A
EXEC sp_set_session_context @key = N'TenantID', @value = 'TenantA';

-- Valid Insert (allowed)
INSERT INTO Orders VALUES (2001, 'TenantA', 'NewCustomer', 5000);
GO

-- Invalid Insert (blocked)
INSERT INTO Orders VALUES (2002, 'TenantB', 'HackAttempt', 9000);
GO



/* 
============================================================
🔐 8. VALIDATE FINAL DATA
============================================================
*/

SELECT * FROM Orders;
GO



/* 
============================================================
🧹 CLEANUP (MANDATORY)
============================================================
*/

-- Step 1: Disable Security Policy
ALTER SECURITY POLICY RLS_Filter_Policy
WITH (STATE = OFF);
GO

-- Step 2: Drop Security Policy
DROP SECURITY POLICY RLS_Filter_Policy;
GO

-- Step 3: Drop Functions
DROP FUNCTION fn_RLS_Filter;
GO

DROP FUNCTION fn_RLS_Block;
GO

-- Step 4: Drop Table
DROP TABLE Orders;
GO