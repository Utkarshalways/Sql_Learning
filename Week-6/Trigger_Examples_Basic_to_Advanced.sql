
-- ===============================================
-- STEP 1: Drop tables and triggers if they exist
-- ===============================================
IF OBJECT_ID('dbo.Products', 'U') IS NOT NULL DROP TABLE dbo.Products;
IF OBJECT_ID('dbo.ProductAudit', 'U') IS NOT NULL DROP TABLE dbo.ProductAudit;
IF OBJECT_ID('dbo.trg_ProductInsert', 'TR') IS NOT NULL DROP TRIGGER dbo.trg_ProductInsert;
IF OBJECT_ID('dbo.trg_ProductUpdate', 'TR') IS NOT NULL DROP TRIGGER dbo.trg_ProductUpdate;

-- ===============================================
-- STEP 2: Basic Example - AFTER INSERT Trigger
-- ===============================================

-- Create a Products table
CREATE TABLE Products (
    ProductID INT IDENTITY PRIMARY KEY,
    ProductName VARCHAR(100),
    Price DECIMAL(10, 2)
);

-- Create a ProductAudit table
CREATE TABLE ProductAudit (
    AuditID INT IDENTITY PRIMARY KEY,
    ProductID INT,
    ProductName VARCHAR(100),
    Price DECIMAL(10,2),
    ActionType VARCHAR(50),
    ActionTime DATETIME
);

-- Create AFTER INSERT trigger
CREATE TRIGGER trg_ProductInsert
ON Products
AFTER INSERT
AS
BEGIN
    INSERT INTO ProductAudit (ProductID, ProductName, Price, ActionType, ActionTime)
    SELECT ProductID, ProductName, Price, 'INSERT', GETDATE()
    FROM inserted;
END;

-- Insert a new product
INSERT INTO Products (ProductName, Price) VALUES ('Gaming Mouse', 1299.99);

SELECT * FROM Products;
SELECT * FROM ProductAudit;

-- ===============================================
-- STEP 3: Intermediate - AFTER UPDATE Trigger
-- ===============================================

-- Create AFTER UPDATE trigger
CREATE TRIGGER trg_ProductUpdate
ON Products
AFTER UPDATE
AS
BEGIN
    INSERT INTO ProductAudit (ProductID, ProductName, Price, ActionType, ActionTime)
    SELECT ProductID, ProductName, Price, 'UPDATE', GETDATE()
    FROM inserted;
END;

-- Update a product
UPDATE Products SET Price = 999.99 WHERE ProductName = 'Gaming Mouse';

-- ===============================================
-- STEP 4: Advanced - Preventing Certain Deletions
-- ===============================================

-- Prevent deletion of high-value products
CREATE TRIGGER trg_PreventDelete
ON Products
INSTEAD OF DELETE
AS
BEGIN
    IF EXISTS (SELECT * FROM deleted WHERE Price > 1000)
    BEGIN
        RAISERROR('Deletion of high-value products is not allowed.', 16, 1);
        ROLLBACK;
    END
    ELSE
    BEGIN
        DELETE FROM Products WHERE ProductID IN (SELECT ProductID FROM deleted);
    END
END;

-- Try deleting a product (will fail if price > 1000)
DELETE FROM Products WHERE ProductName = 'Gaming Mouse';

-- ===============================================
-- STEP 5: Quiz Questions
-- ===============================================
-- Q1. What happens if you update a product?
-- Q2. Can a product be deleted if its price is above 1000?
-- Q3. What tables are affected when a product is inserted?
-- Q4. What is the purpose of the 'inserted' and 'deleted' magic tables?

-- ===============================================
-- STEP 6: Final Checks
-- ===============================================
-- View products and audit
SELECT * FROM Products;
SELECT * FROM ProductAudit;
