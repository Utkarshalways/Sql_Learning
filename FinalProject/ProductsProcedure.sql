-- =========================================
-- ORDER PROCESSING PROCEDURES
-- =========================================

-- 1. Create new order with items
CREATE OR ALTER PROCEDURE sp_CreateOrder
    @OrderId NVARCHAR(50),  -- Now taken as input from the user
    @UserId NVARCHAR(50),
    @OrderItems OrderItemsTableType READONLY,
    @OrderStatus NVARCHAR(50) = 'Pending',
    @PaymentStatus NVARCHAR(50) = 'Pending'
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Calculate total amount
        DECLARE @TotalAmount DECIMAL(18,2);
        SELECT @TotalAmount = SUM(oi.quantity * 
            (p.price * (1 - ISNULL(p.discount, 0)/100)))
        FROM @OrderItems oi
        JOIN products p ON oi.product_id = p.id;

        -- Insert into orders
        INSERT INTO orders (id, user_id, order_date, order_status, total_amount, payment_status)
        VALUES (@OrderId, @UserId, GETDATE(), @OrderStatus, @TotalAmount, @PaymentStatus);

        -- Insert order items
        INSERT INTO order_items (id, order_id, product_id, quantity, unit_price)
        SELECT 
            CONVERT(NVARCHAR(50), NEWID()),
            @OrderId,
            oi.product_id,
            oi.quantity,
            p.price * (1 - ISNULL(p.discount, 0)/100)
        FROM @OrderItems oi
        JOIN products p ON oi.product_id = p.id;

        -- Update inventory
        UPDATE inv
        SET quantity_in_stock = inv.quantity_in_stock - oi.quantity
        FROM inventory inv
        JOIN @OrderItems oi ON inv.product_id = oi.product_id;

        -- Create low inventory alerts
        INSERT INTO alerts (alert_type, product_id, alert_message)
        SELECT 
            'LowInventory',
            inv.product_id,
            'Inventory below threshold: ' + CAST(inv.quantity_in_stock AS NVARCHAR(10)) + ' units left'
        FROM inventory inv
        WHERE inv.quantity_in_stock <= 5;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO


-- Define the OrderItemsTableType
CREATE TYPE OrderItemsTableType AS TABLE
(
    product_id NVARCHAR(50),
    quantity INT
);
GO

-- Declare table variable
DECLARE @Items OrderItemsTableType;
INSERT INTO @Items (product_id, quantity)
VALUES 
    ('PROD001', 1),
    ('PROD002', 2);

-- User-supplied Order ID
DECLARE @UserOrderId NVARCHAR(50) = 'ORD023';

-- Execute the procedure
EXEC sp_CreateOrder 
    @OrderId = @UserOrderId,
    @UserId = 'USR001',
    @OrderItems = @Items,
    @OrderStatus = 'Confirmed',
    @PaymentStatus = 'Paid';


-- Show the generated order ID
SELECT @GeneratedOrderId AS OrderID;

SELECT * FROM orders;

-- 2. Update order status
CREATE OR ALTER PROCEDURE sp_UpdateOrderStatus
    @OrderId NVARCHAR(50),
    @NewStatus NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Update the order status
        UPDATE orders
        SET 
            order_status = @NewStatus,
            updated_at = GETDATE()
        WHERE id = @OrderId;
        
        -- If the order is cancelled, we might want to handle that separately
        IF @NewStatus = 'Cancelled'
        BEGIN
            EXEC sp_CancelOrder @OrderId;
        END
        
        -- Log the event
        INSERT INTO user_event_log (user_id, event_type, action_description)
        SELECT 
            user_id, 
            'OrderStatusUpdate', 
            'Order ' + @OrderId + ' status updated to ' + @NewStatus
        FROM orders
        WHERE id = @OrderId;
    END TRY
    BEGIN CATCH
        -- Log the error
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
GO

