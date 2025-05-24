-- =============================================
-- VIEWS
-- =============================================

-- 1. ProductCatalogView - Comprehensive product information for catalog display
CREATE OR ALTER VIEW vw_ProductCatalog AS
SELECT 
    p.id AS ProductID,
    p.name AS ProductName,
    p.description AS Description,
    p.price AS Price,
    p.discount AS DiscountPercentage,
    (p.price - (p.price * p.discount / 100)) AS DiscountedPrice,
    c.name AS CategoryName,
    v.id AS VendorID,
    u.name AS VendorName,
    i.quantity_in_stock AS AvailableStock
FROM 
    products p
    INNER JOIN categories c ON p.category_id = c.id
    INNER JOIN vendors v ON p.vendor_id = v.id
    INNER JOIN users u ON v.userId = u.id
    LEFT JOIN inventory i ON p.id = i.product_id;
GO

-- 2. OrderDetailsView - Comprehensive order information for reporting
CREATE OR ALTER VIEW vw_OrderDetails AS
SELECT 
    o.id AS OrderID,
    o.order_date AS OrderDate,
    o.order_status AS OrderStatus,
    o.total_amount AS TotalAmount,
    o.payment_status AS PaymentStatus,
    u.id AS UserID,
    u.name AS CustomerName,
    u.email AS CustomerEmail,
    COUNT(oi.id) AS TotalItems,
    s.shipping_method AS ShippingMethod,
    s.tracking_number AS TrackingNumber,
    s.estimated_delivery AS EstimatedDelivery
FROM 
    orders o
    INNER JOIN users u ON o.user_id = u.id
    LEFT JOIN order_items oi ON o.id = oi.order_id
    LEFT JOIN shipping s ON o.id = s.order_id
GROUP BY 
    o.id, o.order_date, o.order_status, o.total_amount, o.payment_status,
    u.id, u.name, u.email, s.shipping_method, s.tracking_number, s.estimated_delivery;
GO

-- 3. CustomerProfileView - Customer information for user profiles
CREATE OR ALTER VIEW vw_CustomerProfile AS
SELECT 
    u.id AS UserID,
    u.name AS CustomerName,
    u.email AS Email,
    u.phone_number AS PhoneNumber,
    u.gender AS Gender,
    u.DateOfBirth AS DateOfBirth,
    u.country AS Country,
    c.id AS CustomerID,
    c.paymentDetails AS PaymentDetails,
    c.age AS Age,
    c.address AS Address,
    c.pinCode AS PinCode,
    COUNT(DISTINCT o.id) AS TotalOrders,
    SUM(o.total_amount) AS TotalSpent
FROM 
    users u
    INNER JOIN customers c ON u.id = c.userId
    LEFT JOIN orders o ON u.id = o.user_id
WHERE 
    u.user_type = 'customer'
GROUP BY 
    u.id, u.name, u.email, u.phone_number, u.gender, u.DateOfBirth, u.country,
    c.id, c.paymentDetails, c.age, c.address, c.pinCode;
GO

-- 4. VendorProfileView - Vendor information for vendor profiles
CREATE OR ALTER VIEW vw_VendorProfile AS
SELECT 
    u.id AS UserID,
    u.name AS VendorName,
    u.email AS Email,
    u.phone_number AS PhoneNumber,
    v.id AS VendorID,
    v.address AS Address,
    v.pinCode AS PinCode,
    v.GSTnumber AS GSTNumber,
    COUNT(DISTINCT p.id) AS TotalProducts,
    SUM(i.quantity_in_stock) AS TotalInventory
FROM 
    users u
    INNER JOIN vendors v ON u.id = v.userId
    LEFT JOIN products p ON v.id = p.vendor_id
    LEFT JOIN inventory i ON p.id = i.product_id
WHERE 
    u.user_type = 'vendor'
GROUP BY 
    u.id, u.name, u.email, u.phone_number, v.id, v.address, v.pinCode, v.GSTnumber;
GO

-- 5. ProductReviewsView - Reviews with product and user information
CREATE OR ALTER VIEW vw_ProductReviews AS
SELECT 
    r.id AS ReviewID,
    r.rating AS Rating,
    r.comment AS Comment,
    r.review_date AS ReviewDate,
    p.id AS ProductID,
    p.name AS ProductName,
    u.id AS UserID,
    u.name AS UserName
FROM 
    reviews r
    INNER JOIN products p ON r.product_id = p.id
    INNER JOIN users u ON r.user_id = u.id;
GO

-- 6. RevenueByVendorView - Revenue information by vendor
CREATE OR ALTER VIEW vw_RevenueByVendor AS
SELECT 
    v.id AS VendorID,
    u.name AS VendorName,
    p.id AS ProductID,
    p.name AS ProductName,
    SUM(oi.quantity) AS TotalQuantitySold,
    SUM(oi.total_price) AS TotalRevenue
FROM 
    vendors v
    INNER JOIN users u ON v.userId = u.id
    INNER JOIN products p ON v.id = p.vendor_id
    INNER JOIN order_items oi ON p.id = oi.product_id
    INNER JOIN orders o ON oi.order_id = o.id
WHERE 
    o.payment_status = 'Completed'
GROUP BY 
    v.id, u.name, p.id, p.name;
GO

-- 7. CategoryHierarchyView - Category hierarchy with parent-child relationships
CREATE OR ALTER VIEW vw_CategoryHierarchy AS
WITH CategoryCTE AS (
    SELECT 
        id,
        name,
        parent_category_id,
        0 AS Level,
        CAST(name AS NVARCHAR(MAX)) AS Hierarchy
    FROM 
        categories
    WHERE 
        parent_category_id IS NULL
    
    UNION ALL
    
    SELECT 
        c.id,
        c.name,
        c.parent_category_id,
        cte.Level + 1,
        CAST(cte.Hierarchy + ' > ' + c.name AS NVARCHAR(MAX))
    FROM 
        categories c
        INNER JOIN CategoryCTE cte ON c.parent_category_id = cte.id
)
SELECT 
    id AS CategoryID,
    name AS CategoryName,
    parent_category_id AS ParentCategoryID,
    Level AS HierarchyLevel,
    Hierarchy AS CategoryPath
