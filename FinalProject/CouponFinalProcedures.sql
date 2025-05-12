SELECT * FROM sys.views;

SELECT * FROM sys.procedures;

SELECT * FROM sys.triggers;

SELECT * FROM sys.tables;


SELECT * FROM product_price_history;

-- =========================================
-- COUPON VALIDATION PROCEDURE
-- =========================================
CREATE OR ALTER PROCEDURE sp_ValidateCoupon
    @CouponCode NVARCHAR(50),
    @UserId NVARCHAR(50),
    @OrderAmount DECIMAL(18,2),
    @IsValid BIT OUTPUT,
    @DiscountAmount DECIMAL(18,2) OUTPUT,
    @CouponId NVARCHAR(50) OUTPUT,
    @ErrorMessage NVARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Initialize outputs
    SET @IsValid = 0;
    SET @DiscountAmount = 0;
    SET @CouponId = NULL;
    SET @ErrorMessage = NULL;
    
    -- Check if coupon exists and is active
    IF NOT EXISTS (SELECT 1 FROM coupons WHERE code = @CouponCode AND is_active = 1)
    BEGIN
        SET @ErrorMessage = 'Invalid coupon code or coupon is inactive.';
        RETURN;
    END;
    
    -- Get coupon details
    DECLARE @DiscountType NVARCHAR(20);
    DECLARE @DiscountValue DECIMAL(18,2);
    DECLARE @MinOrderValue DECIMAL(18,2);
    DECLARE @MaxDiscountAmount DECIMAL(18,2);
    DECLARE @StartDate DATETIME;
    DECLARE @EndDate DATETIME;
    DECLARE @UsageLimit INT;
    DECLARE @UsageCount INT;
    
    SELECT 
        @CouponId = id,
        @DiscountType = discount_type,
        @DiscountValue = discount_value,
        @MinOrderValue = min_order_value,
        @MaxDiscountAmount = max_discount_amount,
        @StartDate = start_date,
        @EndDate = end_date,
        @UsageLimit = usage_limit,
        @UsageCount = usage_count
    FROM coupons 
    WHERE code = @CouponCode;
    
    -- Check if coupon is within valid date range
    IF GETDATE() < @StartDate OR GETDATE() > @EndDate
    BEGIN
        SET @ErrorMessage = 'Coupon is not valid at this time.';
        RETURN;
    END;
    
    -- Check usage limit
    IF @UsageLimit IS NOT NULL AND @UsageCount >= @UsageLimit
    BEGIN
        SET @ErrorMessage = 'Coupon usage limit has been reached.';
        RETURN;
    END;
    
    -- Check minimum order value
    IF @OrderAmount < @MinOrderValue
    BEGIN
        SET @ErrorMessage = 'Order amount does not meet the minimum requirement of ' + 
                           CAST(@MinOrderValue AS NVARCHAR) + '.';
        RETURN;
    END;
    
    -- Check if user has already used this coupon (optional - remove if multiple uses allowed)
    IF EXISTS (
        SELECT 1 
        FROM coupon_usage cu
        JOIN orders o ON cu.order_id = o.id
        WHERE cu.coupon_id = @CouponId 
        AND o.user_id = @UserId
        AND o.order_status != 'Cancelled'
    )
    BEGIN
        SET @ErrorMessage = 'You have already used this coupon.';
        RETURN;
    END;
    
    -- Calculate discount amount
    IF @DiscountType = 'PERCENTAGE'
    BEGIN
        SET @DiscountAmount = (@OrderAmount * @DiscountValue) / 100;
        
        -- Apply max discount limit if specified
        IF @MaxDiscountAmount IS NOT NULL AND @DiscountAmount > @MaxDiscountAmount
            SET @DiscountAmount = @MaxDiscountAmount;
    END
    ELSE IF @DiscountType = 'FIXED'
    BEGIN
        SET @DiscountAmount = @DiscountValue;
        
        -- Ensure discount doesn't exceed order amount
        IF @DiscountAmount > @OrderAmount
            SET @DiscountAmount = @OrderAmount;
    END;
    
    -- Round discount to 2 decimal places
    SET @DiscountAmount = ROUND(@DiscountAmount, 2);
    
    -- Coupon is valid
    SET @IsValid = 1;
END;
GO

