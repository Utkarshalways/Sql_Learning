SELECT * FROM sys.sysdatabases

use Practice

DROP table IF EXISTS Employees

SELECT * FROM sys.tables	
CREATE TABLE Employees (
    EmpID INT,
    Name VARCHAR(50),
	Gender CHAR(1) CHECK (Gender = 'M' OR Gender = 'F'),
    Department VARCHAR(50),
    Salary INT
);


INSERT INTO Employees (EmpID, Name,Gender, Department, Salary) VALUES
(1, 'Alice','F', 'HR', 50000),
(2, 'Bob','M', 'IT', 60000),
(3, 'Charlie','M', 'HR', 55000),
(4, 'David','M', 'IT', 70000),
(5, 'Eve','F', 'Finance', 45000),
(6, 'Frank','M', 'Finance', 55000);

SELECT * FROM Employees;

-- =======================================
-- Aggregate Functions

SELECT * ,
Max(salary) Over (PARTITION BY Salary ) as MaxSalary
From Employees;

SELECT * ,
Max(salary) Over () as MaxSalary
From Employees;

SELECT *,
COUNT(Gender) OVER( PARTITION BY Gender) as Gender_Count
FROM Employees;

SELECT *,
AVG(Salary) OVER( PARTITION BY Gender) as AvgSalary
FROM Employees;

SELECT *,
AVG(Salary) OVER( PARTITION BY Department) as AvgSalary
FROM Employees;

SELECT *,
Max(Salary) OVER( PARTITION BY Gender) as MaxSalary
FROM Employees;


SELECT *,
MIN(Salary) OVER( PARTITION BY Department) as MinSalary
FROM Employees;

-- =======================================
--  ROW_NUMBER()

SELECT Name, Department, Salary,
ROW_NUMBER() OVER (ORDER BY Salary DESC) AS RowNum
FROM Employees;


SELECT Name, Department, Salary,
ROW_NUMBER() OVER () AS RowNum
FROM Employees;


SELECT Name, Department, Salary,
ROW_NUMBER() OVER (PARTITION BY Department ORDER BY Salary) AS RowNum
FROM Employees;



-- =======================================
--  RANK()
SELECT Name, Department, Salary,
RANK() OVER (ORDER BY Salary DESC) AS Rank
FROM Employees;

SELECT Name, Department, Salary,
RANK() OVER () AS Rank
FROM Employees;

SELECT *,
RANK() OVER (ORDER BY Department DESC) AS Rank
FROM Employees;

SELECT Name, Department, Salary,
RANK() OVER (PARTITION BY Department ORDER BY Salary) AS Rank
FROM Employees;


-- =======================================
--  DENSE_RANK()
SELECT Name, Department, Salary,
DENSE_RANK() OVER (ORDER BY Salary DESC) AS DenseRank
FROM Employxees;

SELECT Name, Department, Salary,
DENSE_RANK() OVER () AS DenseRank
FROM Employees;

SELECT Name, Department, Salary,
DENSE_RANK() OVER (ORDER BY Department DESC) AS DenseRank
FROM Employees;

SELECT *,
DENSE_RANK() OVER (PARTITION BY Gender ORDER BY Salary DESC) AS DenseRank
FROM Employees;

-- =======================================
--  NTILE()

SELECT Name, Department, Salary,
NTILE(2) OVER (ORDER BY Salary DESC) AS Quartile
FROM Employees;

SELECT Name, Department, Salary,
NTILE(-1) OVER (ORDER BY Salary DESC) AS Quartile
FROM Employees;

SELECT Name, Department, Salary,
NTILE(10) OVER (ORDER BY Salary DESC) AS Quartile
FROM Employees;

SELECT *,
NTILE(2) OVER (PARTITION BY Gender ORDER BY Salary DESC) AS Quartile
FROM Employees;

-- =======================================
-- LAG() and LEAD()

-- LEAD (Column name,offset,DefaultValue) OVER (ORDER BY)
-- LAG(Column name,offset,DefaultValue) OVER( ORDER BY )


SELECT Name, Department, Salary,
LAG(Salary, 1 ,0) OVER (ORDER BY Salary) AS PrevSalary,
LEAD(Salary, 1 ,0) OVER (ORDER BY Salary) AS NextSalary
FROM Employees;

-- Question: What do LAG() and LEAD() functions do?
-- A) Fetch previous and next values in the result set
-- B) Rank the rows
-- C) Aggregate the values

