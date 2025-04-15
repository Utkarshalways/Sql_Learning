DROP TABLE ORDERS

CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerName VARCHAR(100),
    OrderAmount DECIMAL(10,2),
    City VARCHAR(50)
);

INSERT INTO Orders VALUES
(1, 'Alice', 150.00, 'Delhi'),
(2, 'Bob', 90.00, 'Mumbai'),
(3, 'Charlie', 200.00, 'Delhi'),
(4, 'David', 50.00, 'Chennai'),
(5, 'Eve', 120.00, 'Delhi'),
(6, 'Frank', 60.00, 'Mumbai'),
(7, 'Harsh', 1000.00, 'Mumbai');

select * from orders

--1. Scalar Subquery
--Definition:
--A subquery that returns exactly one value (one row, one column).
--It can be used in SELECT, WHERE, or HAVING clauses.

--Find the customer who placed the highest order:

SELECT CustomerName 
FROM Orders 
WHERE OrderAmount = (
 SELECT MAX(OrderAmount) FROM Orders
)

-- Find customers whose order amount is equal to the second highest order placed.


SELECT *
FROM Orders
WHERE OrderAmount = (
    SELECT MAX(OrderAmount)
    FROM Orders
    WHERE OrderAmount < (
        SELECT MAX(OrderAmount) FROM Orders
    )
);


--2. Multi-Row Subquery
--Definition:
--Returns multiple rows. Used with operators like IN, ANY, or ALL.

--Find orders placed in cities where any order was greater than 100:

SELECT *
FROM Orders
WHERE City IN (
    SELECT DISTINCT City
    FROM Orders
    WHERE OrderAmount > 100
);



SELECT *
FROM Orders
WHERE City IN (
    SELECT City
    FROM Orders
    GROUP BY City
    HAVING MIN(OrderAmount) >= 100
);

--Find customers who live in cities where no one ordered below ₹100.


--3. Correlated Subquery
--Definition:
--A subquery that depends on the outer query. It's executed once per outer row.

--Get orders where the order amount is above average for that customer's city:

SELECT *
FROM Orders O1
WHERE OrderAmount > (
    SELECT AVG(OrderAmount)
    FROM Orders O2
    WHERE O2.City = O1.City
);

--Find customers who placed the maximum order in their city.

SELECT *
FROM Orders O1
WHERE OrderAmount = (
    SELECT MAX(OrderAmount)
    FROM Orders O2
    WHERE O2.City = O1.City
);



--4. Nested Subquery
--Definition:
--A subquery inside another subquery. Layers of logic.

--Find the max order amount using a double subquery:

SELECT *
FROM Orders
WHERE OrderAmount = (
    SELECT MAX(OrderAmount)
    FROM (
        SELECT OrderAmount FROM Orders
    ) AS Sub
);

--Find orders whose amount is above the average of all orders placed in Delhi.

SELECT *
FROM Orders
WHERE OrderAmount > (
    SELECT AVG(OrderAmount)
    FROM (
        SELECT * FROM Orders WHERE City = 'Delhi'
    ) AS DelhiOrders
);

--5. Inline View (FROM Clause Subquery)
--Definition:
--A subquery used as a temporary table in the FROM clause.

--Count high-value orders per city:

SELECT City, COUNT(*) AS HighOrderCount
FROM (
    SELECT * FROM Orders
    WHERE OrderAmount > 100
) AS HighOrders
GROUP BY City;

--Find the total number of orders per city, but only for customers whose order amount is odd 

SELECT City, COUNT(*) AS OddOrderCount
FROM (
    SELECT * FROM Orders
    WHERE OrderAmount % 2 = 1
) AS OddOrders
GROUP BY City;

--6. Subquery in SELECT Clause
--Definition:
--Subquery used to add a calculated column per row.

--Show average order amount of each customer's city:

SELECT 
    OrderID,
    CustomerName,
    City,
    OrderAmount,
    (SELECT AVG(OrderAmount) 
     FROM Orders AS O2 
     WHERE O2.City = O1.City) AS CityAvgOrder
FROM Orders AS O1;




SELECT 
    OrderID,
    CustomerName,
    City,
    OrderAmount,
    OrderAmount - (
        SELECT AVG(OrderAmount)
        FROM Orders AS O2
        WHERE O2.City = O1.City
    ) AS DiffFromCityAvg
FROM Orders AS O1




--List all orders and show how much each order is above or below the average order amount in that city.

DROP TABLE Orders