INSERT INTO users (id, name, email, password, address, phone_number, gender, DateOfBirth, country, user_type) VALUES
('USR001', 'Ravi Sharma', 'ravi.sharma@example.com', HASHBYTES('SHA2_256', CONVERT(VARBINARY, 'ravi123')), '123 MG Road, Delhi', '9876543210', 'Male', '1990-06-15', 'India', 'customer'),
('USR002', 'Priya Singh', 'priya.singh@example.com', HASHBYTES('SHA2_256', CONVERT(VARBINARY, 'priya123')), '45 Park Street, Mumbai', '9123456780', 'Female', '1994-04-21', 'India', 'customer'),
('USR003', 'Ankit Verma', 'ankit.verma@example.com', HASHBYTES('SHA2_256', CONVERT(VARBINARY, 'ankit123')), '88 Jubilee Hills, Hyderabad', '9988776655', 'Male', '1987-12-05', 'India', 'vendor'),
('USR004', 'Kavita Mehra', 'kavita.mehra@example.com', HASHBYTES('SHA2_256', CONVERT(VARBINARY, 'kavita123')), '67 Nungambakkam, Chennai', '9786754321', 'Female', '1992-08-19', 'India', 'vendor'),
('USR005', 'Rahul Desai', 'rahul.desai@example.com', HASHBYTES('SHA2_256', CONVERT(VARBINARY, 'rahul123')), '21 BTM Layout, Bangalore', '9090909090', 'Male', '1989-11-10', 'India', 'customer'),
('USR006', 'Nikita Jain', 'nikita.jain@example.com', HASHBYTES('SHA2_256', CONVERT(VARBINARY, 'nikita123')), '56 Civil Lines, Jaipur', '9999988888', 'Female', '1995-01-28', 'India', 'vendor'),
('USR007', 'Aman Tripathi', 'aman.tripathi@example.com', HASHBYTES('SHA2_256', CONVERT(VARBINARY, 'aman123')), '34 Hitech City, Hyderabad', '9012345678', 'Male', '1991-09-13', 'India', 'customer'),
('USR008', 'Sneha Kulkarni', 'sneha.kulkarni@example.com', HASHBYTES('SHA2_256', CONVERT(VARBINARY, 'sneha123')), '77 Koregaon Park, Pune', '8888877777', 'Female', '1988-07-07', 'India', 'vendor'),
('USR009', 'Vikram Joshi', 'vikram.joshi@example.com', HASHBYTES('SHA2_256', CONVERT(VARBINARY, 'vikram123')), '19 Salt Lake, Kolkata', '9098123456', 'Male', '1993-03-03', 'India', 'customer'),
('USR010', 'Neha Kapoor', 'neha.kapoor@example.com', HASHBYTES('SHA2_256', CONVERT(VARBINARY, 'neha123')), '105 Sector 18, Noida', '9345678901', 'Female', '1996-10-25', 'India', 'customer');


-- Customers 

INSERT INTO users (id, name, email, password, address, phone_number, gender, DateOfBirth, country, user_type) VALUES
('USR001', 'Ravi Sharma', 'ravi.sharma@example.com', HASHBYTES('SHA2_256', CONVERT(VARBINARY, 'ravi123')), '123 MG Road, Delhi', '9876543210', 'Male', '1990-06-15', 'India', 'customer'),
('USR002', 'Priya Singh', 'priya.singh@example.com', HASHBYTES('SHA2_256', CONVERT(VARBINARY, 'priya123')), '45 Park Street, Mumbai', '9123456780', 'Female', '1994-04-21', 'India', 'customer'),
('USR003', 'Ankit Verma', 'ankit.verma@example.com', HASHBYTES('SHA2_256', CONVERT(VARBINARY, 'ankit123')), '88 Jubilee Hills, Hyderabad', '9988776655', 'Male', '1987-12-05', 'India', 'vendor'),
('USR004', 'Kavita Mehra', 'kavita.mehra@example.com', HASHBYTES('SHA2_256', CONVERT(VARBINARY, 'kavita123')), '67 Nungambakkam, Chennai', '9786754321', 'Female', '1992-08-19', 'India', 'vendor'),
('USR005', 'Rahul Desai', 'rahul.desai@example.com', HASHBYTES('SHA2_256', CONVERT(VARBINARY, 'rahul123')), '21 BTM Layout, Bangalore', '9090909090', 'Male', '1989-11-10', 'India', 'customer'),
('USR006', 'Nikita Jain', 'nikita.jain@example.com', HASHBYTES('SHA2_256', CONVERT(VARBINARY, 'nikita123')), '56 Civil Lines, Jaipur', '9999988888', 'Female', '1995-01-28', 'India', 'vendor'),
('USR007', 'Aman Tripathi', 'aman.tripathi@example.com', HASHBYTES('SHA2_256', CONVERT(VARBINARY, 'aman123')), '34 Hitech City, Hyderabad', '9012345678', 'Male', '1991-09-13', 'India', 'customer'),
('USR008', 'Sneha Kulkarni', 'sneha.kulkarni@example.com', HASHBYTES('SHA2_256', CONVERT(VARBINARY, 'sneha123')), '77 Koregaon Park, Pune', '8888877777', 'Female', '1988-07-07', 'India', 'vendor'),
('USR009', 'Vikram Joshi', 'vikram.joshi@example.com', HASHBYTES('SHA2_256', CONVERT(VARBINARY, 'vikram123')), '19 Salt Lake, Kolkata', '9098123456', 'Male', '1993-03-03', 'India', 'customer'),
('USR010', 'Neha Kapoor', 'neha.kapoor@example.com', HASHBYTES('SHA2_256', CONVERT(VARBINARY, 'neha123')), '105 Sector 18, Noida', '9345678901', 'Female', '1996-10-25', 'India', 'customer');


