-- =========================================
-- ORDER PROCESSING PROCEDURES
-- =========================================

-- 1. Create new order with items
CREATE OR ALTER PROCEDURE sp_CreateOrder
    @UserId NVARCHAR(50),
    @CouponCode NVARCHAR(50) = NULL,
    @OrderStatus NVARCHAR(50) = 'Pending',
    @PaymentMethod NVARCHAR(50) = NULL, -- New: to capture payment method
    @PaymentStatus NVARCHAR(50) = 'Pending' -- Moved to payments table
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Generate new Order ID
        DECLARE @OrderId NVARCHAR(50);
        DECLARE @MaxOrderId NVARCHAR(50);
        DECLARE @NewOrderNumber INT;

        SELECT @MaxOrderId = MAX(id) FROM orders;

        IF @MaxOrderId IS NOT NULL 
            SET @NewOrderNumber = CAST(SUBSTRING(@MaxOrderId, 4, LEN(@MaxOrderId) - 3) AS INT) + 1;
        ELSE 
            SET @NewOrderNumber = 1;

        SET @OrderId = 'ORD' + CAST(@NewOrderNumber AS NVARCHAR(20));

        -- Calculate total amount from shopping cart
        DECLARE @TotalAmount DECIMAL(18,2);
        SELECT @TotalAmount = SUM(sc.quantity * (p.price * (1 - ISNULL(p.discount, 0)/100)))
        FROM shopping_cart sc
        JOIN products p ON sc.product_id = p.id
        WHERE sc.user_id = @UserId;

        IF @TotalAmount IS NULL OR @TotalAmount = 0
        BEGIN
            RAISERROR('Shopping cart is empty or invalid', 16, 1);
            RETURN;
        END

		IF UPPER(@PaymentMethod) NOT IN ('COD','CARD','NET BANKING','PAYPAL','UPI')
		BEGIN
			RAISERROR('Please Enter Correct payment method',16,1)
		END

        -- Coupon handling
        DECLARE @CouponId NVARCHAR(50) = NULL;
        DECLARE @DiscountAmount DECIMAL(18,2) = 0;
        DECLARE @FinalAmount DECIMAL(18,2) = @TotalAmount;
        DECLARE @ErrorMessage NVARCHAR(255);

        IF @CouponCode IS NOT NULL AND @CouponCode != ''
        BEGIN
            DECLARE @IsValid BIT;

            EXEC sp_ValidateCoupon
                @CouponCode = @CouponCode,
                @UserId = @UserId,
                @OrderAmount = @TotalAmount,
                @IsValid = @IsValid OUTPUT,
                @DiscountAmount = @DiscountAmount OUTPUT,
                @CouponId = @CouponId OUTPUT,
                @ErrorMessage = @ErrorMessage OUTPUT;

            IF @IsValid = 1
                SET @FinalAmount = @TotalAmount - @DiscountAmount;
            ELSE
            BEGIN
                SET @CouponId = NULL;
                SET @DiscountAmount = 0;
            END
        END

        -- Insert into orders (note: payment_status removed)
        INSERT INTO orders (
            id, user_id, order_date, order_status, 
            total_amount, coupon_id, discount_amount
        )
        VALUES (
            @OrderId, @UserId, GETDATE(), @OrderStatus, 
            @FinalAmount, @CouponId, @DiscountAmount
        );

        -- Insert payment for this order
        DECLARE @MaxPaymentId NVARCHAR(50);
        DECLARE @NewPaymentNumber INT;

        -- Get the maximum payment ID
        SELECT @MaxPaymentId = MAX(id) FROM payments;

        -- Extract the numeric part and increment it
        IF @MaxPaymentId IS NOT NULL 
        BEGIN
            SET @NewPaymentNumber = CAST(SUBSTRING(@MaxPaymentId, 4, LEN(@MaxPaymentId) - 3) AS INT) + 1;
        END
        ELSE
        BEGIN
            SET @NewPaymentNumber = 1;  -- Start from 1 if no payments exist or format doesn't match
        END
		DECLARE @PaymentId VARCHAR(20);
		 -- Format the new Payment ID with leading zeros up to 3 digits
        SET @PaymentId = 'PAY' + CAST(@NewPaymentNumber AS NVARCHAR(20))

		IF UPPER(@PaymentMethod) <> 'COD'
		BEGIN 
			SET @PaymentStatus = 'Paid'
		END
	
        INSERT INTO payments (
            id, order_id, payment_method, amount, payment_date, payment_status
        )
        VALUES (
            @PaymentId, @OrderId, @PaymentMethod, @FinalAmount, GETDATE(), @PaymentStatus
        );

        -- Log coupon usage if applied
        IF @CouponId IS NOT NULL
        BEGIN
            INSERT INTO user_event_log (user_id, event_type, action_description)
            VALUES (
                @UserId, 
                'CouponApplied', 
                'Coupon ' + @CouponCode + ' applied to order ' + @OrderId +
                ' with discount amount ' + CAST(@DiscountAmount AS NVARCHAR(20))
            );
        END

        -- Insert order items
        INSERT INTO order_items (id, order_id, product_id, quantity, unit_price)
        SELECT 
            CONVERT(NVARCHAR(50), NEWID()),
            @OrderId,
            sc.product_id,
            sc.quantity,
            p.price * (1 - ISNULL(p.discount, 0)/100)
        FROM shopping_cart sc
        JOIN products p ON sc.product_id = p.id
        WHERE sc.user_id = @UserId;

        -- Update inventory
        UPDATE inv
        SET quantity_in_stock = inv.quantity_in_stock - sc.quantity
        FROM inventory inv
        JOIN shopping_cart sc ON inv.product_id = sc.product_id
        WHERE sc.user_id = @UserId;

        -- Create low inventory alerts
        INSERT INTO alerts (alert_type, product_id, alert_message)
        SELECT 
            'LowInventory',
            inv.product_id,
            'Inventory below threshold: ' + CAST(inv.quantity_in_stock AS NVARCHAR(10)) + ' units left'
        FROM inventory inv
        WHERE inv.quantity_in_stock <= 5
        AND NOT EXISTS (
            SELECT 1 FROM alerts 
            WHERE product_id = inv.product_id 
                AND alert_type = 'LowInventory' 
                AND is_resolved = 0
        );

        -- Clear cart
        DELETE FROM shopping_cart WHERE user_id = @UserId;

        COMMIT TRANSACTION;

        -- Return new order
        SELECT * FROM orders WHERE id = @OrderId;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @ErrorMessage = ERROR_MESSAGE();
        PRINT @ErrorMessage;
    END CATCH
