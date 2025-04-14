
DROP TABLE IF EXISTS Employees;

CREATE TABLE Employees (
    id INT PRIMARY KEY,
    name VARCHAR(50),
    salary INT,
    manager_id INT
);


INSERT INTO Employees (id, name, salary, manager_id) VALUES
(1, 'Raj', 70000, NULL),
(2, 'Simran', 65000, 1),
(3, 'Aman', 50000, 1),
(4, 'Priya', 45000, 2),
(5, 'Arjun', 60000, 2),
(6, 'Karan', 40000, 3);


WITH HighSalaryEmployees AS (
    SELECT name, salary
    FROM Employees
    WHERE salary > 50000
)
SELECT * FROM HighSalaryEmployees;


WITH OrgChart AS (
   
    SELECT id, name, manager_id, 0 AS level
    FROM Employees
    WHERE manager_id IS NULL

    UNION ALL

    
    SELECT e.id, e.name, e.manager_id, oc.level + 1
    FROM Employees e
    JOIN OrgChart oc ON e.manager_id = oc.id
)
SELECT * FROM OrgChart
ORDER BY level, manager_id;