-- =========================================
-- APPLY COUPON TO ORDER PROCEDURE
-- =========================================
CREATE OR ALTER PROCEDURE sp_ApplyCouponToOrder
    @OrderId NVARCHAR(50),
    @CouponCode NVARCHAR(50),
    @Success BIT OUTPUT,
    @Message NVARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        SET @Success = 0;
        SET @Message = '';
        
        -- Get order details
        DECLARE @UserId NVARCHAR(50);
        DECLARE @OrderAmount DECIMAL(18,2);
        DECLARE @OrderStatus NVARCHAR(50);
        
        SELECT 
            @UserId = user_id,
            @OrderAmount = total_amount,
            @OrderStatus = order_status
        FROM orders 
        WHERE id = @OrderId;
        
        -- Check if order exists
        IF @UserId IS NULL
        BEGIN
            SET @Message = 'Order not found.';
            ROLLBACK TRANSACTION;
            RETURN;
        END;
        
        -- Check if order is in a valid state for applying coupon
        IF @OrderStatus NOT IN ('Pending', 'Confirmed')
        BEGIN
            SET @Message = 'Coupon cannot be applied to orders in ' + @OrderStatus + ' status.';
            ROLLBACK TRANSACTION;
            RETURN;
        END;
        
        -- Check if coupon is already applied
        IF EXISTS (SELECT 1 FROM orders WHERE id = @OrderId AND coupon_id IS NOT NULL)
        BEGIN
            SET @Message = 'A coupon is already applied to this order. Remove existing coupon first.';
            ROLLBACK TRANSACTION;
            RETURN;
        END;
        
        -- Validate coupon
        DECLARE @IsValid BIT;
        DECLARE @DiscountAmount DECIMAL(18,2);
        DECLARE @CouponId NVARCHAR(50);
        DECLARE @ErrorMessage NVARCHAR(255);
        
        EXEC sp_ValidateCoupon
            @CouponCode = @CouponCode,
            @UserId = @UserId,
            @OrderAmount = @OrderAmount,
            @IsValid = @IsValid OUTPUT,
            @DiscountAmount = @DiscountAmount OUTPUT,
            @CouponId = @CouponId OUTPUT,
            @ErrorMessage = @ErrorMessage OUTPUT;
        
        IF @IsValid = 0
        BEGIN
            SET @Message = @ErrorMessage;
            ROLLBACK TRANSACTION;
            RETURN;
        END;
        
        -- Update order with coupon discount
        UPDATE orders
        SET 
            coupon_id = @CouponId,
            discount_amount = @DiscountAmount,
            total_amount = total_amount - @DiscountAmount,
            updated_at = GETDATE()
        WHERE id = @OrderId;
        
        -- Record coupon usage
        INSERT INTO coupon_usage (coupon_id, order_id, user_id, discount_amount)
        VALUES (@CouponId, @OrderId, @UserId, @DiscountAmount);
        
        -- Update coupon usage count
        UPDATE coupons
        SET 
            usage_count = usage_count + 1,
            updated_at = GETDATE()
        WHERE id = @CouponId;
        
        -- Log event
        INSERT INTO user_event_log (user_id, event_type, action_description)
        VALUES (@UserId, 'CouponApplied', 'Coupon ' + @CouponCode + ' applied to order ' + @OrderId + 
                ' with discount amount ' + CAST(@DiscountAmount AS NVARCHAR(20)));
        
        SET @Success = 1;
        SET @Message = 'Coupon applied successfully. Discount amount: ' + CAST(@DiscountAmount AS NVARCHAR(20));
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SET @Success = 0;
        SET @Message = 'Error applying coupon: ' + ERROR_MESSAGE();
        
        -- Log the error
		SET @ErrorMessage = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
GO

-- =========================================
-- REMOVE COUPON FROM ORDER PROCEDURE
-- =========================================
CREATE OR ALTER PROCEDURE sp_RemoveCouponFromOrder
    @OrderId NVARCHAR(50),
    @Success BIT OUTPUT,
    @Message NVARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        SET @Success = 0;
        SET @Message = '';
        
        -- Check if order has a coupon applied
        DECLARE @CouponId NVARCHAR(50);
        DECLARE @DiscountAmount DECIMAL(18,2);
        DECLARE @UserId NVARCHAR(50);
        
        SELECT 
            @CouponId = coupon_id,
            @DiscountAmount = discount_amount,
            @UserId = user_id
        FROM orders 
        WHERE id = @OrderId;
        
        IF @CouponId IS NULL
        BEGIN
            SET @Message = 'No coupon is applied to this order.';
            ROLLBACK TRANSACTION;
            RETURN;
        END;
        
        -- Get coupon code for logging
        DECLARE @CouponCode NVARCHAR(50);
        SELECT @CouponCode = code FROM coupons WHERE id = @CouponId;
        
        -- Update order to remove coupon
        UPDATE orders
        SET 
            coupon_id = NULL,
            discount_amount = 0,
            total_amount = total_amount + @DiscountAmount,
            updated_at = GETDATE()
        WHERE id = @OrderId;
        
        -- Delete coupon usage record
        DELETE FROM coupon_usage
        WHERE order_id = @OrderId AND coupon_id = @CouponId;
        
        -- Decrement coupon usage count
        UPDATE coupons
        SET 
            usage_count = usage_count - 1,
            updated_at = GETDATE()
        WHERE id = @CouponId;
        
        -- Log event
        INSERT INTO user_event_log (user_id, event_type, action_description)
        VALUES (@UserId, 'CouponRemoved', 'Coupon ' + @CouponCode + ' removed from order ' + @OrderId);
        
        SET @Success = 1;
        SET @Message = 'Coupon removed successfully.';
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SET @Success = 0;
        SET @Message = 'Error removing coupon: ' + ERROR_MESSAGE();
        
        -- Log the error
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
GO




