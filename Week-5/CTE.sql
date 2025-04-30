
DROP TABLE IF EXISTS Employees;

CREATE TABLE Employees (
    id INT PRIMARY KEY,
    name VARCHAR(50),
    salary INT,
    manager_id INT
);


SELECT * FROM Employees

INSERT INTO Employees (id, name, salary, manager_id) VALUES
(1, 'Raj', 70000, NULL),
(2, 'Simran', 65000, 1),
(3, 'Aman', 50000, 1),
(4, 'Priya', 45000, 2),
(5, 'Arjun', 60000, 2),
(6, 'Karan', 40000, 3);


WITH HighSalaryEmployees AS (
    SELECT Name, salary
    FROM Employees
    WHERE salary > 50000
)
SELECT * FROM HighSalaryEmployees;


WITH OrgChart AS (
   
    SELECT id, Name, manager_id, 0 AS level
    FROM Employees
    WHERE manager_id IS NULL

    UNION ALL

    
    SELECT e.id, e.name, e.manager_id, oc.level + 1
    FROM Employees e
    JOIN OrgChart oc ON e.manager_id = oc.id
)
SELECT * FROM OrgChart
ORDER BY level, manager_id;


-- CTE is the common Table Expression and it is a temporary named result set which contains the SELECT, UPDATE, DELETE, INSERT Queries.

-- It Makes complex Queries more readable and allows for recursive operations

SELECT * FROM Employees;

WITH topSalary AS (

	SELECT TOP 1 * FROM Employees
	ORDER BY salary desc

)

SELECT * FROM topSalary

-- WHY to use CTE?
-- improve readability and maintainability 
-- helps in breaking down complex queries
-- allow for recursion 
-- can be reused multiple times in the main query 

WITH employeeEarningMorethan5000 AS (
	SELECT * FROM Employees
	WHERE salary > 50000
)
SELECT * FROM employeeEarningMorethan5000


With CountEmployeesPerManager AS (
SELECT manager_id, COUNT(*) as empCount 
FROM Employees
WHERE manager_id is NOT NULL
GROUP BY manager_id
)SELECT * FROM CountEmployeesPerManager




With allEmployeeswithaANDs AS (
	
	SELECT Name,salary FROM Employees
	WHERE name LIKE 's%'
)
SELECT * FROM allEmployeeswithaANDs


With avgSalaryEmp AS ( 
	
	SELECT Name 
	FROM Employees
	WHERE salary > (SELECT AVG(salary) FROM Employees) 
)
SELECT * FROM avgSalaryEmp