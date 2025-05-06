-- =========================================
-- COUPON SYSTEM USAGE EXAMPLES
-- =========================================

-- Example 1: Create a new coupon (50% off with minimum order of $100)
DECLARE @NewCouponId NVARCHAR(50);

EXEC sp_CreateCoupon
    @Code = 'WEL50',
    @Description = '50% off your first order',
    @DiscountType = 'PERCENTAGE',
    @DiscountValue = 50,
    @MinOrderValue = 100.00,
    @MaxDiscountAmount = 200.00,
    @StartDate = '2025-05-01',
    @EndDate = '2025-06-30',
    @IsActive = 1,
    @UsageLimit = 1000,
    @CouponId = @NewCouponId OUTPUT;

SELECT @NewCouponId AS NewCouponId;

SELECT * FROM coupons;

SELECT * FROM sys.tables;

-- Example 2: Create a fixed amount coupon ($20 off)
DECLARE @FixedCouponId NVARCHAR(50);

EXEC sp_CreateCoupon
    @Code = 'SAVE20',
    @Description = '$20 off your purchase',
    @DiscountType = 'FIXED',
    @DiscountValue = 20.00,
    @MinOrderValue = 50.00,
    @StartDate = '2025-05-01',
    @EndDate = '2025-05-31',
    @IsActive = 1,
    @UsageLimit = 500,
    @CouponId = @FixedCouponId OUTPUT;

SELECT @FixedCouponId AS FixedCouponId;

SELECT * FROM coupons;

-- Example 3: Create order using a coupon
DECLARE @OrderItems OrderItemsTableType;
INSERT INTO @OrderItems (product_id, quantity)
VALUES 
    ('PROD001', 2),
    ('PROD002', 1);

-- Use the coupon during order creation
EXEC sp_CreateOrder 
    @OrderId = 'ORD024',
    @UserId = 'USR001',
    @OrderItems = @OrderItems,
    @CouponCode = 'WELCOME50',
    @OrderStatus = 'Confirmed',
    @PaymentStatus = 'Pending';

-- Check order details to see applied discount
SELECT 
    o.id, 
    o.total_amount, 
    o.discount_amount, 
    c.code AS coupon_code
FROM orders o
LEFT JOIN coupons c ON o.coupon_id = c.id
WHERE o.id = 'ORD024';