-- 3. Cancel order with proper inventory adjustment
CREATE OR ALTER PROCEDURE sp_CancelOrder
    @OrderId NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Only proceed if the order exists and is not already cancelled
        IF EXISTS (SELECT 1 FROM orders WHERE id = @OrderId AND order_status != 'Cancelled')
        BEGIN
            -- Return items to inventory
            UPDATE inv
            SET quantity_in_stock = inv.quantity_in_stock + oi.quantity
            FROM inventory inv
            JOIN order_items oi ON inv.product_id = oi.product_id
            WHERE oi.order_id = @OrderId;

            -- Update order status
            UPDATE orders
            SET 
                order_status = 'Cancelled',
                updated_at = GETDATE()
            WHERE id = @OrderId;

            -- Optional: You could log refund as a new entry in another table or track it elsewhere

            -- Log the event
            INSERT INTO user_event_log (user_id, event_type, action_description)
            SELECT 
                user_id, 
                'OrderCancelled', 
                'Order ' + @OrderId + ' has been cancelled'
            FROM orders
            WHERE id = @OrderId;
        END
        ELSE
        BEGIN
            RAISERROR('Order does not exist or is already cancelled', 16, 1);
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
GO


SELECT * FROM payments;

-- 4. Process payment for an order
CREATE OR ALTER PROCEDURE sp_ProcessPayment
    @OrderId NVARCHAR(50),
    @PaymentMethod NVARCHAR(50),
    @Amount DECIMAL(18,2),
    @PaymentId NVARCHAR(50) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Generate a new payment ID
        SET @PaymentId = CONVERT(NVARCHAR(50), NEWID());
        
        -- Insert the payment record
        INSERT INTO payments (id, order_id, payment_method, amount, payment_date)
        VALUES (@PaymentId, @OrderId, @PaymentMethod, @Amount, GETDATE());
        
        -- Update the order's payment status
        UPDATE orders
        SET 
            payment_status = 'Completed',
            updated_at = GETDATE()
        WHERE id = @OrderId;
        
        -- Log the event
        INSERT INTO user_event_log (user_id, event_type, action_description)
        SELECT 
            user_id, 
            'PaymentProcessed', 
            'Payment of ' + CAST(@Amount AS NVARCHAR(20)) + ' processed for order ' + @OrderId
        FROM orders
        WHERE id = @OrderId;
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        -- Log the error
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
GO

-- 5. Create shipping record for order
CREATE OR ALTER PROCEDURE sp_CreateShipment
    @OrderId NVARCHAR(50),
    @ShippingMethod NVARCHAR(100),
    @TrackingNumber NVARCHAR(100),
    @EstimatedDelivery DATETIME
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Insert the shipping record
        INSERT INTO shipping (order_id, shipping_method, tracking_number, estimated_delivery, status)
        VALUES (@OrderId, @ShippingMethod, @TrackingNumber, @EstimatedDelivery, 'Processing');
        
        -- Update the order status
        UPDATE orders
        SET 
            order_status = 'Shipped',
            updated_at = GETDATE()
        WHERE id = @OrderId;
        
        -- Log the event
        INSERT INTO user_event_log (user_id, event_type, action_description)
        SELECT 
            user_id, 
            'OrderShipped', 
            'Shipment created for order ' + @OrderId + ' with tracking number ' + @TrackingNumber
        FROM orders
        WHERE id = @OrderId;
    END TRY
    BEGIN CATCH
        -- Log the error
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
GO

SELECT * FROM orders;
SELECT * FROM shipping;

-- 6. Update shipping status
CREATE OR ALTER PROCEDURE sp_UpdateShipmentStatus
    @OrderId NVARCHAR(50),
    @NewStatus NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Update the shipping status
        UPDATE shipping
        SET status = @NewStatus
        WHERE order_id = @OrderId;
        
        -- If delivered, update the order status as well
        IF @NewStatus = 'Delivered'
        BEGIN
            UPDATE orders
            SET 
                order_status = 'Completed',
                updated_at = GETDATE()
            WHERE id = @OrderId;
        END
        
        -- Log the event
        INSERT INTO user_event_log (user_id, event_type, action_description)
        SELECT 
            user_id, 
            'ShipmentStatusUpdate', 
            'Shipping status for order ' + @OrderId + ' updated to ' + @NewStatus
        FROM orders
        WHERE id = @OrderId;
    END TRY
    BEGIN CATCH
        -- Log the error
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
GO

-- Additional useful procedures

