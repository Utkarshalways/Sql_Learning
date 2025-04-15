-- ========================================
-- Batch 1: Declare Variables
-- ========================================
-- Here we declare all the variables we'll use throughout the script.

DECLARE @ProductName NVARCHAR(50);
DECLARE @Quantity INT;
DECLARE @UnitPrice DECIMAL(10, 2);
DECLARE @DiscountRate DECIMAL(5, 2);
DECLARE @TaxRate DECIMAL(5, 2);
DECLARE @TotalBeforeDiscount DECIMAL(10, 2);
DECLARE @DiscountAmount DECIMAL(10, 2);
DECLARE @TotalAfterDiscount DECIMAL(10, 2);
DECLARE @FinalAmount DECIMAL(10, 2);

PRINT 'Step 1: All variables declared.';


-- ========================================
-- Batch 2: Assign Values
-- ========================================
-- Assigning constant-like values. These are the inputs.

SET @ProductName = 'Bluetooth Speaker';
SET @Quantity = 3;
SET @UnitPrice = 799.99;
SET @DiscountRate = 0.10; -- 10%
SET @TaxRate = 0.18;      -- 18% GST

PRINT 'Step 2: Values assigned to variables.';
GO

