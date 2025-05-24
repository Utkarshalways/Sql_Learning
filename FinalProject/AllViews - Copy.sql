-- =============================================
-- USER & CUSTOMER VIEWS
-- =============================================

-- 1. Complete user profiles excluding sensitive info
CREATE OR ALTER VIEW vw_UserProfiles AS
SELECT 
    u.id, 
    u.name, 
    u.email,
    u.phone_number, 
    u.gender, 
    u.DateOfBirth,
    u.country, 
    u.user_type,
    (SELECT COUNT(*) FROM user_addresses WHERE user_id = u.id) AS address_count,
    (SELECT TOP 1 address_line FROM user_addresses WHERE user_id = u.id AND is_primary = 1) AS primary_address
FROM 
    users u;
GO

SELECT * FROM vw_UserProfiles;

-- 2. Customer information with user details
CREATE OR ALTER VIEW vw_CustomerDetails AS
SELECT 
    c.id AS customer_id,
    u.id AS user_id,
    u.name,
    u.email,
    u.phone_number,
    u.gender,
    u.DateOfBirth,
    u.country,
    c.paymentDetails,
    c.age,
    c.pinCode,
    (SELECT TOP 1 address_line FROM user_addresses WHERE user_id = u.id AND is_primary = 1) AS primary_address,
    (SELECT COUNT(o.id) FROM orders o WHERE o.user_id = u.id) AS total_orders
FROM 
    customers c
    INNER JOIN users u ON c.userId = u.id
WHERE 
    u.user_type = 'customer';
GO

SELECT * FROM vw_CustomerDetails

-- 3. Vendor information with user details
CREATE OR ALTER VIEW vw_VendorDetails AS
SELECT 
    v.id AS vendor_id,
    u.id AS user_id,
    u.name,
    u.email,
    u.phone_number,
    u.country,
    v.paymentReceivingDetails,
    v.address AS vendor_address,
    v.pinCode,
    v.GSTnumber,
    (SELECT COUNT(p.id) FROM products p WHERE p.vendor_id = v.id) AS total_products
FROM 
    vendors v
    INNER JOIN users u ON v.userId = u.id
WHERE 
    u.user_type = 'vendor';
GO


SELECT * FROM vw_VendorDetails;

-- 4. Customers by order value/frequency
CREATE OR ALTER VIEW vw_TopCustomers AS
SELECT 
    u.id AS user_id,
    u.name,
    u.email,
    COUNT(o.id) AS order_count,
    SUM(o.total_amount) AS total_spent,
    AVG(o.total_amount) AS avg_order_value,
    MAX(o.order_date) AS last_order_date
FROM 
    users u
    INNER JOIN orders o ON u.id = o.user_id
WHERE 
    u.user_type = 'customer'
GROUP BY 
    u.id, u.name, u.email;
GO


SELECT * FROM vw_TopCustomers

-- =============================================
-- PRODUCT VIEWS
-- =============================================

-- 1. Complete product details with categories
CREATE OR ALTER VIEW vw_ProductDetails AS
SELECT 
    p.id,
    p.name,
    p.description,
    p.price,
    p.discount,
    p.price * (1 - (p.discount / 100)) AS discounted_price,
    p.stockKeepingUnit,
    c.id AS category_id,
    c.name AS category_name,
    parent.id AS parent_category_id,
    parent.name AS parent_category_name,
    v.id AS vendor_id,
    u.name AS vendor_name,
    v.GSTnumber,
    i.quantity_in_stock
FROM 
    products p
    LEFT JOIN categories c ON p.category_id = c.id
    LEFT JOIN categories parent ON c.parent_category_id = parent.id
    LEFT JOIN vendors v ON p.vendor_id = v.id
    LEFT JOIN users u ON v.userId = u.id
    LEFT JOIN inventory i ON p.id = i.product_id;
GO


SELECT * FROM vw_ProductDetails;

-- 2. Products with inventory levels
CREATE OR ALTER VIEW vw_ProductsWithInventory AS
SELECT 
    p.id,
    p.name,
    p.price,
    p.discount,
    p.price * (1 - (p.discount / 100)) AS discounted_price,
    c.name AS category_name,
    i.quantity_in_stock,
    CASE 
        WHEN i.quantity_in_stock = 0 THEN 'Out of Stock'
        WHEN i.quantity_in_stock < 10 THEN 'Low Stock'
        ELSE 'In Stock'
    END AS stock_status