-- =======================================
	
-- FIRST and LAST VALUE

	SELECT 
	FIRST_VALUE(name) OVER (ORDER BY name) AS First_VALUE,
	LAST_VALUE(name) OVER (ORDER BY name) AS LAST_VALUE,*
	FROM Employees;

	SELECT *,
	FIRST_VALUE(name) OVER (PARTITION BY Department ORDER BY name) AS First_VALUE,
	LAST_VALUE(name) OVER (PARTITION BY Department ORDER BY name) AS LAST_VALUE
	FROM Employees;

-- =======================================
	-- RUNNING TOTAL

	SELECT *,
	SUM(Salary) OVER () AS RunningTotal
	FROM Employees

	SELECT *,
	SUM(Salary) OVER (ORDER BY salary) AS RunningTotal
	FROM Employees

-- =======================================
 -- PERCENT_RANK()
 SELECT *,
 PERCENT_RANK() OVER (ORDER BY Salary) AS PercentRank
 FROM Employees;

  SELECT *,
 PERCENT_RANK() OVER () AS PercentRank
 FROM Employees;

 -- PERCENT_RANK = (RANK - 1) / (TOTALROWS-1)

 SELECT *,
 100 * PERCENT_RANK() OVER (PARTITION BY Gender ORDER BY Salary) AS PercentRank
 FROM Employees;

  SELECT *,
 CUME_DIST() OVER ( ORDER BY Salary) AS CumulativeDistribution
 FROM Employees;

  -- Cummulative Distribution = (No. of rows before or equal) / (TOTALROWS)

   SELECT *,
   PERCENT_RANK() OVER(ORDER BY Salary) AS PercentRank,
 CUME_DIST() OVER ( ORDER BY Salary) AS CumulativeDistribution
 FROM Employees;

-- =======================================
-- Question :-- 

SELECT Department,
SUM(Salary) OVER (PARTITION BY Department) AS TotalSalary,
AVG(Salary) OVER (PARTITION BY Department) AS AvgSalary
FROM Employees;


-- =======================================
--  Rank and Partition Mix

SELECT Name, Department, Salary,
RANK() OVER (PARTITION BY Department ORDER BY Salary DESC) AS Rank
FROM Employees;

-- =======================================
--  Lag with Partition

SELECT Name, Department, Salary,
LAG(Salary, 1, 0) OVER (PARTITION BY Department ORDER BY Salary) AS PrevSalary
FROM Employees;

-- =======================================
-- Combining SUM with ORDER BY

SELECT Name, Salary,
SUM(Salary) OVER (ORDER BY Salary ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS CumulativeSalary
FROM Employees;

-- =======================================
--  Dense Rank with Different Ordering

SELECT Name, Department, Salary,
DENSE_RANK() OVER (ORDER BY Department DESC, Salary ASC) AS DenseRank
FROM Employees;

-- =======================================
--  Mixing NTILE and ROW_NUMBER
SELECT Name, Department, Salary,
NTILE(2) OVER (ORDER BY Salary DESC) AS SalaryGroup,
ROW_NUMBER() OVER (PARTITION BY Department ORDER BY Salary DESC) AS DepartmentRank
FROM Employees;

-- =======================================
-- Combining LEAD and LAG
SELECT Name, Salary,
LAG(Salary, 1) OVER (ORDER BY Salary) AS PrevSalary,
LEAD(Salary, 1) OVER (ORDER BY Salary) AS NextSalary,
(Salary - LAG(Salary, 1) OVER (ORDER BY Salary)) AS SalaryDifference
FROM Employees;



SELECT * FROM Employees;

SELECT Name,Department,Salary,
ROW_NUMBER() OVER (PARTITION BY DEPARTMENT ORDER BY Salary desc) as ROWNUM
FROM Employees;

SELECT Name,Department,Salary,
LAG(Salary,1) OVER(PARTITION BY Department ORDER BY Salary) AS PreviousEmployeeSalary
FROM Employees;

SELECT *,
NTILE(4) OVER (ORDER BY Salary) As DividedSalary
FROM Employees;

SELECT *,
CASE 
WHEN Salary > 60000 THEN 'GOOD'
WHEN Department = 'IT' THEN 'Okay'
ELSE 'BAD'
END
AS Reviews
FROM Employees;