END;
GO


SELECT * FROM orders WHERE id = 'ORD024';



SELECT * FROM shopping_cart WHERE user_id = 'USR016'

-- Execute the procedure
EXEC sp_CreateOrder 
    @UserId = 'USR014',
	@CouponCode = 'SAVE20',
    @OrderStatus = 'Confirmed',
	@PaymentMethod = 'CODdsaf'


SELECT * FROM orders;
SELECT * FROM coupons;

SELECT * FROM user_event_log;


-- 2. Update order status


SELECT * FROM orders;
SELECT * FROM orders WHERE user_id = 'USR018'
SELECT * FROM inventory;
sELECT * FROM products;


CREATE OR ALTER PROCEDURE sp_GetCartDetailsAndSummary
    @UserId NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- 1. Return detailed cart items
        SELECT 
            p.id AS ProductId,
            p.name AS ProductName,
            p.price AS UnitPrice,
            sc.quantity AS Quantity,
            (p.price * sc.quantity) AS Subtotal
        FROM shopping_cart sc
        INNER JOIN products p ON sc.product_id = p.id
        WHERE sc.user_id = @UserId;

        -- 2. Return total summary
        SELECT 
            SUM(sc.quantity) AS TotalQuantity,
            SUM(sc.quantity * p.price) AS TotalAmount
        FROM shopping_cart sc
        INNER JOIN products p ON sc.product_id = p.id
        WHERE sc.user_id = @UserId;

    END TRY
    BEGIN CATCH
        -- Handle errors
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT @ErrorMessage;
    END CATCH
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

            UPDATE payments
			SET 
				payment_status = 'Refunded',
				updated_at = GETDATE()
				WHERE order_id = @OrderId

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
		PRINT @ErrorMessage
    END CATCH;