-- Vendors 

INSERT INTO vendors (id, userId, paymentReceivingDetails, address, pinCode, GSTnumber) VALUES
(101, 'USR003', 'Axis Bank UPI: arun@axis', 'Plot 56, Industrial Area, Pune', 411001, '27AABCU9603R1ZV'),
(102, 'USR004', 'SBI UPI: sonal@sbi', '12 IT Park, Chandigarh', 160101, '29AACCS8570K1ZL'),
(103, 'USR006', 'ICICI Acc No: 123456789', '45 Sector 62, Noida', 201309, '07AAACP2345N1Z2'),
(104, 'USR008', 'HDFC UPI: deepak@hdfc', '24 Nehru Place, Delhi', 110019, '08AAGCB1234K1ZP');

SELECT * FROM sys.tables;


INSERT INTO customers (id, userId, paymentDetails, age, address, pinCode) VALUES
(1, 'USR001', 'Paytm UPI: ravi@paytm', 34, '123 MG Road, Delhi', 110001),
(2, 'USR002', 'PhonePe: priya@ybl', 30, '45 Park Street, Mumbai', 400001),
(3, 'USR005', 'HDFC Card: XXXX-5678', 35, '21 BTM Layout, Bangalore', 560076),
(4, 'USR007', 'Google Pay: aman@okaxis', 33, '34 Hitech City, Hyderabad', 500081),
(5, 'USR009', 'SBI Netbanking', 31, '19 Salt Lake, Kolkata', 700091),
(6, 'USR010', 'ICICI UPI: neha@icici', 28, '105 Sector 18, Noida', 201301);


INSERT INTO orders (id, user_id, order_date, order_status, total_amount, payment_status, created_at, updated_at) VALUES
('ORD001', 'USR001', '2025-04-01 10:00:00', 'Delivered', 1499.00, 'Paid', GETDATE(), GETDATE()),
('ORD002', 'USR002', '2025-04-02 12:30:00', 'Shipped', 2999.00, 'Pending', GETDATE(), GETDATE()),
('ORD003', 'USR003', '2025-04-03 09:45:00', 'Processing', 1799.00, 'Paid', GETDATE(), GETDATE());

INSERT INTO order_items (id, order_id, product_id, quantity, unit_price) VALUES
('OI001', 'ORD001', 'PROD001', 1, 1499.00),
('OI002', 'ORD002', 'PROD002', 2, 1499.50),
('OI003', 'ORD003', 'PROD003', 1, 1799.00);


-- Root Categories
INSERT INTO categories (id, name, parent_category_id) VALUES
('CAT001', 'Electronics', NULL),
('CAT002', 'Wearables', NULL),
('CAT003', 'Audio Devices', NULL);

-- Subcategories
INSERT INTO categories (id, name, parent_category_id) VALUES
('CAT004', 'Smartphones', 'CAT001'),
('CAT005', 'Laptops', 'CAT001'),
('CAT006', 'Smart Watches', 'CAT002'),
('CAT007', 'Headphones', 'CAT003'),
('CAT008', 'Speakers', 'CAT003');


INSERT INTO products (
    id, name, description, category_id, vendor_id, price, stockKeepingUnit, discount
) VALUES
('PROD001', 'Wireless Earbuds', 'High-quality sound with noise cancellation', 'CAT001', 101, 1499.00, 'SKU001', 10.00),
('PROD002', 'Smart Watch', 'Fitness tracking with heart rate monitor', 'CAT002', 102, 2999.00, 'SKU002', 5.00),
('PROD003', 'Bluetooth Speaker', 'Portable speaker with deep bass', 'CAT001', 101, 1799.00, 'SKU003', 15.00);


INSERT INTO inventory (id, product_id, quantity_in_stock) VALUES
('INV001', 'PROD001', 20),
('INV002', 'PROD002', 15),
('INV003', 'PROD003', 30);


INSERT INTO shopping_cart (id, user_id, product_id, quantity, created_at, updated_at) VALUES
('CART001', 'USR001', 'PROD002', 1, GETDATE(), GETDATE()),
('CART002', 'USR002', 'PROD003', 2, GETDATE(), GETDATE()),
('CART003', 'USR003', 'PROD001', 1, GETDATE(), GETDATE());


INSERT INTO wishlist (id, user_id, product_id) VALUES
('WISHLIST001', 'USR001', 'PROD003'),
('WISHLIST002', 'USR002', 'PROD001'),
('WISHLIST003', 'USR003', 'PROD002');

INSERT INTO shipping (id, order_id, shipping_method, tracking_number, estimated_delivery, status) VALUES
('SHIP001', 'ORD001', 'Delhivery', 'DL123456789IN', '2025-04-05', 'Delivered'),
('SHIP002', 'ORD002', 'Blue Dart', 'BD987654321IN', '2025-04-07', 'Shipped'),
('SHIP003', 'ORD003', 'India Post', 'IP1122334455IN', '2025-04-06', 'Processing');




INSERT INTO payments (id, order_id, payment_method, amount, payment_date, created_at, updated_at) VALUES
('PAY001', 'ORD001', 'UPI', 1499.00, '2025-04-01 10:15:00', GETDATE(), GETDATE()),
('PAY002', 'ORD003', 'Credit Card', 1799.00, '2025-04-03 10:00:00', GETDATE(), GETDATE());



SELECT * FROM sys.tables

SELECT * FROM products;
SELECT * FROM inventory

SELECT

SELECT * FROM shopping_cart

INSERT INTO shopping_cart(id,user_id,product_id,quantity) VALUES ('CART004','USR001','PROD002',1);


SELECT * FROM shopping_cart WHERE user_id = 'USR001';