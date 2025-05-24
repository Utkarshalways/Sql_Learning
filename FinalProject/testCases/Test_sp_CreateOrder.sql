-- Test Case 1: Successful Order Creation with Valid Coupon
EXEC sp_CreateOrder  
    @UserId = 'USR001',  -- Assuming this user ID exists
    @CouponCode = 'COUPON10',  -- Assuming this coupon is valid
    @PaymentMethod = 'Credit Card';
GO

-- Test Case 2: Successful Order Creation without Coupon
EXEC sp_CreateOrder  
    @UserId = 'USR001',  -- Assuming this user ID exists
    @PaymentMethod = 'PayPal';
GO

-- Test Case 3: Attempt to Create Order with Empty Shopping Cart
BEGIN TRY
    EXEC sp_CreateOrder  
        @UserId = 'USR002',  -- Assuming this user ID exists but has an empty cart
        @PaymentMethod = 'Credit Card';
END TRY
BEGIN CATCH
    PRINT 'Test Case 3 Error: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Test Case 4: Attempt to Create Order with Invalid Coupon
BEGIN TRY
    EXEC sp_CreateOrder  
        @UserId = 'USR001',  -- Assuming this user ID exists
        @CouponCode = 'INVALIDCOUPON',  -- Assuming this coupon is invalid
        @PaymentMethod = 'Credit Card';
END TRY
BEGIN CATCH
    PRINT 'Test Case 4 Error: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Test Case 5: Attempt to Create Order for Non-Existent User
BEGIN TRY
    EXEC sp_CreateOrder  
        @UserId = 'NON_EXISTENT_USER',  -- Assuming this user ID does not exist
        @PaymentMethod = 'Credit Card';
END TRY
BEGIN CATCH
    PRINT 'Test Case 5 Error: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Test Case 6: Create Order with Multiple Items in Cart
EXEC sp_CreateOrder  
    @UserId = 'USR001',  
    @PaymentMethod = 'Credit Card';
GO

-- Test Case 7: Create Order with Low Inventory Alert Triggered
EXEC sp_CreateOrder  
    @UserId = 'USR003',  -- Assuming this user ID exists and the items in the cart will trigger low inventory alerts
    @PaymentMethod = 'Credit Card';
GO

-- Test Case 8: Create Order with Payment Method as NULL
EXEC sp_CreateOrder  
    @UserId = 'USR00176',  -- Assuming this user ID exists
    @PaymentMethod = NULL;  -- Testing with NULL payment method
GO