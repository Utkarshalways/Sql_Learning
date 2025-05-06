-- ===================================
-- INVENTORY MANAGEMENT TRIGGERS
-- ===================================

-- 1. Update Inventory After Order
CREATE OR ALTER TRIGGER trg_UpdateInventoryAfterOrder
ON order_items
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Update inventory by decreasing the quantity for each product in the order
    UPDATE inv
    SET quantity_in_stock = quantity_in_stock - i.quantity
    FROM inventory inv
    INNER JOIN inserted i ON inv.product_id = i.product_id;
    
    -- Log the inventory update event
    INSERT INTO user_event_log (user_id, event_type, action_description)
    SELECT 
        o.user_id, 
        'InventoryUpdate', 
        'Inventory updated after order ' + i.order_id
    FROM inserted i
    JOIN orders o ON i.order_id = o.id;
END;
GO

-- 2. Low Stock Alert
CREATE OR ALTER TRIGGER trg_LowStockAlert
ON inventory
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @threshold INT = 5; -- Configure your threshold as needed
    
    -- Create alerts for products that have fallen below the threshold
    INSERT INTO alerts (alert_type, product_id, alert_message)
    SELECT 
        'LowInventory',
        i.product_id,
        'Inventory below threshold: ' + CAST(i.quantity_in_stock AS NVARCHAR(10)) + ' units left'
    FROM inserted i
    JOIN deleted d ON i.id = d.id
    JOIN products p ON i.product_id = p.id
    WHERE i.quantity_in_stock <= @threshold 
      AND (d.quantity_in_stock > @threshold OR i.quantity_in_stock < d.quantity_in_stock)
      AND NOT EXISTS (
          SELECT 1 FROM alerts a 
          WHERE a.product_id = i.product_id 
            AND a.alert_type = 'LowInventory' 
            AND a.is_resolved = 0
      );
END;
GO

-- 3. Inventory Validation
CREATE OR ALTER TRIGGER trg_ValidateInventory
ON order_items
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Create a table to store products with insufficient inventory
    DECLARE @insufficientProducts TABLE (
        product_id NVARCHAR(50),
        requested_quantity INT,
        available_quantity INT
    );
    
    -- Find products with insufficient inventory
    INSERT INTO @insufficientProducts
    SELECT 
        i.product_id,
        i.quantity,
        ISNULL(inv.quantity_in_stock, 0)
    FROM inserted i
    LEFT JOIN inventory inv ON i.product_id = inv.product_id
    WHERE ISNULL(inv.quantity_in_stock, 0) < i.quantity;
    
    -- Check if there are any products with insufficient inventory
    IF EXISTS (SELECT 1 FROM @insufficientProducts)
    BEGIN
        -- Option 1: Throw an error with details
        DECLARE @errorMsg NVARCHAR(4000) = 'Insufficient inventory for the following products: ';
        
        SELECT @errorMsg = @errorMsg + CHAR(13) + 
            'Product ID: ' + product_id + 
            ', Requested: ' + CAST(requested_quantity AS NVARCHAR(10)) + 
            ', Available: ' + CAST(available_quantity AS NVARCHAR(10))
        FROM @insufficientProducts;
        
        THROW 50000, @errorMsg, 1;
    END
    ELSE
    BEGIN
        -- All products have sufficient inventory, proceed with insertion
        INSERT INTO order_items (id, order_id, product_id, quantity, unit_price)
        SELECT id, order_id, product_id, quantity, unit_price
        FROM inserted;
    END
END;
GO

-- ===================================
-- ORDER PROCESSING TRIGGERS
-- ===================================

-- 1. Order Total Calculation
CREATE OR ALTER TRIGGER trg_UpdateOrderTotal
ON order_items
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Create a table with all affected order IDs
    DECLARE @affectedOrders TABLE (order_id NVARCHAR(50));
    
    -- Collect order IDs from inserted and deleted records
    INSERT INTO @affectedOrders
    SELECT order_id FROM inserted
    UNION
    SELECT order_id FROM deleted;
    
    -- Update the total amount for each affected order
    UPDATE o
    SET 
        total_amount = ISNULL((
            SELECT SUM(total_price) 
            FROM order_items 
            WHERE order_id = o.id
        ), 0),
        updated_at = GETDATE()
    FROM orders o
    WHERE o.id IN (SELECT order_id FROM @affectedOrders);