-- Inventory Management Procedure
CREATE OR ALTER PROCEDURE sp_UpdateInventory
    @ProductId NVARCHAR(50),
    @QuantityChange INT,  -- Positive for additions, negative for removals
    @ReasonCode NVARCHAR(50) = NULL  -- e.g., 'Restock', 'Adjustment', 'Damaged', etc.
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Check if inventory record exists
        IF NOT EXISTS (SELECT 1 FROM inventory WHERE product_id = @ProductId)
        BEGIN
            -- Create inventory record with initial quantity
            INSERT INTO inventory (id, product_id, quantity_in_stock)
            VALUES (CONVERT(NVARCHAR(50), NEWID()), @ProductId, @QuantityChange);
        END
        ELSE
        BEGIN
            -- Update existing inventory
            UPDATE inventory
            SET quantity_in_stock = quantity_in_stock + @QuantityChange
            WHERE product_id = @ProductId;
            
            -- Check for negative inventory
            IF EXISTS (SELECT 1 FROM inventory WHERE product_id = @ProductId AND quantity_in_stock < 0)
            BEGIN
                RAISERROR('Inventory cannot be negative', 16, 1);
                RETURN;
            END
        END
        
        -- Check for low inventory and create alerts if needed
        INSERT INTO alerts (alert_type, product_id, alert_message)
        SELECT 
            'LowInventory', 
            product_id, 
            'Inventory below threshold: ' + CAST(quantity_in_stock AS NVARCHAR(10)) + ' units left'
        FROM inventory 
        WHERE product_id = @ProductId AND quantity_in_stock <= 5; -- Threshold for low inventory alert
        
        -- Get product name for logging
        DECLARE @ProductName NVARCHAR(255);
        SELECT @ProductName = name FROM products WHERE id = @ProductId;
        
        -- Log inventory change event
        INSERT INTO user_event_log (user_id, event_type, action_description)
        VALUES (
            'SYSTEM', 
            'InventoryUpdate', 
            'Updated inventory for ' + @ProductName + ' (ID: ' + @ProductId + '): ' + 
            CAST(@QuantityChange AS NVARCHAR(10)) + ' units ' + 
            CASE WHEN @QuantityChange >= 0 THEN 'added' ELSE 'removed' END + 
            CASE WHEN @ReasonCode IS NULL THEN '' ELSE ' (Reason: ' + @ReasonCode + ')' END
        );
    END TRY
    BEGIN CATCH
        -- Log the error
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
GO

-- User Profile Management
CREATE OR ALTER PROCEDURE sp_UpdateUserProfile
    @UserId NVARCHAR(50),
    @Name NVARCHAR(255) = NULL,
    @Email NVARCHAR(255) = NULL,
    @PhoneNumber NVARCHAR(20) = NULL,
    @Gender NVARCHAR(10) = NULL,
    @DateOfBirth DATETIME = NULL,
    @Country NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Update only the provided fields
        UPDATE users
        SET 
            name = ISNULL(@Name, name),
            email = ISNULL(@Email, email),
            phone_number = ISNULL(@PhoneNumber, phone_number),
            gender = ISNULL(@Gender, gender),
            DateOfBirth = ISNULL(@DateOfBirth, DateOfBirth),
            country = ISNULL(@Country, country)
        WHERE id = @UserId;
        
        -- Log the event
        INSERT INTO user_event_log (user_id, event_type, action_description)
        VALUES (@UserId, 'ProfileUpdate', 'User profile updated');
    END TRY
    BEGIN CATCH
        -- Log the error
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
GO

-- Address Management
CREATE OR ALTER PROCEDURE sp_ManageUserAddress
    @UserId NVARCHAR(50),
    @AddressLine NVARCHAR(500),
    @AddressType NVARCHAR(50),
    @IsPrimary BIT = 0,
    @AddressId INT = NULL,  -- If provided, update existing; if NULL, create new
    @Operation NVARCHAR(10) = 'ADD'  -- 'ADD', 'UPDATE', 'DELETE'
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Handle different operations
        IF @Operation = 'ADD'
        BEGIN
            -- If setting as primary, unset other addresses of same type
            IF @IsPrimary = 1
            BEGIN
                UPDATE user_addresses
                SET is_primary = 0
                WHERE user_id = @UserId AND address_type = @AddressType;
            END
            
            -- Add new address
            INSERT INTO user_addresses (user_id, address_line, address_type, is_primary)
            VALUES (@UserId, @AddressLine, @AddressType, @IsPrimary);
            
            -- Log the event
            INSERT INTO user_event_log (user_id, event_type, action_description)
            VALUES (@UserId, 'AddressAdded', 'Added new ' + @AddressType + ' address');
        END
        ELSE IF @Operation = 'UPDATE' AND @AddressId IS NOT NULL
        BEGIN
            -- If setting as primary, unset other addresses of same type
            IF @IsPrimary = 1
            BEGIN
                UPDATE user_addresses
                SET is_primary = 0
                WHERE user_id = @UserId AND address_type = @AddressType;
            END
            
            -- Update existing address
            UPDATE user_addresses
            SET 
                address_line = @AddressLine,
                address_type = @AddressType,
                is_primary = @IsPrimary,
                modified_at = GETDATE()
            WHERE id = @AddressId AND user_id = @UserId;
            
            -- Log the event
            INSERT INTO user_event_log (user_id, event_type, action_description)
            VALUES (@UserId, 'AddressUpdated', 'Updated ' + @AddressType + ' address');
        END
        ELSE IF @Operation = 'DELETE' AND @AddressId IS NOT NULL
        BEGIN
            -- Delete address
            DELETE FROM user_addresses
            WHERE id = @AddressId AND user_id = @UserId;
            
            -- Log the event
            INSERT INTO user_event_log (user_id, event_type, action_description)
            VALUES (@UserId, 'AddressDeleted', 'Deleted address');
        END
        ELSE
        BEGIN
            RAISERROR('Invalid operation or missing address ID', 16, 1);
        END
    END TRY
    BEGIN CATCH
        -- Log the error
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
GO

