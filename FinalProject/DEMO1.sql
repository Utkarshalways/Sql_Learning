-- =========================================
-- Complete Flow for Shopping Cart Management, Order Placement, and Shipment
-- =========================================

-- 1. Create a new user (customer)
DECLARE @User Id NVARCHAR(50);
DECLARE @User Name NVARCHAR(255) = 'Lakshya Sharma';
DECLARE @Email NVARCHAR(255) = 'lakshya.sharma@gmail.com';
DECLARE @Password NVARCHAR(255) = 'lakshya123';
DECLARE @PhoneNumber NVARCHAR(20) = '9431343226';
DECLARE @Gender NVARCHAR(10) = 'Male';
DECLARE @DateOfBirth DATETIME = '2003-07-03';
DECLARE @Country NVARCHAR(100) = 'India';
DECLARE @User Type NVARCHAR(50) = 'customer';
DECLARE @Address NVARCHAR(500) = '152, Kanakpura, Jaipur';
DECLARE @PaymentDetails NVARCHAR(1000) = 'Paytm UPI: Lakshya@oksbi';
DECLARE @Age INT = 22;
DECLARE @PinCode INT = 302020;

-- Execute the procedure to create a user
EXEC sp_CreateUser     
    @Name = @User Name,
    @Email = @Email,
    @Password = @Password,
    @PhoneNumber = @PhoneNumber,
    @Gender = @Gender,
    @DateOfBirth = @DateOfBirth,
    @Country = @Country,
    @User Type = @User Type,
    @Address = @Address,
    @PaymentDetails = @PaymentDetails,
    @Age = @Age,
    @PinCode = @PinCode;

-- 2. Authenticate the user
EXEC sp_AuthenticateUser     
    @email_or_phone = @Email,
    @password = @Password;

-- 3. Add products (courses/services) by vendor
DECLARE @ProductId NVARCHAR(50) = 'PROD001';
DECLARE @ProductName NVARCHAR(255) = 'Mastering SQL';
DECLARE @ProductDesc NVARCHAR(MAX) = 'Comprehensive SQL course for beginners to advanced.';
DECLARE @ProductPrice DECIMAL(18,2) = 199.99;
DECLARE @ProductDiscount DECIMAL(5,2) = 10.0; -- 10% discount
DECLARE @ProductCategoryId NVARCHAR(50) = 'CAT001'; -- Example category ID

EXEC sp_AddProduct
    @Id = @ProductId,
    @Name = @ProductName,
    @Description = @ProductDesc,
    @Price = @ProductPrice,
    @Discount = @ProductDiscount,
    @CategoryId = @ProductCategoryId,
    @VendorId = CAST(@User Id AS BIGINT); -- Ensure your VendorId type matches

-- 4. User views products
EXEC sp_SearchProducts 
    @SearchTerm = 'SQL',
    @SortBy = 'name',
    @PageNumber = 1,
    @PageSize = 10;

-- 5. User adds product to cart
DECLARE @CartQuantity INT = 1;

EXEC sp_AddToCart 
    @User Id = @User Id,
    @ProductId = @ProductId,
    @Quantity = @CartQuantity;

-- 6. User views shopping cart
SELECT * FROM shopping_cart WHERE user_id = @User Id;

-- 7. User places order from cart
DECLARE @OrderId NVARCHAR(50);

EXEC sp_CreateOrder 
    @User Id = @User Id,
    @CouponCode = NULL,
    @OrderStatus = 'Pending',
    @PaymentStatus = 'Pending';

-- 8. User makes payment for the order
DECLARE @PaymentId NVARCHAR(50);
DECLARE @PaymentMethod NVARCHAR(50) = 'Credit Card'; -- Example payment method

EXEC sp_ProcessPayment 
    @OrderId = @OrderId,
    @PaymentMethod = @PaymentMethod,
    @PaymentId = @PaymentId OUTPUT;

-- 9. User creates shipment for the order
DECLARE @ShippingMethod NVARCHAR(100) = 'Courier Service';
DECLARE @TrackingNumber NVARCHAR(100) = 'TRACK1001';

EXEC sp_CreateShipment 
    @OrderId = @OrderId,
    @ShippingMethod = @ShippingMethod,
    @TrackingNumber = @TrackingNumber;

-- 10. Update shipment status to shipped
EXEC sp_UpdateShipmentStatus 
    @OrderId = @OrderId,
    @NewStatus = 'Shipped';

-- 11. Update shipment status to delivered
EXEC sp_UpdateShipmentStatus 
    @OrderId = @OrderId,
    @NewStatus = 'Delivered';

-- 12. View order and shipping details
SELECT * FROM orders WHERE id = @OrderId;
SELECT * FROM shipping WHERE order_id = @OrderId;

-- 13. View user event log for actions taken
SELECT * FROM user_event_log WHERE user_id = @User Id;

-- 14. Clean up (optional)
-- EXEC sp_DeleteUser   @Id = @User Id; -- Uncomment to delete the user after demo