END;
GO

-- 2. Order Status Update After Payment
CREATE OR ALTER TRIGGER trg_UpdateOrderStatusAfterPayment
ON payments
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Update order payment status to 'Paid' when payment is received
    UPDATE o
    SET 
        payment_status = 'Paid',
        order_status = 
            CASE 
                WHEN o.order_status = 'Pending Payment' THEN 'Processing'
                ELSE o.order_status 
            END,
        updated_at = GETDATE()
    FROM orders o
    INNER JOIN inserted i ON o.id = i.order_id
    WHERE i.amount >= o.total_amount;
    
    -- Update order payment status to 'Partially Paid' when partial payment is received
    UPDATE o
    SET 
        payment_status = 'Partially Paid',
        updated_at = GETDATE()
    FROM orders o
    INNER JOIN inserted i ON o.id = i.order_id
    WHERE i.amount < o.total_amount;
END;
GO

-- 3. Customer Order History Update
CREATE OR ALTER TRIGGER trg_LogOrderStatusChange
ON orders
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Check if order_status has changed
    IF UPDATE(order_status)
    BEGIN
        -- Log the order status change
        INSERT INTO user_event_log (user_id, event_type, action_description)
        SELECT 
            i.user_id,
            'OrderStatusChange',
            'Order ' + i.id + ' status changed from "' + d.order_status + '" to "' + i.order_status + '"'
        FROM inserted i
        JOIN deleted d ON i.id = d.id
        WHERE i.order_status <> d.order_status;
    END
END;
GO

-- ===================================
-- USER & SECURITY TRIGGERS
-- ===================================

-- 1. Password Hashing
CREATE OR ALTER TRIGGER trg_HashPassword
ON users
INSTEAD OF INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Handle INSERT operations
    IF EXISTS (SELECT * FROM inserted WHERE NOT EXISTS (SELECT 1 FROM deleted WHERE deleted.id = inserted.id))
    BEGIN
        INSERT INTO users (
            id, name, email, password, phone_number, gender, 
            DateOfBirth, country, user_type
        )
        SELECT 
            i.id, i.name, i.email, 
            -- Hash the password if it's not already in binary format
            CASE 
                WHEN DATALENGTH(i.password) = 32 THEN i.password -- Already hashed
                ELSE HASHBYTES('SHA2_256', CONVERT(VARBINARY, i.password)) -- Hash the password
            END,
            i.phone_number, i.gender, i.DateOfBirth, i.country, i.user_type
        FROM inserted i;
    END
    
    -- Handle UPDATE operations
    IF EXISTS (SELECT * FROM deleted)
    BEGIN
        UPDATE u
        SET 
            u.name = i.name,
            u.email = i.email,
            -- Only update password if it has changed
            u.password = 
                CASE 
                    WHEN i.password <> d.password THEN 
                        CASE 
                            WHEN DATALENGTH(i.password) = 32 THEN i.password -- Already hashed
                            ELSE HASHBYTES('SHA2_256', CONVERT(VARBINARY, i.password)) -- Hash the password
                        END
                    ELSE d.password
                END,
            u.phone_number = i.phone_number,
            u.gender = i.gender,
            u.DateOfBirth = i.DateOfBirth,
            u.country = i.country,
            u.user_type = i.user_type
        FROM users u
        JOIN inserted i ON u.id = i.id
        JOIN deleted d ON u.id = d.id;
    END
END;
GO

-- 2. User Activity Logging
CREATE OR ALTER TRIGGER trg_LogUserActivity
ON users
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Log email changes
    IF UPDATE(email)
    BEGIN
        INSERT INTO user_event_log (user_id, event_type, action_description)
        SELECT 
            i.id,
            'ProfileUpdate',
            'Email changed from "' + ISNULL(d.email, 'NULL') + '" to "' + ISNULL(i.email, 'NULL') + '"'
        FROM inserted i
        JOIN deleted d ON i.id = d.id
        WHERE ISNULL(i.email, '') <> ISNULL(d.email, '');
    END
    
    -- Log phone number changes
    IF UPDATE(phone_number)
    BEGIN
        INSERT INTO user_event_log (user_id, event_type, action_description)
        SELECT 
            i.id,
            'ProfileUpdate',
            'Phone number changed from "' + ISNULL(d.phone_number, 'NULL') + '" to "' + ISNULL(i.phone_number, 'NULL') + '"'
        FROM inserted i
        JOIN deleted d ON i.id = d.id
        WHERE ISNULL(i.phone_number, '') <> ISNULL(d.phone_number, '');
    END
    
    -- Additional user activity logging can be added here
