SELECT * FROM sys.tables;
-- USERS
CREATE TABLE users (
    id NVARCHAR(50) PRIMARY KEY,
    name NVARCHAR(255) NOT NULL UNIQUE,
    email NVARCHAR(255) UNIQUE,
    password VARBINARY(MAX) NOT NULL, -- Store using HASHBYTES('SHA2_256', CONVERT(VARBINARY, 'password'))
    address NVARCHAR(500),
    phone_number NVARCHAR(20) UNIQUE,
    gender NVARCHAR(10),
    DateOfBirth DATETIME,
    user_type NVARCHAR(50) CHECK (user_type IN ('customer', 'vendor')) NOT NULL
);


ALTER TABLE users
DROP COLUMN country;
-- for creating multiples address ( want to store multiple addresses of a single user)

CREATE TABLE user_addresses (
    id INT IDENTITY(1,1) PRIMARY KEY,
    user_id NVARCHAR(50),
    address_line NVARCHAR(500),
    address_type NVARCHAR(50), -- e.g., 'Home', 'Office', 'Billing'
    is_primary BIT DEFAULT 0,
    modified_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_user_address FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);


-- transfer the data of the old table into new address one 
INSERT INTO user_addresses (user_id, address_line, address_type, is_primary)
SELECT id, address, 'Home', 1 FROM users WHERE address IS NOT NULL;

SELECT * FROM user_addresses;

-- drop the address from the user table as now it is no need of that
ALTER TABLE users DROP COLUMN address; 



-- CUSTOMERS
CREATE TABLE customers (
    id BIGINT PRIMARY KEY,
    userId NVARCHAR(50) UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    paymentDetails NVARCHAR(1000),
    age INT CHECK (age >= 0),
    address NVARCHAR(500),
    pinCode INT CHECK (pinCode >= 100000)
);

-- VENDORS
CREATE TABLE vendors (
    id BIGINT PRIMARY KEY,
    userId NVARCHAR(50) UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    paymentReceivingDetails NVARCHAR(1000),
    address NVARCHAR(500),
    pinCode INT CHECK (pinCode >= 100000),
    GSTnumber NVARCHAR(50) NOT NULL
);

-- CATEGORIES
CREATE TABLE categories (
    id NVARCHAR(50) PRIMARY KEY,
    name NVARCHAR(255),
    parent_category_id NVARCHAR(50) NULL,
    CONSTRAINT FK_categories_parent 
        FOREIGN KEY (parent_category_id) 
        REFERENCES categories(id)
);

-- PRODUCTS
CREATE TABLE products (
    id NVARCHAR(50) PRIMARY KEY,
    name NVARCHAR(255),
    description NVARCHAR(MAX),
    category_id NVARCHAR(50) REFERENCES categories(id) ON DELETE CASCADE,
    vendor_id BIGINT REFERENCES vendors(id) ON DELETE CASCADE,
    price DECIMAL(18,2) CHECK (price >= 0),
    stockKeepingUnit NVARCHAR(100) UNIQUE,
    discount DECIMAL(5,2) CHECK (discount >= 0)
);

-- ORDERS
CREATE TABLE orders (
    id NVARCHAR(50) PRIMARY KEY,
    user_id NVARCHAR(50) REFERENCES users(id) ON DELETE CASCADE,
    order_date DATETIME,
    order_status NVARCHAR(50),
    total_amount DECIMAL(18,2) CHECK (total_amount >= 0),
    payment_status NVARCHAR(50),
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE()
);



-- ORDER ITEMS
CREATE TABLE order_items (
    id NVARCHAR(50) PRIMARY KEY,
    order_id NVARCHAR(50) NOT NULL,
    product_id NVARCHAR(50) NOT NULL,
    quantity INT CHECK (quantity > 0),
    unit_price DECIMAL(18,2) CHECK (unit_price >= 0),
    total_price AS (quantity * unit_price) PERSISTED,
    CONSTRAINT FK_order_items_order FOREIGN KEY (order_id)
        REFERENCES orders(id),
    CONSTRAINT FK_order_items_product FOREIGN KEY (product_id)
        REFERENCES products(id)
);




-- PAYMENTS
CREATE TABLE payments (
    id NVARCHAR(50) PRIMARY KEY,
    order_id NVARCHAR(50) REFERENCES orders(id) ON DELETE CASCADE,
    payment_method NVARCHAR(50),
    amount DECIMAL(18,2) CHECK (amount >= 0),
    payment_date DATETIME,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE()
);

ALTER TABLE payments
ADD payment_status NVARCHAR(50) 
    CONSTRAINT chk_payment_status CHECK (payment_status IN ('Pending', 'Completed', 'Failed'))
    DEFAULT 'Pending';

	ALTER TABLE payments DROP CONSTRAINT chk_payment_status
	
UPDATE p
SET p.payment_status = o.payment_status FROM orders o JOIN payments p ON o.id = p.order_id

-- REVIEWS
CREATE TABLE reviews (
    id NVARCHAR(50) PRIMARY KEY,
    user_id NVARCHAR(50) NOT NULL,
    product_id NVARCHAR(50) NOT NULL,
    rating INT CHECK (rating >= 1 AND rating <= 5),
    comment NVARCHAR(MAX),
    review_date DATETIME,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_reviews_user FOREIGN KEY (user_id)
        REFERENCES users(id) ON DELETE NO ACTION,
    CONSTRAINT FK_reviews_product FOREIGN KEY (product_id)
        REFERENCES products(id) ON DELETE NO ACTION
);

