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



INSERT INTO users (id, name, email, password, address, phone_number, gender, DateOfBirth, country, user_type) VALUES
('USR011', 'Deepak Rana', 'deepak.rana@example.com', HASHBYTES('SHA2_256', CONVERT(VARBINARY, 'deepak123')), '22 Rajpur Road, Dehradun', '9001112233', 'Male', '1992-03-10', 'India', 'customer'),
('USR012', 'Meera Iyer', 'meera.iyer@example.com', HASHBYTES('SHA2_256', CONVERT(VARBINARY, 'meera123')), '14 T Nagar, Chennai', '9877123456', 'Female', '1990-11-22', 'India', 'vendor'),
('USR013', 'Farhan Qureshi', 'farhan.qureshi@example.com', HASHBYTES('SHA2_256', CONVERT(VARBINARY, 'farhan123')), '78 Lalbagh, Lucknow', '9234567890', 'Male', '1986-07-18', 'India', 'vendor'),
('USR014', 'Simran Kaur', 'simran.kaur@example.com', HASHBYTES('SHA2_256', CONVERT(VARBINARY, 'simran123')), '89 Sector 22, Chandigarh', '9800001234', 'Female', '1995-05-12', 'India', 'customer'),
('USR015', 'Rohan Malhotra', 'rohan.malhotra@example.com', HASHBYTES('SHA2_256', CONVERT(VARBINARY, 'rohan123')), '3 Camac Street, Kolkata', '9812345670', 'Male', '1988-09-30', 'India', 'vendor');


INSERT INTO vendors (id, userId, paymentReceivingDetails, address, pinCode, GSTnumber) VALUES
(105, 'USR012', 'BOI UPI: meera@boi', '14 T Nagar, Chennai', 600017, '33ABCDE1234F1Z9'),
(106, 'USR013', 'SBI Acc No: 2233445566', 'Lalbagh, Lucknow', 226001, '09AAACX1234G1ZP'),
(107, 'USR015', 'HDFC UPI: rohan@hdfc', 'Camac Street, Kolkata', 700016, '19ABCDF4567P1Z8');


INSERT INTO customers (id, userId, paymentDetails, age, address, pinCode) VALUES
(7, 'USR011', 'GPay: deepak@okhdfcbank', 33, '22 Rajpur Road, Dehradun', 248001),
(8, 'USR014', 'PhonePe: simran@ybl', 29, 'Sector 22, Chandigarh', 160022);


INSERT INTO products (
    id, name, description, category_id, vendor_id, price, stockKeepingUnit, discount
) VALUES
('PROD004', 'Fitness Tracker Band', 'Sleep and heart-rate monitoring', 'CAT002', 105, 1299.00, 'SKU004', 7.50),
('PROD005', 'Over-Ear Headphones', 'Comfortable fit with great sound', 'CAT007', 106, 2499.00, 'SKU005', 12.00),
('PROD006', 'Mini Bluetooth Speaker', 'Compact design with powerful sound', 'CAT008', 107, 999.00, 'SKU006', 10.00);


INSERT INTO inventory (id, product_id, quantity_in_stock) VALUES
('INV004', 'PROD004', 25),
('INV005', 'PROD005', 18),
('INV006', 'PROD006', 40);


INSERT INTO orders (id, user_id, order_date, order_status, total_amount, payment_status, created_at, updated_at) VALUES
('ORD004', 'USR011', '2025-04-04 14:00:00', 'Shipped', 1299.00, 'Paid', GETDATE(), GETDATE()),
('ORD005', 'USR014', '2025-04-05 17:30:00', 'Processing', 2499.00, 'Pending', GETDATE(), GETDATE());



INSERT INTO order_items (id, order_id, product_id, quantity, unit_price) VALUES
('OI004', 'ORD004', 'PROD004', 1, 1299.00),
('OI005', 'ORD005', 'PROD005', 1, 2499.00);


