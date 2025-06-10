--Customer Flow Execution 

-- 1. User Registration: CreateUser as Customer
EXEC sp_CreateUser  
    @Name = 'Sumit Pareek', 
    @Email = 'SumitPareek99@gmail.com', 
    @Password = 'Sumit@123', 
    @PhoneNumber = '7212331433', 
    @Gender = 'Male',  
    @UserType = 'customer',
    @PaymentDetails = 'Sumit99@paytm',
    @PinCode = 302012,
    @Age = 35;
GO


EXEC sp_CreateUser  
    @Name = 'Bhavin', 
    @Email = 'Bhavin@@gmail.com', 
    @Password = 'Sumit@123', 
    @PhoneNumber = '7212331433', 
    @Gender = 'Male',  
    @UserType = 'customer',
    @PaymentDetails = 'Sumit99@paytm',
    @PinCode = 302012,
    @Age = 35;
GO
-- 2. User Authentication
EXEC sp_AuthenticateUser  
    @email_or_phone = 'SumitPareek99@gmail.com', 
    @password = 'Sumit@123';
GO

-- 3. Update User Profile
DECLARE @id VARCHAR(10) ;
SELECT @id = MAX(id) FROM users
EXEC sp_UpdateUserProfile  
    @UserId = @id, 
    @Name = 'Sumit Pareek', 
	@DateOfBirth = '5-1-2000'
GO

-- 4. Reset Password
DECLARE @id VARCHAR(10) ;
SELECT @id = MAX(id) FROM users
EXEC sp_ResetPassword @id,'Sumit@123','Sumit@1234'

-- 5. Manage Addresses
DECLARE @id VARCHAR(10);
SELECT @id = MAX(id) FROM users
EXEC sp_AddUserAddress  
    @UserId = @id,
    @AddressLine = 'jhotwara, jaipur',
    @AddressType = 'Home',
    @IsPrimary = 1;
GO

SELECT * FROM users;

-- Fetch User Addresses
DECLARE @id VARCHAR(10);
SELECT @id = MAX(id) FROM users
EXEC sp_GetUserAddresses  
    @UserId = @id;
GO

-- 6. Product Browsing 
EXEC sp_SearchProducts  
    @SearchTerm = 'Cricket Bat';
GO

-- 7. Wishlist Management: Add and Remove
DECLARE @id VARCHAR(10) ;
SELECT @id = MAX(id) FROM users
EXEC sp_AddProductToWishlist  
    @UserId = @id,
    @ProductId = 'PROD25';
GO


DECLARE @id VARCHAR(10) ;
SELECT @id = MAX(id) FROM users
SELECT * FROM wishlist WHERE user_id = @id;

-- 8. CAN remove from wishlist
DECLARE @id VARCHAR(10);
SELECT @id = MAX(id) FROM users
EXEC sp_RemoveFromWishlist  
    @UserId = @id,
    @ProductId = 'PROD25';
GO

--  9. Move Wishlist to cart
DECLARE @id VARCHAR(10) ;
SELECT @id = MAX(id) FROM users
EXEC sp_MoveWishlistToCart @id

-- 10. Shopping Cart Management: Add, Update, Remove, Clear, and Move to Order

SELECT * FROM users;

DECLARE @id VARCHAR(10);
SELECT @id = MAX(id) FROM users
EXEC sp_AddToCart  
    @UserId = @id,
    @ProductId = 'PROD25', 
    @Quantity = 1;
GO

SELECT * FROM products;

DECLARE @id VARCHAR(10) ;
SELECT @id = MAX(id) FROM users
EXEC sp_UpdateCartQuantity  
    @UserId = @id,
    @ProductId = 'PROD25', 
    @NewQuantity = 1;
GO

DECLARE @id VARCHAR(10) ;
SELECT @id = MAX(id) FROM users
SELECT * FROM shopping_cart WHERE user_id = @id;


DECLARE @id VARCHAR(10) ;
SELECT @id = MAX(id) FROM users
EXEC sp_RemoveFromCart  
    @UserId = @id,
    @ProductId = 'PROD25';
