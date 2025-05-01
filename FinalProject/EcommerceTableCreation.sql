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
    country NVARCHAR(100),
    user_type NVARCHAR(50) CHECK (user_type IN ('customer', 'vendor')) NOT NULL
);


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
    id NVARCHAR(50) PRIMARY KEY,
    order_id NVARCHAR(50) REFERENCES orders(id) ON DELETE CASCADE,
    shipping_method NVARCHAR(100),
    tracking_number NVARCHAR(100),
    estimated_delivery DATETIME,
    status NVARCHAR(50)
);

-- WISHLIST
CREATE TABLE wishlist (
    id NVARCHAR(50) PRIMARY KEY,
    user_id NVARCHAR(50),
    product_id NVARCHAR(50),
    CONSTRAINT FK_wishlist_user FOREIGN KEY (user_id)
        REFERENCES users(id) ON DELETE NO ACTION,
    CONSTRAINT FK_wishlist_product FOREIGN KEY (product_id)
        REFERENCES products(id) ON DELETE NO ACTION
);
-- SHOPPING CART
CREATE TABLE shopping_cart (
    id NVARCHAR(50) PRIMARY KEY,
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
