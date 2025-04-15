use ViewPractice;

SELECT * FROM sys.tables;

SELECT * FROM customers;
SELECT * FROM orders;
SELECT * FROM sales;

SELECT c.customer_name
FROM customers as c
WHERE c.customer_id IN (
SELECT o.customer_id
FROM orders as o
JOIN sales as s ON o.order_id = s.order_id
GROUP BY o.customer_id
HAVING SUM(s.amount) > 2000
)


-- Customer Who have not placed any orders

SELECT c.customer_name
FROM customers as c
WHERE c.customer_id NOT IN (
	SELECT o.customer_id FROM orders as o
)


SELECT c.customer_name
FROM customers as c
WHERE c.customer_id = (
	SELECT TOP 1 o.customer_id 
	FROM orders as o
	WHERE o.order_amount = (SELECT MAX(o.order_amount) FROM orders as o)
)


SELECT c.customer_name
FROM customers as c
WHERE c.customer_id IN (
SELECT o.customer_id
FROM orders as o
JOIN sales as s ON o.order_id = s.order_id
WHERE s.amount > 1000
)

SELECT o.order_id
FROM orders as o
WHERE o.order_id IN (
SELECT order_id 
FROM sales 
WHERE quantity > 1)


SELECT c.customer_name 
FROM customers as c
WHERE c.customer_id IN (
SELECT o.customer_id 
FROM orders as o
JOIN sales as s ON o.order_id = s.order_id
GROUP BY o.customer_id
HAVING SUM(s.amount) > (SELECT AVG(amount) FROM sales)
)


SELECT c.customer_name 
FROM customers as c
WHERE customer_id IN (
SELECT TOP 1 o.customer_id 
FROM orders as o
JOIN sales as s ON s.order_id = o.order_id
GROUP BY o.customer_id
ORDER BY SUM(s.amount)
)

SELECT s.product_name 
FROM sales as s
WHERE s.order_id IN (
SELECT o.order_id FROM orders as o 
WHERE o.order_date > '2024-01-01'
)


SELECT c.customer_name
FROM customers as c
WHERE c.customer_id IN (
		SELECT o.customer_id 
		FROM orders as o
		JOIN sales as s ON s.order_id = o.order_id
		GROUP BY s.order_id,o.customer_id
		HAVING COUNT(s.product_name) > 1
)


SELECT c.customer_name
FROM customers as c
WHERE c.customer_id IN (
	SELECT o.customer_id 
	FROM orders as o
	JOIN sales as s ON o.order_id = s.order_id
	WHERE s.product_name IN (
	SELECT s.product_name 
	FROM sales 
	GROUP BY product_name
	HAVING COUNT(DISTINCT order_id) = 1
	))

	--Find the user who placed the most expensive order.

	SELECT c.customer_name 
	FROM customers as c
	WHERE c.customer_id IN (
		SELECT o.customer_id
		FROM orders as o
		WHERE order_amount = (SELECT MAX(order_amount) FROM orders)
	)

	--List orders where the order total is above the overall average order total.

	SELECT c.customer_name
	FROM customers as c
	WHERE c.customer_id IN (
	SELECT o.customer_id 
	FROM orders as o
	WHERE o.order_amount > (SELECT AVG(order_amount) FROM orders))

	SELECT c.customer_name
	FROM customers as c
	WHERE c.customer_id IN (
	SELECT  TOP 1 o.customer_id 
	FROM orders as o
	WHERE o.order_amount < (SELECT MAX(order_amount) FROM orders)
	ORDER BY o.order_amount desc)
	
