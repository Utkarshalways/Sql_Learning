use AdventureWorks2022;

-- Agregate Functions

SELECT * from Production.ProductCategory;

SELECT * from HumanResources.Employee;

SELECT ROUND(SUM(totalDue),2) AS TotalSUM from Sales.SalesOrderHeader;

SELECT * from Sales.SalesOrderDetail;

SELECT COUNT(SalesOrderID) as TOTALCOUNT from Sales.SalesOrderDetail;

SELECT AVG(OrderQty) as AVGDETAILS from Sales.SalesOrderDetail;

SELECT MAX(ListPrice) as MaximumPrice FROM Production.Product;

SELECT MIN(ListPrice) as MinimumPrice FROM Production.Product;

