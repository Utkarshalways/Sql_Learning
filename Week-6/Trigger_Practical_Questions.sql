
-- Question 1:
-- Suppose you want to log deleted rows from the 'Employees' table into 'Employees_Deleted_Log'.
-- What type of trigger will you use?
-- A) AFTER INSERT
-- B) AFTER DELETE
-- C) INSTEAD OF UPDATE
-- D) BEFORE INSERT

-- Practical Test:
CREATE TABLE Employees (
    EmpID INT PRIMARY KEY,
    Name VARCHAR(50),
    Department VARCHAR(50)
);

CREATE TABLE Employees_Deleted_Log (
    EmpID INT,
    Name VARCHAR(50),
    Department VARCHAR(50),
    DeletedAt DATETIME DEFAULT GETDATE()
);

CREATE TRIGGER trg_AfterDelete_Employees
ON Employees
AFTER DELETE
AS
BEGIN
    INSERT INTO Employees_Deleted_Log (EmpID, Name, Department)
    SELECT EmpID, Name, Department FROM DELETED;
END;

-- Insert and delete for testing
INSERT INTO Employees VALUES (101, 'John Doe', 'IT');
DELETE FROM Employees WHERE EmpID = 101;

SELECT * FROM Employees_Deleted_Log;



-- Question:
-- What will happen if a trigger contains a syntax error?
-- A) It will not be created
-- B) It will be created but not fire
-- C) It will be ignored during runtime
-- D) It will rollback immediately


CREATE TABLE SecureTable (
    ID INT PRIMARY KEY,
    Data VARCHAR(100)
);

CREATE TRIGGER trg_PreventDelete_SecureTable
ON SecureTable
INSTEAD OF DELETE
AS
BEGIN
    PRINT 'Deletion is not allowed on SecureTable.';
END;

INSERT INTO SecureTable VALUES (1, 'Sensitive Data');
DELETE FROM SecureTable WHERE ID = 1;



-- Question 4:
-- Which table is used to access the new inserted values in a trigger?
-- A) MODIFIED
-- B) INSERTED
-- C) NEW
-- D) CREATED

-- Practical Test:
CREATE TABLE AuditLog (
    EmpID INT,
    ChangeType VARCHAR(10),
    ChangeDate DATETIME DEFAULT GETDATE()
);

CREATE TRIGGER trg_LogInsert
ON Employees
AFTER INSERT
AS
BEGIN
    INSERT INTO AuditLog (EmpID, ChangeType)
    SELECT EmpID, 'INSERT' FROM INSERTED;
END;

-- Test Insert
INSERT INTO Employees VALUES (102, 'Jane Smith', 'HR');

SELECT * FROM AuditLog;

-- Clean Up (Optional)
-- DROP TABLE AuditLog, Employees_Deleted_Log, SecureTable, Employees;
-- DROP TRIGGER trg_AfterDelete_Employees, trg_PreventDelete_SecureTable, trg_LogInsert;




