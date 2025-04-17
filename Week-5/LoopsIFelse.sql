SELECT * FROM sys.databases;
use week5Prac;

SELECT * FROM sys.tables;

SELECT * FROM Sales;
SELECT * FROM EMPLOYEES;

DECLARE @AvgVariable INT;
SELECT @AvgVariable	= AVG(amount) FROM Sales

IF @AvgVariable > 1000
 print 'HIGH sales Value'
ELSE 
 print 'NORMAL'


 DECLARE @i INT = 5;
 DECLARE @j INT;
 DECLARE @line VARCHAR(100)
 WHILE @i  > 0
 BEGIN 
	SET @line = ''
	SET @j = @i
	WHILE @j > 0 
	BEGIN 
		SET @line = @line + CAST(@j as VARCHAR)
		SET @j = @j - 1
	END
	PRINT @line
	SET @i = @i - 1;
END





BEGIN TRANSACTION;

INSERT INTO Sales VALUES ('utkarsh','March',12000)
INSERT INTO Sales VALUES ('utkarsh','March',12000)
INSERT INTO Sales VALUES ('utkarsh','March',12000)
INSERT INTO Sales VALUES ('utkarsh','March',12000)



SELECT * FROM Sales

ROLLBACK;
COMMIT;
SAVEPOINT;



-- Create demo table
CREATE TABLE BankAccounts (
    AccountID INT PRIMARY KEY,
    AccountHolder VARCHAR(50),
    Balance DECIMAL(10,2)
);

-- Insert test data
INSERT INTO BankAccounts VALUES
(1, 'Ravi', 5000),
(2, 'Amit', 3000);



BEGIN TRANSACTION;

BEGIN TRY
    -- Debit from Ravi
    UPDATE BankAccounts 
    SET Balance = Balance - 1000 
    WHERE AccountID = 1;

    UPDATE BankAccounts 
    SET Balance = Balance + 1000 
    WHERE AccountID = 2;

    COMMIT; -- If both succeed
    PRINT 'Transfer Successful';
END TRY
BEGIN CATCH
    ROLLBACK; -- Undo everything if any error occurs
    PRINT 'Transaction Failed';
END CATCH;