-- SHIPPING
CREATE TABLE shipping (
    id INT IDENTITY(1,1) PRIMARY KEY,
    order_id NVARCHAR(50) REFERENCES orders(id) ON DELETE CASCADE,
    shipping_method NVARCHAR(100),
    tracking_number NVARCHAR(100),
    estimated_delivery DATETIME,
    status NVARCHAR(50)
);


-- WISHLIST
CREATE TABLE wishlist (
    id INT IDENTITY(1,1) PRIMARY KEY,
    user_id NVARCHAR(50),
    product_id NVARCHAR(50),
    CONSTRAINT FK_wishlist_user FOREIGN KEY (user_id)
        REFERENCES users(id) ON DELETE NO ACTION,
    CONSTRAINT FK_wishlist_product FOREIGN KEY (product_id)
        REFERENCES products(id) ON DELETE NO ACTION
);

-- SHOPPING CART
CREATE TABLE shopping_cart (
    id INT IDENTITY(1,1) PRIMARY KEY,
    user_id NVARCHAR(50),
    product_id NVARCHAR(50),
    quantity INT CHECK (quantity > 0),
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_shoppingcart_user FOREIGN KEY (user_id)
        REFERENCES users(id) ON DELETE NO ACTION,
    CONSTRAINT FK_shoppingcart_product FOREIGN KEY (product_id)
        REFERENCES products(id) ON DELETE NO ACTION
);


-- INVENTORY
CREATE TABLE inventory (
    id NVARCHAR(50) PRIMARY KEY,
    product_id NVARCHAR(50) REFERENCES products(id) ON DELETE CASCADE,
    quantity_in_stock INT CHECK (quantity_in_stock >= 0)
);

-- INVOICES
CREATE TABLE invoices (
    id NVARCHAR(50) PRIMARY KEY,
    order_id NVARCHAR(50),
    payment_id NVARCHAR(50),
    vendor_id BIGINT,
    invoice_date DATETIME,
    due_date DATETIME,
    billing_address NVARCHAR(500),
    shipping_address NVARCHAR(500),
    total_amount DECIMAL(18,2) CHECK (total_amount >= 0),
    payment_method NVARCHAR(50),
    status NVARCHAR(50),	
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_invoice_order FOREIGN KEY (order_id)
        REFERENCES orders(id) ON DELETE NO ACTION,
    CONSTRAINT FK_invoice_payment FOREIGN KEY (payment_id)
        REFERENCES payments(id) ON DELETE NO ACTION,
    CONSTRAINT FK_invoice_vendor FOREIGN KEY (vendor_id)
        REFERENCES vendors(id) ON DELETE NO ACTION
);


CREATE TABLE user_event_log (
    id INT IDENTITY(1,1) PRIMARY KEY,
    user_id NVARCHAR(50) NOT NULL,
    event_type NVARCHAR(100),         -- e.g., Login, Logout, ViewProduct, AddToCart
    event_time DATETIME DEFAULT GETDATE(),
    action_description NVARCHAR(MAX), -- What exactly happened
    CONSTRAINT FK_event_user FOREIGN KEY (user_id)
        REFERENCES users(id) ON DELETE CASCADE
);


CREATE TABLE alerts (
    id INT IDENTITY(1,1) PRIMARY KEY,
    alert_type NVARCHAR(100),         -- e.g., 'LowInventory', 'PriceDrop', etc.
    product_id NVARCHAR(50),          -- FK to products
    alert_message NVARCHAR(500),      -- e.g., 'Inventory below threshold: 2 units left'
    alert_time DATETIME DEFAULT GETDATE(),
    is_resolved BIT DEFAULT 0,        -- 0 = Unresolved, 1 = Resolved
    resolved_time DATETIME NULL,      -- When alert was resolved (optional)
    CONSTRAINT FK_alert_product FOREIGN KEY (product_id)
        REFERENCES products(id) ON DELETE CASCADE
);


CREATE TABLE coupons (
    id NVARCHAR(50) PRIMARY KEY,
    code NVARCHAR(50) UNIQUE NOT NULL,
    description NVARCHAR(255),
    discount_type NVARCHAR(20) NOT NULL CHECK (discount_type IN ('PERCENTAGE', 'FIXED')),
    discount_value DECIMAL(18,2) NOT NULL CHECK (discount_value > 0),
    min_order_value DECIMAL(18,2) DEFAULT 0,
    max_discount_amount DECIMAL(18,2) NULL,
    start_date DATETIME NOT NULL,
    end_date DATETIME NOT NULL,
    is_active BIT DEFAULT 1,
    usage_limit INT NULL,
    usage_count INT DEFAULT 0,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT CHK_valid_dates CHECK (end_date > start_date)
);



-- Add coupon_id and discount_amount columns to orders table
ALTER TABLE orders
ADD coupon_id NVARCHAR(50) NULL,
    discount_amount DECIMAL(18,2) DEFAULT 0,
    CONSTRAINT FK_orders_coupon FOREIGN KEY (coupon_id) 
        REFERENCES coupons(id) ON DELETE NO ACTION;

BEGIN TRANSACTION

ALTER TABLE orders
DROP COLUMN payment_status


DROP TABLE coupon_usage