-- Product Search and Filtering
CREATE OR ALTER PROCEDURE sp_SearchProducts
    @SearchTerm NVARCHAR(255) = NULL,
    @CategoryId NVARCHAR(50) = NULL,
    @MinPrice DECIMAL(18,2) = NULL,
    @MaxPrice DECIMAL(18,2) = NULL,
    @VendorId BIGINT = NULL,
    @SortBy NVARCHAR(50) = 'name',  -- 'name', 'price_asc', 'price_desc', 'newest', 'rating'
    @PageNumber INT = 1,
    @PageSize INT = 20
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Calculate pagination
    DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;
    
    -- Build dynamic SQL for flexibility
    DECLARE @SQL NVARCHAR(MAX) = N'
    SELECT 
        p.id, p.name, p.description, p.price, 
        p.discount, 
        (p.price * (1 - ISNULL(p.discount, 0)/100)) AS final_price,
        c.name AS category_name,
        v.id AS vendor_id,
        u.name AS vendor_name,
        i.quantity_in_stock,
        ISNULL((SELECT AVG(CAST(rating AS FLOAT)) FROM reviews WHERE product_id = p.id), 0) AS avg_rating,
        (SELECT COUNT(*) FROM reviews WHERE product_id = p.id) AS review_count
    FROM products p
    JOIN categories c ON p.category_id = c.id
    JOIN vendors v ON p.vendor_id = v.id
    JOIN users u ON v.userId = u.id
    LEFT JOIN inventory i ON p.id = i.product_id
    WHERE 1=1';
    
    -- Add filters
    IF @SearchTerm IS NOT NULL
        SET @SQL = @SQL + N' AND (p.name LIKE ''%' + @SearchTerm + '%'' OR p.description LIKE ''%' + @SearchTerm + '%'')';
    
    IF @CategoryId IS NOT NULL
        SET @SQL = @SQL + N' AND (p.category_id = ''' + @CategoryId + ''' OR c.parent_category_id = ''' + @CategoryId + ''')';
    
    IF @MinPrice IS NOT NULL
        SET @SQL = @SQL + N' AND (p.price * (1 - ISNULL(p.discount, 0)/100)) >= ' + CAST(@MinPrice AS NVARCHAR);
    
    IF @MaxPrice IS NOT NULL
        SET @SQL = @SQL + N' AND (p.price * (1 - ISNULL(p.discount, 0)/100)) <= ' + CAST(@MaxPrice AS NVARCHAR);
    
    IF @VendorId IS NOT NULL
        SET @SQL = @SQL + N' AND v.id = ' + CAST(@VendorId AS NVARCHAR);
    
    -- Add sorting
    SET @SQL = @SQL + N' ORDER BY ';
    
    IF @SortBy = 'name'
        SET @SQL = @SQL + N'p.name ASC';
    ELSE IF @SortBy = 'price_asc'
        SET @SQL = @SQL + N'final_price ASC';
    ELSE IF @SortBy = 'price_desc'
        SET @SQL = @SQL + N'final_price DESC';
    ELSE IF @SortBy = 'newest'
        SET @SQL = @SQL + N'p.id DESC';  -- Assuming newer products have higher IDs
    ELSE IF @SortBy = 'rating'
        SET @SQL = @SQL + N'avg_rating DESC, review_count DESC';
    ELSE
        SET @SQL = @SQL + N'p.name ASC';  -- Default sort
    
    -- Add pagination
    SET @SQL = @SQL + N' OFFSET ' + CAST(@Offset AS NVARCHAR) + ' ROWS FETCH NEXT ' + CAST(@PageSize AS NVARCHAR) + ' ROWS ONLY;';
    
    -- Execute the query
    EXEC sp_executesql @SQL;
    
    -- Get total count for pagination info
    SET @SQL = N'
    SELECT COUNT(*) AS TotalCount
    FROM products p
    JOIN categories c ON p.category_id = c.id
    JOIN vendors v ON p.vendor_id = v.id
    WHERE 1=1';
    
    -- Add the same filters
    IF @SearchTerm IS NOT NULL
        SET @SQL = @SQL + N' AND (p.name LIKE ''%' + @SearchTerm + '%'' OR p.description LIKE ''%' + @SearchTerm + '%'')';
    
    IF @CategoryId IS NOT NULL
        SET @SQL = @SQL + N' AND (p.category_id = ''' + @CategoryId + ''' OR c.parent_category_id = ''' + @CategoryId + ''')';
    
    IF @MinPrice IS NOT NULL
        SET @SQL = @SQL + N' AND (p.price * (1 - ISNULL(p.discount, 0)/100)) >= ' + CAST(@MinPrice AS NVARCHAR);
    
    IF @MaxPrice IS NOT NULL
        SET @SQL = @SQL + N' AND (p.price * (1 - ISNULL(p.discount, 0)/100)) <= ' + CAST(@MaxPrice AS NVARCHAR);
    
    IF @VendorId IS NOT NULL
        SET @SQL = @SQL + N' AND v.id = ' + CAST(@VendorId AS NVARCHAR);
    
    -- Execute the count query
    EXEC sp_executesql @SQL;
END;
GO

-- Customer Analytics - Get Customer Purchase History
CREATE OR ALTER PROCEDURE sp_GetCustomerPurchaseHistory
    @UserId NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Get basic customer info
    SELECT 
        u.id,
        u.name,
        u.email,
        u.phone_number,
        COUNT(DISTINCT o.id) AS TotalOrders,
        SUM(o.total_amount) AS TotalSpent,
        MAX(o.order_date) AS LastOrderDate
    FROM users u
    JOIN orders o ON u.id = o.user_id
    WHERE u.id = @UserId
    GROUP BY u.id, u.name, u.email, u.phone_number;
    
    -- Get order history
    SELECT 
        o.id AS OrderId,
        o.order_date,
        o.total_amount,
        o.order_status,
        o.payment_status,
        p.id AS PaymentId,
        p.payment_method,
        p.payment_date,
        s.shipping_method,
        s.tracking_number,
        s.status AS ShippingStatus
    FROM orders o
    LEFT JOIN payments p ON o.id = p.order_id
    LEFT JOIN shipping s ON o.id = s.order_id
    WHERE o.user_id = @UserId
    ORDER BY o.order_date DESC;
    
    -- Get item details for each order
    SELECT 
        o.id AS OrderId,
        o.order_date,
        oi.product_id,
        p.name AS ProductName,
        c.name AS CategoryName,
        oi.quantity,
        oi.unit_price,
        oi.total_price
    FROM orders o
    JOIN order_items oi ON o.id = oi.order_id
    JOIN products p ON oi.product_id = p.id
    JOIN categories c ON p.category_id = c.id
    WHERE o.user_id = @UserId
    ORDER BY o.order_date DESC, oi.product_id;
    
    -- Get preferred categories (based on purchase history)
    SELECT 
        c.name AS CategoryName,
        COUNT(DISTINCT oi.id) AS ItemCount,
        SUM(oi.total_price) AS TotalSpent
    FROM orders o
    JOIN order_items oi ON o.id = oi.order_id
    JOIN products p ON oi.product_id = p.id
    JOIN categories c ON p.category_id = c.id
    WHERE o.user_id = @UserId
    GROUP BY c.name
    ORDER BY TotalSpent DESC;
END;
GO

-- Product Performance Analytics
CREATE OR ALTER PROCEDURE sp_GetProductPerformance
    @ProductId NVARCHAR(50) = NULL,
    @Days INT = 30
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @StartDate DATETIME = DATEADD(DAY, -@Days, GETDATE());
    
    -- If specific product
    IF @ProductId IS NOT NULL
    BEGIN
        -- Get product details
        SELECT 
            p.id,
            p.name,
            p.description,
            c.name AS CategoryName,
            p.price,
            p.discount,
            (p.price * (1 - ISNULL(p.discount, 0)/100)) AS FinalPrice,
            i.quantity_in_stock,
            u.name AS VendorName
        FROM products p
        JOIN categories c ON p.category_id = c.id
        JOIN vendors v ON p.vendor_id = v.id
        JOIN users u ON v.userId = u.id
        LEFT JOIN inventory i ON p.id = i.product_id
        WHERE p.id = @ProductId;
        
        -- Get sales performance
        SELECT 
            COUNT(DISTINCT o.id) AS OrderCount,
            SUM(oi.quantity) AS UnitsSold,
            SUM(oi.total_price) AS TotalRevenue,
            COUNT(DISTINCT o.user_id) AS UniqueCustomers
        FROM order_items oi
        JOIN orders o ON oi.order_id = o.id
        WHERE 
            oi.product_id = @ProductId
            AND o.order_date >= @StartDate
            AND o.order_status != 'Cancelled';
            
        -- Get daily sales trend
        SELECT 
            CAST(o.order_date AS DATE) AS OrderDate,
            SUM(oi.quantity) AS UnitsSold,
            SUM(oi.total_price) AS Revenue
        FROM order_items oi
        JOIN orders o ON oi.order_id = o.id
        WHERE 
            oi.product_id = @ProductId
            AND o.order_date >= @StartDate
            AND o.order_status != 'Cancelled'
        GROUP BY CAST(o.order_date AS DATE)
        ORDER BY OrderDate;
        
        -- Get review statistics
        SELECT 
            COUNT(*) AS TotalReviews,
            AVG(CAST(rating AS FLOAT)) AS AverageRating,
            COUNT(CASE WHEN rating >= 4 THEN 1 END) AS PositiveReviews,
            COUNT(CASE WHEN rating <= 2 THEN 1 END) AS NegativeReviews
        FROM reviews
        WHERE product_id = @ProductId;
    END
    ELSE
    BEGIN
        -- Top selling products
        SELECT TOP 20
            p.id,
            p.name,
            c.name AS CategoryName,
            SUM(oi.quantity) AS UnitsSold,
            SUM(oi.total_price) AS TotalRevenue,
            COUNT(DISTINCT o.id) AS OrderCount,
            AVG(CAST(r.rating AS FLOAT)) AS AverageRating
        FROM products p
        JOIN order_items oi ON p.id = oi.product_id
        JOIN orders o ON oi.order_id = o.id
        JOIN categories c ON p.category_id = c.id
        LEFT JOIN reviews r ON p.id = r.product_id
        WHERE 
            o.order_date >= @StartDate
            AND o.order_status != 'Cancelled'
        GROUP BY p.id, p.name, c.name
        ORDER BY UnitsSold DESC;
        
        -- Top rated products (with minimum review count)
        SELECT TOP 20
            p.id,
            p.name,
            c.name AS CategoryName,
            COUNT(r.id) AS ReviewCount,
            AVG(CAST(r.rating AS FLOAT)) AS AverageRating,
            SUM(oi.quantity) AS UnitsSold
        FROM products p
        JOIN categories c ON p.category_id = c.id
        JOIN reviews r ON p.id = r.product_id
        LEFT JOIN order_items oi ON p.id = oi.product_id
        LEFT JOIN orders o ON oi.order_id = o.id AND o.order_date >= @StartDate AND o.order_status != 'Cancelled'
        GROUP BY p.id, p.name, c.name
        HAVING COUNT(r.id) >= 5 -- Minimum review threshold
        ORDER BY AverageRating DESC, ReviewCount DESC;
        
        -- Low inventory products that need restocking
        SELECT
            p.id,
            p.name,
            i.quantity_in_stock,
            u.name AS VendorName
        FROM products p
        JOIN inventory i ON p.id = i.product_id
        JOIN vendors v ON p.vendor_id = v.id
        JOIN users u ON v.userId = u.id
        WHERE i.quantity_in_stock <= 5
        ORDER BY i.quantity_in_stock ASC;
    END
END;
GO