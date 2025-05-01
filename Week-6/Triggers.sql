-- Drop tables if they exist
IF OBJECT_ID('dbo.Users', 'U') IS NOT NULL DROP TABLE dbo.Users;
IF OBJECT_ID('dbo.UserAudit', 'U') IS NOT NULL DROP TABLE dbo.UserAudit;

CREATE DATABASE week6prac;
USE week6Prac;

-- Create main Users table
CREATE TABLE Users (
    UserID INT IDENTITY PRIMARY KEY,
    Name VARCHAR(100),
    Email VARCHAR(100)
);

-- Create an audit table to track insertions
CREATE TABLE UserAudit (
    AuditID INT IDENTITY PRIMARY KEY,
    UserID INT,
    Name VARCHAR(100),
    Email VARCHAR(100),
    ActionType VARCHAR(50),
    ActionTime DATETIME
);

-- Create AFTER INSERT trigger on Users
CREATE TRIGGER trg_AfterInsert_Users
ON Users
AFTER INSERT
AS
BEGIN
    INSERT INTO UserAudit (UserID, Name, Email, ActionType, ActionTime)
    SELECT UserID, Name, Email, 'INSERT', GETDATE()
    FROM inserted;

    PRINT 'New user has been inserted and audit logged.';
END;



-- Create AFTER DELETE trigger on Users
CREATE TRIGGER trg_AfterDelete_Users
ON Users
AFTER DELETE
AS
BEGIN
    INSERT INTO UserAudit (UserID, Name, Email, ActionType, ActionTime)
    SELECT UserID, Name, Email, 'DELETE', GETDATE()
    FROM deleted;

    PRINT 'User deletion has been logged in audit.';
END;

-- Insert new users
INSERT INTO Users (Name, Email) VALUES ('Riya Sharma', 'riya@example.com');
INSERT INTO Users (Name, Email) VALUES ('Amit Patel', 'amit@example.com');

-- Delete one user
DELETE FROM Users WHERE Name = 'Amit Patel';

-- View Users
SELECT * FROM Users;

-- View Audit Log
SELECT * FROM UserAudit;

-- Question/Quiz Query: Who was deleted?
SELECT Name, ActionType, ActionTime
FROM UserAudit
WHERE ActionType = 'DELETE';