SELECT * FROM users;

INSERT INTO reviews (id, user_id, product_id, rating, comment, review_date)
VALUES
('R001', 'USR001', 'PROD001', 5, 'Excellent quality! Totally worth the price.', '2025-04-10'),
('R002', 'USR002', 'PROD002', 4, 'Good product but delivery was delayed.', '2025-04-11'),
('R003', 'USR003', 'PROD003', 3, 'Average performance, expected better.', '2025-04-12'),
('R004', 'USR004', 'PROD004', 2, 'Stopped working after a week. Disappointed.', '2025-04-13'),
('R005', 'USR005', 'PROD005', 5, 'Super fast and sleek. Highly recommend!', '2025-04-14'),
('R006', 'USR006', 'PROD006', 4, 'Nice battery backup and stylish design.', '2025-04-15'),
('R007', 'USR007', 'PROD001', 3, 'Build quality is okay, nothing special.', '2025-04-16'),
('R008', 'USR001', 'PROD004', 5, 'Customer service was very helpful.', '2025-04-17'),
('R009', 'USR002', 'PROD005', 4, 'Smooth UI and fast processing.', '2025-04-18'),
('R010', 'USR003', 'PROD003', 1, 'Terrible experience. Wouldn’t recommend.', '2025-04-19');


SELECT * FROM reviews;



-- 1. Create a new table with INT IDENTITY
CREATE TABLE reviews_new (
    id INT IDENTITY(1,1) PRIMARY KEY,
    user_id NVARCHAR(50) NOT NULL,
    product_id NVARCHAR(50) NOT NULL,
    rating INT CHECK (rating >= 1 AND rating <= 5),
    comment NVARCHAR(MAX),
    review_date DATETIME,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_review_user FOREIGN KEY (user_id)
        REFERENCES users(id) ON DELETE NO ACTION,
    CONSTRAINT FK_review_product FOREIGN KEY (product_id)
        REFERENCES products(id) ON DELETE NO ACTION
);

-- 2. Copy data (exclude the old id column)
INSERT INTO reviews_new (user_id, product_id, rating, comment, review_date, created_at, updated_at)
SELECT user_id, product_id, rating, comment, review_date, created_at, updated_at
FROM reviews;

-- 3. Drop the old table
DROP TABLE reviews;

-- 4. Rename the new table to original name
EXEC sp_rename 'reviews_new', 'reviews';


SELECT * FROM reviews;


INSERT INTO categories (id, name, parent_category_id) VALUES
('CAT009', 'Gaming Consoles', 'CAT001'),
('CAT010', 'Home Appliances', NULL),
('CAT011', 'Kitchen Appliances', 'CAT010');


INSERT INTO products (
    id, name, description, category_id, vendor_id, price, stockKeepingUnit, discount
) VALUES
('PROD007', 'Induction Cooktop', 'Energy efficient cooking solution', 'CAT011', 104, 3499.00, 'SKU007', 12.00),
('PROD008', 'Bluetooth Neckband', 'Sweat-proof neckband with long battery', 'CAT007', 103, 1099.00, 'SKU008', 7.00),
('PROD009', 'Smart LED TV', '4K Ultra HD Smart LED TV', 'CAT001', 102, 29999.00, 'SKU009', 6.00),
('PROD010', 'Wireless Mouse', 'Ergonomic wireless mouse', 'CAT005', 104, 799.00, 'SKU010', 3.00),
('PROD011', 'Mixer Grinder', '3-jar multipurpose mixer', 'CAT011', 105, 2399.00, 'SKU011', 9.00),
('PROD012', 'Tablet X10', 'Large screen Android tablet', 'CAT004', 101, 18999.00, 'SKU012', 10.00),
('PROD013', 'Fitness Tracker', 'Tracks activity and sleep', 'CAT006', 102, 1999.00, 'SKU013', 4.00),
('PROD014', 'Air Purifier', 'Removes allergens and pollutants', 'CAT010', 103, 7499.00, 'SKU014', 6.00),
('PROD015', 'Noise Cancelling Headphones', 'Premium audio with ANC', 'CAT007', 104, 6999.00, 'SKU015', 15.00),
('PROD016', 'Mini Speaker', 'Compact Bluetooth speaker', 'CAT008', 103, 1499.00, 'SKU016', 11.00),
('PROD017', 'Coffee Maker', 'Automatic drip coffee machine', 'CAT011', 105, 3299.00, 'SKU017', 8.00),
('PROD018', 'Keyboard Mechanical', 'RGB mechanical gaming keyboard', 'CAT005', 101, 4599.00, 'SKU018', 5.00),
('PROD019', 'Smartphone Case Z', 'Shockproof case for Smartphone Z', 'CAT004', 102, 599.00, 'SKU019', 2.00),
('PROD020', 'Electric Kettle', 'Stainless steel body, 1.5L', 'CAT011', 105, 1299.00, 'SKU020', 6.00);



