-- ============================================
-- Step 1: In-Memory Table (Fast, RAM-based)
-- ============================================
-- Used for high-performance OLTP (no disk I/O, latch-free)

CREATE TABLE InMemory_Demo (
    ID INT PRIMARY KEY NONCLUSTERED,
    Name VARCHAR(50)
) WITH (MEMORY_OPTIMIZED = ON, DURABILITY = SCHEMA_AND_DATA);

-- Insert Sample Data
INSERT INTO InMemory_Demo VALUES (1, 'Vaibhav'), (2, 'Niharika');

-- Example:
-- Best for real-time systems like trading apps
-- Faster reads/writes compared to disk tables



-- ============================================
-- Step 2: Temporal Table (History Tracking)
-- ============================================
-- Automatically keeps history of changes (SCD Type 2)

CREATE TABLE Temporal_Demo (
    ID INT PRIMARY KEY,
    Name VARCHAR(50),
    ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START,
    ValidTo DATETIME2 GENERATED ALWAYS AS ROW END,
    PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo)
) 
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.Temporal_Demo_History));

-- Insert Data
INSERT INTO Temporal_Demo (ID, Name) VALUES (1, 'Vaibhav');

-- Update to create history
UPDATE Temporal_Demo SET Name = 'Vaibhav Updated' WHERE ID = 1;

-- Query History
SELECT * FROM Temporal_Demo
FOR SYSTEM_TIME ALL;

-- Example:
-- Track employee salary changes over time



-- ============================================
-- Step 3: External Table (Data Lake / ADLS)
-- ============================================
-- Reads data without storing in SQL Server

-- NOTE: Requires external data source setup (Fabric / Synapse)

CREATE EXTERNAL TABLE External_Demo (
    ID INT,
    Name VARCHAR(50)
)
WITH (
    LOCATION = '/data/sample/',
    DATA_SOURCE = MyDataSource,
    FILE_FORMAT = MyFileFormat
);

-- Query External Data
SELECT * FROM External_Demo;

-- Example:
-- Query CSV/Parquet files directly from Data Lake



-- ============================================
-- Step 4: Ledger Table (Immutable / Blockchain-like)
-- ============================================
-- Ensures tamper-proof data (auditing, compliance)

CREATE TABLE Ledger_Demo (
    ID INT PRIMARY KEY,
    Name VARCHAR(50)
)
WITH (LEDGER = ON);

-- Insert Data
INSERT INTO Ledger_Demo VALUES (1, 'Vaibhav');

-- Example:
-- Financial transactions where data must not be altered



-- ============================================
-- Step 5: Graph Table (Node & Edge)
-- ============================================
-- Used for relationship-based queries

-- Node Table
CREATE TABLE Person_Node (
    ID INT PRIMARY KEY,
    Name VARCHAR(50)
) AS NODE;

-- Edge Table
CREATE TABLE Friend_Edge AS EDGE;

-- Insert Nodes
INSERT INTO Person_Node VALUES (1, 'Vaibhav'), (2, 'Niharika');

-- Create Relationship
INSERT INTO Friend_Edge ($from_id, $to_id)
VALUES (
    (SELECT $node_id FROM Person_Node WHERE ID = 1),
    (SELECT $node_id FROM Person_Node WHERE ID = 2)
);

-- Query Relationship
SELECT *
FROM Person_Node p1, Friend_Edge f, Person_Node p2
WHERE MATCH(p1-(f)->p2);

-- Example:
-- Social network (who is connected to whom)



-- ============================================
-- FINAL SUMMARY
-- ============================================
-- In-Memory → Fast OLTP (RAM-based)
-- Temporal → Tracks history automatically
-- External → Query data lake without loading
-- Ledger → Immutable, tamper-proof data
-- Graph → Relationship-based queries