END;
GO


EXEC sp_CancelOrder @OrderId = 'ORD0232'

SELECT * FROM orders;

SELECT * FROM payments;


CREATE OR ALTER PROCEDURE sp_UpdateOrderStatus
    @OrderId NVARCHAR(50),
    @NewStatus NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Check if the OrderId exists
        IF NOT EXISTS (SELECT 1 FROM orders WHERE id = @OrderId)
        BEGIN
            RAISERROR('Order ID %s not found.', 16, 1, @OrderId);
            RETURN;
        END

        -- Update the order status
        UPDATE orders
        SET 
            order_status = @NewStatus,
            updated_at = GETDATE()
        WHERE id = @OrderId;

        -- If the order is cancelled, call the cancel procedure
        IF LOWER(@NewStatus) = 'cancelled'
        BEGIN
            EXEC sp_CancelOrder @OrderId;
        END

        -- If the order is shipped, mark the payment as completed
        IF LOWER(@NewStatus) = 'delivered'
        BEGIN
            UPDATE payments
            SET 
                payment_status = 'Paid',
                updated_at = GETDATE()
            WHERE order_id = @OrderId;

			UPDATE shipping
			SET 
			status = 'Delivered'
			WHERE order_id = @OrderId
        END


        -- Log the event
        INSERT INTO user_event_log (user_id, event_type, action_description)
        SELECT 
            user_id, 
            'OrderStatusUpdate', 
            'Order ' + @OrderId + ' status updated to ' + @NewStatus
        FROM orders
        WHERE id = @OrderId;

		SELECT id,order_status,updated_at FROM orders WHERE id = @OrderId;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT 'Error: ' + @ErrorMessage;
    END CATCH;
END;
GO


SELECT * FROM payments;

SELECT * FROM orders;

SELECT * FROM user_event_log;

SELECT * FROM customers WHERE userid = 'USR014'

DECLARE @paymentid VARCHAR(30) ;
EXEC sp_ProcessPayment @OrderId = 'ORD28',@PaymentMethod = 'UPI',@Paymentid = @paymentid OUTPUT
SELECT @paymentid as ID

SELECT * FROM orders WHERE id = 'ORD27'

-- 5. Create shipping record for order
CREATE OR ALTER PROCEDURE sp_CreateShipment
    @OrderId NVARCHAR(50),
    @ShippingMethod NVARCHAR(100),
    @TrackingNumber NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY

		DECLARE @OrderDate DATETIME;
        DECLARE @EstimatedDelivery DATETIME;

        -- Retrieve the order date from the orders table
        SELECT @OrderDate = order_date FROM orders WHERE id = @OrderId;

        -- Check if the order exists
        IF @OrderDate IS NULL
        BEGIN
            RAISERROR('Order ID does not exist.', 16, 1);
            RETURN;
        END
        -- Calculate the estimated delivery date (4 days after the order date)
        SET @EstimatedDelivery = DATEADD(DAY, 4, @OrderDate);

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

		SELECT * FROM shipping where order_id = @OrderId
    END TRY
    BEGIN CATCH
        -- Log the error
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT @ErrorMessage
    END CATCH;
END;
GO

SELECT 
    o.id AS order_id,
    o.order_date,
    o.order_status,
    s.shipping_method,
    s.tracking_number,
    s.estimated_delivery,
    s.status AS shipping_status
FROM 
    orders o
LEFT JOIN 
    shipping s ON o.id = s.order_id
WHERE 
    o.id = 'ORD28';

SELECT * FROM orders;
SELECT * FROM shipping;

