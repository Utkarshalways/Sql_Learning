
use week5Prac;
SELECT * FROM Employees;

CREATE OR ALTER FUNCTION functionEmployee(@parameter_1 INT)
RETURNS VARCHAR(20)
AS 
BEGIN
	DECLARE @name VARCHAR(20)
	SELECT  @name =  NAME FROM Employees WHERE salary > @parameter_1
	return @name
END


SELECT dbo.functionEmployee(30000) 




CREATE OR ALTER FUNCTION dbo.functionEmployeereturnTable(@parameter_1 INT)
RETURNS TABLE 
AS 
	RETURN (
	SELECT  NAME FROM Employees WHERE salary > @parameter_1

	)


SELECT * from dbo.functionEmployeereturnTable(30000);


-- MTVF