-- =========================================
-- CREATE COUPON PROCEDURE
-- =========================================
CREATE OR ALTER PROCEDURE sp_CreateCoupon
    @Code NVARCHAR(50),
    @Description NVARCHAR(255),
    @DiscountType NVARCHAR(20),
    @DiscountValue DECIMAL(18,2),
    @MinOrderValue DECIMAL(18,2) = 0,
    @MaxDiscountAmount DECIMAL(18,2) = NULL,
    @StartDate DATETIME,
    @EndDate DATETIME,
    @IsActive BIT = 1,
    @UsageLimit INT = NULL,
    @CouponId NVARCHAR(50) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Validate parameters
        IF @DiscountType NOT IN ('PERCENTAGE', 'FIXED')
        BEGIN
            RAISERROR('Discount type must be either PERCENTAGE or FIXED', 16, 1);
            RETURN;
        END
        
        IF @DiscountValue <= 0
        BEGIN
            RAISERROR('Discount value must be greater than zero', 16, 1);
            RETURN;
        END
        
        IF @DiscountType = 'PERCENTAGE' AND @DiscountValue > 100
        BEGIN
            RAISERROR('Percentage discount cannot exceed 100%%', 16, 1);
            RETURN;
        END
        
        IF @EndDate <= @StartDate
        BEGIN
            RAISERROR('End date must be after start date', 16, 1);
            RETURN;
        END
        
        -- Check if coupon code already exists
        IF EXISTS (SELECT 1 FROM coupons WHERE code = @Code)
        BEGIN
            RAISERROR('Coupon code already exists', 16, 1);
            RETURN;
        END
        
        -- Generate coupon ID
        SET @CouponId = CONVERT(NVARCHAR(50), NEWID());
        
        -- Insert coupon
        INSERT INTO coupons (
            id, code, description, discount_type, discount_value,
            min_order_value, max_discount_amount, start_date, end_date,
            is_active, usage_limit, usage_count
        )
        VALUES (
            @CouponId, @Code, @Description, @DiscountType, @DiscountValue,
            @MinOrderValue, @MaxDiscountAmount, @StartDate, @EndDate,
            @IsActive, @UsageLimit, 0
        );
        
        -- Log event
        INSERT INTO user_event_log (user_id, event_type, action_description)
        VALUES (
            'USR001', 
            'CouponCreated', 
            'Created coupon ' + @Code + ' with ID ' + @CouponId
        );
    END TRY
    BEGIN CATCH
        SET @CouponId = NULL;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO

-- =========================================
-- GET COUPON DETAILS PROCEDURE
-- =========================================
CREATE OR ALTER PROCEDURE sp_GetCouponDetails
    @CouponCode NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Get coupon details
    SELECT 
        c.id,
        c.code,
        c.description,
        c.discount_type,
        c.discount_value,
        c.min_order_value,
        c.max_discount_amount,
        c.start_date,
        c.end_date,
        c.is_active,
        c.usage_limit,
        c.usage_count,
        c.created_at,
        c.updated_at,
        CASE 
            WHEN GETDATE() < c.start_date THEN 'Not Started'
            WHEN GETDATE() > c.end_date THEN 'Expired'
            WHEN c.is_active = 0 THEN 'Inactive'
            WHEN c.usage_limit IS NOT NULL AND c.usage_count >= c.usage_limit THEN 'Exhausted'
            ELSE 'Valid'
        END AS coupon_status
    FROM coupons c
    WHERE c.code = @CouponCode;
    
    -- Get usage statistics
    SELECT 
        COUNT(*) AS total_usages,
        COUNT(DISTINCT cu.user_id) AS unique_users,
        SUM(cu.discount_amount) AS total_discount_provided,
        MAX(cu.used_at) AS last_used
    FROM coupon_usage cu
    JOIN coupons c ON cu.coupon_id = c.id
    WHERE c.code = @CouponCode;
    
    -- Get recent usage details
    SELECT TOP 10
        o.id AS order_id,
        u.name AS user_name,
        o.order_date,
        o.total_amount + cu.discount_amount AS original_amount,
        cu.discount_amount,
        o.total_amount AS final_amount,
        o.order_status
    FROM coupon_usage cu
    JOIN coupons c ON cu.coupon_id = c.id
    JOIN orders o ON cu.order_id = o.id
    JOIN users u ON cu.user_id = u.id
    WHERE c.code = @CouponCode
    ORDER BY cu.used_at DESC;
END;
GO