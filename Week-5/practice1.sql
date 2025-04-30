CREATE PROCEDURE CountDown
    @Number INT
AS
BEGIN
    IF @Number > 0
    BEGIN
        PRINT @Number;
		SET @Number = @Number - 1;
        EXEC CountDown @Number;
    END
END
 

 EXEC CountDown @Number = 9


 CREATE OR ALTER  PROCEDURE loopTo 
 @num INT 
 AS
 BEGIN 
	WHILE @num <= 5 
	BEGIN 
	PRINT @num
	SET @num = @num + 1
	END
END 

EXEC loopto @num = 1


use week5Prac;

SELECT * FROM Employees;


DECLARE c CURSOR FOR 
SELECT salary FROM Employees

OPEN c;

DECLARE @salary INT
FETCH NEXT FROM c INTO @salary 
WHILE @@FETCH_STATUS = 0 
BEGIN 
	IF @salary < 50000 
	BEGIN  
		DECLARE @updatedSalary INT = @salary  + (@salary * 0.5);
		PRINT @updateSalary
	END
	ELSE 
		PRINT @salary

	FETCH NEXT FROM c INTO @salary 
END 

CLOSE c
DEALLOCATE c