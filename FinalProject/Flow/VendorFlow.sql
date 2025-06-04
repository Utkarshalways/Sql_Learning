-- Vendor Flow Execution Script

-- 1. Vendor Registration: CreateUser and CreateVendor
EXEC sp_CreateUser  
    @Name = 'SS Sports Pvt Ltd',
    @Email = 'ContractSSsports@gmail.com', 
    @Password = 'SSsport@123', 
    @PhoneNumber = '9322213241', 
	@Address = 'Bengaluru',
    @Gender = 'Male', 
    @UserType = 'vendor',
    @PaymentDetails = 'ssSports@paytm',
    @PinCode = 914312,
    @Age = 32,
    @GSTnumber = 'ABCDE99992128';
GO

SELECT * FROm users;
SELECT * FROM vendors;


SELECT * FROM vw_VendorPerformance;



-- 2. Vendor Authentication
EXEC sp_AuthenticateUser  
    @email_or_phone = 'ContractSSsports@gmail.com', 
    @password = 'SSsport@123';
GO

DECLARE @id VARCHAR(10) ;
SELECT @id = MAX(id) FROM users
EXEC sp_UpdateUserProfile @id,'SS Sports Pvt Ltd'


DECLARE @id VARCHAR(10) ;
SELECT @id = MAX(id) FROM users
EXEC sp_AddUserAddress  
    @UserId = @id,
    @AddressLine = 'IT Park,Bengaluru',
    @AddressType = 'Office',
    @IsPrimary = 1;
GO

SELECT * FROM products;
SELECT * FROM categories
SELECT * FROM inventory;

-- 3. Product Management: Add and Update Products
DECLARE @id VARCHAR(10) ;
SELECT @id = MAX(id) FROM vendors
EXEC sp_AddProduct  
    @name = 'SS Cricket Ball', 
    @description = 'Test Cricket Ball', 
    @category_id = 'C005', 
    @vendor_id = @id, -- vendor id
    @price = 549.00, 
    @sku = 'SS-CRICKET-BALL-RED', 
    @discount = 1.0, 
    @quantity_in_stock = 89, 
    @inventory_id = 'INV27'; 
GO


SELECT * FROM vw_VendorProducts

DECLARE @id VARCHAR(10) ;
SELECT @id = MAX(id) FROM products
EXEC sp_UpdateProduct  
    @id = @id, 
    @discount = 2.00;
GO

SELECT * FROM products;

-- 5. Inventory Management
DECLARE @id VARCHAR(10) ;
SELECT @id = MAX(id) FROM products
EXEC sp_ManageInventory
    @product_id = @id, 
    @quantity_change = 50,
	@action_type = 'add'
	-- Increase by 50 units
GO


SELECT * FROM inventory;

-- 7. Product Performance and Reports
DECLARE @id VARCHAR(10) ;
SELECT @id = MAX(id) FROM products
EXEC sp_GetProductPerformance  
    @ProductId = @id;
GO


-- 8. Review Management: Delete a Product Review
EXEC sp_DeleteProductReview  
    @UserId = 'USR',  -- Customer user ID
    @ProductId = 'PROD';  -- Product ID
GO


SELECT * FROM vw_VendorPerformance;

SELECT * FROM vw_OrdersByVendor

SELECT * FROM vw_ProductRevenue;

SELECT * FROM vw_PopularProducts;