INSERT INTO orders (
    id, user_id, order_date, order_status, total_amount, payment_status, created_at, updated_at
) VALUES
('ORD004', 'USR001', '2025-04-04', 'Shipped', 49999.00, 'Paid', GETDATE(), GETDATE()),
('ORD005', 'USR002', '2025-04-04', 'Delivered', 1099.00, 'Paid', GETDATE(), GETDATE()),
('ORD006', 'USR003', '2025-04-05', 'Processing', 2399.00, 'Pending', GETDATE(), GETDATE()),
('ORD007', 'USR001', '2025-04-05', 'Delivered', 1299.00, 'Paid', GETDATE(), GETDATE()),
('ORD008', 'USR002', '2025-04-06', 'Shipped', 1499.00, 'Paid', GETDATE(), GETDATE()),
('ORD009', 'USR003', '2025-04-06', 'Processing', 6999.00, 'Pending', GETDATE(), GETDATE()),
('ORD010', 'USR001', '2025-04-06', 'Delivered', 3299.00, 'Paid', GETDATE(), GETDATE());

-- Order Items
INSERT INTO order_items (id, order_id, product_id, quantity, unit_price) VALUES
('OI004', 'ORD004', 'PROD006', 1, 49999.00),
('OI005', 'ORD005', 'PROD008', 1, 1099.00),
('OI006', 'ORD006', 'PROD011', 1, 2399.00),
('OI007', 'ORD007', 'PROD020', 1, 1299.00),
('OI008', 'ORD008', 'PROD016', 1, 1499.00),
('OI009', 'ORD009', 'PROD015', 1, 6999.00),
('OI010', 'ORD010', 'PROD017', 1, 3299.00);


INSERT INTO inventory (id, product_id, quantity_in_stock) VALUES
('INV007', 'PROD007', 22),
('INV008', 'PROD008', 35),
('INV009', 'PROD009', 12),
('INV010', 'PROD010', 50),
('INV011', 'PROD011', 28),
('INV012', 'PROD012', 20),
('INV013', 'PROD013', 38),
('INV014', 'PROD014', 16),
('INV015', 'PROD015', 25),
('INV016', 'PROD016', 42),
('INV017', 'PROD017', 30),
('INV018', 'PROD018', 27),
('INV019', 'PROD019', 60),
('INV020', 'PROD020', 45);



INSERT INTO orders (id, user_id, order_date, order_status, total_amount, payment_status, created_at, updated_at) VALUES
('ORD006', 'USR012', '2025-04-06 10:45:00', 'Delivered', 3499.00, 'Paid', GETDATE(), GETDATE()),
('ORD007', 'USR015', '2025-04-07 11:30:00', 'Shipped', 1099.00, 'Paid', GETDATE(), GETDATE()),
('ORD008', 'USR003', '2025-04-08 09:15:00', 'Processing', 7499.00, 'Pending', GETDATE(), GETDATE()),
('ORD009', 'USR007', '2025-04-08 18:10:00', 'Processing', 4599.00, 'Pending', GETDATE(), GETDATE()),
('ORD010', 'USR009', '2025-04-09 12:20:00', 'Delivered', 1299.00, 'Paid', GETDATE(), GETDATE());

