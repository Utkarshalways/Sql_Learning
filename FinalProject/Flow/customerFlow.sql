-- Test Customer Flow Execution Script

-- 1. User Registration: CreateUser and CreateCustomer
EXEC sp_CreateUser  
    @Name = 'Kavya Khandelwal', 
    @Email = 'Kavyakhandelwal300@gmail.com', 
    @Password = 'kavya123', 
    @PhoneNumber = '7297643404', 
    @Gender = 'Male', 
    @DateOfBirth = '', 
    @UserType = 'customer',
    @Address = '123, vidhyadhar nagar, jaipur',
    @PaymentDetails = 'harsh@paytm',
    @PinCode = 302021,
    @Age = 23;
GO

SELECT * FROM users;


EXEC sp_depends @objname = 'Users'

-- Assuming the new user ID is 'USR1' (update as per your actual output)

EXEC sp_CreateCustomer
    @id = 1,  -- Adjust as per your customer ID generation logic
    @userId = 'USR1',
    @paymentDetails = 'Visa **** 1234',
    @age = 33,
    @address = '123 Maple Street',
    @pinCode = 123456;
GO

-- 2. User Authentication
EXEC sp_AuthenticateUser  
    @email_or_phone = 'Harshtodwal@gmail.com', 
    @password = 'Harsh123';
GO

-- 3. Update User Profile
EXEC sp_UpdateUserProfile  
    @Id = 'USR20', 
    @Name = 'Harsh Todwal', 
	@DateOfBirth = '1-1-2000'
    
GO

-- 4. Manage Addresses
EXEC sp_AddUserAddress  
    @UserId = 'USR20',
    @AddressLine = 'kanakpura, jaipur',
    @AddressType = 'Office',
    @IsPrimary = 0;
GO

EXEC sp_GetUserAddresses  
    @UserId = 'USR20';
GO

-- 5. Product Browsing (search - example with partial name)
EXEC sp_SearchProducts  
    @SearchTerm = 'Laptop';
GO

-- 6. Wishlist Management: Add and Remove
EXEC sp_AddProductToWishlist  
    @UserId = 'USR20',
    @ProductId = 'PROD022';
GO

SELECT * FROM wishlist;

EXEC sp_RemoveFromWishlist  
    @UserId = 'USR20',
    @ProductId = 'PROD23';
GO


-- 7. Shopping Cart Management: Add, Update, Remove, Clear, and Move to Order
EXEC sp_AddToCart  
    @UserId = 'USR23',
    @ProductId = 'PROD002', 
    @Quantity = 2;
GO

SELECT * FROM products;

EXEC sp_UpdateCartQuantity  
    @UserId = 'USR20',
    @ProductId = 'PROD23', 
    @NewQuantity = 1;
GO

SELECT * FROM shopping_cart;

EXEC sp_RemoveFromCart  
    @UserId = 'USR1',
    @ProductId = 'PROD1002';
GO

EXEC sp_ClearCart  
    @UserId = 'USR1';
GO

-- 8. Order Creation and Payment Processing
EXEC sp_MoveCartToOrder  
    @UserId = 'USR1';
GO

SELECT * FROM coupons;

EXEC sp_CreateOrder  
    @UserId = 'USR23',
    @CouponCode = 'SAVE20',
    @PaymentMethod = 'UPI';
GO

SELECT * FROM payments;
SELECT * FROM orders;
SELECT * FROM order_items;


SELECT * FROM sys.tables;
EXEC sp_ProcessPayment  
    @OrderId = 'ORD33',   -- Use actual order ID generated
    @PaymentMethod = 'COD'
GO

-- 9. Order Management: Update Status and Cancel Order
EXEC sp_UpdateOrderStatus  
    @OrderId = 'ORD32',   -- Use actual order ID
    @NewStatus = 'Shipped';
GO

SELECT *  FROM orders;
SELECT * FROM payments;

EXEC sp_CancelOrder  
    @OrderId = 'ORD31';   -- Use actual order ID if needed
GO

EXEC sp_GetCustomerPurchaseHistory  
    @UserId = 'USR20';
GO 

SELECT * FROM user_event_log WHERE user_id = 'USR20'

-- 10. Product Review Management: Add, Update, Delete
EXEC sp_AddProductReview  
    @UserId = 'USR20',
    @ProductId = 'PROD23',
    @Rating = 4,
    @Comment = 'Good Book to read!! Everyone should read it';
GO

SELECT * FROM reviews;
SELECT * FROM orders;
SELECT * FROM payments;

EXEC sp_UpdateProductReview  
    @UserId = 'USR20',
    @ProductId = 'PROD23',
    @Rating = 3,
    @Comment = 'Good product, but a bit expensive.';
GO

EXEC sp_DeleteProductReview  
    @UserId = 'USR1',
    @ProductId = 'PROD1003';
GO

-- 11. Coupon Management: Validate, Apply, Remove
DECLARE @IsValid BIT,
        @DiscountAmount DECIMAL(18,2),
        @CouponId NVARCHAR(50),
        @ErrorMessage NVARCHAR(255);

EXEC sp_ValidateCoupon  
    @CouponCode = 'WELCOME50',
    @UserId = 'USR1',
    @OrderAmount = 200.00,
    @IsValid = @IsValid OUTPUT,
    @DiscountAmount = @DiscountAmount OUTPUT,
    @CouponId = @CouponId OUTPUT,
    @ErrorMessage = @ErrorMessage OUTPUT;

SELECT @IsValid AS IsValid, @DiscountAmount AS DiscountAmount, @CouponId AS CouponId, @ErrorMessage AS ErrorMessage;
GO

EXEC sp_ApplyCouponToOrder  
    @OrderId = 'ORD1',
    @CouponCode = 'DISCOUNT10';
GO

EXEC sp_RemoveCouponFromOrder  
    @OrderId = 'ORD1';
GO

-- 12. Shipping Management: Create and Update Shipment Status
EXEC sp_CreateShipment  
    @OrderId = 'ORD32',
    @ShippingMethod = 'Standard Shipping', 
    @TrackingNumber = 'TRACK123456';
GO

EXEC sp_UpdateShipmentStatus  
    @OrderId = 'ORD31',
    @NewStatus = 'Delivered';
GO