GO

DECLARE @id VARCHAR(10) ;
SELECT @id = MAX(id) FROM users
EXEC sp_ClearCart  
    @UserId = @id;
GO

-- 11. get the cart summary
DECLARE @id VARCHAR(10) ;
SELECT @id = MAX(id) FROM users
EXEC sp_GetCartDetailsAndSummary @id

-- 12. Check coupons
SELECT * FROM coupons;

EXEC sp_GetAllAvailableCoupons

-- 13. Create Order
DECLARE @id VARCHAR(10);
SELECT @id = MAX(id) FROM users
EXEC sp_CreateOrder  
    @UserId = @id,
    @PaymentMethod = 'UPI',
	@CouponCode = 'WEL50';
GO

SELECT * FROM payments;
SELECT * FROM orders;

DECLARE @id VARCHAR(10) ;
SELECT @id = MAX(id) FROM orders
SELECT * FROM order_items WHERE order_id = @id;


-- 14. Create Shippment
DECLARE @id VARCHAR(10) ;
SELECT @id = MAX(id) FROM orders
EXEC sp_CreateShipment  
    @OrderId = @id,
    @ShippingMethod = 'Delhivery', 
    @TrackingNumber = 'TRACKORD';
GO


SELECT * FROM payments;

-- Out for Delivery Status
DECLARE @id VARCHAR(10) ;
SELECT @id = MAX(id) FROM orders
EXEC sp_UpdateOrderStatus  
    @OrderId = @id,   
    @NewStatus = 'Out For Delivery';
GO

-- 16. Order Delivered
DECLARE @id VARCHAR(10) ;
SELECT @id = MAX(id) FROM orders
EXEC sp_UpdateOrderStatus @id,'Delivered'


SELECT * FROM shipping;
SELECT *  FROM orders;
SELECT * FROM payments;

-- 17. Cancel the Order
DECLARE @id VARCHAR(10) ;
SELECT @id = MAX(id) FROM orders
EXEC sp_CancelOrder  
    @OrderId = @id;   -- Use actual order ID if needed
GO

SELECT * FROM orders;
SELECT * FROM order_items WHERE order_id = 'ORD'
SELECT * FROM order_returns;


-- 18. Return From the order
EXEC sp_return_product_from_order @order_id = 'ORD',@product_id = 'PROD001', @quantity = 1,@reason = 'Defective Product';

DECLARE @id VARCHAR(10) ;
SELECT @id = MAX(id) FROM orders
SELECT * FROM OrdersAndReturnSummary WHERE order_id = @id




DECLARE @id VARCHAR(10) ;
SELECT @id = MAX(id) FROM orders
SELECT * FROM invoices WHERE order_id = @id;


DECLARE @id VARCHAR(10) ;
SELECT @id = MAX(id) FROM users
EXEC sp_GetCustomerPurchaseHistory  
    @UserId = @id;
GO 

DECLARE @id VARCHAR(10) ;
SELECT @id = MAX(id) FROM users
SELECT * FROM user_event_log WHERE user_id = @id

-- 10. Product Review Management: Add, Update, Delete
DECLARE @id VARCHAR(10) ;
SELECT @id = MAX(id) FROM users
EXEC sp_AddProductReview  
    @UserId = @id,
    @ProductId = 'PROD',
    @Rating = 4,
    @Comment = 'Great Product';
GO

SELECT * FROM reviews;
SELECT * FROM orders;
SELECT * FROM payments;


DECLARE @id VARCHAR(10) ;
SELECT @id = MAX(id) FROM users
EXEC sp_UpdateProductReview  
    @UserId = @id,
    @ProductId = 'PROD23',
    @Rating = 3,
    @Comment = 'Good product, but a bit expensive.';
GO

DECLARE @id VARCHAR(10) ;
SELECT @id = MAX(id) FROM users
EXEC sp_DeleteProductReview  
    @UserId = @id,
    @ProductId = 'PROD1003';
GO

