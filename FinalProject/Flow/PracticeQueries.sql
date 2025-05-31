SELECT * FROM products;

SELECT * FROM categories;

SELECT * FROM inventory;

SELECT * FROM coupons;

SELECT * FROM sys.procedures;


Declare @IsValid BIT
EXEC sp_ValidateCoupon @CouponCode = 'SAVE20',@UserId = 'USR19', @OrderAmount = 149,@IsValid


SELECT 
    TABLE_NAME, 
    COLUMN_NAME, 
    DATA_TYPE, 
    IS_NULLABLE 
FROM INFORMATION_SCHEMA.COLUMNS
ORDER BY TABLE_NAME, COLUMN_NAME;





-- PRACTICE 

-- ALERTS

SELECT * FROM alerts WHERE is_resolved = 0;

SELECT alert_type,COUNT(*) FROM alerts GROUP BY alert_type

SELECT a.*,p.* FROM alerts a 
JOIN products p ON p.id = a.product_id
WHERE p.price < 1000;



-- CATEGORIES 
SELECT * FROM categories WHERE parent_category_id IS NULL

SELECT c1.name as Child,c2.name as parent 
FROM categories c1
JOIN categories c2 ON c1.parent_category_id = c2.id;



-- COUPONS 

SELECT * FROM coupons
WHERE GETDATE() BETWEEN start_date AND end_date
AND is_active = 1


SELECT TOP 1 code,start_date,end_date,usage_count FROM coupons WHERE is_active = 1 AND GETDATE() BETWEEN start_date AND end_date ORDER BY usage_count desc 
 
-- Customers
SELECT 
	CASE 
	WHEN age < 18 THEN 'MINOR'
	WHEN age BETWEEN 18 AND 60 THEN 'ADULT'
	ELSE 'Senior'
	END as AgeGroup,
	COUNT (*) as totalCount
	FROM customers 
GROUP BY 
	CASE
	WHEN age < 18 THEN 'MINOR'
	WHEN age BETWEEN 18 AND 60 THEN 'ADULT'
	ELSE 'Senior'
	END;


SELECT * FROM customers WHERE paymentDetails is NULL;


SELECT * FROM invoices;


SELECT * FROM orders WHERE coupon_id IS NOT NULL;



SELECT FORMAT(order_date, 'yyyy-MM') AS month, COUNT(*) AS total
FROM orders
GROUP BY FORMAT(order_date, 'yyyy-MM');




SELECT SUM(amount) AS total_revenue FROM payments;


SELECT * FROM products WHERE discount > 10;

SELECT TOP 5 * FROM products ORDER BY price DESC;


SELECT product_id, AVG(rating) AS avg_rating
FROM reviews
GROUP BY product_id;
