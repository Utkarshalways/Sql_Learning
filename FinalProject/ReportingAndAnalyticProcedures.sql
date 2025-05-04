
-- =========================================
-- REPORTING & ANALYTICS PROCEDURES
-- =========================================

-- 1. Generate invoice for order
CREATE OR ALTER PROCEDURE sp_GenerateInvoice
    @OrderId NVARCHAR(50),
    @InvoiceId NVARCHAR(50) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Generate a new invoice ID
        SET @InvoiceId = CONVERT(NVARCHAR(50), NEWID());
        
        -- Get payment information
        DECLARE @PaymentId NVARCHAR(50);
        SELECT TOP 1 @PaymentId = id FROM payments WHERE order_id = @OrderId ORDER BY payment_date DESC;
        
        -- Get vendor information (assuming single vendor per order for simplicity)
        DECLARE @VendorId BIGINT;
        SELECT TOP 1 @VendorId = v.id
        FROM vendors v
        JOIN products p ON v.id = p.vendor_id
        JOIN order_items oi ON p.id = oi.product_id
        WHERE oi.order_id = @OrderId;
        
        -- Get address information from user_addresses
        DECLARE @BillingAddress NVARCHAR(500);
        DECLARE @ShippingAddress NVARCHAR(500);
        DECLARE @UserId NVARCHAR(50);
        
        SELECT @UserId = user_id FROM orders WHERE id = @OrderId;
        
        SELECT TOP 1 @BillingAddress = address_line
        FROM user_addresses
        WHERE user_id = @UserId AND address_type = 'Billing'
        ORDER BY is_primary DESC;
        
        IF @BillingAddress IS NULL
            SELECT TOP 1 @BillingAddress = address_line
            FROM user_addresses
            WHERE user_id = @UserId
            ORDER BY is_primary DESC;
            
        SELECT TOP 1 @ShippingAddress = address_line
        FROM user_addresses
        WHERE user_id = @UserId AND address_type = 'Shipping'
        ORDER BY is_primary DESC;
        
        IF @ShippingAddress IS NULL
            SELECT TOP 1 @ShippingAddress = address_line
            FROM user_addresses
            WHERE user_id = @UserId
            ORDER BY is_primary DESC;
        
        -- Get order total
        DECLARE @TotalAmount DECIMAL(18,2);
        SELECT @TotalAmount = total_amount FROM orders WHERE id = @OrderId;
        
        -- Get payment method
        DECLARE @PaymentMethod NVARCHAR(50);
        SELECT @PaymentMethod = payment_method FROM payments WHERE id = @PaymentId;
        
        -- Insert invoice
        INSERT INTO invoices (
            id, order_id, payment_id, vendor_id, invoice_date, due_date,
            billing_address, shipping_address, total_amount, payment_method, status
        )
        VALUES (
            @InvoiceId, @OrderId, @PaymentId, @VendorId, GETDATE(), DATEADD(DAY, 30, GETDATE()),
            @BillingAddress, @ShippingAddress, @TotalAmount, @PaymentMethod, 'Issued'
        );
        
        -- Log the event
        INSERT INTO user_event_log (user_id, event_type, action_description)
        VALUES (@UserId, 'InvoiceGenerated', 'Generated invoice ' + @InvoiceId + ' for order ' + @OrderId);
    END TRY
    BEGIN CATCH
        -- Log the error
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
GO

-- 2. Get sales report for vendor
CREATE OR ALTER PROCEDURE sp_GetVendorSalesReport
    @VendorId BIGINT,
    @StartDate DATETIME,
    @EndDate DATETIME
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Get sales data for the vendor
    SELECT 
        p.id AS ProductId,
        p.name AS ProductName,
        c.name AS CategoryName,
        COUNT(DISTINCT o.id) AS OrderCount,
        SUM(oi.quantity) AS TotalQuantitySold,
        SUM(oi.total_price) AS TotalRevenue,
        AVG(r.rating) AS AverageRating,
        COUNT(r.id) AS ReviewCount
    FROM products p
    JOIN order_items oi ON p.id = oi.product_id
    JOIN orders o ON oi.order_id = o.id
    LEFT JOIN categories c ON p.category_id = c.id
    LEFT JOIN reviews r ON p.id = r.product_id
    WHERE 
        p.vendor_id = @VendorId
        AND o.order_date BETWEEN @StartDate AND @EndDate
        AND o.order_status IN ('Completed', 'Shipped')
    GROUP BY p.id, p.name, c.name
    ORDER BY TotalRevenue DESC;
    
    -- Get summary statistics
    SELECT 
        COUNT(DISTINCT o.id) AS TotalOrders,
        COUNT(DISTINCT o.user_id) AS UniqueCustomers,
        SUM(o.total_amount) AS TotalSales,
        SUM(CASE WHEN o.payment_status = 'Completed' THEN o.total_amount ELSE 0 END) AS PaidSales,
        SUM(CASE WHEN o.payment_status != 'Completed' THEN o.total_amount ELSE 0 END) AS PendingSales
    FROM orders o
    JOIN order_items oi ON o.id = oi.order_id
    JOIN products p ON oi.product_id = p.id
    WHERE 
        p.vendor_id = @VendorId
        AND o.order_date BETWEEN @StartDate AND @EndDate;