FROM 
    products p
    LEFT JOIN categories c ON p.category_id = c.id
    LEFT JOIN inventory i ON p.id = i.product_id;
GO

SELECT * FROM vw_ProductsWithInventory;

-- 3. Products by vendor
CREATE OR ALTER VIEW vw_VendorProducts AS
SELECT 
    v.id AS vendor_id,
    u.name AS vendor_name,
    p.id AS product_id,
    p.name AS product_name,
    p.price,
    p.discount,
    p.price * (1 - (p.discount / 100)) AS discounted_price,
    c.name AS category_name,
    i.quantity_in_stock,
    (SELECT COUNT(r.id) FROM reviews r WHERE r.product_id = p.id) AS review_count,
    (SELECT AVG(CAST(r.rating AS FLOAT)) FROM reviews r WHERE r.product_id = p.id) AS avg_rating
FROM 
    vendors v
    INNER JOIN users u ON v.userId = u.id
    INNER JOIN products p ON v.id = p.vendor_id
    LEFT JOIN categories c ON p.category_id = c.id
    LEFT JOIN inventory i ON p.id = i.product_id;
GO


SELECT * FROM vw_VendorProducts

-- 4. Category hierarchy
CREATE OR ALTER VIEW vw_ProductCategories AS
SELECT 
    c.id AS category_id,
    c.name AS category_name,
    c.parent_category_id,
    parent.name AS parent_category_name,
    (SELECT COUNT(p.id) FROM products p WHERE p.category_id = c.id) AS product_count
FROM 
    categories c
    LEFT JOIN categories parent ON c.parent_category_id = parent.id;
GO

SELECT * FROM vw_ProductCategories;

-- 5. Products by order frequency
CREATE OR ALTER VIEW vw_PopularProducts AS
SELECT 
    p.id,
    p.name,
    p.description,
    p.price,
    p.discount,
    c.name AS category_name,
    COUNT(oi.id) AS times_ordered,
    SUM(oi.quantity) AS total_quantity_ordered,
    (SELECT AVG(CAST(r.rating AS FLOAT)) FROM reviews r WHERE r.product_id = p.id) AS avg_rating,
    (SELECT COUNT(r.id) FROM reviews r WHERE r.product_id = p.id) AS review_count
FROM 
    products p
    LEFT JOIN categories c ON p.category_id = c.id
    LEFT JOIN order_items oi ON p.id = oi.product_id
GROUP BY 
    p.id, p.name, p.description, p.price, p.discount, c.name
GO

SELECT * FROM vw_PopularProducts;

-- 6. Products with low inventory
CREATE OR ALTER VIEW vw_LowStockProducts AS
SELECT 
    p.id,
    p.name,
    p.stockKeepingUnit,
    c.name AS category_name,
    u.name AS vendor_name,
    i.quantity_in_stock,
    CASE 
        WHEN i.quantity_in_stock = 0 THEN 'Out of Stock'
        WHEN i.quantity_in_stock < 5 THEN 'Critical'
        WHEN i.quantity_in_stock < 10 THEN 'Low'
        ELSE 'Adequate'
    END AS stock_level
FROM 
    products p
    INNER JOIN inventory i ON p.id = i.product_id
    LEFT JOIN categories c ON p.category_id = c.id
    LEFT JOIN vendors v ON p.vendor_id = v.id
    LEFT JOIN users u ON v.userId = u.id
WHERE 
    i.quantity_in_stock < 10;
GO

SELECT * FROM vw_LowStockProducts;

-- =============================================
-- ORDER VIEWS
-- =============================================

-- 1. Orders with items and amounts
CREATE OR ALTER VIEW vw_OrderDetails AS
SELECT 
    o.id AS order_id,
    o.order_date,
    o.order_status,
    o.payment_status,
    o.total_amount,
    u.id AS user_id,
    u.name AS customer_name,
    u.email AS customer_email,
    (SELECT COUNT(oi.id) FROM order_items oi WHERE oi.order_id = o.id) AS item_count,
    (SELECT SUM(oi.quantity) FROM order_items oi WHERE oi.order_id = o.id) AS total_items