INSERT INTO order_items (id, order_id, product_id, quantity, unit_price) VALUES
('OI006', 'ORD006', 'PROD007', 1, 3499.00),
('OI007', 'ORD007', 'PROD008', 1, 1099.00),
('OI008', 'ORD008', 'PROD014', 1, 7499.00),
('OI009', 'ORD009', 'PROD018', 1, 4599.00),
('OI010', 'ORD010', 'PROD020', 1, 1299.00);


SELECT * FROM inventory;

INSERT INTO invoices (
    id, order_id, payment_id, vendor_id, invoice_date, due_date,
    billing_address, shipping_address, total_amount, payment_method, status, created_at, updated_at
) VALUES
('INV001', 'ORD004', 'PAY004', 101, '2025-04-04', '2025-04-14',
 '221 MG Road, Pune, MH', '221 MG Road, Pune, MH', 1299.00, 'UPI', 'Paid', GETDATE(), GETDATE()),

('INV002', 'ORD005', 'PAY005', 102, '2025-04-05', '2025-04-15',
 '44 Sarojini Nagar, Lucknow, UP', '44 Sarojini Nagar, Lucknow, UP', 2499.00, 'Card', 'Pending', GETDATE(), GETDATE()),

('INV003', 'ORD006', 'PAY006', 104, '2025-04-06', '2025-04-16',
 '17 Church Street, Bengaluru, KA', '17 Church Street, Bengaluru, KA', 3499.00, 'Net Banking', 'Paid', GETDATE(), GETDATE()),

('INV004', 'ORD007', 'PAY007', 103, '2025-04-07', '2025-04-17',
 '108 Jawahar Marg, Indore, MP', '108 Jawahar Marg, Indore, MP', 1099.00, 'UPI', 'Paid', GETDATE(), GETDATE()),

('INV005', 'ORD008', 'PAY008', 105, '2025-04-08', '2025-04-18',
 '55 Elgin Road, Kolkata, WB', '55 Elgin Road, Kolkata, WB', 7499.00, 'Card', 'Pending', GETDATE(), GETDATE()),

('INV006', 'ORD009', 'PAY009', 101, '2025-04-08', '2025-04-18',
 '205 Gandhi Road, Ahmedabad, GJ', '205 Gandhi Road, Ahmedabad, GJ', 4599.00, 'Cash on Delivery', 'Pending', GETDATE(), GETDATE()),

('INV007', 'ORD010', 'PAY010', 104, '2025-04-09', '2025-04-19',
 '88 Park Street, Kolkata, WB', '88 Park Street, Kolkata, WB', 1299.00, 'UPI', 'Paid', GETDATE(), GETDATE());


 SELECT * FROM invoices;

 INSERT INTO payments (
    id, order_id, payment_method, amount, payment_date, created_at, updated_at
) VALUES
('PAY004', 'ORD004', 'UPI', 1299.00, '2025-04-04 14:05:00', GETDATE(), GETDATE()),
('PAY005', 'ORD005', 'Card', 2499.00, '2025-04-05 17:35:00', GETDATE(), GETDATE()),
('PAY006', 'ORD006', 'Net Banking', 3499.00, '2025-04-06 10:50:00', GETDATE(), GETDATE()),
('PAY007', 'ORD007', 'UPI', 1099.00, '2025-04-07 11:35:00', GETDATE(), GETDATE()),
('PAY008', 'ORD008', 'Card', 7499.00, '2025-04-08 09:20:00', GETDATE(), GETDATE()),
('PAY009', 'ORD009', 'Cash on Delivery', 4599.00, '2025-04-08 18:15:00', GETDATE(), GETDATE()),
('PAY010', 'ORD010', 'UPI', 1299.00, '2025-04-09 12:25:00', GETDATE(), GETDATE());

