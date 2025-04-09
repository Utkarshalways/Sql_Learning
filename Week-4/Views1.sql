CREATE DATABASE ViewPractice

use ViewPractice;

CREATE TABLE dbo.sales (
    id INT PRIMARY KEY,
    region VARCHAR(50),
    amount INT,
    sale_date DATE
);

INSERT INTO dbo.sales VALUES (1, 'East', 1000, '2024-01-01');
INSERT INTO dbo.sales VALUES (2, 'West', 1500, '2024-01-02');
INSERT INTO dbo.sales VALUES (3, 'North', 800, '2024-01-03');

CREATE VIEW dbo.v_sales_basic AS
SELECT id, region, amount FROM dbo.sales;


-- SELECT THE VIEW
SELECT * FROM dbo.v_sales_basic;


-- ALTER THE VIEW
ALTER VIEW dbo.v_sales_basic AS
SELECT id, region, amount, sale_date FROM dbo.sales;


-- Update amount using the view
UPDATE dbo.v_sales_basic
SET amount = 1300
WHERE id = 1;

SELECT * FROM dbo.sales;

--Note: This works because:
--The view is updatable
--There’s no DISTINCT, JOIN, GROUP BY, UNION, etc.
--It includes the primary key (id) of the base table


DELETE FROM dbo.v_sales_basic
WHERE id = 3;

-- Not Allowed Cases
--If your view includes:
--JOIN
--GROUP BY, HAVING
--DISTINCT, TOP
--Aggregates (e.g., SUM, AVG)
--then updating or deleting through the view will not be allowed.

-- DROP THE VIEW
DROP VIEW dbo.v_sales_basic;



-- Simple View (Basic View)

CREATE VIEW v_simple_sales AS
SELECT id, region, amount FROM dbo.sales;

SELECT * FROM v_simple_sales;

SELECT * FROM v_simple_sales WHERE amount > 1400;

DROP TABLE dbo.sales;



CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    FOREIGN KEY (customer_id) REFERENCES dbo.customers(customer_id) ON DELETE CASCADE
);

INSERT INTO customers VALUES (1, 'Alice');
INSERT INTO customers VALUES (2, 'Bob');

INSERT INTO orders VALUES (101, 1);
INSERT INTO orders VALUES (102, 2);

SELECT * FROM customers;
SELECT * FROM orders;


-- View With WHERE
CREATE VIEW dbo.v_filtered_sales AS
SELECT * FROM dbo.sales WHERE amount > 900;

SELECT * FROM v_filtered_sales;

-- View WITH JOIN

CREATE VIEW v_order_details AS
SELECT o.order_id, c.customer_name
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id;

SELECT * FROM v_order_details;

DROP VIEW v_order_details;

-- Nested Views

CREATE VIEW dbo.v_region_avg AS
SELECT region, AVG(amount) AS avg_sales
FROM dbo.sales
GROUP BY region;

SELECT * FROM v_region_avg;

CREATE VIEW dbo.v_top_regions AS
SELECT * FROM dbo.v_region_avg WHERE avg_sales > 1400;

SELECT * FROM v_top_regions;

DROP VIEW v_top_regions;


-- Modify Base Table, Reflect in View
-- Example update:

UPDATE sales SET amount = 700 WHERE id = 2;

SELECT * FROM v_filtered_sales;

-- VIEW WITH ORDER BY 


CREATE VIEW v_sorted_sales AS
SELECT * FROM sales ORDER BY amount DESC; 


CREATE VIEW dbo.v_top_sales AS
SELECT TOP 100 PERCENT * FROM dbo.sales
ORDER BY amount DESC;

SELECT * FROM v_top_sales;



-- SYSTEM VIEW

SELECT name, type_desc FROM sys.views WHERE is_ms_shipped = 0;

SELECT * FROM  sys.system_views;

SELECT * FROM sys.tables;


-- PARTITION VIEWS

CREATE VIEW v_all_details AS
SELECT * FROM customers
UNION ALL
SELECT * FROM orders;


SELECT * FROM v_all_details;


CREATE TABLE orders_2023 (
    order_id INT,
    customer_id INT
);
GO

CREATE TABLE orders_2024 (
    order_id INT,
    customer_id INT
);
GO

INSERT INTO orders_2023 VALUES (201, 1);
INSERT INTO orders_2024 VALUES (301, 2);
GO

CREATE VIEW v_all_orders AS
SELECT * FROM orders_2023
UNION ALL
SELECT * FROM orders_2024;
GO

SELECT * FROM v_all_orders;
GO


DROP TABLE customers;
DROP TABLE orders;
DROP TABLE sales;

IF OBJECT_ID('dbo.v_filtered_sales', 'V') IS NOT NULL DROP VIEW dbo.v_filtered_sales;
IF OBJECT_ID('dbo.v_region_avg', 'V') IS NOT NULL DROP VIEW dbo.v_region_avg;
IF OBJECT_ID('dbo.v_top_regions', 'V') IS NOT NULL DROP VIEW dbo.v_top_regions;
IF OBJECT_ID('dbo.v_customer_orders', 'V') IS NOT NULL DROP VIEW dbo.v_customer_orders;
IF OBJECT_ID('dbo.v_sorted_sales', 'V') IS NOT NULL DROP VIEW dbo.v_sorted_sales;
IF OBJECT_ID('dbo.v_top_sales', 'V') IS NOT NULL DROP VIEW dbo.v_top_sales;
IF OBJECT_ID('dbo.v_sales_summary', 'V') IS NOT NULL DROP VIEW dbo.v_sales_summary;


-- Group By + Having + Join in View

CREATE VIEW v_sales_summary AS
SELECT c.customer_name, COUNT(*) AS total_orders
FROM dbo.orders o
JOIN dbo.customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_name
HAVING COUNT(*) > 0;


SELECT * FROM sys.tables;

SELECT * FROM sys.objects;


DROP TABLE sales
DROP TABLE customers
DROP TABLE orders