FROM 
    orders o
    INNER JOIN users u ON o.user_id = u.id;
GO


SELECT * FROM vw_OrderDetails;

-- 2. Orders with shipping information
CREATE OR ALTER VIEW vw_OrdersWithShipping AS
SELECT 
    o.id AS order_id,
    o.order_date,
    o.order_status,
    o.payment_status,
    o.total_amount,
    u.name AS customer_name,
    s.shipping_method,
    s.tracking_number,
    s.estimated_delivery,
    s.status AS shipping_status,
    (SELECT TOP 1 address_line FROM user_addresses WHERE user_id = u.id AND is_primary = 1) AS shipping_address
FROM 
    orders o
    INNER JOIN users u ON o.user_id = u.id
    LEFT JOIN shipping s ON o.id = s.order_id;
GO

-- 3. Orders awaiting processing
CREATE OR ALTER VIEW vw_PendingOrders AS
SELECT 
    o.id AS order_id,
    o.order_date,
    o.user_id,
    u.name AS customer_name,
    u.email AS customer_email,
    o.total_amount,
    o.payment_status,
    s.shipping_method,
    s.status AS shipping_status,
    DATEDIFF(day, o.order_date, GETDATE()) AS days_pending
FROM 
    orders o
    INNER JOIN users u ON o.user_id = u.id
    LEFT JOIN shipping s ON o.id = s.order_id
WHERE 
    o.order_status IN ('Pending', 'Processing')
    OR (s.status IS NOT NULL AND s.status NOT IN ('Delivered', 'Cancelled'));
GO

-- 4. Delivered orders
CREATE OR ALTER VIEW vw_CompletedOrders AS
SELECT 
    o.id AS order_id,
    o.order_date,
    o.user_id,
    u.name AS customer_name,
    o.total_amount,
    o.payment_status,
    s.shipping_method,
    s.tracking_number,
    s.estimated_delivery,
    s.status AS shipping_status,
    p.payment_method,
    p.payment_date,
    DATEDIFF(day, o.order_date, s.estimated_delivery) AS delivery_days
FROM 
    orders o
    INNER JOIN users u ON o.user_id = u.id
    INNER JOIN shipping s ON o.id = s.order_id
    LEFT JOIN payments p ON o.id = p.order_id
WHERE 
    o.order_status = 'Completed'
    AND s.status = 'Delivered';
GO

-- 5. Orders grouped by customer
CREATE OR ALTER VIEW vw_OrdersByCustomer AS
SELECT 
    u.id AS user_id,
    u.name AS customer_name,
    u.email,
    COUNT(o.id) AS order_count,
    SUM(o.total_amount) AS total_spent,
    MIN(o.order_date) AS first_order_date,
    MAX(o.order_date) AS last_order_date,
    AVG(o.total_amount) AS avg_order_value
FROM 
    users u
    INNER JOIN orders o ON u.id = o.user_id
GROUP BY 
    u.id, u.name, u.email;
GO

-- 6. Orders containing products from vendors
CREATE OR ALTER VIEW vw_OrdersByVendor AS
SELECT 
    v.id AS vendor_id,
    u.name AS vendor_name,
    COUNT(DISTINCT o.id) AS order_count,
    SUM(oi.quantity) AS total_items_sold,
    SUM(oi.total_price) AS total_revenue
FROM 
    vendors v
    INNER JOIN users u ON v.userId = u.id
    INNER JOIN products p ON v.id = p.vendor_id
    INNER JOIN order_items oi ON p.id = oi.product_id
    INNER JOIN orders o ON oi.order_id = o.id
GROUP BY 
    v.id, u.name;
GO

-- =============================================
-- FINANCIAL VIEWS
-- =============================================