SELECT * FROM wishlist
SELECT * FROM shipping

SELECT * FROM shopping_cart

INSERT INTO shipping (order_id, shipping_method, tracking_number, estimated_delivery, status) VALUES
('ORD004', 'Standard Delivery', 'TRK100004', '2025-04-09 18:00:00', 'Shipped'),
('ORD005', 'Express Delivery', 'TRK100005', '2025-04-07 14:00:00', 'Processing'),
('ORD006', 'Standard Delivery', 'TRK100006', '2025-04-11 10:00:00', 'Delivered'),
('ORD007', 'Express Delivery', 'TRK100007', '2025-04-12 16:30:00', 'Shipped'),
('ORD008', 'Standard Delivery', 'TRK100008', '2025-04-15 11:00:00', 'Processing'),
('ORD009', 'Overnight', 'TRK100009', '2025-04-09 10:00:00', 'Processing'),
('ORD010', 'Standard Delivery', 'TRK100010', '2025-04-14 13:00:00', 'Delivered');


INSERT INTO wishlist (user_id, product_id) VALUES
('USR002', 'PROD006'),
('USR005', 'PROD009'),
('USR008', 'PROD014'),
('USR003', 'PROD012'),
('USR010', 'PROD020'),
('USR012', 'PROD015'),
('USR015', 'PROD017');


INSERT INTO shopping_cart (user_id, product_id, quantity) VALUES
('USR001', 'PROD007', 1),
('USR004', 'PROD011', 2),
('USR006', 'PROD018', 1),
('USR007', 'PROD010', 3),
('USR009', 'PROD013', 1),
('USR011', 'PROD016', 2),
('USR014', 'PROD019', 1);


INSERT INTO alerts (product_id, alert_type, alert_message)
VALUES
('PROD001', 'Low Stock', 'Stock for iPhone 13 is below 3 units. Immediate restock needed.'),
('PROD005', 'Out of Stock', 'Samsung Microwave is out of stock.'),
('PROD009', 'Low Stock', 'Fire-Boltt Phoenix Smart Watch stock is low.');

SELECT * FROM alerts;




INSERT INTO user_event_log (user_id, event_type, action_description)
VALUES
-- Login Events
('USR001', 'Login', 'User logged in successfully.'),
('USR002', 'Login', 'User logged in successfully.'),
('USR005', 'Login', 'User logged in successfully.'),

-- Product Views
('USR003', 'ViewProduct', 'Viewed product: Samsung Galaxy M14'),
('USR004', 'ViewProduct', 'Viewed product: Lenovo Legion 5 Pro'),
('USR007', 'ViewProduct', 'Viewed product: Fire-Boltt Phoenix Smart Watch'),

-- Add to Cart
('USR005', 'AddToCart', 'Added LG OLED TV to cart'),
('USR006', 'AddToCart', 'Added Samsung Microwave to cart'),
('USR009', 'AddToCart', 'Added Realme Narzo 60 to cart'),

-- Wishlist
('USR010', 'AddToWishlist', 'Added Apple MacBook Air M2 to wishlist'),
('USR011', 'AddToWishlist', 'Added Dell XPS 13 to wishlist'),

-- Order Events
('USR012', 'PlaceOrder', 'Placed Order ORD006'),
('USR014', 'PlaceOrder', 'Placed Order ORD005'),
('USR015', 'PlaceOrder', 'Placed Order ORD007'),

-- Logout
('USR001', 'Logout', 'User logged out.'),
('USR005', 'Logout', 'User logged out.'),
('USR009', 'Logout', 'User logged out.');


SELECT * FROM user_event_log