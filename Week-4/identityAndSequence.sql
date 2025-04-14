-- File: identity_sequence_examples.sql

-- =============================
-- SECTION 1: IDENTITY EXAMPLE
-- =============================

-- Drop table if it already exists
IF OBJECT_ID('dbo.IdentityExample', 'U') IS NOT NULL
    DROP TABLE dbo.IdentityExample;

-- Create a table with IDENTITY column
CREATE TABLE dbo.IdentityExample (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(100)
);

-- Insert rows into the table
INSERT INTO dbo.IdentityExample (name) VALUES ('Alice');
INSERT INTO dbo.IdentityExample (name) VALUES ('Bob');
INSERT INTO dbo.IdentityExample (name) VALUES ('Charlie');

-- View the data
SELECT * FROM dbo.IdentityExample;

-- Try to insert value into the identity column manually (will fail unless SET IDENTITY_INSERT is ON)
-- This will throw an error:
-- INSERT INTO dbo.IdentityExample (id, name) VALUES (10, 'Manual ID');

-- Correct way (if needed): Temporarily enable identity insert
SET IDENTITY_INSERT dbo.IdentityExample ON;
INSERT INTO dbo.IdentityExample (id, name) VALUES (10, 'Manual ID');
SET IDENTITY_INSERT dbo.IdentityExample OFF;

-- View updated data
SELECT * FROM dbo.IdentityExample;


-- =============================
-- SECTION 2: SEQUENCE EXAMPLE
-- =============================

-- Drop sequence if it already exists
IF OBJECT_ID('dbo.seq_invoice_number', 'SO') IS NOT NULL
    DROP SEQUENCE dbo.seq_invoice_number;

-- Create a sequence object
CREATE SEQUENCE dbo.seq_invoice_number
    START WITH 1000
    INCREMENT BY 1;

-- Check next value from sequence
SELECT NEXT VALUE FOR dbo.seq_invoice_number AS NextInvoice;

-- Create another table that uses the sequence
IF OBJECT_ID('dbo.Invoice', 'U') IS NOT NULL
    DROP TABLE dbo.Invoice;

CREATE TABLE dbo.Invoice (
    invoice_no INT PRIMARY KEY DEFAULT NEXT VALUE FOR dbo.seq_invoice_number,
    customer_name VARCHAR(100),
    amount DECIMAL(10,2)
);

-- Insert using default (sequence auto-generates)
INSERT INTO dbo.Invoice (customer_name, amount) VALUES ('Amazon', 2500.00);
INSERT INTO dbo.Invoice (customer_name, amount) VALUES ('Flipkart', 1800.00);

-- Insert with manual override (not recommended unless identity/sequence logic is not needed)
-- INSERT INTO dbo.Invoice (invoice_no, customer_name, amount) VALUES (999, 'Manual Corp', 1000.00);

-- View the invoice table
SELECT * FROM dbo.Invoice;


-- =============================
-- SECTION 3: BONUS — Resetting Identity or Sequence
-- =============================

-- Reset identity seed (use with caution)
-- DBCC CHECKIDENT ('dbo.IdentityExample', RESEED, 1);

-- Restart sequence from specific number
-- ALTER SEQUENCE dbo.seq_invoice_number RESTART WITH 2000;

-- =============================
-- End of Script
-- =============================