-- 1. Payment information for orders
CREATE OR ALTER VIEW vw_PaymentDetails AS
SELECT 
    p.id AS payment_id,
    o.id AS order_id,
    u.name AS customer_name,
    p.payment_method,
    p.amount,
    p.payment_date,
    o.total_amount AS order_amount,
    o.order_status,
    o.payment_status,
    CASE 
        WHEN p.amount >= o.total_amount THEN 'Fully Paid'
        WHEN p.amount > 0 AND p.amount < o.total_amount THEN 'Partially Paid'
        ELSE 'Not Paid'
    END AS payment_completion_status
FROM 
    payments p
    INNER JOIN orders o ON p.order_id = o.id
    INNER JOIN users u ON o.user_id = u.id;
GO

-- 2. Orders with invoice details
CREATE OR ALTER VIEW vw_OrderInvoices AS
SELECT 
    i.id AS invoice_id,
    i.invoice_date,
    i.due_date,
    o.id AS order_id,
    o.order_date,
    u.name AS customer_name,
    v.id AS vendor_id,
    vendor_user.name AS vendor_name,
    i.total_amount,
    i.status AS invoice_status,
    i.payment_method,
    p.payment_date,
    i.billing_address,
    i.shipping_address
FROM 
    invoices i
    INNER JOIN orders o ON i.order_id = o.id
    INNER JOIN users u ON o.user_id = u.id
    LEFT JOIN vendors v ON i.vendor_id = v.id
    LEFT JOIN users vendor_user ON v.userId = vendor_user.id
    LEFT JOIN payments p ON i.payment_id = p.id;
GO

-- 3. Revenue by month
CREATE OR ALTER VIEW vw_MonthlyRevenue AS
SELECT 
    YEAR(o.order_date) AS year,
    MONTH(o.order_date) AS month,
    COUNT(DISTINCT o.id) AS order_count,
    SUM(o.total_amount) AS total_revenue,
    AVG(o.total_amount) AS avg_order_value,
    (SELECT COUNT(DISTINCT u.id) 
     FROM users u 
     WHERE u.user_type = 'customer' 
       AND EXISTS (SELECT 1 FROM orders o2 WHERE o2.user_id = u.id AND YEAR(o2.order_date) = YEAR(o.order_date) AND MONTH(o2.order_date) = MONTH(o.order_date))
    ) AS active_customers
FROM 
    orders o
WHERE 
    o.payment_status = 'Completed'
GROUP BY 
    YEAR(o.order_date), MONTH(o.order_date);
GO

-- 4. Revenue by product
CREATE OR ALTER VIEW vw_ProductRevenue AS
SELECT 
    p.id AS product_id,
    p.name AS product_name,
    c.name AS category_name,
    COUNT(DISTINCT oi.order_id) AS order_count,
    SUM(oi.quantity) AS units_sold,
    SUM(oi.total_price) AS total_revenue,
    AVG(oi.unit_price) AS avg_selling_price,
    (SELECT AVG(CAST(r.rating AS FLOAT)) FROM reviews r WHERE r.product_id = p.id) AS avg_rating
FROM 
    products p
    LEFT JOIN categories c ON p.category_id = c.id
    LEFT JOIN order_items oi ON p.id = oi.product_id
    LEFT JOIN orders o ON oi.order_id = o.id
WHERE 
    o.payment_status = 'Completed'
GROUP BY 
    p.id, p.name, c.name;
GO

-- 5. Revenue by category
CREATE OR ALTER VIEW vw_CategoryRevenue AS
SELECT 
    c.id AS category_id,
    c.name AS category_name,
    parent.name AS parent_category_name,
    COUNT(DISTINCT p.id) AS product_count,
    COUNT(DISTINCT oi.order_id) AS order_count,
    SUM(oi.quantity) AS units_sold,
    SUM(oi.total_price) AS total_revenue,
    AVG(oi.unit_price) AS avg_product_price
FROM 
    categories c
    LEFT JOIN categories parent ON c.parent_category_id = parent.id
    LEFT JOIN products p ON c.id = p.category_id
    LEFT JOIN order_items oi ON p.id = oi.product_id
    LEFT JOIN orders o ON oi.order_id = o.id
WHERE 
    o.payment_status = 'Completed' OR o.payment_status IS NULL
GROUP BY 
    c.id, c.name, parent.name;
GO

-- =============================================
-- CUSTOMER ENGAGEMENT VIEWS
-- =============================================

