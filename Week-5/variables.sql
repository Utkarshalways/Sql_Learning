-- ========================================
-- Batch 1: Declare Variables
-- ========================================
-- Here we declare all the variables we'll use throughout the script.




DECLARE @ProductName NVARCHAR(50);
SELECT @ProductName


DECLARE @price INT; ​
SET @price = 500; ​
SELECT @price as Price;

-- OUTPUT?
DECLARE @productName VARCHAR; ​
SET @productName = 'Mobile Phone'; ​
SELECT @ProductName as productName


DECLARE @productName VARCHAR(20) = 'Mobile Phone'; ​
SELECT @ProductName as productName
SET @ProductName = 'Laptop'
SELECT @ProductName as productName;


SET @date = 'something'
DECLARE @date DATE;
SET @date = GETDATE();
SELECT @date as [DATE];


DECLARE @ProductName VARCHAR(50);
DECLARE @Quantity INT;
DECLARE @UnitPrice DECIMAL(10, 2);
DECLARE @DiscountRate DECIMAL(5, 2);
DECLARE @TaxRate DECIMAL(5, 2);
DECLARE @TotalBeforeDiscount DECIMAL(10, 2);
DECLARE @DiscountAmount DECIMAL(10, 2);
DECLARE @TotalAfterDiscount DECIMAL(10, 2);
DECLARE @FinalAmount DECIMAL(10, 2);
PRINT 'Step 1: All variables declared.';


SET @ProductName = 'Bluetooth Speaker';
SET @Quantity = 3;
SET @UnitPrice = 799.99;
SET @DiscountRate = 0.10; -- 10%
SET @TaxRate = 0.18;      -- 18% GST
PRINT 'Step 2: Values assigned to variables.';

SET @TotalBeforeDiscount = @Quantity * @UnitPrice;
PRINT 'Step 3: Total before discount is ₹' + CAST(@TotalBeforeDiscount AS NVARCHAR);

SET @DiscountAmount = @TotalBeforeDiscount * @DiscountRate;
SET @TotalAfterDiscount = @TotalBeforeDiscount - @DiscountAmount;
PRINT 'Step 4: Discount is ₹' + CAST(@DiscountAmount AS NVARCHAR);
PRINT 'Step 4: Total after discount is ₹' + CAST(@TotalAfterDiscount AS NVARCHAR);

SET @FinalAmount = @TotalAfterDiscount + (@TotalAfterDiscount * @TaxRate);
PRINT 'Step 5: Final payable amount including tax is ₹' + CAST(@FinalAmount AS NVARCHAR);

PRINT '=======================================';
PRINT '         FINAL INVOICE SUMMARY         ';
PRINT '=======================================';
PRINT 'Product: ' + @ProductName;
PRINT 'Quantity: ' + CAST(@Quantity AS NVARCHAR);
PRINT 'Unit Price: ₹' + CAST(@UnitPrice AS NVARCHAR);
PRINT 'Subtotal: ₹' + CAST(@TotalBeforeDiscount AS NVARCHAR);
PRINT 'Discount Applied: ₹' + CAST(@DiscountAmount AS NVARCHAR);
PRINT 'Post-discount Total: ₹' + CAST(@TotalAfterDiscount AS NVARCHAR);
PRINT 'Tax: ' + CAST(@TaxRate * 100 AS NVARCHAR) + '%';
PRINT 'Total Amount to Pay: ₹' + CAST(@FinalAmount AS NVARCHAR);
GO


-- STORED PROCEDURE

CREATE TABLE Orders (
    OrderID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT,
    ProductName NVARCHAR(100),
    Quantity INT,
    OrderDate DATE
);

INSERT INTO Orders (CustomerID, ProductName, Quantity, OrderDate)
VALUES 
(1, 'Wireless Mouse', 2, '2024-12-10'),
(1, 'Bluetooth Headphones', 1, '2024-12-15'),
(2, 'Laptop', 1, '2025-01-05'),
(3, 'Monitor', 2, '2025-02-01'),
(2, 'Keyboard', 1, '2025-03-01');

DROP TABLE Orders;

CREATE PROCEDURE GetCustomerOrders​
  @CustomerId INT​ = NULL
AS​
BEGIN​
  SELECT * FROM Orders WHERE CustomerID = @CustomerId;​
END;



EXEC GetCustomerOrders;


DROP PROCEDURE GetCustomerOrders