use ViewPractice;

SELECT * FROM sys.tables;

SELECT * FROM customers;
SELECT * FROM ORDERS;
SELECT * FROM sales;

select cus.customer_name
from customers as cus
where customer_id = 
(
select ord.customer_id 
from orders as ord
where ord.order_amount = (select max(o2.order_amount) from orders as o2)
	)



-- List all orders where the sale amount is more than average.

SELECT o.*
FROM orders as o
WHERE o.order_amount > ( SELECT AVG(order_amount) FROM orders)

SELECT *
FROM sales
WHERE amount > (
  SELECT AVG(amount) FROM sales
);

SELECT customer_name
FROM customers
WHERE customer_id IN (
SELECT o.customer_id
FROM orders as o
JOIN sales as s ON o.order_id = s.order_id	
WHERE s.product_name = 'Laptop'
)

SELECT order_amount 
FROM orders WHERE order_id = (
SELECT order_id
FROM sales
WHERE quantity = (
  SELECT MAX(quantity) FROM sales
)

