-- ==============================================
-- IF...ELSE Example: E-Commerce Free Delivery Check
-- ==============================================
DECLARE @TotalAmount DECIMAL(10,2) = 950.00;

IF @TotalAmount >= 1000
    SELECT  N'🎉 You are eligible for free delivery!' AS Result;
ELSE
    SELECT  N'🛒 Add items worth ₹' + CAST(1000 - @TotalAmount AS NVARCHAR) + ' more to get free delivery.' AS result
GO


-- ==============================================
-- CASE Example: Assign Grade based on Order Rating
-- ==============================================
DECLARE @CustomerRating INT = 4;
DECLARE @Feedback NVARCHAR(50);

SET @Feedback = 
    CASE 
        WHEN @CustomerRating = 5 THEN 'Excellent Service'
        WHEN @CustomerRating = 4 THEN 'Very Good'
        WHEN @CustomerRating = 3 THEN 'Average'
        WHEN @CustomerRating = 2 THEN 'Needs Improvement'
        WHEN @CustomerRating = 1 THEN 'Poor'
        ELSE 'Invalid Rating'
    END;

PRINT 'Customer Feedback: ' + @Feedback;

GO


-- ==============================================
-- WHILE LOOP Example: Simulate Cart Items Scan at Checkout
-- ==============================================
DECLARE @ItemCounter INT = 1;
DECLARE @MaxItems INT = 5;

PRINT 'Scanning your cart items...';

WHILE @ItemCounter <= @MaxItems
BEGIN
    PRINT 'Scanned item #' + CAST(@ItemCounter AS NVARCHAR);
    SET @ItemCounter = @ItemCounter + 1;
END

PRINT 'All items scanned. Proceed to payment.';

-- 💬 Question: How can we use loops to handle batch processing in billing?
GO


-- ==============================================
-- BREAK + CONTINUE Example: Skip Out-of-Stock Items
-- ==============================================
DECLARE @CurrentItem INT = 1;
DECLARE @TotalItems INT = 6;

PRINT '🛍 Checking stock status for each item...';

WHILE @CurrentItem <= @TotalItems
BEGIN
    IF @CurrentItem = 3
    BEGIN
        PRINT '❌ Item #' + CAST(@CurrentItem AS NVARCHAR) + ' is out of stock. Skipping.';
        SET @CurrentItem = @CurrentItem + 1;
        CONTINUE;
    END

    PRINT '📦 Item #' + CAST(@CurrentItem AS NVARCHAR) + ' is in stock.';
    SET @CurrentItem = @CurrentItem + 1;
END

PRINT '📋 Stock check complete.';

-- 💬 Question: How does CONTINUE differ from BREAK? When would you use each?
GO




-- QUESTIONS 


-- 👨‍🍳 Real-World Scenario: A restaurant gives discounts based on order quantity.
DECLARE @Quantity INT = 7;
DECLARE @Discount INT;

IF @Quantity >= 10
    SET @Discount = 20;
ELSE IF @Quantity >= 5
    SET @Discount = 10;
ELSE
    SET @Discount = 0;

PRINT 'Discount applied: ' + CAST(@Discount AS VARCHAR) + '%';

-- ❓ Question: What will be the discount if the quantity is 7?



-- 🛍 Scenario: E-commerce platform categorizes items
DECLARE @Price DECIMAL(10,2) = 1199.00;
DECLARE @Category NVARCHAR(50);

SET @Category =
    CASE 
        WHEN @Price < 500 THEN 'Budget'
        WHEN @Price BETWEEN 500 AND 1000 THEN 'Mid-Range'
        ELSE 'Premium'
    END;

PRINT 'This product falls into: ' + @Category + ' category';

-- ❓ Question: What category will be shown if price is ₹1199.00?


-- ⏱ Countdown timer for limited offer
DECLARE @SecondsLeft INT = 5;

WHILE @SecondsLeft > 0
BEGIN
    PRINT '⏳ Offer ends in: ' + CAST(@SecondsLeft AS VARCHAR) + ' seconds';
    SET @SecondsLeft = @SecondsLeft - 1;
END

PRINT '🎉 Offer expired!';

-- ❓ Question: How many print statements will be shown?


-- 📦 Inventory check with emergency break if zero stock found
DECLARE @Shelf INT = 1;
DECLARE @TotalShelves INT = 5;

WHILE @Shelf <= @TotalShelves
BEGIN
    IF @Shelf = 3
    BEGIN
        PRINT '⚠️ Empty shelf detected at position ' + CAST(@Shelf AS VARCHAR);
        BREAK;
    END
    PRINT '✅ Shelf ' + CAST(@Shelf AS VARCHAR) + ' is stocked.';
    SET @Shelf = @Shelf + 1;
END

-- ❓ Question: What is the last shelf number that was printed?



-- 🧮 Real-world: Reward Points Calculation System
DECLARE @TotalSpent INT = 3500;
DECLARE @Points INT = 0;

IF @TotalSpent > 2000
BEGIN
    SET @Points = 100;
    IF @TotalSpent > 3000
        SET @Points = @Points + 50;
END
ELSE
    SET @Points = 20;

PRINT '🎁 Reward Points Earned: ' + CAST(@Points AS VARCHAR);

-- ❓ Question: What will be the final reward points if total spent is ₹3500?
-- (Hint: Pay attention to nested IFs and reassignment.)



-- 💳 Insurance billing codes processing
DECLARE @Code INT = 1;

WHILE @Code <= 4
BEGIN
    PRINT 
        CASE @Code
            WHEN 1 THEN '🩺 General Consultation'
            WHEN 2 THEN '🧪 Lab Test'
            WHEN 3 THEN '💉 Vaccination'
            ELSE '❓ Unknown Code'
        END;

    SET @Code = @Code + 1;
END

-- ❓ Question: What will be printed for each value from 1 to 4?
-- Will '❓ Unknown Code' appear?



-- 📮 Skipping blocked user from sending notifications
DECLARE @UserID INT = 1;

WHILE @UserID <= 5
BEGIN
    IF @UserID = 3
    BEGIN
        SET @UserID = @UserID + 1;
        CONTINUE;
    END
    PRINT '🔔 Sent notification to user ' + CAST(@UserID AS VARCHAR);
    SET @UserID = @UserID + 1;
END

-- ❓ Question: Will notification be sent to user 3? How many total messages will be printed?


-- 🚗 Speed Monitoring for Safe Driving
DECLARE @Speed INT = 85;
DECLARE @Message NVARCHAR(100);

SET @Message =
    CASE 
        WHEN @Speed < 40 THEN 'Too Slow: Risk of traffic jam.'
        WHEN @Speed BETWEEN 40 AND 80 THEN 'Safe Driving Speed.'
        WHEN @Speed BETWEEN 80 AND 120 THEN 'Caution: Approaching speed limit.'
        ELSE 'Overspeeding! Penalty applies.'
    END;

PRINT '🚦 Status: ' + @Message;

-- ❓ Question: Will it show "Safe Driving" or "Caution" for speed 85?
-- (Watch those ranges closely!)
