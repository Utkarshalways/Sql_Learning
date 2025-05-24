SELECT * FROM orders;
SELECT * FROM order_items;

SELECT 
o.order_id,
COUNT (o.id)  as orderidcount,
COUNT(o.product_id) as productCount,
COUNT(p.name) as productName
FROM orders as orders
JOIN order_items as o  ON orders.id = o.order_id
JOIN products as p ON o.product_id = p.id
WHERE orders.user_id = 'USR001'
GROUP BY o.order_id 


SELECT * FROM sysdiagrams;
SELECT * FROM sys.tables;



SELECT * FROM invoices;
SELECT * FROM shopping_cart;
SELECT * FROM users;
SELECT * FROM wishlist;


CREATE PROCEDURE searchUserWishlist AS
	@userid INT 
BEGIN 
	SELECT 
	u.name,
	p.name
	FROM users as u 
	JOIN wishlist w ON u.id = w.user_id
	JOIN products p ON p.id = w.product_id
	WHERE w.user_id = @user_id
END


SELECT * FROM orders;
select * FROm order_items;
SELECT * FROM products;


