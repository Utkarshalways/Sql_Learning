use Ecommerce;
CREATE DATABASE Ecommerce

-- Table: brands
CREATE TABLE brands (
    id VARCHAR(255) PRIMARY KEY,
    name VARCHAR(255) UNIQUE NOT NULL
);

-- Table: users
CREATE TABLE users (
    id VARCHAR(255) PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    address TEXT,
    phone_number VARCHAR(20) UNIQUE NOT NULL,
    gender VARCHAR(20),
    DateOfBirth TIMESTAMP,
    country VARCHAR(100)
);

-- Table: Customers
CREATE TABLE Customers (
    id BIGINT PRIMARY KEY,
    userId VARCHAR(255),
    paymentDetails TEXT,
    Age INT,
    Address TEXT,
    PinCode INT,
    CONSTRAINT fk_customer_user FOREIGN KEY (userId) REFERENCES users(id)
);

-- Table: Vendor
CREATE TABLE Vendor (
    id BIGINT PRIMARY KEY,
    userId VARCHAR(255),
    paymentReceivingDetails TEXT,
    Address TEXT,
    BrandId VARCHAR(255),
    PinCode INT,
    GSTnumber VARCHAR(255) NOT NULL,
    inventoryID VARCHAR(255),
    CONSTRAINT fk_vendor_user FOREIGN KEY (userId) REFERENCES users(id),
    CONSTRAINT fk_vendor_brand FOREIGN KEY (BrandId) REFERENCES brands(id)
);

-- Table: categories
CREATE TABLE categories (
    id VARCHAR(255) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    parent_category_id VARCHAR(255),
    CONSTRAINT fk_category_parent FOREIGN KEY (parent_category_id) REFERENCES categories(id)
);

-- Table: products
CREATE TABLE products (
    id VARCHAR(255) PRIMARY KEY,
    name VARCHAR(255),
    description TEXT,
    category_id VARCHAR(255),
    price DECIMAL(10,2),
    stockKeepingUnit VARCHAR(100) UNIQUE,
    brandId VARCHAR(255),
    discount DECIMAL(5,2),
    CONSTRAINT fk_product_category FOREIGN KEY (category_id) REFERENCES categories(id),
    CONSTRAINT fk_product_brand FOREIGN KEY (brandId) REFERENCES brands(id)
);

-- Table: orders
CREATE TABLE orders (
    id VARCHAR(255) PRIMARY KEY,
    user_id VARCHAR(255),
    order_date TIMESTAMP,
    order_status VARCHAR(50),
    total_amount DECIMAL(10,2),
    payment_status VARCHAR(50),
    quantity INT,
    unit_price DECIMAL(10,2),
    total_price DECIMAL(10,2),
    CONSTRAINT fk_order_user FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Table: order_items
CREATE TABLE order_items (
    id VARCHAR(255) PRIMARY KEY,
    order_id VARCHAR(255),
    product_id VARCHAR(255),
    CONSTRAINT fk_orderitem_order FOREIGN KEY (order_id) REFERENCES orders(id),
    CONSTRAINT fk_orderitem_product FOREIGN KEY (product_id) REFERENCES products(id)
);

-- Table: payments
CREATE TABLE payments (
    id VARCHAR(255) PRIMARY KEY,
    order_id VARCHAR(255),
    payment_method VARCHAR(50),
    amount DECIMAL(10,2),
    payment_date TIMESTAMP,
    CONSTRAINT fk_payment_order FOREIGN KEY (order_id) REFERENCES orders(id)
);

-- Table: reviews
CREATE TABLE reviews (
    id VARCHAR(255) PRIMARY KEY,
    user_id VARCHAR(255),
    product_id VARCHAR(255),
    rating INT CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    review_date TIMESTAMP,
    CONSTRAINT fk_review_user FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT fk_review_product FOREIGN KEY (product_id) REFERENCES products(id)
);

-- Table: shipping
CREATE TABLE shipping (
    id VARCHAR(255) PRIMARY KEY,
    order_id VARCHAR(255),
    shipping_method VARCHAR(100),
    tracking_number VARCHAR(100),
    estimated_delivery TIMESTAMP,
    status VARCHAR(50),
    CONSTRAINT fk_shipping_order FOREIGN KEY (order_id) REFERENCES orders(id)
);

-- Table: wishlist
CREATE TABLE wishlist (
    id VARCHAR(255) PRIMARY KEY,
    user_id VARCHAR(255),
    product_id VARCHAR(255),
    CONSTRAINT fk_wishlist_user FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT fk_wishlist_product FOREIGN KEY (product_id) REFERENCES products(id)
);

-- Table: shopping_cart
CREATE TABLE shopping_cart (
    id VARCHAR(255) PRIMARY KEY,
    user_id VARCHAR(255),
    product_id VARCHAR(255),
    quantity INT CHECK (quantity > 0),
    CONSTRAINT fk_cart_user FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT fk_cart_product FOREIGN KEY (product_id) REFERENCES products(id)
);

-- Table: inventory
CREATE TABLE inventory (
    id VARCHAR(255) PRIMARY KEY,
    product_id VARCHAR(255),
    quantity_in_stock INT CHECK (quantity_in_stock >= 0),
    CONSTRAINT fk_inventory_product FOREIGN KEY (product_id) REFERENCES products(id)
);


DROP TABLE IF EXISTS shopping_cart;
DROP TABLE IF EXISTS wishlist;
DROP TABLE IF EXISTS shipping;
DROP TABLE IF EXISTS reviews;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS inventory;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS Vendor;
DROP TABLE IF EXISTS Customers;
DROP TABLE  Users;
DROP TABLE  userRole;
DROP TABLE IF EXISTS brands;
DROP TABLE sysdiagrams;

SELECT * FROM sys.tables;
use master;

DROP DATABASE Ecommerce;