END;
GO

-- 3. Calculate monthly revenue
CREATE OR ALTER PROCEDURE sp_GetMonthlyRevenue
    @Year INT = NULL,
    @Month INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    -- If year not provided, use current year
    IF @Year IS NULL
        SET @Year = YEAR(GETDATE());
    
    -- If month not provided, show all months in the year
    IF @Month IS NULL
    BEGIN
        -- Monthly breakdown
        SELECT 
            MONTH(o.order_date) AS Month,
            DATENAME(MONTH, o.order_date) AS MonthName,
            COUNT(DISTINCT o.id) AS OrderCount,
            SUM(o.total_amount) AS TotalRevenue,
            SUM(CASE WHEN o.payment_status = 'Completed' THEN o.total_amount ELSE 0 END) AS ReceivedRevenue,
            COUNT(DISTINCT o.user_id) AS UniqueCustomers
        FROM orders o
        WHERE 
            YEAR(o.order_date) = @Year
            AND o.order_status != 'Cancelled'
        GROUP BY MONTH(o.order_date), DATENAME(MONTH, o.order_date)
        ORDER BY Month;
        
        -- Category breakdown
        SELECT 
            c.name AS CategoryName,
            COUNT(DISTINCT o.id) AS OrderCount,
            SUM(oi.total_price) AS TotalRevenue
        FROM orders o
        JOIN order_items oi ON o.id = oi.order_id
        JOIN products p ON oi.product_id = p.id
        JOIN categories c ON p.category_id = c.id
        WHERE 
            YEAR(o.order_date) = @Year
            AND o.order_status != 'Cancelled'
        GROUP BY c.name
        ORDER BY TotalRevenue DESC;
        
        -- Vendor breakdown
        SELECT 
            v.id AS VendorId,
            u.name AS VendorName,
            COUNT(DISTINCT o.id) AS OrderCount,
            SUM(oi.total_price) AS TotalRevenue
        FROM orders o
        JOIN order_items oi ON o.id = oi.order_id
        JOIN products p ON oi.product_id = p.id
        JOIN vendors v ON p.vendor_id = v.id
        JOIN users u ON v.userId = u.id
        WHERE 
            YEAR(o.order_date) = @Year
            AND o.order_status != 'Cancelled'
        GROUP BY v.id, u.name
        ORDER BY TotalRevenue DESC;
    END
    ELSE
    BEGIN
        -- Detailed breakdown for specific month
        SELECT 
            DAY(o.order_date) AS Day,
            COUNT(DISTINCT o.id) AS OrderCount,
            SUM(o.total_amount) AS TotalRevenue,
            COUNT(DISTINCT o.user_id) AS UniqueCustomers
        FROM orders o
        WHERE 
            YEAR(o.order_date) = @Year
            AND MONTH(o.order_date) = @Month
            AND o.order_status != 'Cancelled'
        GROUP BY DAY(o.order_date)
        ORDER BY Day;
        
        -- Product performance for the month
        SELECT 
            p.id AS ProductId,
            p.name AS ProductName,
            c.name AS CategoryName,
            COUNT(DISTINCT o.id) AS OrderCount,
            SUM(oi.quantity) AS TotalQuantitySold,
            SUM(oi.total_price) AS TotalRevenue
        FROM orders o
        JOIN order_items oi ON o.id = oi.order_id
        JOIN products p ON oi.product_id = p.id
        JOIN categories c ON p.category_id = c.id
        WHERE 
            YEAR(o.order_date) = @Year
            AND MONTH(o.order_date) = @Month
            AND o.order_status != 'Cancelled'
        GROUP BY p.id, p.name, c.name
        ORDER BY TotalRevenue DESC;
    END
END;
GO