CREATE TABLE EMPLOYEES(
EmpId INT,
EmpName VARCHAR(100),
Dept VARCHAR(50),
Salary INT
)
DROP TABLE IF EXISTS EMPLOYEES

INSERT INTO EMPLOYEES VALUES(1, 'Amit', 'HR', 40000),
(2, 'Priya', 'IT', 60000),
(3, 'Vikram', 'Finance', 55000),
(4, 'Sneha', 'IT', 62000),
(5, 'Rahul', 'HR', 45000);



DECLARE @EmpName VARCHAR(100), @Salary INT;

DECLARE static_cursor CURSOR FOR
SELECT EmpName, Salary FROM Employees;

OPEN static_cursor;

FETCH NEXT FROM static_cursor INTO @EmpName, @Salary;
WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT 'Employee: ' + @EmpName + ' | Bonus: ' + CAST(@Salary * 0.1 AS VARCHAR);
    FETCH NEXT FROM static_cursor INTO @EmpName, @Salary;
END

CLOSE static_cursor;
DEALLOCATE static_cursor;



-- DYNAMIC CURSOR

DECLARE @EmpName VARCHAR(100), @Salary INT;

DECLARE dynamic_cursor CURSOR DYNAMIC FOR
SELECT EmpName, Salary FROM Employees;

OPEN dynamic_cursor;

FETCH NEXT FROM dynamic_cursor INTO @EmpName, @Salary;
WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT 'Live Data - ' + @EmpName + ': ' + CAST(@Salary AS VARCHAR);
    FETCH NEXT FROM dynamic_cursor INTO @EmpName, @Salary;
END

CLOSE dynamic_cursor;
DEALLOCATE dynamic_cursor;






-- STORE Procedure
CREATE PROCEDURE uspGetEmployeeDetails
    @DeptId VARCHAR(50)
AS
BEGIN
    SELECT * FROM Employees WHERE Department = @DeptId;
END;

EXEC uspGetEmployeeDetails @DeptId = 'HR';


DROP PROCEDURE uspGetEmployeeDetails;
