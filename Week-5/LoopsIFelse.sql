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


