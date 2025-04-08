CREATE DATABASE Week3;

USE Week3

CREATE TABLE Employees(
emp_id VARCHAR(10) PRIMARY KEY);


INSERT INTO Employees VALUES('EMP00123'),
('EMP04567'),
('EMP00001'),
('EMP98765');
 
SELECT * FROM Employees;

SELECT CAST(SUBSTRING(emp_id,4,LEN(emp_id)) AS INT) AS NUMERIC_VALUES FROM Employees


-- QUESTION - 2

CREATE TABLE Customers (
id INT identity(1,1),
name VARCHAR(50)
)

ALTER TABLE Customers 
ALTER COLUMN name VARCHAR(50);

INSERT INTO Customers VALUES ('  John    Doe'),('Alice   Smith   '),(' Bob    Johnson '),('Emily Davis');


SELECT STUFF(REPLACE(TRIM(name),' ',''),CHARINDEX(' ',TRIM(name)),0,' ') FROM Customers;


-- QUESTION 3

CREATE TABLE SALES(
id INT identity(1,1),
employee_name VARCHAR(20),
region varchar(10),
sale_amount INT);

INSERT INTO SALES VALUES ('john','EAST',5000),
('Alice','EAST',7000),
('Bob','EAST',6000),
('Dave','WEST',9000),
 ('Emma','SOUTH',8500),
  ('Frank','WEST',7000);


SELECT TOP 1 * 
SELECT employee_name,sale_amount,region
FROM(
    SELECT *,
    DENSE_RANK() OVER (PARTITION BY region ORDER BY sale_amount DESC) AS d_rank
    FROM SALES
) T
WHERE d_rank <= 2;


-- QUESTION 4

CREATE TABLE orders (
  order_id INT IDENTITY(1,1) PRIMARY KEY,
  order_date VARCHAR(20) 
);

INSERT INTO orders VALUES 
('07-04-2025'),
('12-12-2024'),
('23-01-2025'),
('01-06-2022')

SELECT order_id,CONVERT(DATE,order_date,105) as [DATE],DATENAME(MONTH,CONVERT(DATE,order_date,105)) as MonthName FROM orders;


-- QUESTION 5

CREATE TABLE dailySales(
storeId varchar(20) PRIMARY KEY,
saleDate DATE,
saleAmount DECIMAL(10,2)
);

SELECT 
  name 
FROM 
  sys.key_constraints 
WHERE 
  type = 'PK' AND parent_object_id = OBJECT_ID('dailySales');

  ALTER TABLE dailySales
  DROP CONSTRAINT PK__dailySal__1EA7161318EFBB06;

INSERT INTO dailySales(storeId, saleDate, saleAmount) VALUES
  ('Store1', '2025-04-01', 1000.00),
  ('Store1', '2025-04-02', 1500.00),
  ('Store1', '2025-04-03', 1200.00),
  ('Store2', '2025-04-01', 800.00),
  ('Store2', '2025-04-02', 950.00),
  ('Store2', '2025-04-03', 1100.00),
  ('Store1', '2025-04-04', 1300.00),
  ('Store2', '2025-04-04', 1000.00);


  SELECT *,
  SUM(saleAmount)
   OVER(PARTITION BY storeId
		ORDER BY saleDate)
		as RunningTotal
		FROM dailySales
		ORDER BY storeId,saleDate;


-- QUESTION 6

DECLARE @input VARCHAR(100) = 'ab12cd345ef6';

