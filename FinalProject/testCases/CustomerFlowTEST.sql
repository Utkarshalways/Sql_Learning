--Customer Flow Execution 

-- 1. User Registration: CreateUser as Customer
EXEC sp_CreateUser  
    @Name = 'Yash Dayal', 
    @Email = 'YashDayal93@gmail.com', 
    @Password = 'YashDayal93@123', 
    @PhoneNumber = '7212331232', 
    @Gender = 'Male',  
    @UserType = 'customer',
    @PaymentDetails = 'Dayal93@paytm',
    @PinCode = 313322,
    @Age = 32;
GO


SELECT * FROM users;



-- 2. User Authentication
EXEC sp_AuthenticateUser  
    @email_or_phone = 'YashDayal93@gmail.com', 
    @password = 'YashDayal93@123';
GO

-- 3. Update User Profile
EXEC sp_UpdateUserProfile  
    @UserId = 'USR', 
    @Name = 'Sumit Pareek', 
	@DateOfBirth = '5-1-2000'
GO

-- 4. Reset Password
EXEC sp_ResetPassword 'USR','Sumit@123','Sumit@123'

-- 5. Manage Addresses
EXEC sp_AddUserAddress  
    @UserId = 'USR25',
    @AddressLine = 'Vijay nagar, Madhya pradesh',
    @AddressType = 'Home',
    @IsPrimary = 1;
GO

-- Fetch User Addresses
EXEC sp_GetUserAddresses  
    @UserId = 'USR25';
GO

-- 6. Product Browsing (search - example with partial name)
EXEC sp_SearchProducts  
    @SearchTerm = 'Coffee';
GO

SELECT * FROM products;
-- 7. Wishlist Management: Add and Remove
EXEC sp_AddProductToWishlist  
    @UserId = 'USR25',
    @ProductId = 'PROD009';
GO

SELECT * FROM wishlist;

-- 8. CAN remove from wishlist
EXEC sp_RemoveFromWishlist  
    @UserId = 'USR',
    @ProductId = 'PROD23';
GO

--  9. Move Wishlist to cart
EXEC sp_MoveWishlistToCart 'USR25'

-- 10. Shopping Cart Management: Add, Update, Remove, Clear, and Move to Order

SELECT * FROM users;

EXEC sp_AddToCart  
    @UserId = 'USR25',
    @ProductId = 'PROD017', 
    @Quantity = 1;
GO

SELECT * FROM products;

EXEC sp_UpdateCartQuantity  
    @UserId = 'USR',
    @ProductId = 'PROD002', 
    @NewQuantity = 1;
GO

SELECT * FROM shopping_cart WHERE user_id = 'USR';

-- 11. get the cart summary
EXEC sp_GetCartDetailsAndSummary 'USR25'

EXEC sp_RemoveFromCart  
    @UserId = 'USR1',
    @ProductId = 'PROD1002';
GO

EXEC sp_ClearCart  
    @UserId = 'USR1';
GO


-- 12. Check coupons
SELECT * FROM coupons;

EXEC sp_GetAllAvailableCoupons

-- 13. Create Order
EXEC sp_CreateOrder  
    @UserId = 'USR25',
	@CouponCode = 'WELCOME50',
    @PaymentMethod = 'UPI';
GO

SELECT * FROM payments;
SELECT * FROM orders;
SELECT * FROM order_items WHERE order_id = 'ORD41';


-- 14. Create Shippment

EXEC sp_CreateShipment  
    @OrderId = 'ORD42',
    @ShippingMethod = 'Delhivery', 
    @TrackingNumber = 'TRACKORD42';
GO


SELECT * FROM payments;

-- Out for Delivery Status
EXEC sp_UpdateOrderStatus  
    @OrderId = 'ORD42',   
    @NewStatus = 'Out For Delivery';
GO

-- 16. Order Delivered
EXEC sp_UpdateOrderStatus 'ORD42','Delivered'


SELECT * FROM shipping;
SELECT *  FROM orders;
SELECT * FROM payments;

-- 17. Cancel the Order
EXEC sp_CancelOrder  
    @OrderId = 'ORD35';   -- Use actual order ID if needed
GO

SELECT * FROM orders;
SELECT * FROM order_items WHERE order_id = 'ORD36'
SELECT * FROM order_returns;


-- 18. Return From the order
EXEC sp_return_product_from_order @order_id = 'ORD36',@product_id = 'PROD001', @quantity = 1,@reason = 'Defective Product';

SELECT * FROM OrdersAndReturnSummary WHERE order_id = 'ORD42'

EXEC sp_GetCustomerPurchaseHistory  
    @UserId = 'USR25';
GO 

SELECT * FROM user_event_log WHERE user_id = 'USR25'

-- 10. Product Review Management: Add, Update, Delete
EXEC sp_AddProductReview  
    @UserId = 'USR24',
    @ProductId = 'PROD002',
    @Rating = 4,
    @Comment = 'Great Product';
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


SELECT * FROM invoices WHERE order_id = 'ORD42';

