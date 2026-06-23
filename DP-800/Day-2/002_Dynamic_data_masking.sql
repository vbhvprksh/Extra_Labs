/* 
============================================================
🎭 DYNAMIC DATA MASKING IN SQL SERVER (SINGLE SCRIPT)
Covers:
- default()
- email()
- random()
- partial()
- UNMASK permission
============================================================
*/


/* 
============================================================
🎭 1. CREATE TABLE WITH MASKED COLUMNS
- Real data is stored but masked for unauthorized users
============================================================
*/

-- Step 1: Create Demo Table
CREATE TABLE Employee_Masked (
    ID INT PRIMARY KEY,

    -- SSN fully masked using default()
    SSN VARCHAR(20) MASKED WITH (FUNCTION = 'default()'),

    -- Email masking (shows first letter + domain)
    Email VARCHAR(100) MASKED WITH (FUNCTION = 'email()'),

    -- Salary masked with random range
    Salary DECIMAL(10,2) MASKED WITH (FUNCTION = 'random(10000, 100000)'),

    -- Phone masking (show first 3 and last 2 digits)
    Phone VARCHAR(20) MASKED WITH (FUNCTION = 'partial(3,"XXX-",2)')
);
GO


/* 
============================================================
🎭 2. INSERT REAL DATA (UNMASKED STORAGE)
- Actual values are stored in table
============================================================
*/

INSERT INTO Employee_Masked (ID, SSN, Email, Salary, Phone)
VALUES
(1, '478-23-9012', 'john.smith@contoso.com', 85000.00, '206-555-0189'),
(2, '589-11-2233', 'vaibhav.data@company.com', 92000.00, '987-654-3210');
GO


/* 
============================================================
🎭 3. VIEW DATA (MASKED OUTPUT)
- Normal users will see masked values
============================================================
*/

SELECT * FROM Employee_Masked;
GO


/* 
============================================================
🎭 4. CREATE USER WITHOUT UNMASK PERMISSION
- This user will see masked data
============================================================
*/

CREATE USER MaskedUser WITHOUT LOGIN;
GO

GRANT SELECT ON Employee_Masked TO MaskedUser;
GO

-- Execute as masked user
EXECUTE AS USER = 'MaskedUser';

SELECT * FROM Employee_Masked;
GO

REVERT;
GO


/* 
============================================================
🎭 5. GRANT UNMASK PERMISSION
- User can now see actual data
============================================================
*/

GRANT UNMASK TO MaskedUser;
GO

EXECUTE AS USER = 'MaskedUser';

SELECT * FROM Employee_Masked;
GO

REVERT;
GO


/* 
============================================================
🎭 6. COLUMN METADATA VALIDATION
- Check which columns are masked
============================================================
*/

SELECT 
    name AS Column_Name,
    is_masked,
    masking_function
FROM sys.masked_columns
WHERE OBJECT_NAME(object_id) = 'Employee_Masked';
GO



/* 
============================================================
🧹 CLEANUP (MANDATORY)
============================================================
*/

-- Step 1: Revoke Permissions
REVOKE UNMASK FROM MaskedUser;
GO

-- Step 2: Drop User
DROP USER MaskedUser;
GO

-- Step 3: Drop Table
DROP TABLE Employee_Masked;
GO