-- Vendor Flow Execution Script

-- 1. Vendor Registration: CreateUser and CreateVendor
EXEC sp_CreateUser  
    @Name = 'rajiv Tanvar',
    @Email = 'rajiv.vendor@gmail.com', 
    @Password = 'rajiv123', 
    @PhoneNumber = '5559876543', 
    @Gender = 'Male', 
    @DateOfBirth = '1985-07-10',
    @UserType = 'vendor',
    @Address = '789, Noida, UP',
    @PaymentDetails = 'rajiv@paytm',
    @PinCode = 654321,
    @Age = 40,
    @GSTnumber = 'GST123456';
GO

SELECT * FROm users;
SELECT * FROM vendors;

-- 2. Vendor Authentication
EXEC sp_AuthenticateUser  
    @email_or_phone = 'rajiv.vendor@gmail@.com', 
    @password = 'rajiv123';
GO

-- 3. Update Vendor Profile
EXEC sp_UpdateUserProfile  
    @UserId = 'USR21',
	@Email = 'rajiv.vendor@gmail.com'
GO

SELECT * FROM products;
SELECT * FROM categories
SELECT * FROM inventory;

-- 4. Product Management: Add and Update Products
EXEC sp_AddProduct  
    @name = 'Boat Rockerz 111', 
    @description = 'A great neckbands from Boat', 
    @category_id = 'CAT007', 
    @vendor_id = 108, -- Adjust to match vendor id
    @price = 899.00, 
    @sku = 'boatRock111', 
    @discount = 1.0, 
    @quantity_in_stock = 100, 
    @inventory_id = 'INV024';
GO

-- Assume product ID generated is PROD1; update as needed

EXEC sp_UpdateProduct  
    @id = 'PROD24', 
    @discount = 2.00;
GO

-- 5. Inventory Management
EXEC sp_ManageInventory
    @product_id = 'PROD24', 
    @quantity_change = 20 ,
	@action_type = 'add'
	-- Increase by 50 units
GO

EXEC sp_UpdateInventory  
    @inventory_id = 'VINV001', 
    @quantity_in_stock = 150;
GO

-- 6. Order Fulfillment and Shipping
EXEC sp_UpdateOrderStatus  
    @OrderId = 'ORD100',  -- Adjust to actual order ID
    @Status = 'Processing';
GO

EXEC sp_CreateShipment  
    @OrderId = 'ORD100',
    @ShippingMethod = 'Courier',
    @TrackingNumber = 'TRACKVEND001';
GO

EXEC sp_UpdateShipmentStatus  
    @OrderId = 'ORD100',
    @NewStatus = 'In Transit';
GO

-- 7. Financial Management: Process Payment (example)
EXEC sp_ProcessPayment  
    @OrderId = 'ORD100', 
    @PaymentMethod = 'Bank Transfer', 
    @Amount = 500.00;
GO

-- 8. Product Performance and Reports
EXEC sp_GetProductPerformance  
    @ProductId = 'PROD24';
GO

EXEC sp_GetCustomerPurchaseHistory  
    @UserId = 'USR21';
GO

-- 9. Review Management: Delete a Product Review
EXEC sp_DeleteProductReview  
    @UserId = 'USR5',  -- Customer user ID
    @ProductId = 'PROD1';  
GO

-- 10. Coupon and Promotions: Create and Validate Coupon
EXEC sp_CreateCoupon  
    @id = 'COUP1', 
    @code = 'VENDDIS10', 
    @description = '10% discount for vendor products', 
    @discount_type = 'PERCENTAGE', 
    @discount_value = 10.00, 
    @min_order_value = 100.00, 
    @max_discount_amount = 50.00, 
    @start_date = GETDATE(), 
    @end_date = DATEADD(day, 30, GETDATE());
GO

DECLARE @IsValid BIT,
        @DiscountAmount DECIMAL(18,2),
        @CouponId NVARCHAR(50),
        @ErrorMessage NVARCHAR(255);

EXEC sp_ValidateCoupon  
    @CouponCode = 'VENDDIS10',
    @UserId = 'USR2',
    @OrderAmount = 200.00,
    @IsValid = @IsValid OUTPUT,
    @DiscountAmount = @DiscountAmount OUTPUT,
    @CouponId = @CouponId OUTPUT,
    @ErrorMessage = @ErrorMessage OUTPUT;

SELECT @IsValid AS IsValid, @DiscountAmount AS DiscountAmount, @CouponId AS CouponId, @ErrorMessage AS ErrorMessage;
GO