-- 1. Product reviews with user info
CREATE OR ALTER VIEW vw_ProductReviews AS
SELECT 
    r.id AS review_id,
    p.id AS product_id,
    p.name AS product_name,
    u.id AS user_id,
    u.name AS user_name,
    r.rating,
    r.comment,
    r.review_date,
    EXISTS (
        SELECT 1 FROM orders o 
        INNER JOIN order_items oi ON o.id = oi.order_id
        WHERE o.user_id = u.id AND oi.product_id = p.id
    ) AS verified_purchase
FROM 
    reviews r
    INNER JOIN products p ON r.product_id = p.id
    INNER JOIN users u ON r.user_id = u.id;
GO

-- 2. Products by rating
CREATE OR ALTER VIEW vw_TopRatedProducts AS
SELECT 
    p.id AS product_id,
    p.name AS product_name,
    c.name AS category_name,
    p.price,
    p.discount,
    u.name AS vendor_name,
    COUNT(r.id) AS review_count,
    AVG(CAST(r.rating AS FLOAT)) AS avg_rating,
    (SELECT COUNT(oi.id) FROM order_items oi WHERE oi.product_id = p.id) AS times_ordered
FROM 
    products p
    LEFT JOIN categories c ON p.category_id = c.id
    LEFT JOIN vendors v ON p.vendor_id = v.id
    LEFT JOIN users u ON v.userId = u.id
    LEFT JOIN reviews r ON p.id = r.product_id
GROUP BY 
    p.id, p.name, c.name, p.price, p.discount, u.name
HAVING 
    COUNT(r.id) > 0;
GO

-- 3. Customer wishlist items
CREATE OR ALTER VIEW vw_ProductReviews AS
SELECT 
    r.id AS review_id,
    p.id AS product_id,
    p.name AS product_name,
    u.id AS user_id,
    u.name AS user_name,
    r.rating,
    r.comment,
    r.review_date,
    CASE WHEN EXISTS (
        SELECT 1 FROM orders o 
        INNER JOIN order_items oi ON o.id = oi.order_id
        WHERE o.user_id = u.id AND oi.product_id = p.id
    ) THEN 1 ELSE 0 END AS verified_purchase
FROM 
    reviews r
    INNER JOIN products p ON r.product_id = p.id
    INNER JOIN users u ON r.user_id = u.id;
GO


SELECT * FROM vw_productReview

-- 4. Active shopping carts
CREATE OR ALTER VIEW vw_ActiveShoppingCarts AS
SELECT 
    u.id AS user_id,
    u.name AS user_name,
    p.id AS product_id,
    p.name AS product_name,
    sc.quantity,
    p.price,
    p.discount,
    p.price * (1 - (p.discount / 100)) * sc.quantity AS subtotal,
    i.quantity_in_stock,
    CASE 
        WHEN i.quantity_in_stock < sc.quantity THEN 'Insufficient Stock'
        WHEN i.quantity_in_stock = 0 THEN 'Out of Stock'
        ELSE 'Available'
    END AS availability_status,
    sc.created_at AS added_to_cart_date,
    sc.updated_at AS last_updated
FROM 
    shopping_cart sc
    INNER JOIN users u ON sc.user_id = u.id
    INNER JOIN products p ON sc.product_id = p.id
    LEFT JOIN inventory i ON p.id = i.product_id;
GO

-- =============================================
-- ANALYTICAL VIEWS
-- =============================================

-- 1. Sales performance by category
CREATE OR ALTER VIEW vw_CategoryPerformance AS
SELECT 
    c.id AS category_id,
    c.name AS category_name,
    parent.name AS parent_category_name,
    COUNT(DISTINCT p.id) AS product_count,
    SUM(i.quantity_in_stock) AS total_inventory,
    (SELECT COUNT(oi.id) FROM order_items oi 
     INNER JOIN products p2 ON oi.product_id = p2.id 
     WHERE p2.category_id = c.id) AS total_items_sold,
    (SELECT SUM(oi.total_price) FROM order_items oi 
     INNER JOIN products p2 ON oi.product_id = p2.id 
     WHERE p2.category_id = c.id) AS total_revenue,
    (SELECT AVG(CAST(r.rating AS FLOAT)) FROM reviews r 
     INNER JOIN products p2 ON r.product_id = p2.id 
     WHERE p2.category_id = c.id) AS avg_rating
