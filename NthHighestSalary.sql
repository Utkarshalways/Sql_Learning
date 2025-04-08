use practice;

CREATE TABLE Employees (
    EmployeeID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Department VARCHAR(100),
    JobTitle VARCHAR(100),
    Salary DECIMAL(10, 2),
    HireDate DATE
);

INSERT INTO Employees (FirstName, LastName, Department, JobTitle, Salary, HireDate) VALUES
('David', 'Lee', 'Sales', 'Sales Representative', 45000.00, '2020-09-01'),
('Sarah', 'Taylor', 'Marketing', 'Marketing Coordinator', 50000.00, '2021-01-01'),
('Kevin', 'White', 'IT', 'Junior Developer', 60000.00, '2020-06-01'),
('Rebecca', 'Hall', 'Finance', 'Accountant', 65000.00, '2019-03-01'),
('Michael', 'Davis', 'Sales', 'Regional Sales Manager', 90000.00, '2015-01-01'),
('Lisa', 'Martin', 'Marketing', 'Creative Director', 85000.00, '2018-09-01'),
('Daniel', 'Garcia', 'IT', 'Senior Software Engineer', 95000.00, '2016-06-01'),
('Jessica', 'Miller', 'Finance', 'Financial Manager', 75000.00, '2014-01-01');


SELECT * FROM Employees;

DECLARE @n INT = 3; -- Set n to 3 for the third highest salary
SELECT DISTINCT TOP 1 salary
FROM (
    SELECT DISTINCT TOP (@n) salary
    FROM Employees
	Order by Salary DESC
) AS salary
Order by salary
