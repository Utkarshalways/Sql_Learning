use MyDatabase;


SELECT 10 + 5;

SELECT 10 - 5;

SELECT 10 * 5;

SELECT 10 / 5;

SELECT 10 % 3;



-- -> 15
-- -> 5
-- -> 50
-- -> 2
-- -> 1



use MyDatabase;


CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY,
    Name VARCHAR(50),
    Age INT,
    Department VARCHAR(50),
    Salary DECIMAL(10,2)
);

INSERT INTO Employees (EmployeeID, Name, Age, Department, Salary) VALUES
(1, 'Alice', 30, 'HR', 50000),
(2, 'Bob', 25, 'IT', 60000),
(3, 'Charlie', 28, 'Finance', 55000),
(4, 'David', 35, 'HR', 70000),
(5, 'Eve', 40, 'IT', 80000),
(6, 'Frank', 22, 'Finance', 45000),
(7, 'Grace', 29, 'HR', 50000),
(8, 'Hannah', 32, 'IT', 75000),
(9, 'Ian', 27, 'Finance', 52000),
(10, 'Jack', 24, 'HR', 48000);


-- EQUALS 

SELECT * FROM Employees WHERE Salary = 50000;

-- NOT EQUALS

SELECT * FROM Employees WHERE Salary <> 50000;
SELECT * FROM Employees WHERE Salary != 50000;

-- Greater Than ( > )

SELECT * FROM Employees WHERE Salary > 60000;

-- LESS Than ( < )

SELECT * FROM Employees WHERE Salary < 60000;

-- GREATER Than Equals To

SELECT * FROM Employees WHERE Salary >= 55000;


-- LESS Than Equals To

SELECT * FROM Employees WHERE Salary <= 50000;

-- BETWEEN 

SELECT * FROM Employees WHERE Salary BETWEEN 50000 AND 70000;

-- LIKE 

SELECT * FROM Employees WHERE Name LIKE 'A%';

--  IN (Matching a Set of Values)

SELECT * FROM Employees WHERE Department IN ('IT', 'HR');




-- SQL LOGICAL QUERY

-- AND 
SELECT * FROM Employees WHERE Age > 25 AND Salary > 50000;

-- OR 
SELECT * FROM Employees WHERE Department = 'IT' OR Department = 'HR';

-- NOT
SELECT * FROM Employees WHERE NOT Age = 30;



-- PAGINATION QUERIES

-- TOP 
SELECT TOP 5 * FROM Employees ORDER BY Salary DESC;

-- ORDER BY
SELECT * FROM Employees ORDER BY age; 

-- OFFSET FETCH
SELECT * FROM Employees ORDER BY Salary DESC OFFSET 2 ROWS
SELECT * FROM Employees ORDER BY Salary DESC OFFSET 2 ROWS FETCH NEXT 2 ROWS ONLY



--Which QUERY is Right ? about fetching First 5 top rows
SELECT * FROM Employees ORDER BY EmployeeID OFFSET 5 ROWS;
SELECT TOP 5 * FROM Employees;


-- How do you retrieve the top 3 highest-paid employees?
SELECT TOP 3 * FROM Employees ORDER BY Salary DESC;
SELECT * FROM Employees ORDER BY Salary DESC OFFSET 0 ROWS FETCH NEXT 3 ROWS ONLY


DROP TABLE Employees;