FROM 
    categories c
    LEFT JOIN categories parent ON c.parent_category_id = parent.id
    LEFT JOIN products p ON c.id = p.category_id
    LEFT JOIN inventory i ON p.id = i.product_id
GROUP BY 
    c.id, c.name, parent.name;
GO

-- 2. Customer demographic data
CREATE OR ALTER VIEW vw_CustomerDemographics AS
SELECT 
    u.country,
    u.gender,
    FLOOR(DATEDIFF(YEAR, u.DateOfBirth, GETDATE()) / 10) * 10 AS age_group,
    COUNT(DISTINCT u.id) AS customer_count,
    COUNT(DISTINCT o.id) AS order_count,
    SUM(o.total_amount) AS total_revenue,
    AVG(o.total_amount) AS avg_order_value
FROM 
    users u
    LEFT JOIN orders o ON u.id = o.user_id
WHERE 
    u.user_type = 'customer'
GROUP BY 
    u.country, u.gender, FLOOR(DATEDIFF(YEAR, u.DateOfBirth, GETDATE()) / 10) * 10;
GO

-- 3. Sales by country/region
CREATE OR ALTER VIEW vw_GeographicalSales AS
SELECT 
    u.country,
    COUNT(DISTINCT u.id) AS customer_count,
    COUNT(DISTINCT o.id) AS order_count,
    SUM(o.total_amount) AS total_revenue,
    AVG(o.total_amount) AS avg_order_value,
    (SELECT TOP 1 p.category_id FROM order_items oi 
     INNER JOIN products p ON oi.product_id = p.id
     INNER JOIN orders o2 ON oi.order_id = o2.id
     INNER JOIN users u2 ON o2.user_id = u2.id
     WHERE u2.country = u.country
     GROUP BY p.category_id
     ORDER BY COUNT(*) DESC) AS most_popular_category
FROM 
    users u
    LEFT JOIN orders o ON u.id = o.user_id
WHERE 
    u.user_type = 'customer'
GROUP BY 
    u.country;
GO

-- 4. Vendor sales performance
CREATE OR ALTER VIEW vw_VendorPerformance AS
SELECT 
    v.id AS vendor_id,
    u.name AS vendor_name,
    COUNT(DISTINCT p.id) AS product_count,
    SUM(i.quantity_in_stock) AS total_inventory,
    COUNT(DISTINCT oi.order_id) AS order_count,
    SUM(oi.quantity) AS units_sold,
    SUM(oi.total_price) AS total_revenue,
    (SELECT AVG(CAST(r.rating AS FLOAT)) FROM reviews r 
     INNER JOIN products p2 ON r.product_id = p2.id
     WHERE p2.vendor_id = v.id) AS avg_product_rating
FROM 
    vendors v
    INNER JOIN users u ON v.userId = u.id
    LEFT JOIN products p ON v.id = p.vendor_id
    LEFT JOIN inventory i ON p.id = i.product_id
    LEFT JOIN order_items oi ON p.id = oi.product_id
GROUP BY 
    v.id, u.name;
GO

-- 5. Shopping carts without follow-up orders
CREATE OR ALTER VIEW vw_AbandonedCarts AS
SELECT 
    u.id AS user_id,
    u.name AS user_name,
    u.email,
    COUNT(sc.id) AS cart_items,
    SUM(p.price * (1 - (p.discount / 100)) * sc.quantity) AS cart_value,
    MIN(sc.created_at) AS first_item_added,
    MAX(sc.updated_at) AS last_activity,
    DATEDIFF(day, MAX(sc.updated_at), GETDATE()) AS days_inactive
FROM 
    shopping_cart sc
    INNER JOIN users u ON sc.user_id = u.id
    INNER JOIN products p ON sc.product_id = p.id
WHERE 
    NOT EXISTS (
        SELECT 1 FROM orders o 
        WHERE o.user_id = u.id 
        AND o.created_at > sc.created_at
    )
GROUP BY 
    u.id, u.name, u.email;
GO