END;
GO

-- 3. Address Management
CREATE OR ALTER TRIGGER trg_ManagePrimaryAddress
ON user_addresses
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Only proceed if a new primary address is being set
    IF EXISTS (SELECT 1 FROM inserted WHERE is_primary = 1)
    BEGIN
        -- Update all other addresses for the same user to non-primary
        UPDATE a
        SET 
            a.is_primary = 0,
            a.modified_at = GETDATE()
        FROM user_addresses a
        INNER JOIN inserted i ON a.user_id = i.user_id
        WHERE a.id <> i.id          -- Not the currently inserted/updated address
          AND i.is_primary = 1      -- New address is primary
          AND a.is_primary = 1;     -- Old address was primary
    END
END;
GO

-- ===================================
-- DATA QUALITY TRIGGERS
-- ===================================

-- 1. Product Price History
-- First, create a table to store price history
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'product_price_history')
BEGIN
    CREATE TABLE product_price_history (
        id INT IDENTITY(1,1) PRIMARY KEY,
        product_id NVARCHAR(50),
        old_price DECIMAL(18,2),
        new_price DECIMAL(18,2),
        changed_at DATETIME DEFAULT GETDATE(),
        CONSTRAINT FK_pricehistory_product FOREIGN KEY (product_id)
            REFERENCES products(id) ON DELETE CASCADE
    );
END
GO

CREATE OR ALTER TRIGGER trg_TrackProductPriceChanges
ON products
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Check if price has been updated
    IF UPDATE(price)
    BEGIN
        -- Insert price change record
        INSERT INTO product_price_history (product_id, old_price, new_price)
        SELECT 
            i.id,
            d.price,
            i.price
        FROM inserted i
        JOIN deleted d ON i.id = d.id
        WHERE i.price <> d.price;
    END
END;
GO

-- 2. Review Validation
CREATE OR ALTER TRIGGER trg_ValidateProductReview
ON reviews
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Create a table to store invalid reviews
    DECLARE @invalidReviews TABLE (
        user_id NVARCHAR(50),
        product_id NVARCHAR(50),
        reason NVARCHAR(255)
    );
    
    -- Find reviews where the user hasn't purchased the product
    INSERT INTO @invalidReviews
    SELECT 
        i.user_id,
        i.product_id,
        'User has not purchased this product'
    FROM inserted i
    WHERE NOT EXISTS (
        SELECT 1
        FROM orders o
        JOIN order_items oi ON o.id = oi.order_id
        WHERE o.user_id = i.user_id
          AND oi.product_id = i.product_id
          AND o.order_status IN ('Delivered', 'Completed')
    );
    
    -- Check if there are any invalid reviews
    IF EXISTS (SELECT 1 FROM @invalidReviews)
    BEGIN
        -- Option 1: Throw an error with details
        DECLARE @errorMsg NVARCHAR(4000) = 'Invalid reviews detected: ';
        
        SELECT @errorMsg = @errorMsg + CHAR(13) + 
            'User ID: ' + user_id + 
            ', Product ID: ' + product_id + 
            ', Reason: ' + reason
        FROM @invalidReviews;
        
        THROW 50001, @errorMsg, 1;
    END
    ELSE
    BEGIN
        -- All reviews are valid, proceed with insertion
        INSERT INTO reviews (
            id, user_id, product_id, rating, 
            comment, review_date, created_at, updated_at
        )
        SELECT 
            id, user_id, product_id, rating, 
            comment, 
            ISNULL(review_date, GETDATE()), 
            GETDATE(), 
            GETDATE()
        FROM inserted;
    END
END;
GO

-- ===================================
-- BONUS: ADDITIONAL USEFUL TRIGGERS
-- ===================================

