
--RETURN VALUE IN STORED PROCEDURE 

select * from Employees

CREATE PROCEDURE spCountTotalEmp
AS
BEGIN
	return (select count(*) from employees)
END

DECLARE @totalCount INT
EXEC @totalCount = spCountTotalEmp 
PRINT @totalCount

DROP Procedure spCountTotalEmp

--Question : What will the given stored procedure return


CREATE PROCEDURE spEmpNameById
@Id int
AS
BEGIN
	return (select [Name] from employees where Id = @Id)
END

DECLARE @empName varchar(MAX)
EXEC @empName = spEmpNameById 1
PRINT @empName



DROP PROCEDURE spEmpNameById

DROP PROCEDURE [dbo].[spEmpCountByGender]

DROP PROCEDURE [dbo].[spEmpSalary]



create table ##temptbl
(
	id int,
	name varchar(20)
);
insert into ##temptbl values(
1,'Utkarsh'),
(2,'Sumit')

select * from ##temptbl

DECLARE @tblVar TABLE(
	varInt int,
	varFloat float
)
INSERT INTO @tblVar Values(1,2.0),(12,3.1)
select * from @tblVar
 