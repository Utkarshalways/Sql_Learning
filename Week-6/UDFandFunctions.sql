use gds;

select SQRT(4)
select getdate()

DECLARE @DOB DATE='10/08/1982'
DECLARE @Age INT  
SET @Age = DATEDIFF(YEAR, @DOB, GETDATE()) - 
	CASE 
		WHEN (MONTH(@DOB) > MONTH(GETDATE())) OR (MONTH(@DOB) = MONTH(GETDATE()) AND DAY(@DOB) > DAY(GETDATE())) 
			THEN 1 
		ELSE 0 
	END  

Select @Age Age;


select 
	case when dbo.age('02-04-1999')>40 
		then 'old'
	else 'young'
end aj;



--sp_helptext age
--sp_help age
--sp_depends age



--as a udf
CREATE or alter FUNCTION dbo.Age(@DOB Date)
RETURNS INT  
AS  
BEGIN  
 DECLARE @Age INT  
 SET @Age = DATEDIFF(YEAR, @DOB, GETDATE()) - CASE WHEN (MONTH(@DOB) > MONTH(GETDATE())) OR (MONTH(@DOB) = MONTH(GETDATE()) AND DAY(@DOB) > DAY(GETDATE())) THEN 1 ELSE 0 END  
 RETURN @Age  
END
 
Select dbo.Age('10/08/1982') Age

drop function dbo.age

--can't return text, image, timestamp, cursor


CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    price DECIMAL(10, 2),
    is_active BIT
);

-- Sample data
INSERT INTO products VALUES
(1, 'Laptop', 1500.00, 1),
(2, 'Mouse', 25.00, 1),
(3, 'Keyboard', 45.00, 0),
(4, 'Monitor', 300.00, 1);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    total_amount DECIMAL(10, 2)
);

-- Sample data
INSERT INTO orders VALUES
(101, 1, 250.00),
(102, 2, 1200.00),
(103, 3, 75.00),
(104, 1, 600.00);

drop table if exists orders;
drop table if exists products;

CREATE FUNCTION dbo.GetDiscountedPrice(@price DECIMAL(10, 2))
RETURNS DECIMAL(10, 2)
AS
BEGIN
    RETURN @price * 0.90  -- 10% discount
END

SELECT 
    product_name,
    price,
    dbo.GetDiscountedPrice(price) AS discounted_price
FROM products;

drop function dbo.GetDiscountedPrice

--Output?
CREATE or alter FUNCTION dbo.IsAboveAveragePrice(@price DECIMAL(10,2))
RETURNS BIT
AS
BEGIN
    DECLARE @avg DECIMAL(10,2)
    SELECT @avg = AVG(price) FROM products
    RETURN IIF(@price > @avg, 1, 0)
END

SELECT product_name, price
FROM products
WHERE dbo.IsAboveAveragePrice(price)=0;

drop function dbo.IsAboveAveragePrice


-- Create the inline TVF
CREATE or alter FUNCTION dbo.GetActiveProducts()
RETURNS TABLE
AS
RETURN (
    SELECT product_id, product_name, price, is_active
    FROM products
    WHERE is_active = 1
);

SELECT * FROM dbo.GetActiveProducts();

drop function dbo.GetActiveProducts

--Output?
CREATE FUNCTION dbo.GetPremiumActiveProducts(@minPrice DECIMAL(10,2))
RETURNS TABLE
AS
RETURN (
    SELECT product_id, product_name, price
    FROM products
    WHERE is_active = 1 AND price > @minPrice
);

SELECT * FROM dbo.GetPremiumActiveProducts(100);

drop function dbo.GetPremiumActiveProducts

-- Create the multi-statement TVF
CREATE FUNCTION dbo.GetHighValueOrders(@minAmount DECIMAL(10, 2))
RETURNS @result TABLE (
    order_id INT,
    customer_id INT,
    total_amount DECIMAL(10, 2)
)
AS
BEGIN
    INSERT INTO @result
    SELECT order_id, customer_id, total_amount
    FROM orders
    WHERE total_amount >= @minAmount;

    RETURN;
END

SELECT * FROM dbo.GetHighValueOrders(500.00) ;

drop function dbo.GetHighValueOrders

--Output?
CREATE FUNCTION dbo.ClassifyProducts()
RETURNS @result TABLE (
    product_id INT,
    product_name VARCHAR(100),
    price DECIMAL(10,2),
    category VARCHAR(10)
)
AS
BEGIN
    INSERT INTO @result
    SELECT product_id, product_name, price,
           CASE WHEN price > 500 THEN 'Expensive' ELSE 'Cheap' END
    FROM products
    RETURN
END

SELECT * FROM dbo.ClassifyProducts();

drop function dbo.ClassifyProducts

--Udf vs Sp
-- Inline Table-Valued Function
CREATE FUNCTION dbo.GetProductsAbovePrice_UDF(@minPrice DECIMAL(10,2))
RETURNS TABLE
AS
RETURN (
    SELECT product_id, product_name, price
    FROM products
    WHERE price > @minPrice
);

-- Can be used in a SELECT
SELECT * FROM dbo.GetProductsAbovePrice_UDF(100);

drop function GetProductsAbovePrice_UDF

-- Stored Procedure
CREATE PROCEDURE dbo.GetProductsAbovePrice_SP
    @minPrice DECIMAL(10,2)
AS
BEGIN
    SELECT product_id, product_name, price
    FROM products
    WHERE price > @minPrice;
END;

-- Must be called separately
EXEC dbo.GetProductsAbovePrice_SP @minPrice = 100;

drop proc GetProductsAbovePrice_SP


-- UDF to check if a product is expensive
CREATE FUNCTION dbo.IsExpensive(@price DECIMAL(10,2))
RETURNS BIT
AS
BEGIN
    IF @price > 1000
        RETURN 1
    RETURN 0
END

SELECT product_name, price
FROM products
WHERE dbo.IsExpensive(price) = 1;

drop function dbo.IsExpensive