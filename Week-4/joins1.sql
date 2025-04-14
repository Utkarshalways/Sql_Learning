
select * from sys.databases;

use ViewPractice;

SELECT * FROM sys.tables;

select * FROM orders;
select * from customers;
select * from sales;

SELECT c.customer_name, c.city ,o.order_id,o.order_amount
FROM 
customers as c JOIN 
orders as o ON c.customer_id = o.customer_id;

SELECT  c.customer_id,count(o.order_id) as totalCOUNT
FROM customers as c
JOIN
orders as o ON c.customer_id = o.customer_id
GROUP BY c.customer_id,c.customer_name
HAVING COUNT(o.order_id) > 1;

SELECT c.customer_id,sum(order_amount) AS orderSum
FROM customers as c
JOIN
orders as o ON c.customer_id = o.customer_id
GROUP BY c.customer_id

DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS sales;
DROP TABLE IF EXISTS orders;

-- Customers
CREATE TABLE customers (
  customer_id INT PRIMARY KEY,
  customer_name VARCHAR(100)
);

-- Orders
CREATE TABLE orders (
  order_id INT PRIMARY KEY,
  customer_id INT,
  order_amount INT,
  order_date DATE,
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Sales
CREATE TABLE sales (
  sale_id INT PRIMARY KEY,
  order_id INT,
  product_name VARCHAR(100),
  quantity INT,
  amount INT,
  FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- Insert customers
INSERT INTO customers (customer_id, customer_name) VALUES
(1, 'Alice'),
(2, 'Bob'),
(3, 'Charlie'),
(4, 'David'),
(5, 'Eva'),
(6, 'Farhan'),
(7, 'Gauri'),
(8, 'Himanshu');

-- Insert orders
INSERT INTO orders (order_id, customer_id, order_amount, order_date) VALUES
(101, 1, 1200, '2024-01-05'),
(102, 1, 900,  '2024-01-10'),
(103, 2, 450,  '2024-02-01'),
(104, 2, 1300, '2024-02-11'),
(105, 3, 800,  '2024-03-15'),
(106, 4, 1500, '2024-04-01'),
(107, 5, 700,  '2024-04-07'),
(108, 5, 1100, '2024-04-20'),
(109, 6, 500,  '2024-05-01'),
(110, 7, 1800, '2024-05-10');

-- Insert sales
INSERT INTO sales (sale_id, order_id, product_name, quantity, amount) VALUES
(201, 101, 'Laptop', 1, 1200),
(202, 102, 'Mouse', 2, 900),
(203, 103, 'Keyboard', 1, 450),
(204, 104, 'Monitor', 2, 1300),
(205, 105, 'Speaker', 2, 800),
(206, 106, 'Tablet', 1, 1500),
(207, 107, 'USB Cable', 3, 700),
(208, 108, 'Charger', 1, 1100),
(209, 109, 'Pen Drive', 2, 500),
(210, 110, 'Smartphone', 1, 1800),
(211, 101, 'Headphones', 1, 300),     -- Alice has multiple items in a single order
(212, 104, 'Webcam', 1, 400),         -- Bob’s second order has multiple items
(213, 108, 'Power Bank', 1, 600),     -- Eva’s second order multiple items
(214, 110, 'Case Cover', 2, 200);     -- Extra product for Himanshu


SELECT * FROM customers
SELECT * FROM orders;
SELECT * FROM sales


SELECT c.customer_name,SUM(o.order_amount) as totalOrderAmount
FROM customers as c
JOIN orders as o
ON c.customer_id = o.customer_id
GROUP BY c.customer_name


SELECT c.customer_name,o.order_id,COUNT(s.order_id) as COUNT
FROM customers as c
JOIN Orders as o ON o.customer_id = c.customer_id
JOIN sales as s ON s.order_id = o.order_id
GROUP BY c.customer_name,o.order_id 
HAVING COUNT(*) > 1


SELECT o.order_id
FROM orders as o
LEFT JOIN sales as s ON o.order_id = s.order_id
WHERE s.order_id is NULL

SELECT c.customer_name,COUNT(o.order_id) as ordersCount
FROM customers as c
JOIN orders as o ON o.customer_id = c.customer_id
GROUP BY c.customer_name

SELECT s.*
FROM sales as s
JOIN orders as o ON s.order_id = o.order_id
JOIN customers as c ON c.customer_id = o.customer_id
WHERE c.customer_name LIKE 'A%';