-- 1. Shopping Cart Item Validation
CREATE OR ALTER TRIGGER trg_ValidateCartItem
ON shopping_cart
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Check if product exists and is in stock
    IF EXISTS (
        SELECT 1 
        FROM inserted i
        LEFT JOIN inventory inv ON i.product_id = inv.product_id
        WHERE inv.quantity_in_stock IS NULL OR inv.quantity_in_stock = 0
    )
    BEGIN
        THROW 50002, 'Cannot add out-of-stock or non-existent product to cart', 1;
        RETURN;
    END
    
    -- Check if item already exists in cart
    MERGE shopping_cart AS target
    USING inserted AS source
    ON (target.user_id = source.user_id AND target.product_id = source.product_id)
    WHEN MATCHED THEN
        -- If item exists, update quantity and timestamp
        UPDATE SET 
            quantity = target.quantity + source.quantity,
            updated_at = GETDATE()
    WHEN NOT MATCHED THEN
        -- If item doesn't exist, insert new record
        INSERT (user_id, product_id, quantity, created_at, updated_at)
        VALUES (source.user_id, source.product_id, source.quantity, GETDATE(), GETDATE());
END;
GO

-- 2. Handle Automatic Invoice Generation
CREATE OR ALTER TRIGGER trg_GenerateInvoice
ON orders
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Generate invoice when order status changes to 'Completed'
    IF UPDATE(order_status)
    BEGIN
        INSERT INTO invoices (
            id, order_id, payment_id, vendor_id, 
            invoice_date, due_date, 
            billing_address, shipping_address,
            total_amount, payment_method, status
        )
        SELECT 
            'INV-' + CAST(NEWID() AS NVARCHAR(36)),  -- Generate invoice ID
            o.id,                                    -- Order ID
            p.id,                                    -- Payment ID (most recent)
            v.id,                                    -- Vendor ID
            GETDATE(),                               -- Invoice date
            DATEADD(DAY, 30, GETDATE()),             -- Due date (30 days)
            ua.address_line,                         -- Billing address
            ua.address_line,                         -- Shipping address (same as billing for simplicity)
            o.total_amount,                          -- Total amount
            p.payment_method,                        -- Payment method
            'Generated'                              -- Status
        FROM inserted i
        JOIN orders o ON i.id = o.id
        JOIN deleted d ON i.id = d.id
        JOIN order_items oi ON o.id = oi.order_id
        JOIN products pr ON oi.product_id = pr.id
        JOIN vendors v ON pr.vendor_id = v.id
        LEFT JOIN payments p ON o.id = p.order_id
        LEFT JOIN user_addresses ua ON o.user_id = ua.user_id AND ua.is_primary = 1
        WHERE i.order_status = 'Completed'
          AND d.order_status <> 'Completed'
          AND NOT EXISTS (
              SELECT 1 FROM invoices inv WHERE inv.order_id = o.id
          )
        GROUP BY o.id, p.id, v.id, o.total_amount, p.payment_method, ua.address_line;
    END
END;
GO

-- 3. Data Consistency Check for Categories
CREATE OR ALTER TRIGGER trg_PreventCategoryCircularReference
ON categories
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Check for circular references in category hierarchy
    DECLARE @HasCircularRef BIT = 0;
    
    WITH CategoryHierarchy AS (
        -- Base case: get all inserted/updated categories
        SELECT id, parent_category_id, 1 AS level
        FROM inserted
        
        UNION ALL
        
        -- Recursive case: get parent categories
        SELECT c.id, c.parent_category_id, ch.level + 1
        FROM categories c
        JOIN CategoryHierarchy ch ON c.id = ch.parent_category_id
        WHERE c.parent_category_id IS NOT NULL
          AND ch.level < 100  -- Prevent infinite recursion
    )
    
    SELECT @HasCircularRef = CASE WHEN EXISTS (
        SELECT 1
        FROM CategoryHierarchy ch1
        JOIN CategoryHierarchy ch2 ON ch1.id = ch2.parent_category_id
        WHERE ch1.parent_category_id = ch2.id
    ) THEN 1 ELSE 0 END;
    
    -- Check if any category is its own ancestor
    IF @HasCircularRef = 1
    BEGIN
        THROW 50003, 'Circular reference detected in category hierarchy', 1;
    END
END;
GO