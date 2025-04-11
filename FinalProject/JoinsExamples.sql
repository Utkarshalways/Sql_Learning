SELECT * FROM USERS;
SELECT * FROM CUSTOMERS;

-- List all customers along with their user details (name, email, address).
SELECT u.id,name,email,u.address FROM USERS as u 
JOIN CUSTOMERS as c ON u.id = c.userId


-- Find all products along with their vendor's name and GST number.

SELECT * FROM Products;
SELECT * FROM Vendors;
SELECT * FROM USERS;

SELECT p.name,u.name,v.GSTnumber 
FROM users as u
JOIN Vendors as v ON v.userId = u.id
JOIN Products as p ON p.vendor_id = v.id;

-- Show all orders with user name, total amount, and payment status.

SELECT * FROM orders;

SELECT * FROM Users;

SELECT O.id,u.id,u.name,o.total_amount,o.payment_status
FROM Orders as O
LEFT JOIN users as u ON O.user_id = u.id