FROM 
    CategoryCTE;
GO

-- 8. CustomerWishlistView - Customer wishlist with product details
CREATE OR ALTER VIEW vw_CustomerWishlist AS
SELECT 
    w.id AS WishlistID,
    u.id AS UserID,
    u.name AS CustomerName,
    p.id AS ProductID,
    p.name AS ProductName,
    p.price AS Price,
    p.discount AS DiscountPercentage,
    (p.price - (p.price * p.discount / 100)) AS DiscountedPrice,
    i.quantity_in_stock AS AvailableStock
FROM 
    wishlist w
    INNER JOIN users u ON w.user_id = u.id
    INNER JOIN products p ON w.product_id = p.id
    LEFT JOIN inventory i ON p.id = i.product_id;
GO

-- 9. ShoppingCartView - Shopping cart with product details
CREATE OR ALTER VIEW vw_ShoppingCart AS
SELECT 
    sc.id AS CartID,
    u.id AS UserID,
    u.name AS CustomerName,
    p.id AS ProductID,
    p.name AS ProductName,
    sc.quantity AS Quantity,
    p.price AS UnitPrice,
    p.discount AS DiscountPercentage,
    (p.price - (p.price * p.discount / 100)) AS DiscountedUnitPrice,
    (p.price - (p.price * p.discount / 100)) * sc.quantity AS TotalPrice,
    i.quantity_in_stock AS AvailableStock
FROM 
    shopping_cart sc
    INNER JOIN users u ON sc.user_id = u.id
    INNER JOIN products p ON sc.product_id = p.id
    LEFT JOIN inventory i ON p.id = i.product_id;
GO

-- 10. InvoiceSummaryView - Invoice summary with payment and order details
CREATE OR ALTER VIEW vw_InvoiceSummary AS
SELECT 
    i.id AS InvoiceID,
    i.invoice_date AS InvoiceDate,
    i.due_date AS DueDate,
    i.total_amount AS TotalAmount,
    i.status AS InvoiceStatus,
    o.id AS OrderID,
    o.order_date AS OrderDate,
    o.order_status AS OrderStatus,
    u.id AS CustomerID,
    u.name AS CustomerName,
    u.email AS CustomerEmail,
    v.id AS VendorID,
    vu.name AS VendorName,
    p.id AS PaymentID,
    p.payment_method AS PaymentMethod,
    p.amount AS PaymentAmount,
    p.payment_date AS PaymentDate
FROM 
    invoices i
    INNER JOIN orders o ON i.order_id = o.id
    INNER JOIN users u ON o.user_id = u.id
    INNER JOIN vendors v ON i.vendor_id = v.id
    INNER JOIN users vu ON v.userId = vu.id
    LEFT JOIN payments p ON i.payment_id = p.id;
GO

-- =============================================
-- STORED PROCEDURES
-- =============================================

-- 1. Register New User
CREATE OR ALTER PROCEDURE sp_RegisterUser
    @id NVARCHAR(50),
    @name NVARCHAR(255),
    @email NVARCHAR(255),
    @password NVARCHAR(255),
    @address NVARCHAR(500),
    @phone_number NVARCHAR(20),
    @gender NVARCHAR(10),
    @DateOfBirth DATETIME,
    @country NVARCHAR(100),
    @user_type NVARCHAR(50),
    @paymentDetails NVARCHAR(1000) = NULL,
    @age INT = NULL,
    @pinCode INT = NULL,
    @GSTnumber NVARCHAR(50) = NULL,
    @paymentReceivingDetails NVARCHAR(1000) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;
    DECLARE @CustomerId BIGINT;
    DECLARE @VendorId BIGINT;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Input validation
        IF @user_type NOT IN ('customer', 'vendor')
            THROW 50001, 'Invalid user type. User type must be either customer or vendor.', 1;
            
        IF @user_type = 'vendor' AND @GSTnumber IS NULL
            THROW 50002, 'GST number is required for vendor registration.', 1;
            
        -- Hash the password
        DECLARE @HashedPassword VARBINARY(MAX);
        SET @HashedPassword = HASHBYTES('SHA2_256', CONVERT(VARBINARY, @password));
        
        -- Insert user
        INSERT INTO users (id, name, email, password, address, phone_number, gender, DateOfBirth, country, user_type)
        VALUES (@id, @name, @email, @HashedPassword, @address, @phone_number, @gender, @DateOfBirth, @country, @user_type);
        
        -- Insert customer or vendor details based on user type
        IF @user_type = 'customer'
        BEGIN
            SET @CustomerId = NEXT VALUE FOR customer_id_seq;
            
            INSERT INTO customers (id, userId, paymentDetails, age, address, pinCode)
            VALUES (@CustomerId, @id, @paymentDetails, @age, @address, @pinCode);
            
            SELECT 'Customer registered successfully' AS Result, @id AS UserId, @CustomerId AS CustomerId;
        END
        ELSE IF @user_type = 'vendor'
        BEGIN
            SET @VendorId = NEXT VALUE FOR vendor_id_seq;
            
            INSERT INTO vendors (id, userId, paymentReceivingDetails, address, pinCode, GSTnumber)
            VALUES (@VendorId, @id, @paymentReceivingDetails, @address, @pinCode, @GSTnumber);
            
            SELECT 'Vendor registered successfully' AS Result, @id AS UserId, @VendorId AS VendorId;
        END
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_SEVERITY() AS ErrorSeverity,
            ERROR_STATE() AS ErrorState,
            ERROR_PROCEDURE() AS ErrorProcedure,
            ERROR_LINE() AS ErrorLine,
            ERROR_MESSAGE() AS ErrorMessage;
            
        -- Get error details
        SELECT @ErrorMessage = ERROR_MESSAGE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE();
               
        -- Re-throw the error
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
GO

