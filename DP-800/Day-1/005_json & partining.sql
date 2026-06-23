-- ============================================
-- Step 1: Create Table with JSON Column
-- ============================================
CREATE TABLE Customer_Data (
    CustomerID INT PRIMARY KEY,

    CustomerName VARCHAR(100) NOT NULL,

    Preferences NVARCHAR(MAX),   -- JSON stored as NVARCHAR

    CreatedDate DATE             -- Used for partitioning
);



-- ============================================
-- Step 2: Insert Sample JSON Data
-- ============================================
INSERT INTO Customer_Data VALUES 
(1, 'Vaibhav', '{"Theme":"Dark","Language":"English"}', '2023-01-10'),
(2, 'Niharika', '{"Theme":"Light","Language":"Hindi"}', '2023-06-15'),
(3, 'Rahul', '{"Theme":"Dark","Language":"English"}', '2024-02-20');

SELECT * FROM Customer_Data;



-- ============================================
-- Step 3: JSON_VALUE and JSON_QUERY Usage
-- ============================================
-- Extract scalar value
SELECT 
    CustomerName,
    JSON_VALUE(Preferences, '$.Theme') AS Theme
FROM Customer_Data;

-- Extract JSON object/array
SELECT 
    CustomerName,
    JSON_QUERY(Preferences) AS FullJSON
FROM Customer_Data;



-- ============================================
-- Step 4: Enforce JSON Validation (CHECK)
-- ============================================
ALTER TABLE Customer_Data
ADD CONSTRAINT CHK_JSON_VALID
CHECK (ISJSON(Preferences) = 1);

-- ❌ Invalid JSON Insert
INSERT INTO Customer_Data VALUES 
(4, 'TestUser', 'Invalid_JSON', '2024-03-01');
-- Error: CHECK constraint failed



-- ============================================
-- Step 5: Enforce Required JSON Fields
-- ============================================
ALTER TABLE Customer_Data
ADD CONSTRAINT CHK_JSON_THEME
CHECK (JSON_VALUE(Preferences, '$.Theme') IS NOT NULL);

-- ❌ Missing Theme field
INSERT INTO Customer_Data VALUES 
(5, 'User2', '{"Language":"English"}', '2024-03-01');
-- Error: Required JSON field missing



-- ============================================
-- Step 6: Computed Column from JSON
-- ============================================
ALTER TABLE Customer_Data
ADD Theme AS JSON_VALUE(Preferences, '$.Theme');

-- Create index on computed column
CREATE NONCLUSTERED INDEX IX_Theme
ON Customer_Data (Theme);

-- ✔ Faster query using index
SELECT * 
FROM Customer_Data
WHERE Theme = 'Dark';



-- ============================================
-- Step 7: PARTITION FUNCTION
-- ============================================
-- Partition based on CreatedDate
-- Range RIGHT means boundary belongs to next partition

CREATE PARTITION FUNCTION PF_CustomerDate (DATE)
AS RANGE RIGHT FOR VALUES 
('2023-01-01', '2024-01-01');



-- ============================================
-- Step 8: PARTITION SCHEME
-- ============================================
-- Map partitions to filegroups (here using PRIMARY for simplicity)

CREATE PARTITION SCHEME PS_CustomerDate
AS PARTITION PF_CustomerDate
ALL TO ([PRIMARY]);



-- ============================================
-- Step 9: Create Partitioned Table
-- ============================================
CREATE TABLE Customer_Data_Partitioned (
    CustomerID INT,
    CustomerName VARCHAR(100),
    Preferences NVARCHAR(MAX),
    CreatedDate DATE
)
ON PS_CustomerDate (CreatedDate);



-- ============================================
-- Step 10: Insert Data into Partitions
-- ============================================
INSERT INTO Customer_Data_Partitioned VALUES
(1, 'A', '{"Theme":"Dark"}', '2022-12-01'),  -- Partition 1
(2, 'B', '{"Theme":"Light"}', '2023-05-01'), -- Partition 2
(3, 'C', '{"Theme":"Dark"}', '2024-02-01');  -- Partition 3



-- ============================================
-- Step 11: Partition Explanation
-- ============================================
-- Based on PF_CustomerDate:

-- Partition 1 → Dates <= 2023-01-01
-- Partition 2 → 2023-01-02 to 2024-01-01
-- Partition 3 → > 2024-01-01

-- SQL Server automatically routes rows based on CreatedDate



-- ============================================
-- Step 12: Partition Elimination (Performance)
-- ============================================
-- ✔ Only scans relevant partition
SELECT * 
FROM Customer_Data_Partitioned
WHERE CreatedDate = '2024-02-01';

-- Explanation:
-- Instead of scanning full table → only Partition 3 is scanned



-- ============================================
-- Step 13: When NOT to Use Partitioning
-- ============================================
-- ❗ Avoid if:
-- - Table is small
-- - No clear filtering column
-- - Queries don't use partition column



-- ============================================
-- Step 14: Cleanup
-- ============================================
DROP TABLE Customer_Data;
DROP TABLE Customer_Data_Partitioned;

DROP PARTITION SCHEME PS_CustomerDate;
DROP PARTITION FUNCTION PF_CustomerDate;