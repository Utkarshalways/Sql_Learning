-- Test Case 1: Successful Deletion of Existing Product Review
EXEC sp_DeleteProductReview
    @UserId = 'USR018',
    @ProductId = 'PROD007';
GO

-- Test Case 2: Attempt to Delete Non-Existent Review
BEGIN TRY
    EXEC sp_DeleteProductReview
        @UserId = 'USR018',
        @ProductId = 'PROD999'; -- Assuming this review does not exist
END TRY
BEGIN CATCH
    PRINT 'Test Case 2 Error: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Test Case 3: Delete Review with Null User ID
BEGIN TRY
    EXEC sp_DeleteProductReview
        @UserId = NULL,
        @ProductId = 'PROD007';
END TRY
BEGIN CATCH
    PRINT 'Test Case 3 Error: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Test Case 4: Delete Review with Null Product ID
BEGIN TRY
    EXEC sp_DeleteProductReview
        @UserId = 'USR018',
        @ProductId = NULL;
END TRY
BEGIN CATCH
    PRINT 'Test Case 4 Error: ' + ERROR_MESSAGE();
END CATCH;
GO