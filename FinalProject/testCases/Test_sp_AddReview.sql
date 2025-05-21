-- Test Case 1: Successful Addition of Product Review
EXEC sp_AddProductReview  
    @UserId = 'USR018', 
    @ProductId = 'PROD007', 
    @Rating = 5, 
    @Comment = 'Great product!';
GO


SELECT * FROM reviews
SELECT * FROM order_items;
SELECT * FROM orders;

-- Test Case 2: User Tries to Review a Product Not Purchased
BEGIN TRY
    EXEC sp_AddProductReview  
        @UserId = 'USR2',  -- Assuming this user has not purchased the product
        @ProductId = 'PROD1', 
        @Rating = 4, 
        @Comment = 'Good quality!';
END TRY
BEGIN CATCH
    PRINT 'Test Case 2 Error: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Test Case 3: User Tries to Review a Product Already Reviewed
BEGIN TRY
    -- First, add a review for the product
    EXEC sp_AddProductReview  
    @UserId = 'USR018', 
    @ProductId = 'PROD007', 
    @Rating = 5, 
    @Comment = 'Great product!!!';

    -- Attempt to add the same review again
    EXEC sp_AddProductReview  
        @UserId = 'USR1', 
        @ProductId = 'PROD1', 
        @Rating = 4, 
        @Comment = 'Good quality!';
END TRY
BEGIN CATCH
    PRINT 'Test Case 3 Error: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Test Case 4: Add Review with Null User ID
BEGIN TRY
    EXEC sp_AddProductReview  
        @UserId = NULL, 
        @ProductId = 'PROD1', 
        @Rating = 5, 
        @Comment = 'Great product!';
END TRY
BEGIN CATCH
    PRINT 'Test Case 4 Error: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Test Case 5: Add Review with Null Product ID
BEGIN TRY
    EXEC sp_AddProductReview  
        @UserId = 'USR1', 
        @ProductId = NULL, 
        @Rating = 5, 
        @Comment = 'Great product!';
END TRY
BEGIN CATCH
    PRINT 'Test Case 5 Error: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Test Case 6: Add Review with Invalid Rating
BEGIN TRY
    EXEC sp_AddProductReview  
        @UserId = 'USR018', 
        @ProductId = 'PROD007', 
        @Rating = 6,  -- Assuming rating should be between 1 and 5
        @Comment = 'Great product!';
END TRY
BEGIN CATCH
    PRINT 'Test Case 6 Error: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Test Case 7: Add Review with Null Comment
EXEC sp_AddProductReview  
    @UserId = 'USR018', 
    @ProductId = 'PROD1', 
    @Rating = 5, 
    @Comment = NULL;  -- Comment can be null
GO


