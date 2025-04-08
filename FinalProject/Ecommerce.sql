Create Database Ecommerce;

use Ecommerce;

use master

DROP DATABASE Ecommerce;
-- Brands Table
CREATE TABLE Brands (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100) UNIQUE
);

CREATE SCHEMA userSchema;


CREATE TABLE userSchema.UserRole(
	id INT PRIMARY KEY,
	name VARCHAR(50) UNIQUE NOT NULL);

EXEC sp_MSforeachtable 'DROP TABLE ?';

CREATE TABLE userSchema.Users (
    id BIGINT identity(1,1) PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    password VARBINARY(64) CHECK (LEN(password) > 8),
    address VARCHAR(255),
	country VARCHAR(20),
	gender CHAR(1) CHECK (gender = 'M' OR gender = 'F'),
	dob DATE,
    phone_number INT,
    user_roleId INT,
	FOREIGN KEY(user_roleId) REFERENCES userSchema.UserRole(id) ON DELETE CASCADE
);

DROP TABLE userSchema.UserRole

INSERT INTO userSchema.UserRole VALUES(1,'admin'),(2,'vendor'),(3,'prime'),(4,'user');

SELECT *  FROM userSchema.Users

DROP TABLE userSchema.Users





CREATE TABLE Categories (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100),
    parent_category_id VARCHAR(50),
    FOREIGN KEY (parent_category_id) REFERENCES Categories(id)
);

-- Products Table
CREATE TABLE Products (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100),
    description TEXT,
    category_id VARCHAR(50),
    price DECIMAL(10, 2),
    sku VARCHAR(50) UNIQUE,
    brand VARCHAR(50),
    discount DECIMAL(5, 2),
    FOREIGN KEY (category_id) REFERENCES Categories(id),
    FOREIGN KEY (brand) REFERENCES Brands(id)
);

-- Orders Table
CREATE TABLE Orders (
    id VARCHAR(50) PRIMARY KEY,
    user_id VARCHAR(50),
    order_date DATETIME,
    order_status VARCHAR(50),
    total_amount DECIMAL(10, 2),
    payment_status VARCHAR(50),
    FOREIGN KEY (user_id) REFERENCES Users(id)
);

-- Order Items Table
CREATE TABLE OrderItems (
    id VARCHAR(50) PRIMARY KEY,
    order_id VARCHAR(50),
    product_id VARCHAR(50),
    quantity INT,
    unit_price DECIMAL(10, 2),
    total_price DECIMAL(10, 2),
    FOREIGN KEY (order_id) REFERENCES Orders(id),
    FOREIGN KEY (product_id) REFERENCES Products(id)
);

-- Payments Table
CREATE TABLE Payments (
    id VARCHAR(50) PRIMARY KEY,
    order_id VARCHAR(50),
    payment_method VARCHAR(50),
    amount DECIMAL(10, 2),
    payment_date DATETIME,
    FOREIGN KEY (order_id) REFERENCES Orders(id)
);

-- Reviews Table
CREATE TABLE Reviews (
    id VARCHAR(50) PRIMARY KEY,
    user_id VARCHAR(50),
    product_id VARCHAR(50),
    rating INT CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    review_date DATETIME,
    FOREIGN KEY (user_id) REFERENCES Users(id),
    FOREIGN KEY (product_id) REFERENCES Products(id)
);

-- Shipping Table
CREATE TABLE Shipping (
    id VARCHAR(50) PRIMARY KEY,
    order_id VARCHAR(50),
    shipping_method VARCHAR(50),
    tracking_number VARCHAR(50),
    estimated_delivery DATETIME,
    status VARCHAR(50),
    FOREIGN KEY (order_id) REFERENCES Orders(id)
);

-- Wishlist Table
CREATE TABLE Wishlist (
    id VARCHAR(50) PRIMARY KEY,
    user_id VARCHAR(50),
    product_id VARCHAR(50),
    FOREIGN KEY (user_id) REFERENCES userSchema.Users(id),
    FOREIGN KEY (product_id) REFERENCES Products(id)
);

-- Shopping Cart Table
CREATE TABLE ShoppingCart (
    id VARCHAR(50) PRIMARY KEY,
    user_id VARCHAR(50),
    product_id VARCHAR(50),
    quantity INT,
    FOREIGN KEY (user_id) REFERENCES Users(id),
    FOREIGN KEY (product_id) REFERENCES Products(id)
);

-- Inventory Table
CREATE TABLE Inventory (
    id VARCHAR(50) PRIMARY KEY,
    product_id VARCHAR(50),
    quantity_in_stock INT,
    FOREIGN KEY (product_id) REFERENCES Products(id)
);


INSERT INTO Brands (id, name) VALUES ('B1', 'Nike'), ('B2', 'Adidas'), ('B3', 'Puma');

-- Users
INSERT INTO userSchema.Users (name, email, password, address, country,dob, gender,phone_number, user_roleId) 
VALUES	
('John Doe', 'john@example.com', HASHBYTES('SHA2_256', 'secure_password'), '123 Street, City', 'USA','2000-01-01','M', '1234567890', 4),
('Jane Smith', 'jane@example.com', HASHBYTES('SHA2_256', 'another_password'), '456 Avenue, City', 'Canada','2000-01-01','F', '0987654321', 1);

SELECT * FROM userSchema.Users

-- Categories
INSERT INTO Categories (id, name, parent_category_id) VALUES
('C1', 'Clothing', NULL),
('C2', 'Shoes', 'C1');

-- Products
INSERT INTO Products (id, name, description, category_id, price, sku, brand, discount) VALUES
('P1', 'Running Shoes', 'Comfortable running shoes', 'C2', 79.99, 'RS-001', 'B1', 10.00),
('P2', 'T-Shirt', 'Breathable sports t-shirt', 'C1', 29.99, 'TS-001', 'B2', 5.00);

-- Orders
INSERT INTO Orders (id, user_id, order_date, order_status, total_amount, payment_status) VALUES
('O1', 'U1', GETDATE(), 'Completed', 109.98, 'Paid');

-- Order Items
INSERT INTO OrderItems (id, order_id, product_id, quantity, unit_price, total_price) VALUES
('OI1', 'O1', 'P1', 1, 79.99, 79.99),
('OI2', 'O1', 'P2', 1, 29.99, 29.99);

-- Payments
INSERT INTO Payments (id, order_id, payment_method, amount, payment_date) VALUES
('PM1', 'O1', 'Credit Card', 109.98, GETDATE());


SELECT * FROM Users;
4	
SELECT * FROM sys.tables;