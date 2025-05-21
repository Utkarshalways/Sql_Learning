-- Test Case 1: Successful Removal of Product from Wishlist
EXEC sp_RemoveFromWishlist  
    @UserId = 'USR19', 
    @ProductId = 'PROD022';  -- Assuming this product exists in the wishlist
GO

SELECT * FROM wishlist WHERE user_id = 'USR19'
-- Test Case 2: Remove Non-Existent Product from Wishlist
BEGIN TRY
    EXEC sp_RemoveFromWishlist  
        @UserId = 'USR19', 
        @ProductId = 'NON_EXISTENT_PRODUCT';  -- Assuming this product does not exist in the wishlist
END TRY
BEGIN CATCH
    PRINT 'Test Case 2 Error: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Test Case 3: Remove Product from Wishlist for Non-Existent User
BEGIN TRY
    EXEC sp_RemoveFromWishlist  
        @UserId = 'USR999',  -- Assuming this user does not exist
        @ProductId = 'PROD1';
END TRY
BEGIN CATCH
    PRINT 'Test Case 3 Error: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Test Case 4: Remove Product with Null User ID
BEGIN TRY
    EXEC sp_RemoveFromWishlist  
        @UserId = NULL, 
        @ProductId = 'PROD1';
END TRY
BEGIN CATCH
    PRINT 'Test Case 4 Error: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Test Case 5: Remove Product with Null Product ID
BEGIN TRY
    EXEC sp_RemoveFromWishlist  
        @UserId = 'USR19', 
        @ProductId = NULL;
END TRY
BEGIN CATCH
    PRINT 'Test Case 5 Error: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Test Case 6: Remove Product from Wishlist When Already Removed
BEGIN TRY
    -- First, remove the product
    EXEC sp_RemoveFromWishlist  
        @User Id = 'USR1', 
        @ProductId = 'PROD1';  -- Assuming this product exists in the wishlist

    -- Attempt to remove the same product again
    EXEC sp_RemoveFromWishlist  
        @UserId = 'USR19', 
        @ProductId = 'PROD022';  -- This should not raise an error but will not find the product
END TRY
BEGIN CATCH
    PRINT 'Test Case 6 Error: ' + ERROR_MESSAGE();
END CATCH;
GO

SELECT * FROM wishlist;