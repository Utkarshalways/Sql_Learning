-- Create a new database
CREATE DATABASE MyDatabase;
GO

-- Use the new database
USE MyDatabase;
GO

-- Create a table for demonstration
CREATE TABLE MyTable (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(50),
    Description VARCHAR(100)
);
GO

-- Insert some data into the table
INSERT INTO MyTable (Name, Description) VALUES
('Product1', 'This is product 1'),
('Product2', 'This is product 2'),
('Product3', 'This is product 3');
GO

-- Create logins
CREATE LOGIN AdminLogin WITH PASSWORD = 'admin@123';
CREATE LOGIN ReadOnlyLogin WITH PASSWORD = 'readonly@123';
CREATE LOGIN WriterLogin WITH PASSWORD = 'writer@123';
GO

-- Create users
CREATE USER AdminUser FOR LOGIN AdminLogin;
CREATE USER ReadOnlyUser FOR LOGIN ReadOnlyLogin;
CREATE USER WriterUser FOR LOGIN WriterLogin;
GO

-- Create roles
CREATE ROLE AdminRole;
CREATE ROLE ReadOnlyRole;
CREATE ROLE WriterRole;
GO

-- Assign roles to users
ALTER ROLE AdminRole ADD MEMBER AdminUser;
ALTER ROLE ReadOnlyRole ADD MEMBER ReadOnlyUser;
ALTER ROLE WriterRole ADD MEMBER WriterUser;
GO

-- Grant permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON MyTable TO AdminRole;
GRANT SELECT ON MyTable TO ReadOnlyRole;
GRANT SELECT, INSERT, UPDATE ON MyTable TO WriterRole;
GO

-- Test permissions
-- Switch to each user to test permissions
EXECUTE AS USER = 'AdminUser';
SELECT * FROM MyTable; -- Should work
INSERT INTO MyTable (Name, Description) VALUES ('Product4', 'This is product 4'); -- Should work
UPDATE MyTable SET Name = 'Product5' WHERE ID = 1; -- Should work
DELETE FROM MyTable WHERE ID = 1; -- Should work
REVERT;

EXECUTE AS USER = 'ReadOnlyUser';
SELECT * FROM MyTable; -- Should work
INSERT INTO MyTable (Name, Description) VALUES ('Product4', 'This is product 4'); -- Should fail
REVERT;

EXECUTE AS USER = 'WriterUser';
SELECT * FROM MyTable; -- Should work
INSERT INTO MyTable (Name, Description) VALUES ('Product4', 'This is product 4'); -- Should work
UPDATE MyTable SET Name = 'Product5' WHERE ID = 1; -- Should work
DELETE FROM MyTable WHERE ID = 1; -- Should fail
REVERT;