-- 14. Add Product Review
CREATE OR ALTER PROCEDURE sp_AddProductReview
    @id NVARCHAR(50),
    @user_id NVARCHAR(50),
    @product_id NVARCHAR(50),
    @rating INT,
    @comment NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Check if user exists
        IF NOT EXISTS (SELECT 1 FROM users WHERE id = @user_id)
            THROW 50014, 'User does not exist.', 1;
            
        -- Check if product exists
        IF NOT EXISTS (SELECT 1 FROM products WHERE id = @product_id)
            THROW 50009, 'Product does not exist.', 1;
            
        -- Validate rating
        IF @rating < 1 OR @rating > 5
            THROW 50025, 'Rating must be between 1 and 5.', 1;
            
        -- Check if user has purchased the product
        IF NOT EXISTS (
            SELECT 1
            FROM orders o
            INNER JOIN order_items oi ON o.id = oi.order_id
            WHERE o.user_id = @user_id AND oi.product_id = @product_id AND o.order_status = 'Delivered'
        )
            THROW 50026, 'You can only review products you have purchased and received.', 1;
            
        -- Check if user has already reviewed this product
        IF EXISTS (SELECT 1 FROM reviews WHERE user_id = @user_id AND product_id = @product_id)
        BEGIN
            -- Update existing review
            UPDATE reviews
            SET 
                rating = @rating,
                comment = @comment,
                review_date = GETDATE(),
                updated_at = GETDATE()
            WHERE 
                user_id = @user_id AND product_id = @product_id;
                
            SELECT 'Review updated successfully' AS Result;
        END
        ELSE
        BEGIN
            -- Insert new review
            INSERT INTO reviews (id, user_id, product_id, rating, comment, review_date, created_at, updated_at)
            VALUES (@id, @user_id, @product_id, @rating, @comment, GETDATE(), GETDATE(), GETDATE());
            
            SELECT 'Review added successfully' AS Result, @id AS ReviewId;
        END
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_SEVERITY() AS ErrorSeverity,
            ERROR_STATE() AS ErrorState,
            ERROR_PROCEDURE() AS ErrorProcedure,
            ERROR_LINE() AS ErrorLine,
            ERROR_MESSAGE() AS ErrorMessage;
            
        -- Get error details
        SELECT @ErrorMessage = ERROR_MESSAGE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE();
               
        -- Re-throw the error
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
GO

-- 15. Get User Orders
CREATE OR ALTER PROCEDURE sp_GetUserOrders
    @user_id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Check if user exists
        IF NOT EXISTS (SELECT 1 FROM users WHERE id = @user_id)
            THROW 50014, 'User does not exist.', 1;
            
        -- Get user orders with order items and product information
        SELECT 
            o.id AS OrderID,
            o.order_date AS OrderDate,
            o.order_status AS OrderStatus,
            o.total_amount AS TotalAmount,
            o.payment_status AS PaymentStatus,
            COUNT(oi.id) AS TotalItems,
            p.id AS PaymentID,
            p.payment_method AS PaymentMethod,
            p.payment_date AS PaymentDate,
            s.shipping_method AS ShippingMethod,
            s.tracking_number AS TrackingNumber,
            s.estimated_delivery AS EstimatedDelivery
        FROM 
            orders o
            LEFT JOIN order_items oi ON o.id = oi.order_id
            LEFT JOIN payments p ON o.id = p.order_id
            LEFT JOIN shipping s ON o.id = s.order_id
        WHERE 
            o.user_id = @user_id
        GROUP BY 
            o.id, o.order_date, o.order_status, o.total_amount, o.payment_status,
            p.id, p.payment_method, p.payment_date,
            s.shipping_method, s.tracking_number, s.estimated_delivery
        ORDER BY 
            o.order_date DESC;
    END TRY
    BEGIN CATCH
        SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_SEVERITY() AS ErrorSeverity,
            ERROR_STATE() AS ErrorState,
            ERROR_PROCEDURE() AS ErrorProcedure,
            ERROR_LINE() AS ErrorLine,
            ERROR_MESSAGE() AS ErrorMessage;
    END CATCH;
END;
GO

