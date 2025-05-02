-- ============================================
-- Practical File: SQL Server Indexing Concepts
-- ============================================

-- ============================================
-- 1. SQL Server Pages (Conceptual Only)
-- ============================================
/*
In SQL Server, data is stored in 8 KB pages. Types include:
- Data Page: Stores table data rows.
- Index Page: Stores index rows.
- Text/Image Page: Stores LOB data like VARCHAR(MAX), TEXT, etc.
- GAM/SGAM Page: Track space allocation.
- IAM Page: Index Allocation Map – tracks extents.
- PFS Page: Page Free Space tracking.
*/

-- ============================================
-- 2. Setup Sample Database and Table
-- ============================================

-- Create a sample database
CREATE DATABASE IndexDemoDB;
GO

USE IndexDemoDB;
GO

-- Create a sample table
CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY, -- This will create a Clustered Index
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50),
    Department NVARCHAR(50),
    Salary INT
);
GO

-- Insert sample data
INSERT INTO Employees VALUES 
(1, 'Amit', 'Sharma', 'IT', 70000),
(2, 'Priya', 'Verma', 'HR', 65000),
(3, 'Ravi', 'Kumar', 'Finance', 72000),
(4, 'Neha', 'Singh', 'IT', 69000),
(5, 'Arjun', 'Mehta', 'Sales', 60000);
GO

-- ============================================
-- 3. What is Indexing?
-- ============================================
/*
Indexing is used to speed up retrieval of rows by using a pointer-based structure.
SQL Server supports different types of indexes:
- Clustered Index
- Non-Clustered Index
- Unique Index
- Filtered Index
- Columnstore Index
- Full-Text Index
*/

-- ============================================
-- 4. Clustered vs. Non-Clustered Index
-- ============================================

-- Clustered Index (already created on PRIMARY KEY = EmployeeID)
-- The table data is physically sorted based on this index.

-- Create a Non-Clustered Index on LastName column
CREATE NONCLUSTERED INDEX IDX_LastName
ON Employees(LastName);
GO

-- Query using the clustered index
SELECT * FROM Employees WHERE EmployeeID = 3;

-- Query using the non-clustered index
SELECT * FROM Employees WHERE LastName = 'Singh';

-- ============================================
-- 5. Additional Index Examples
-- ============================================

-- Unique Index (prevents duplicate entries)
CREATE UNIQUE INDEX IDX_Unique_Department_Salary
ON Employees(Department, Salary);
GO

-- Filtered Index (only on IT department)
CREATE NONCLUSTERED INDEX IDX_Filtered_IT
ON Employees(Department)
WHERE Department = 'IT';
GO

-- Drop indexes (if needed)
-- DROP INDEX IDX_LastName ON Employees;
-- DROP INDEX IDX_Filtered_IT ON Employees;

-- ============================================
-- 6. View Index Information
-- ============================================

-- View all indexes on the Employees table
EXEC sp_helpindex 'Employees';
GO

-- Use DMVs to check usage stats
SELECT 
    OBJECT_NAME(i.object_id) AS TableName,
    i.name AS IndexName,
    i.type_desc,
    user_seeks, user_scans, user_lookups, user_updates
FROM sys.dm_db_index_usage_stats AS s
JOIN sys.indexes AS i 
    ON i.index_id = s.index_id AND s.object_id = i.object_id
WHERE OBJECT_NAME(i.object_id) = 'Employees';
GO