SELECT 
  REPLACE(
    TRANSLATE(@input, 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ', REPLICATE(' ', 52)),
    ' ',
    ''
  ) AS only_digits;

 SELECT LEN(TRANSLATE('HEllo92world','abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ',REPLICATE(' ',52)));

-- QUESTION 7

CREATE TABLE ORDERTABLE (
  order_id INT PRIMARY KEY,
  customer_id VARCHAR(10),
  order_date DATE,
  amount DECIMAL(10,2)
);

INSERT INTO ORDERTABLE VALUES
  (1, 'CUST1', '2025-01-05', 1500.00),
  (2, 'CUST1', '2025-01-15', 1800.00),
  (3, 'CUST1', '2025-02-02', 1200.00),
  (4, 'CUST1', '2025-02-10', 1300.00),
  (5, 'CUST2', '2025-01-03', 1600.00),
  (6, 'CUST2', '2025-01-20', 1700.00),
  (7, 'CUST2', '2025-02-01', 1900.00),
  (8, 'CUST2', '2025-02-18', 2000.00),
  (9, 'CUST3', '2025-01-25', 900.00),
  (10, 'CUST3', '2025-03-05', 1100.00),
  (11, 'CUST3', '2025-03-10', 1150.00);


 SELECT *
FROM (
  SELECT 
    *,
	DATENAME(MONTH,order_date) as MONTH,
	DATENAME(YEAR,order_date) as YEAR,
    ROW_NUMBER() OVER (
      PARTITION BY customer_id, YEAR(order_date), MONTH(order_date)
      ORDER BY order_date
    ) AS rn
  FROM ORDERTABLE
) AS Ranked
WHERE rn = 1;


-- QUESTION 8 

SELECT PARSE(N'₹1,25,000' as MONEY USING 'en-IN')


-- QUESTION 9

CREATE TABLE customer_orders (
  customer_id VARCHAR(10) PRIMARY KEY,
  customer_name VARCHAR(100),
  last_order_date DATE 
);

INSERT INTO customer_orders (customer_id, customer_name, last_order_date) VALUES
  ('CUST1', 'Alice', '2025-04-01'),
  ('CUST2', 'Bob', '2025-03-15'),
  ('CUST4', 'Diana', '2025-04-06'),
  ('CUST5', 'Ethan', NULL);           

SELECT *,
CASE 
WHEN last_order_date is NULL then 'No orders YET'
ELSE CAST(DATEDIFF(DAY,last_order_date,GETDATE()) as VARCHAR)
END as Daydiff
FROM customer_orders;

-- QUESTION 10 

SELECT * FROM sys.tables
SELECT * FROM Employees;

CREATE TABLE DeptEmployees(
id int identity(1,1) PRIMARY KEY,
dept VARCHAR(20),
name varchar(10),
salary int);

INSERT INTO DeptEmployees VALUES ('IT','Rohit',13000),('IT','Virat',15000),('HR','Jitesh',12000),('HR','Sanju',12500);

SELECT *,
DENSE_RANK() OVER (PARTITION BY dept ORDER BY salary desc) as RANKINGS
FROM DeptEmployees;

-- QUESTION 11 

DECLARE @time TIME = '17:30:00';
SELECT SUBSTRING(CONVERT(VARCHAR(20), CAST(@time AS DATETIME), 100),13,LEN(CONVERT(VARCHAR(20), CAST(@time AS DATETIME), 100))) AS time;
-- QUESTION 12

CREATE TABLE audit_logs (
    log_id INT PRIMARY KEY,
    log_timestamp DATETIME
);

INSERT INTO audit_logs (log_id, log_timestamp) VALUES
(1, '2025-04-07 09:15:23'),
(2, '2025-04-07 11:45:10'),
(3, '2025-04-07 15:30:55'),
(4, '2025-04-06 08:10:00'),
(5, '2025-04-06 17:20:15'),
(6, '2025-04-05 14:05:33'),
(7, '2025-04-05 18:45:21'),
(8, '2025-04-05 23:59:59'),
(9, '2025-04-04 07:00:00');

SELECT DATEPART(DAY,log_timestamp) FROM audit_logs;

SELECT * 
,
COUNT(*) OVER(PARTITION BY CAST(log_timestamp as DATE)) AS dailyCount
FROM audit_logs
ORDER BY log_timestamp

-- QUESTION 13

CREATE TABLE users (
  user_id INT IDENTITY(1,1) PRIMARY KEY,
  status VARCHAR(20)
);

INSERT INTO users (status) VALUES
  ( 'active   '),
  ('  ACTIVE'),
  ( 'Active  '),
  (' Active     '),
  ('  active');

  SELECT user_id,
  LOWER(TRIM(status)) FROM users;

  -- QUESTION 14

  CREATE TABLE sensorReadings(
  id int identity(1,1),
  timestamp DATETIME,
  temp FLOAT)

  INSERT INTO sensorReadings(timestamp, temp) VALUES
  ( '2025-04-01 08:00:00', 35.5),
  ( '2025-04-01 12:00:00', 37.2),
  ( '2025-04-01 16:00:00', 36.1),
  ('2025-04-01 10:00:00', 30.0),
  ('2025-04-01 14:00:00', 32.5);

  SELECT TOP 1 * ,
  RANK() OVER( ORDER BY temp desc) AS [Rank]
  FROM sensorReadings


  -- QUESTION 15

  CREATE TABLE BoolDataset(
	id INT identity(1,1),
	value VARCHAR(10))
	
	INSERT INTO BoolDataset VALUES ('true  '),
	('  false'),
	('    true  '),
	('  true  '),
	('   false  '),
	('true  '),
	(' false  '),
	('false  ');

	SELECT *,
	IIF(LOWER(TRIM(value)) = 'true',1,0) 
	FROM BoolDataset;

