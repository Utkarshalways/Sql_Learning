-- Test Case 1: Successful Addition of Product to Wishlist
EXEC sp_AddProductToWishlist  
    @UserId = 'USR19', 
    @ProductId = 'PROD022';
GO

SELECT * FROM wishlist;

-- Test Case 2: Add Duplicate Product to Wishlist
EXEC sp_AddProductToWishlist  
    @UserId = 'USR19', 
    @ProductId = 'PROD022';
GO  -- Attempt to add again


-- Test Case 3: Add Product to Wishlist for Non-Existent User
BEGIN TRY
    EXEC sp_AddProductToWishlist  
        @UserId = 'USR999',  -- Assuming this user does not exist
        @ProductId = 'PROD1';
END TRY
BEGIN CATCH
    PRINT 'Test Case 3 Error: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Test Case 4: Add Product with Null User ID
BEGIN TRY
    EXEC sp_AddProductToWishlist  
        @UserId = NULL, 
        @ProductId = 'PROD1';
END TRY
BEGIN CATCH
    PRINT 'Test Case 4 Error: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Test Case 5: Add Product with Null Product ID
BEGIN TRY
    EXEC sp_AddProductToWishlist  
        @UserId = 'USR19', 
        @ProductId = NULL;
END TRY
BEGIN CATCH
    PRINT 'Test Case 5 Error: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Test Case 6: Add Product to Wishlist with Invalid Product ID
EXEC sp_AddProductToWishlist  
    @UserId = 'USR1', 
    @ProductId = 'INVALID_PRODUCT';  -- Assuming this product does not exist
GO
