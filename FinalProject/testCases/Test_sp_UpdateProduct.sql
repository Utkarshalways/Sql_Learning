-- Test Case 1: Successful Update of Existing Product
EXEC sp_UpdateProduct  
    @id = 'PROD23',  -- Assuming this product ID exists
    @name = 'Create An Impact', 
    @description = 'Updated description for the product.', 
    @category_id = 'CAT004', 
    @price = 199.99, 
    @discount = 10.00;
GO

SELECT * FROM products;

-- Test Case 2: Attempt to Update Non-Existent Product
BEGIN TRY
    EXEC sp_UpdateProduct  
        @id = 'NON_EXISTENT_PROD',  -- Assuming this product ID does not exist
        @name = 'Should Fail', 
        @description = 'This update should fail because the product does not exist.';
END TRY
BEGIN CATCH
    PRINT 'Test Case 2 Error: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Test Case 3: Update Product with Non-Existent Category
BEGIN TRY
    EXEC sp_UpdateProduct  
        @id = 'PROD001',  -- Assuming this product ID exists
        @name = 'Another Update', 
        @description = 'This update has a non-existent category.', 
        @category_id = 'NON_EXISTENT_CAT', 
        @price = 199.99, 
        @discount = 5.00;
END TRY
BEGIN CATCH
    PRINT 'Test Case 3 Error: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Test Case 4: Update Product with Null Values (Should Not Change Existing Values)
EXEC sp_UpdateProduct  
    @id = 'PROD001',  -- Assuming this product ID exists
    @name = NULL, 
    @description = NULL, 
    @category_id = NULL, 
    @price = NULL, 
    @discount = NULL;
GO

-- Test Case 5: Update Product with Only Price Change
EXEC sp_UpdateProduct  
    @id = 'PROD001',  -- Assuming this product ID exists
    @price = 249.99;  -- Only updating the price
GO

-- Test Case 6: Update Product with All Fields Changed
EXEC sp_UpdateProduct  
    @id = 'PROD001',  -- Assuming this product ID exists
    @name = 'Completely New Name', 
    @description = 'A completely new description.', 
    @category_id = 'CAT002', 
    @price = 299.99, 
    @discount = 15.00;
GO