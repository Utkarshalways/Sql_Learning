use practice

select * from sys.tables;

select * from customers

insert into customers values (4,'rohit','sharma','rohit.sh@intimetec.com',123456742,'mansarovar','IT',45000,'2023-02-01')

UPDATE customers SET salary = NULL where customer_id = 3

SELECT * from customers 
where salary is NULL

-- Using ISNULL
SELECT 
customer_id,
CONCAT (first_name,' ',last_name) as full_name,
department,
ISNULL(salary,10000) as salary
from customers


-- Using Coalesce 
DECLARE @baseSalary INT = 10000;
SELECT 
customer_id,
CONCAT (first_name,' ',last_name) as full_name,
department,
COALESCE(salary,@baseSalary,0) as salary
from customers
GO

-- Using Case Function

	
	SELECT 
	customer_id,
	CONCAT (first_name,' ',last_name) as full_name,
	department,
	CASE 
		WHEN salary is NULL THEN 10000
		ELSE salary
	END
	AS Salary,
	joiningDATE
	from customers;


-- Using Update KeyWord

UPDATE customers SET salary = 10000 WHERE salary is NULL