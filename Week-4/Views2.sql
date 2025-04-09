SELECT * FROM sys.DATABASEs;

use ViewPractice;
-- Drop existing tables if they exist
DROP TABLE IF EXISTS dbo.orders;
DROP TABLE IF EXISTS dbo.customers;
DROP TABLE IF EXISTS dbo.sales;

-- ========================================
-- 1. Creating Tables
-- ========================================
CREATE TABLE dbo.sales (
    id INT PRIMARY KEY,
    region VARCHAR(50),
    amount INT,
    sale_date DATE
);

CREATE TABLE dbo.customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    city VARCHAR(100)
);

CREATE TABLE dbo.orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_amount INT,
    order_date DATE,
    FOREIGN KEY (customer_id) REFERENCES dbo.customers(customer_id) ON DELETE CASCADE 
);

-- ========================================
-- 2. Inserting Sample Data
-- ========================================
INSERT INTO dbo.sales VALUES (1, 'East', 1000, '2024-01-01');
INSERT INTO dbo.sales VALUES (2, 'West', 1500, '2024-01-02');
INSERT INTO dbo.sales VALUES (3, 'North', 800, '2024-01-03');
INSERT INTO dbo.sales VALUES (4, 'East', 1300, '2024-01-04');

INSERT INTO dbo.customers VALUES (1, 'Alice', 'New York');
INSERT INTO dbo.customers VALUES (2, 'Bob', 'Los Angeles');
INSERT INTO dbo.customers VALUES (3, 'Charlie', 'Chicago');

INSERT INTO dbo.orders VALUES (101, 1, 500, '2024-01-01');
INSERT INTO dbo.orders VALUES (102, 1, 700, '2024-01-03');
INSERT INTO dbo.orders VALUES (103, 2, 450, '2024-01-05');
INSERT INTO dbo.orders VALUES (104, 3, 300, '2024-01-06');

-- ========================================



-- ========================================


CREATE VIEW v_sales_above_avg AS
SELECT * FROM dbo.sales
WHERE amount > (SELECT AVG(amount) FROM dbo.sales);

SELECT * FROM v_sales_above_avg;




-- View 1: Sales greater than average
-- Question: Will this view update automatically if new data is added to sales?


CREATE VIEW v_customers_multiple_orders AS
SELECT customer_id FROM dbo.orders
GROUP BY customer_id
HAVING COUNT(order_id) > 1;

SELECT * FROM v_customers_multiple_orders;


-- View 2: Customers who placed more than one order
-- Question: What will this return if all customers have only one order?


CREATE VIEW v_orders_above_customer_avg AS
SELECT *
FROM dbo.orders o
WHERE o.order_amount > (
    SELECT AVG(order_amount)
    FROM dbo.orders o2
    WHERE o2.customer_id = o.customer_id
);

SELECT * FROM v_orders_above_customer_avg;

-- View 3: Orders above customer's average order
-- Question: Does this view work for all customers?


CREATE VIEW v_latest_sale_per_region AS
SELECT * FROM dbo.sales s
WHERE sale_date = (
    SELECT MAX(s2.sale_date) FROM dbo.sales s2 WHERE s2.region = s.region
);


SELECT * FROM v_latest_sale_per_region;

-- View 4: Latest sale per region
-- Question: What if two sales have the same latest date?


CREATE VIEW v_rich_customers AS
SELECT customer_id, SUM(order_amount) AS total_spent
FROM dbo.orders
GROUP BY customer_id
HAVING SUM(order_amount) > (
    SELECT AVG(order_amount) FROM dbo.orders
);

SELECT * FROM v_rich_customers;
-- View 5: Total order amount per customer shown only if above overall average
-- Question: Is AVG inside HAVING okay here?


CREATE VIEW v_sales_on_max_order_day AS
SELECT * FROM dbo.sales
WHERE sale_date IN (
    SELECT order_date FROM dbo.orders
    WHERE order_amount = (SELECT MAX(order_amount) FROM dbo.orders)
);

SELECT * FROM v_sales_on_max_order_day

-- View 6: Sales on the same day as max order
-- Question: What happens if there are two orders with max amount?


CREATE VIEW v_latest_order_customer AS
SELECT * FROM dbo.orders o1
WHERE order_date = (
    SELECT MAX(order_date)
    FROM dbo.orders o2
    WHERE o2.customer_id = o1.customer_id
);

SELECT * FROM v_latest_order_customer;


-- View 7: View with correlated subquery (latest order per customer)
-- Question: Can this view be updated?



CREATE VIEW v_customer_orders AS
SELECT c.customer_name, o.order_id, o.order_amount
FROM dbo.customers c
JOIN dbo.orders o ON c.customer_id = o.customer_id;

SELECT * FROM v_customer_orders;

-- View 8: Customer and their orders
-- Question: Can we insert into this view?

CREATE VIEW v_customers_no_orders AS
SELECT c.customer_id, c.customer_name
FROM dbo.customers c
LEFT JOIN dbo.orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

SELECT * FROM v_customers_no_orders;



-- View 9: Customers without orders (LEFT JOIN)
-- Question: What will this return if all customers have orders?




CREATE VIEW v_large_orders_by_customers AS
SELECT c.customer_name, o.order_amount
FROM dbo.customers c
JOIN dbo.orders o ON c.customer_id = o.customer_id
WHERE o.order_amount > 600;

SELECT * FROM v_large_orders_by_customers;

-- View 10: Join with WHERE filter
-- Question: Can we update the order amount using this view?


CREATE VIEW v_customer_total_order_amount AS
SELECT c.customer_name, SUM(o.order_amount) AS total
FROM dbo.customers c
JOIN dbo.orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_name;

SELECT * FROM v_customer_total_order_amount;

-- View 11: Join + Aggregation
-- Question: Can we directly insert a new customer into this view?
