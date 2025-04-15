
CREATE DATABASE week5Prac

USE week5Prac


CREATE TABLE Sales (
    SalesPerson VARCHAR(50),
    MonthName VARCHAR(20),
    Amount INT
);

INSERT INTO Sales (SalesPerson, MonthName, Amount) VALUES
('Amit', 'January', 1000),
('Amit', 'February', 1200),
('Amit', 'March', 1100),
('Neha', 'January', 1500),
('Neha', 'February', 1600),
('Neha', 'March', 1700);


--PIVOT: Convert rows to columns

SELECT *
INTO PivotedSales
FROM (
    SELECT SalesPerson, MonthName, Amount
    FROM Sales
) AS SourceTable
PIVOT (
    SUM(Amount) FOR MonthName IN ([January], [February], [March])
) AS PivotTable;

SELECT * FROM PivotedSales

-- UNPIVOT : columns to ROWs
SELECT SalesPerson, MonthName, Amount
INTO UnpivotedSales
FROM (
    SELECT SalesPerson, [January], [February], [March]
    FROM PivotedSales
) AS Pivoted
UNPIVOT (
    Amount FOR MonthName IN ([January], [February], [March])
) AS Unpivoted;

SELECT * FROM UnpivotedSales;


SELECT *
INTO SalesFlyTable
FROM Sales;


SELECT * FROM SalesFlyTable;


CREATE TABLE SalesBackup (
    SalesPerson VARCHAR(50),
    MonthName VARCHAR(20),
    Amount INT
);


INSERT INTO SalesBackup (SalesPerson, MonthName, Amount)
SELECT SalesPerson, MonthName, Amount
FROM Sales;


SELECT * FROM SalesBackup;


-- Drop tables if they already exist
DROP TABLE IF EXISTS Sales;
DROP TABLE IF EXISTS PivotedSales;
DROP TABLE IF EXISTS UnpivotedSales;
DROP TABLE IF EXISTS SalesBackup;




CREATE TABLE EMPLOYEES (    Name VARCHAR(50),    Department VARCHAR(50));INSERT INTO EMPLOYEES (Name, Department) VALUES('Alice', 'HR'),('Bob', 'Finance'),('Charlie', 'Engineering'),('Diana', 'HR'),('Ethan', 'Finance'),('Fiona', 'Engineering'),('George', 'HR');with baseCTE (SELECT * FROM SELECT * INTO NEWEMPLOYEEFROM (SELECT Name,department FROM EMPLOYEES) as TblPIVOT (	MAX(Department) FOR Department IN ([HR],[Finance],[Engineering])) as pvtbl)SELECT * FROM NEWEMPLOYEE