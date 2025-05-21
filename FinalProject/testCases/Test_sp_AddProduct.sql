-- Test Case 1: Successful Addition of a New Product with Generated Product ID
EXEC sp_AddProduct  
    @name = 'Create An Impact', 
    @description = 'Achieving Peace inside,results outside.', 
    @category_id = 'CAT004', 
    @vendor_id = 103, 
    @price = 199.00, 
    @sku = 'SKU023', 
    @discount = 0.00, 
    @quantity_in_stock = 10,
	@inventory_id = 'INV023'
GO


SELECT * FROM inventory;
SELECT * FROM products;
SELECT * FROM categories;

-- Test Case 2: Attempt to Add Product with Non-Existent Category
BEGIN TRY
    EXEC sp_AddProduct  
        @name = 'Another Product', 
        @description = 'This product has a non-existent category.', 
        @category_id = 'NON_EXISTENT_CAT', 
        @vendor_id = 1, 
        @price = 29.99, 
        @sku = 'SKU002', 
        @discount = 0.00, 
        @quantity_in_stock = 5, 
        @inventory_id = 'INV002';
END TRY
BEGIN CATCH
    PRINT 'Test Case 2 Error: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Test Case 3: Attempt to Add Product with Non-Existent Vendor
BEGIN TRY
    EXEC sp_AddProduct  
        @name = 'Product with Non-Existent Vendor', 
        @description = 'This product has a non-existent vendor.', 
        @category_id = 'CAT001', 
        @vendor_id = 9999,  -- Assuming this vendor does not exist
        @price = 39.99, 
        @sku = 'SKU003', 
        @discount = 0.00, 
        @quantity_in_stock = 5, 
        @inventory_id = 'INV003';
END TRY
BEGIN CATCH
    PRINT 'Test Case 3 Error: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Test Case 4: Attempt to Add Product with Duplicate SKU
BEGIN TRY
    -- First, add a product with SKU 'SKU004'
    EXEC sp_AddProduct  
        @name = 'Product with Duplicate SKU', 
        @description = 'This product has a duplicate SKU.', 
        @category_id = 'CAT001', 
        @vendor_id = 1, 
        @price = 49.99, 
        @sku = 'SKU004', 
        @discount = 0.00, 
        @quantity_in_stock = 5, 
        @inventory_id = 'INV004';

    -- Attempt to add another product with the same SKU
    EXEC sp_AddProduct  
        @name = 'Another Product with Duplicate SKU', 
        @description = 'This product has a duplicate SKU.', 
        @category_id = 'CAT001', 
        @vendor_id = 1, 
        @price = 59.99, 
        @sku = 'SKU004', 
        @discount = 0.00, 
        @quantity_in_stock = 5, 
        @inventory_id = 'INV005';
END TRY
BEGIN CATCH
    PRINT 'Test Case 4 Error: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Test Case 5: Attempt to Add Product with Duplicate Inventory ID
BEGIN TRY
    -- First, add a product with inventory ID 'INV006'
    EXEC sp_AddProduct  
        @name = 'Product with Duplicate Inventory ID', 
        @description = 'This product has a duplicate inventory ID.', 
        @category_id = 'CAT001', 
        @vendor_id = 1, 
        @price = 69.99, 
        @sku = 'SKU005', 
        @discount = 0.00, 
        @quantity_in_stock = 5, 
        @inventory_id = 'INV006';

    -- Attempt to add another product with the same inventory ID
    EXEC sp_AddProduct  
        @name = 'Another Product with Duplicate Inventory ID', 
        @description = 'This product has a duplicate inventory ID.', 
        @category_id = 'CAT001', 
        @vendor_id = 1, 
        @price = 79.99, 
        @sku = 'SKU006', 
        @discount = 0.00, 
        @quantity_in_stock = 5, 
        @inventory_id = 'INV006';
END TRY
BEGIN CATCH
    PRINT 'Test Case 5 Error: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Test Case 6: Add Product with Low Stock (Should Trigger Low Stock Alert)
EXEC sp_AddProduct  
    @name = 'Low Stock Product', 
    @description = 'This product has low stock.', 
    @category_id = 'CAT001', 
    @vendor_id = 1, 
    @price = 89.99, 
    @sku = 'SKU007', 
    @discount = 0.00, 
    @quantity_in_stock = 3,  -- This should trigger a low stock alert
    @inventory_id = 'INV007';
GO