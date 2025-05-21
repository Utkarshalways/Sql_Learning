-- Test Case 1: Successful Update of Existing Product Review
EXEC sp_UpdateProductReview  
    @UserId = 'USR018', 
    @ProductId = 'PROD007', 
    @Rating = 4, 
    @Comment = 'Updated review: Great product with minor issues.';
GO

SELECT * FROM reviews;
-- Test Case 2: Attempt to Update Non-Existent Review
BEGIN TRY
    EXEC sp_UpdateProductReview  
        @UserId = 'USR018',  -- Assuming this user has not reviewed this product
        @ProductId = 'PROD999', 
        @Rating = 5, 
        @Comment = 'Trying to update a non-existent review.';
END TRY
BEGIN CATCH
    PRINT 'Test Case 2 Error: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Test Case 3: Update Review with Null User ID
BEGIN TRY
    EXEC sp_UpdateProductReview  
        @UserId = NULL, 
        @ProductId = 'PROD007', 
        @Rating = 4, 
        @Comment = 'This should fail due to null User ID.';
END TRY
BEGIN CATCH
    PRINT 'Test Case 3 Error: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Test Case 4: Update Review with Null Product ID
BEGIN TRY
    EXEC sp_UpdateProductReview  
        @UserId = 'USR018', 
        @ProductId = NULL, 
        @Rating = 4, 
        @Comment = 'This should fail due to null Product ID.';
END TRY
BEGIN CATCH
    PRINT 'Test Case 4 Error: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Test Case 5: Update Review with Invalid Rating (Greater than 5)
BEGIN TRY
    EXEC sp_UpdateProductReview  
        @UserId = 'USR018', 
        @ProductId = 'PROD007', 
        @Rating = 6,  -- Assuming rating should be between 1 and 5
        @Comment = 'Invalid rating test.';
END TRY
BEGIN CATCH
    PRINT 'Test Case 5 Error: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Test Case 6: Update Review with Null Comment (Should Succeed)
EXEC sp_UpdateProductReview  
    @UserId = 'USR018', 
    @ProductId = 'PROD007', 
    @Rating = 4, 
    @Comment = NULL;  -- Comment can be null
GO

SELECT * FROM reviews;