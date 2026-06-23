-- Step 1: Create table with all major data types
CREATE TABLE Demo_DataTypes (
    -- Numeric
    ID INT PRIMARY KEY,
    BigNumber BIGINT,
    Price DECIMAL(10,2),
    Rating FLOAT,

    -- String
    Name VARCHAR(100),
    Description NVARCHAR(200),
    Code CHAR(5),

    -- Date/Time
    CreatedDate DATE,
    UpdatedDateTime DATETIME2,
    EventTime DATETIMEOFFSET,

    -- Binary
    FileData VARBINARY(MAX),

    -- Special
    UniqueID UNIQUEIDENTIFIER,
    XmlData XML,
    JsonData NVARCHAR(MAX)  -- JSON stored as NVARCHAR
);

-- Step 2: Insert realistic sample data
INSERT INTO Demo_DataTypes (
    ID, BigNumber, Price, Rating,
    Name, Description, Code,
    CreatedDate, UpdatedDateTime, EventTime,
    FileData,
    UniqueID, XmlData, JsonData
)
VALUES
(
    1,
    9876543210,
    1999.99,
    4.5,
    'Vaibhav',
    N'Data Engineer with Azure experience',
    'A1234',
    '2024-01-15',
    SYSDATETIME(),
    SYSDATETIMEOFFSET(),
    0x5465737442696E617279,  -- Binary sample
    NEWID(),
    '<Employee><Name>Vaibhav</Name><Role>Engineer</Role></Employee>',
    '{ "Name": "Vaibhav", "Role": "Data Engineer", "Experience": 2 }'
),
(
    2,
    1234567890,
    499.50,
    3.8,
    'Niharika',
    N'Data Analyst and Trainer',
    'B5678',
    '2023-11-10',
    SYSDATETIME(),
    SYSDATETIMEOFFSET(),
    0x42696E61727944617461,
    NEWID(),
    '<Employee><Name>Niharika</Name><Role>Analyst</Role></Employee>',
    '{ "Name": "Niharika", "Role": "Analyst", "Experience": 3 }'
);

---------------------------------------------------------------------------------------------------CHECK DATA FROM HERE------------
Select * from Demo_DataTypes
-- Step 1: Get column names and data types for Sales.SalesOrderDetail
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'
AND TABLE_NAME = 'Demo_DataTypes'
ORDER BY ORDINAL_POSITION;


---DROPPING Tables ----

Drop table Demo_DataTypes