EXEC sp_CreateShipment @OrderId = 'ORD27',@ShippingMethod = 'Delhivery', @TrackingNumber = 'TRACK123'

SELECT * FROM shipping;


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
           -- Generate new Inventory ID
DECLARE @InventoryId NVARCHAR(50);
DECLARE @MaxInventoryId NVARCHAR(50);
DECLARE @NewInventoryNumber INT;

SELECT @MaxInventoryId = MAX(id) FROM inventory;

IF @MaxInventoryId IS NOT NULL AND ISNUMERIC(SUBSTRING(@MaxInventoryId, 4, LEN(@MaxInventoryId))) = 1
BEGIN
    SET @NewInventoryNumber = CAST(SUBSTRING(@MaxInventoryId, 4, LEN(@MaxInventoryId)) AS INT) + 1;
END
ELSE
BEGIN
    SET @NewInventoryNumber = 1;
END

SET @InventoryId = 'INV' + CAST(@NewInventoryNumber AS NVARCHAR(20));

-- Insert new inventory record
INSERT INTO inventory (id, product_id, quantity_in_stock)
VALUES (@InventoryId, @ProductId, @QuantityChange);
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
		DECLARE @vendorId INT;
		DECLARE @userId NVARCHAR(20);
		SELECT @vendorId = vendor_id FROM products WHERE id = @ProductId;
		SELECT @userId = userId FROM vendors WHERE id = @vendorId;
        SELECT @ProductName = name FROM products WHERE id = @ProductId;
		
        
        -- Log inventory change event
        INSERT INTO user_event_log (user_id, event_type, action_description)
        VALUES (
            @userId, 
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
        PRINT @ErrorMessage;
    END CATCH;
END;
GO
 
 SELECT * FROM vendors;
 SELECT * FROM products;
 SELECT * FROM inventory;
EXEC sp_UpdateInventory @ProductId = 'PROD022',@QuantityChange = 8,@ReasonCode= 'Restock'

SELECT * FROM user_event_log;

-- User Profile Management
CREATE OR ALTER PROCEDURE sp_UpdateUserProfile
    @UserId NVARCHAR(50),
    @Name NVARCHAR(255) = NULL,
    @Email NVARCHAR(255) = NULL,
    @PhoneNumber NVARCHAR(20) = NULL,
    @Gender NVARCHAR(10) = NULL,
    @DateOfBirth DATETIME = NULL
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
            DateOfBirth = ISNULL(@DateOfBirth, DateOfBirth)
        WHERE id = @UserId;
        
        -- Log the event
        INSERT INTO user_event_log (user_id, event_type, action_description)
        VALUES (@UserId, 'ProfileUpdate', 'User profile updated');
    END TRY
    BEGIN CATCH
        -- Log the error
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
		PRINT @ErrorMessage
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
       PRINT @ErrorMessage
    END CATCH;
END;
GO


SELECT * FROM order_returns;

CREATE OR ALTER PROCEDURE sp_return_product_from_order
    @order_id NVARCHAR(50),
    @product_id NVARCHAR(50),
    @quantity INT,
    @reason NVARCHAR(255)
AS
BEGIN

	BEGIN TRANSACTION 
	BEGIN TRY
    SET NOCOUNT ON;

    DECLARE @ordered_qty INT;
    SELECT @ordered_qty = quantity
    FROM order_items
    WHERE order_id = @order_id AND product_id = @product_id;

    IF @ordered_qty IS NULL
    BEGIN
        RAISERROR('Product not found in the order.', 16, 1);
        RETURN;
    END

    IF @quantity > @ordered_qty
    BEGIN
        RAISERROR('Return quantity exceeds ordered quantity.', 16, 1);
        RETURN;
    END

    -- Get unit price
    DECLARE @unit_price DECIMAL(10,2);
    SELECT @unit_price = unit_price
    FROM order_items
    WHERE order_id = @order_id AND product_id = @product_id;

    DECLARE @refund_amount DECIMAL(10,2) = @unit_price * @quantity;

    -- Insert return record
    INSERT INTO order_returns (
        order_id, product_id, quantity,
        reason, refund_amount,
    processed 
    )
    VALUES (
        @order_id, @product_id, @quantity,
        @reason, @refund_amount,1
    );

    -- Update inventory
    UPDATE inventory
    SET quantity_in_stock = quantity_in_stock + @quantity
    WHERE product_id = @product_id;

    -- Update order item quantity
    UPDATE order_items
    SET quantity = quantity - @quantity
    WHERE order_id = @order_id AND product_id = @product_id;

	-- Check if all items have quantity = 0
IF NOT EXISTS (
    SELECT 1
    FROM order_items
    WHERE order_id = @order_id AND quantity > 0
)
BEGIN
    -- Update order status as returned
    UPDATE orders
    SET order_status = 'Returned',
        isReturned = 1 -- already fully returned
    WHERE id = @order_id;
END
ELSE
BEGIN
    -- Partially returned
    UPDATE orders
    SET isReturned = 1
    WHERE id = @order_id;
END

    PRINT 'Return processed successfully.';


	COMMIT TRANSACTION
	END TRY

	BEGIN CATCH
	IF @@TRANCOUNT > 0 
			ROLLBACK TRANSACTION;
			
		DECLARE @ErrorMessage VARCHAR(200) = Error_Message();
		PRINT @ErrorMessage
	END CATCH
END;


SELECT * FROM orders;

EXEC sp_return_product_from_order @order_id = 'ORD33',@product_id = 'PROD016', @quantity = 1,@reason = 'Defective Product';

SELECT * FROM order_items WHERE order_id = 'ORD33';
SELECT * FROM order_items;
SELECT * FROM orders;
SELECT * FROM order_returns;



CREATE OR ALTER VIEW OrdersAndReturnSummary 
AS 
SELECT 
    o.id AS order_id,
    o.user_id,
    o.order_date,
    o.order_status,
    o.isReturned,

    oi.product_id,
    p.name AS product_name,

    oi.quantity + ISNULL(r.total_returned_qty, 0) AS ordered_qty,
    ISNULL(r.total_returned_qty, 0) AS returned_qty,
    oi.quantity AS remaining_qty,

    oi.unit_price,
    (oi.unit_price * (oi.quantity + ISNULL(r.total_returned_qty, 0))) AS total_purchase_amount,
    ISNULL(r.refund_amount, 0) AS total_refund_amount,
    ((oi.unit_price * (oi.quantity + ISNULL(r.total_returned_qty, 0))) - ISNULL(r.refund_amount, 0)) AS net_amount,

    CASE 
        WHEN ISNULL(r.total_returned_qty, 0) = 0 THEN 'No'
        WHEN oi.quantity = 0 THEN 'Fully Returned'
        ELSE 'Partially Returned'
    END AS return_status

FROM orders o
JOIN order_items oi ON o.id = oi.order_id
JOIN products p ON oi.product_id = p.id

LEFT JOIN (
    SELECT 
        order_id, 
        product_id,
        SUM(quantity) AS total_returned_qty,
        SUM(refund_amount) AS refund_amount
    FROM order_returns
    GROUP BY order_id, product_id
) r ON oi.order_id = r.order_id AND oi.product_id = r.product_id





CREATE OR ALTER FUNCTION dbo.fn_SearchProducts
(
    @SearchTerm NVARCHAR(255) = NULL
)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        p.id, 
        p.name, 
        p.description, 
        p.price, 
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
    WHERE @SearchTerm IS NULL OR (p.name LIKE '%' + @SearchTerm + '%' OR p.description LIKE '%' + @SearchTerm + '%')
);
GO

SELECT * FROM dbo.fn_SearchProducts('watch')
SELECT * FROM products;

SELECT * FROM sys.objects;


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

EXEC sp_GetCustomerPurchaseHistory @UserId = 'USR19'

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


EXEC sp_GetProductPerformance @ProductId = 'PROD24',@Days = 10