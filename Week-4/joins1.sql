
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