-- 17. Search Products
CREATE OR ALTER PROCEDURE sp_SearchProducts
    @search_term NVARCHAR(255) = NULL,
    @category_id NVARCHAR(50) = NULL,
    @min_price DECIMAL(18,2) = NULL,
    @max_price DECIMAL(18,2) = NULL,
    @sort_by NVARCHAR(50) = 'name', -- Options: 'name', 'price_asc', 'price_desc', 'newest'
    @page_number INT = 1,
    @page_size INT = 20
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Calculate pagination parameters
        DECLARE @offset INT = (@page_number - 1) * @page_size;
        
        -- Validate sort_by parameter
        IF @sort_by NOT IN ('name', 'price_asc', 'price_desc', 'newest')
            SET @sort_by = 'name';
            
        -- Build dynamic SQL query
        DECLARE @sql NVARCHAR(MAX);
        
        SET @sql = N'
            SELECT 
                p.id AS ProductID,
                p.name AS ProductName,
                p.description AS Description,
                p.price AS Price,
                p.discount AS DiscountPercentage,
                (p.price - (p.price * p.discount / 100)) AS DiscountedPrice,
                c.name AS CategoryName,
                v.id AS VendorID,
                u.name AS VendorName,
                i.quantity_in_stock AS AvailableStock,
                COUNT(*) OVER() AS TotalCount
            FROM 
                products p
                INNER JOIN categories c ON p.category_id = c.id
                INNER JOIN vendors v ON p.vendor_id = v.id
                INNER JOIN users u ON v.userId = u.id
                LEFT JOIN inventory i ON p.id = i.product_id
            WHERE 1 = 1';
            
        -- Add search conditions if provided
        IF @search_term IS NOT NULL
            SET @sql = @sql + N' AND (p.name LIKE ''%' + @search_term + '%'' OR p.description LIKE ''%' + @search_term + '%'')';
            
        IF @category_id IS NOT NULL
            SET @sql = @sql + N' AND p.category_id = ''' + @category_id + '''';
            
        IF @min_price IS NOT NULL
            SET @sql = @sql + N' AND (p.price - (p.price * p.discount / 100)) >= ' + CAST(@min_price AS NVARCHAR(20));
            
        IF @max_price IS NOT NULL
            SET @sql = @sql + N' AND (p.price - (p.price * p.discount / 100)) <= ' + CAST(@max_price AS NVARCHAR(20));
            
        -- Add sort order
        SET @sql = @sql + N' ORDER BY ';
        
        IF @sort_by = 'name'
            SET @sql = @sql + N'p.name';
        ELSE IF @sort_by = 'price_asc'
            SET @sql = @sql + N'(p.price - (p.price * p.discount / 100))';
        ELSE IF @sort_by = 'price_desc'
            SET @sql = @sql + N'(p.price - (p.price * p.discount / 100)) DESC';
        ELSE IF @sort_by = 'newest'
            SET @sql = @sql + N'p.id DESC'; -- Assuming newer products have higher ID values
            
        -- Add pagination
        SET @sql = @sql + N' OFFSET ' + CAST(@offset AS NVARCHAR(10)) + N' ROWS FETCH NEXT ' + CAST(@page_size AS NVARCHAR(10)) + N' ROWS ONLY';
        
        -- Execute the query
        EXEC sp_executesql @sql;
    END TRY
    BEGIN CATCH
        SELECT 
            ERROR_

-- 16. Get Order Details
CREATE OR ALTER PROCEDURE sp_GetOrderDetails
    @order_id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Check if order exists
        IF NOT EXISTS (SELECT 1 FROM orders WHERE id = @order_id)
            THROW 50021, 'Order does not exist.', 1;
            
        -- Get order header information
        SELECT 
            o.id AS OrderID,
            o.order_date AS OrderDate,
            o.order_status AS OrderStatus,
            o.total_amount AS TotalAmount,
            o.payment_status AS PaymentStatus,
            u.id AS UserID,
            u.name AS CustomerName,
            u.email AS CustomerEmail,
            s.shipping_method AS ShippingMethod,
            s.tracking_number AS TrackingNumber,
            s.estimated_delivery AS EstimatedDelivery,
            s.status AS ShippingStatus,
            p.id AS PaymentID,
            p.payment_method AS PaymentMethod,
            p.payment_date AS PaymentDate
        FROM 
            orders o
            INNER JOIN users u ON o.user_id = u.id
            LEFT JOIN shipping s ON o.id = s.order_id
            LEFT JOIN payments p ON o.id = p.order_id
        WHERE 
            o.id = @order_id;
            
        -- Get order items with product details
        SELECT 
            oi.id AS OrderItemID,
            oi.order_id AS OrderID,
            oi.product_id AS ProductID,
            p.name AS ProductName,
            oi.quantity AS Quantity,
            oi.unit_price AS UnitPrice,
            oi.total_price AS TotalPrice,
            c.name AS CategoryName,
            v.id AS VendorID,
            u.name AS VendorName
        FROM 
            order_items oi
            INNER JOIN products p ON oi.product_id = p.id
            INNER JOIN categories c ON p.category_id = c.id
            INNER JOIN vendors v ON p.vendor_id = v.id
            INNER JOIN users u ON v.userId = u.id
        WHERE 
            oi.order_id = @order_id
        ORDER BY 
            p.name;
    END TRY
    BEGIN CATCH
        SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_SEVERITY() AS ErrorSeverity,
            ERROR_STATE() AS ErrorState,
            ERROR_PROCEDURE() AS ErrorProcedure,
            ERROR_LINE() AS ErrorLine,
            ERROR_MESSAGE() AS ErrorMessage;
    END CATCH;
END;
GO

-- 2. User Authentication
CREATE OR ALTER PROCEDURE sp_AuthenticateUser
    @email NVARCHAR(255),
    @password NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Hash the provided password
        DECLARE @HashedPassword VARBINARY(MAX);
        SET @HashedPassword = HASHBYTES('SHA2_256', CONVERT(VARBINARY, @password));
        
        -- Check if user exists with matching email and password
        DECLARE @UserId NVARCHAR(50);
        DECLARE @UserType NVARCHAR(50);
        
        SELECT @UserId = id, @UserType = user_type
        FROM users
        WHERE email = @email AND password = @HashedPassword;
        
        IF @UserId IS NULL
            THROW 50003, 'Invalid email or password.', 1;
            
        -- Return user information based on user type
        IF @UserType = 'customer'
        BEGIN
            SELECT 
                u.id AS UserId,
                u.name AS UserName,
                u.email AS Email,
                u.user_type AS UserType,
                c.id AS CustomerId
            FROM 
                users u
                INNER JOIN customers c ON u.id = c.userId
            WHERE 
                u.id = @UserId;
        END
        ELSE IF @UserType = 'vendor'
        BEGIN
            SELECT 
                u.id AS UserId,
                u.name AS UserName,
                u.email AS Email,
                u.user_type AS UserType,
                v.id AS VendorId,
                v.GSTnumber AS GSTNumber
            FROM 
                users u
                INNER JOIN vendors v ON u.id = v.userId
            WHERE 
                u.id = @UserId;
        END
    END TRY
    BEGIN CATCH
        SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_SEVERITY() AS ErrorSeverity,
            ERROR_STATE() AS ErrorState,
            ERROR_PROCEDURE() AS ErrorProcedure,
            ERROR_LINE() AS ErrorLine,
            ERROR_MESSAGE() AS ErrorMessage;
    END CATCH;
END;
GO

-- 3. Add Product
CREATE OR ALTER PROCEDURE sp_AddProduct
    @id NVARCHAR(50),
    @name NVARCHAR(255),
    @description NVARCHAR(MAX),
    @category_id NVARCHAR(50),
    @vendor_id BIGINT,
    @price DECIMAL(18,2),
    @stockKeepingUnit NVARCHAR(100),
    @discount DECIMAL(5,2),
    @initial_stock INT = 0
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Input validation
        IF @price < 0
            THROW 50004, 'Product price cannot be negative.', 1;
            
        IF @discount < 0
            THROW 50005, 'Product discount cannot be negative.', 1;
            
        IF @initial_stock < 0
            THROW 50006, 'Initial stock cannot be negative.', 1;
            
        -- Check if vendor exists
        IF NOT EXISTS (SELECT 1 FROM vendors WHERE id = @vendor_id)
            THROW 50007, 'Specified vendor does not exist.', 1;
            
        -- Check if category exists
        IF NOT EXISTS (SELECT 1 FROM categories WHERE id = @category_id)
            THROW 50008, 'Specified category does not exist.', 1;
            
        -- Insert product
        INSERT INTO products (id, name, description, category_id, vendor_id, price, stockKeepingUnit, discount)
        VALUES (@id, @name, @description, @category_id, @vendor_id, @price, @stockKeepingUnit, @discount);
        
        -- Insert into inventory if initial stock is provided
        IF @initial_stock > 0
        BEGIN
            INSERT INTO inventory (id, product_id, quantity_in_stock)
            VALUES (NEWID(), @id, @initial_stock);
        END
        ELSE
        BEGIN
            INSERT INTO inventory (id, product_id, quantity_in_stock)
            VALUES (NEWID(), @id, 0);
        END
        
        SELECT 'Product added successfully' AS Result, @id AS ProductId;
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_SEVERITY() AS ErrorSeverity,
            ERROR_STATE() AS ErrorState,
            ERROR_PROCEDURE() AS ErrorProcedure,
            ERROR_LINE() AS ErrorLine,
            ERROR_MESSAGE() AS ErrorMessage;
            
        -- Get error details
        SELECT @ErrorMessage = ERROR_MESSAGE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE();
               
        -- Re-throw the error
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
GO

-- 4. Update Product
CREATE OR ALTER PROCEDURE sp_UpdateProduct
    @id NVARCHAR(50),
    @name NVARCHAR(255) = NULL,
    @description NVARCHAR(MAX) = NULL,
    @category_id NVARCHAR(50) = NULL,
    @price DECIMAL(18,2) = NULL,
    @discount DECIMAL(5,2) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Check if product exists
        IF NOT EXISTS (SELECT 1 FROM products WHERE id = @id)
            THROW 50009, 'Product does not exist.', 1;
            
        -- Input validation
        IF @price IS NOT NULL AND @price < 0
            THROW 50004, 'Product price cannot be negative.', 1;
            
        IF @discount IS NOT NULL AND @discount < 0
            THROW 50005, 'Product discount cannot be negative.', 1;
            
        IF @category_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM categories WHERE id = @category_id)
            THROW 50008, 'Specified category does not exist.', 1;
            
        -- Update product
        UPDATE products
        SET 
            name = ISNULL(@name, name),
            description = ISNULL(@description, description),
            category_id = ISNULL(@category_id, category_id),
            price = ISNULL(@price, price),
            discount = ISNULL(@discount, discount)
        WHERE 
            id = @id;
            
        SELECT 'Product updated successfully' AS Result, @id AS ProductId;
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_SEVERITY() AS ErrorSeverity,
            ERROR_STATE() AS ErrorState,
            ERROR_PROCEDURE() AS ErrorProcedure,
            ERROR_LINE() AS ErrorLine,
            ERROR_MESSAGE() AS ErrorMessage;
            
        -- Get error details
        SELECT @ErrorMessage = ERROR_MESSAGE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE();
               
        -- Re-throw the error
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
GO

-- 5. Update Inventory
CREATE OR ALTER PROCEDURE sp_UpdateInventory
    @product_id NVARCHAR(50),
    @quantity_change INT,
    @operation CHAR(1) -- 'A' for add, 'S' for subtract, 'R' for replace
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;
    DECLARE @CurrentStock INT;
    DECLARE @InventoryID NVARCHAR(50);
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Check if product exists
        IF NOT EXISTS (SELECT 1 FROM products WHERE id = @product_id)
            THROW 50009, 'Product does not exist.', 1;
            
        -- Get current inventory information
        SELECT @InventoryID = id, @CurrentStock = quantity_in_stock
        FROM inventory
        WHERE product_id = @product_id;
        
        -- Create inventory record if it doesn't exist
        IF @InventoryID IS NULL
        BEGIN
            SET @InventoryID = NEWID();
            SET @CurrentStock = 0;
            
            INSERT INTO inventory (id, product_id, quantity_in_stock)
            VALUES (@InventoryID, @product_id, 0);
        END
        
        -- Update inventory based on operation
        IF @operation = 'A' -- Add
        BEGIN
            UPDATE inventory
            SET quantity_in_stock = quantity_in_stock + @quantity_change
            WHERE id = @InventoryID;
            
            SELECT 'Inventory increased successfully' AS Result, @product_id AS ProductId, @CurrentStock AS OldStock, @CurrentStock + @quantity_change AS NewStock;
        END
        ELSE IF @operation = 'S' -- Subtract
        BEGIN
            IF @CurrentStock < @quantity_change
                THROW 50010, 'Insufficient inventory to subtract the specified quantity.', 1;
                
            UPDATE inventory
            SET quantity_in_stock = quantity_in_stock - @quantity_change
            WHERE id = @InventoryID;
            
            SELECT 'Inventory decreased successfully' AS Result, @product_id AS ProductId, @CurrentStock AS OldStock, @CurrentStock - @quantity_change AS NewStock;
        END
        ELSE IF @operation = 'R' -- Replace
        BEGIN
            IF @quantity_change < 0
                THROW 50011, 'Replacement quantity cannot be negative.', 1;
                
            UPDATE inventory
            SET quantity_in_stock = @quantity_change
            WHERE id = @InventoryID;
            
            SELECT 'Inventory updated successfully' AS Result, @product_id AS ProductId, @CurrentStock AS OldStock, @quantity_change AS NewStock;
        END
        ELSE
            THROW 50012, 'Invalid operation. Use ''A'' for add, ''S'' for subtract, or ''R'' for replace.', 1;
            
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_SEVERITY() AS ErrorSeverity,
            ERROR_STATE() AS ErrorState,
            ERROR_PROCEDURE() AS ErrorProcedure,
            ERROR_LINE() AS ErrorLine,
            ERROR_MESSAGE() AS ErrorMessage;
            
        -- Get error details
        SELECT @ErrorMessage = ERROR_MESSAGE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE();
               
        -- Re-throw the error
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
GO

-- 6. Add to Cart
CREATE OR ALTER PROCEDURE sp_AddToCart
    @user_id NVARCHAR(50),
    @product_id NVARCHAR(50),
    @quantity INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;
    DECLARE @CurrentStock INT;
    DECLARE @CurrentCartQuantity INT = 0;
    DECLARE @ExistingCartItemID NVARCHAR(50);
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Input validation
        IF @quantity <= 0
            THROW 50013, 'Quantity must be greater than zero.', 1;
            
        -- Check if user exists
        IF NOT EXISTS (SELECT 1 FROM users WHERE id = @user_id)
            THROW 50014, 'User does not exist.', 1;
            
        -- Check if product exists
        IF NOT EXISTS (SELECT 1 FROM products WHERE id = @product_id)
            THROW 50009, 'Product does not exist.', 1;
            
        -- Check if there's sufficient inventory
        SELECT @CurrentStock = quantity_in_stock
        FROM inventory
        WHERE product_id = @product_id;
        
        IF @CurrentStock IS NULL
            SET @CurrentStock = 0;
            
        -- Check if item already exists in the cart
        SELECT @ExistingCartItemID = id, @CurrentCartQuantity = quantity
        FROM shopping_cart
        WHERE user_id = @user_id AND product_id = @product_id;
        
        -- Calculate total quantity needed
        DECLARE @TotalQuantityNeeded INT = @quantity;
        IF @ExistingCartItemID IS NOT NULL
            SET @TotalQuantityNeeded = @TotalQuantityNeeded + @CurrentCartQuantity;
            
        -- Check if there's enough inventory
        IF @CurrentStock < @TotalQuantityNeeded
            THROW 50015, 'Insufficient inventory to add the requested quantity to cart.', 1;
            
        -- Update or insert cart item
        IF @ExistingCartItemID IS NOT NULL
        BEGIN
            UPDATE shopping_cart
            SET 
                quantity = @TotalQuantityNeeded,
                updated_at = GETDATE()
            WHERE 
                id = @ExistingCartItemID;
                
            SELECT 'Item quantity updated in cart' AS Result, @ExistingCartItemID AS CartItemId, @TotalQuantityNeeded AS NewQuantity;
        END
        ELSE
        BEGIN
            DECLARE @CartItemID NVARCHAR(50) = NEWID();
            
            INSERT INTO shopping_cart (id, user_id, product_id, quantity, created_at, updated_at)
            VALUES (@CartItemID, @user_id, @product_id, @quantity, GETDATE(), GETDATE());
            
            SELECT 'Item added to cart' AS Result, @CartItemID AS CartItemId, @quantity AS Quantity;
        END
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_SEVERITY() AS ErrorSeverity,
            ERROR_STATE() AS ErrorState,
            ERROR_PROCEDURE() AS ErrorProcedure,
            ERROR_LINE() AS ErrorLine,
            ERROR_MESSAGE() AS ErrorMessage;
            
        -- Get error details
        SELECT @ErrorMessage = ERROR_MESSAGE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE();
               
        -- Re-throw the error
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
GO

-- 7. Remove from Cart
CREATE OR ALTER PROCEDURE sp_RemoveFromCart
    @cart_item_id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Check if cart item exists
        IF NOT EXISTS (SELECT 1 FROM shopping_cart WHERE id = @cart_item_id)
            THROW 50016, 'Cart item does not exist.', 1;
            
        -- Delete cart item
        DELETE FROM shopping_cart
        WHERE id = @cart_item_id;
        
        SELECT 'Item removed from cart successfully' AS Result, @cart_item_id AS CartItemId;
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_SEVERITY() AS ErrorSeverity,
            ERROR_STATE() AS ErrorState,
            ERROR_PROCEDURE() AS ErrorProcedure,
            ERROR_LINE() AS ErrorLine,
            ERROR_MESSAGE() AS ErrorMessage;
            
        -- Get error details
        SELECT @ErrorMessage = ERROR_MESSAGE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE();
               
        -- Re-throw the error
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
GO

-- 8. Add to Wishlist
CREATE OR ALTER PROCEDURE sp_AddToWishlist
    @user_id NVARCHAR(50),
    @product_id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Check if user exists
        IF NOT EXISTS (SELECT 1 FROM users WHERE id = @user_id)
            THROW 50014, 'User does not exist.', 1;
            
        -- Check if product exists
        IF NOT EXISTS (SELECT 1 FROM products WHERE id = @product_id)
            THROW 50009, 'Product does not exist.', 1;
            
        -- Check if item already exists in the wishlist
        IF EXISTS (SELECT 1 FROM wishlist WHERE user_id = @user_id AND product_id = @product_id)
            THROW 50017, 'Product already exists in wishlist.', 1;
            
        -- Add to wishlist
        DECLARE @WishlistID NVARCHAR(50) = NEWID();
        
        INSERT INTO wishlist (id, user_id, product_id)
        VALUES (@WishlistID, @user_id, @product_id);
        
        SELECT 'Product added to wishlist successfully' AS Result, @WishlistID AS WishlistId;
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_SEVERITY() AS ErrorSeverity,
            ERROR_STATE() AS ErrorState,
            ERROR_PROCEDURE() AS ErrorProcedure,
            ERROR_LINE() AS ErrorLine,
            ERROR_MESSAGE() AS ErrorMessage;
            
        -- Get error details
        SELECT @ErrorMessage = ERROR_MESSAGE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE();
               
        -- Re-throw the error
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
GO

-- 9. Remove from Wishlist
CREATE OR ALTER PROCEDURE sp_RemoveFromWishlist
    @wishlist_id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Check if wishlist item exists
        IF NOT EXISTS (SELECT 1 FROM wishlist WHERE id = @wishlist_id)
            THROW 50018, 'Wishlist item does not exist.', 1;
            
        -- Delete wishlist item
        DELETE FROM wishlist
        WHERE id = @wishlist_id;
        
        SELECT 'Item removed from wishlist successfully' AS Result, @wishlist_id AS WishlistItemId;
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_SEVERITY() AS ErrorSeverity,
            ERROR_STATE() AS ErrorState,
            ERROR_PROCEDURE() AS ErrorProcedure,
            ERROR_LINE() AS ErrorLine,
            ERROR_MESSAGE() AS ErrorMessage;
            
        -- Get error details
        SELECT @ErrorMessage = ERROR_MESSAGE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE();
               
        -- Re-throw the error
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
GO

-- 10. Create Order
CREATE OR ALTER PROCEDURE sp_CreateOrder
    @id NVARCHAR(50),
    @user_id NVARCHAR(50),
    @shipping_address NVARCHAR(500),
    @shipping_method NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;
    DECLARE @TotalAmount DECIMAL(18,2) = 0;
    DECLARE @ShippingId NVARCHAR(50) = NEWID();
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Check if user exists
        IF NOT EXISTS (SELECT 1 FROM users WHERE id = @user_id)
            THROW 50014, 'User does not exist.', 1;
            
        -- Check if user has items in cart
        IF NOT EXISTS (SELECT 1 FROM shopping_cart WHERE user_id = @user_id)
            THROW 50019, 'Shopping cart is empty.', 1;
            
        -- Check inventory for all cart items
        IF EXISTS (
            SELECT sc.product_id
            FROM shopping_cart sc
            LEFT JOIN inventory i ON sc.product_id = i.product_id
            WHERE sc.user_id = @user_id
            AND (i.quantity_in_stock IS NULL OR i.quantity_in_stock < sc.quantity)
        )
        BEGIN
            THROW 50020, 'One or more products in your cart have insufficient inventory.', 1;
        END
        
        -- Create order
        INSERT INTO orders (id, user_id, order_date, order_status, total_amount, payment_status, created_at, updated_at)
        VALUES (@id, @user_id, GETDATE(), 'Pending', 0, 'Pending', GETDATE(), GETDATE());
        
        -- Create shipping record
        INSERT INTO shipping (id, order_id, shipping_method, tracking_number, estimated_delivery, status)
        VALUES (@ShippingId, @id, @shipping_method, NULL, DATEADD(DAY, 7, GETDATE()), 'Processing');
        
        -- Transfer items from cart to order items and update inventory
        INSERT INTO order_items (id, order_id, product_id, quantity, unit_price)
        SELECT 
            NEWID(), 
            @id, 
            sc.product_id, 
            sc.quantity, 
            (p.price - (p.price * p.discount / 100))
        FROM 
            shopping_cart sc
            INNER JOIN products p ON sc.product_id = p.product_id
        WHERE 
            sc.user_id = @user_id;
            
        -- Update inventory
        UPDATE i
        SET quantity_in_stock = i.quantity_in_stock - sc.quantity
        FROM 
            inventory i
            INNER JOIN shopping_cart sc ON i.product_id = sc.product_id
        WHERE 
            sc.user_id = @user_id;
            
        -- Calculate total amount
        SELECT @TotalAmount = SUM(oi.total_price)
        FROM order_items oi
        WHERE oi.order_id = @id;
        
        -- Update order total
        UPDATE orders
        SET total_amount = @TotalAmount
        WHERE id = @id;
        
        -- Clear the cart
        DELETE FROM shopping_cart
        WHERE user_id = @user_id;
        
        SELECT 'Order created successfully' AS Result, @id AS OrderId, @TotalAmount AS TotalAmount;
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_SEVERITY() AS ErrorSeverity,
            ERROR_STATE() AS ErrorState,
            ERROR_PROCEDURE() AS ErrorProcedure,
            ERROR_LINE() AS ErrorLine,
            ERROR_MESSAGE() AS ErrorMessage;
            
        -- Get error details
        SELECT @ErrorMessage = ERROR_MESSAGE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE();
               
        -- Re-throw the error
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
GO

-- 11. Process Payment
CREATE OR ALTER PROCEDURE sp_ProcessPayment
    @id NVARCHAR(50),
    @order_id NVARCHAR(50),
    @payment_method NVARCHAR(50),
    @amount DECIMAL(18,2)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;
    DECLARE @OrderTotal DECIMAL(18,2);
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Check if order exists
        IF NOT EXISTS (SELECT 1 FROM orders WHERE id = @order_id)
            THROW 50021, 'Order does not exist.', 1;
            
        -- Get order total
        SELECT @OrderTotal = total_amount
        FROM orders
        WHERE id = @order_id;
        
        -- Check if payment amount matches order total
        IF @amount != @OrderTotal
            THROW 50022, 'Payment amount does not match order total.', 1;
            
        -- Insert payment record
        INSERT INTO payments (id, order_id, payment_method, amount, payment_date, created_at, updated_at)
        VALUES (@id, @order_id, @payment_method, @amount, GETDATE(), GETDATE(), GETDATE());
        
        -- Update order payment status
        UPDATE orders
        SET payment_status = 'Completed', updated_at = GETDATE()
        WHERE id = @order_id;
        
        SELECT 'Payment processed successfully' AS Result, @id AS PaymentId, @order_id AS OrderId;
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_SEVERITY() AS ErrorSeverity,
            ERROR_STATE() AS ErrorState,
            ERROR_PROCEDURE() AS ErrorProcedure,
            ERROR_LINE() AS ErrorLine,
            ERROR_MESSAGE() AS ErrorMessage;
            
        -- Get error details
        SELECT @ErrorMessage = ERROR_MESSAGE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE();
               
        -- Re-throw the error
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
GO

-- 12. Update Order Status
CREATE OR ALTER PROCEDURE sp_UpdateOrderStatus
    @order_id NVARCHAR(50),
    @order_status NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Check if order exists
        IF NOT EXISTS (SELECT 1 FROM orders WHERE id = @order_id)
            THROW 50021, 'Order does not exist.', 1;
            
        -- Validate order status
        IF @order_status NOT IN ('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled')
            THROW 50023, 'Invalid order status.', 1;
            
        -- Update order status
        UPDATE orders
        SET order_status = @order_status, updated_at = GETDATE()
        WHERE id = @order_id;
        
        -- Update shipping status if order is shipped or delivered
        IF @order_status = 'Shipped'
        BEGIN
            UPDATE shipping
            SET status = 'Shipped', tracking_number = 'TRK' + REPLACE(CONVERT(VARCHAR(36), NEWID()), '-', '')
            WHERE order_id = @order_id;
        END
        ELSE IF @order_status = 'Delivered'
        BEGIN
            UPDATE shipping
            SET status = 'Delivered'
            WHERE order_id = @order_id;
        END
        
        SELECT 'Order status updated successfully' AS Result, @order_id AS OrderId, @order_status AS OrderStatus;
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_SEVERITY() AS ErrorSeverity,
            ERROR_STATE() AS ErrorState,
            ERROR_PROCEDURE() AS ErrorProcedure,
            ERROR_LINE() AS ErrorLine,
            ERROR_MESSAGE() AS ErrorMessage;
            
        -- Get error details
        SELECT @ErrorMessage = ERROR_MESSAGE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE();
               
        -- Re-throw the error
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
GO

-- 13. Generate Invoice
CREATE OR ALTER PROCEDURE sp_GenerateInvoice
    @id NVARCHAR(50),
    @order_id NVARCHAR(50),
    @payment_id NVARCHAR(50),
    @billing_address NVARCHAR(500),
    @shipping_address NVARCHAR(500),
    @due_date DATETIME = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;
    DECLARE @VendorId BIGINT;
    DECLARE @OrderTotal DECIMAL(18,2);
    DECLARE @PaymentMethod NVARCHAR(50);
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Check if order exists
        IF NOT EXISTS (SELECT 1 FROM orders WHERE id = @order_id)
            THROW 50021, 'Order does not exist.', 1;
            
        -- Check if payment exists
        IF NOT EXISTS (SELECT 1 FROM payments WHERE id = @payment_id AND order_id = @order_id)
            THROW 50024, 'Invalid payment information for the specified order.', 1;
            
        -- Get payment method
        SELECT @PaymentMethod = payment_method, @OrderTotal = amount
        FROM payments
        WHERE id = @payment_id;
        
        -- Get vendor ID (assuming single vendor per order for simplicity)
        SELECT TOP 1 @VendorId = p.vendor_id
        FROM order_items oi
        INNER JOIN products p ON oi.product_id = p.id
        WHERE oi.order_id = @order_id;
        
        -- Set due date if not provided
        IF @due_date IS NULL
            SET @due_date = DATEADD(DAY, 30, GETDATE());
            
        -- Insert invoice
        INSERT INTO invoices (
            id, order_id, payment_id, vendor_id, invoice_date, due_date,
            billing_address, shipping_address, total_amount, payment_method,
            status, created_at, updated_at
        )
        VALUES (
            @id, @order_id, @payment_id, @VendorId, GETDATE(), @due_date,
            @billing_address, @shipping_address, @OrderTotal, @PaymentMethod,
            'Paid', GETDATE(), GETDATE()
        );
        
        SELECT 'Invoice generated successfully' AS Result, @id AS InvoiceId, @order_id AS OrderId;
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_SEVERITY() AS ErrorSeverity,
            ERROR_STATE() AS ErrorState,
            ERROR_PROCEDURE() AS ErrorProcedure,
            ERROR_LINE() AS ErrorLine,
            ERROR_MESSAGE() AS ErrorMessage;
            
        -- Get error details
        SELECT @ErrorMessage = ERROR_MESSAGE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE();
               
        -- Re-throw the error
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
GO

SELECT * FROM orders;

SELECT * FROM inventory;
SELECT * FROM products;

SELECT i.id,
		i.quantity_in_stock,
		p.id,
		p.name,
		p.category_id
		FROM inventory i 
		INNER JOIN products p ON i.product_id = p.id