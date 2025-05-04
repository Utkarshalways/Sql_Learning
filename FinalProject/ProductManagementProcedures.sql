 --Product Management Procedures

SELECT * FROM products;
SELECT * FROM categories;

-- 1. sp_AddProduct - Add new product with inventory

-- ✅ Step 2: Create or Alter Procedure
CREATE OR ALTER PROCEDURE sp_AddProduct
    @id NVARCHAR(50),
    @name NVARCHAR(255),
    @description NVARCHAR(MAX),
    @category_id NVARCHAR(50),
    @vendor_id BIGINT,
    @price DECIMAL(18,2),
    @sku NVARCHAR(100),
    @discount DECIMAL(5,2),
    @quantity_in_stock INT,
    @inventory_id NVARCHAR(50)  -- ✅ New parameter added
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Check if category exists
        IF NOT EXISTS (SELECT 1 FROM categories WHERE id = @category_id)
        BEGIN
            RAISERROR('Category does not exist.', 16, 1);
            RETURN;
        END
        
        -- Check if vendor exists
        IF NOT EXISTS (SELECT 1 FROM vendors WHERE id = @vendor_id)
        BEGIN
            RAISERROR('Vendor does not exist.', 16, 1);
            RETURN;
        END

        -- Check if SKU is unique
        IF EXISTS (SELECT 1 FROM products WHERE stockKeepingUnit = @sku)
        BEGIN
            RAISERROR('SKU already exists.', 16, 1);
            RETURN;
        END

        -- Check if inventory ID already exists
        IF EXISTS (SELECT 1 FROM inventory WHERE id = @inventory_id)
        BEGIN
            RAISERROR('Inventory ID already exists.', 16, 1);
            RETURN;
        END
        
        -- Insert product
        INSERT INTO products (id, name, description, category_id, vendor_id, price, stockKeepingUnit, discount)
        VALUES (@id, @name, @description, @category_id, @vendor_id, @price, @sku, @discount);
        
        -- Insert inventory
        INSERT INTO inventory (id, product_id, quantity_in_stock)
        VALUES (@inventory_id, @id, @quantity_in_stock);
        
        -- Insert low stock alert
        IF @quantity_in_stock < 5
        BEGIN
            INSERT INTO alerts (alert_type, product_id, alert_message)
            VALUES ('Low Stock', @id, CONCAT('Stock for ', @name, ' is below 5 units. Restock needed.'));
        END

        COMMIT;

        SELECT 'Product added successfully.' AS Result;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;

        SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_SEVERITY() AS ErrorSeverity,
            ERROR_STATE() AS ErrorState,
            ERROR_PROCEDURE() AS ErrorProcedure,
            ERROR_LINE() AS ErrorLine,
            ERROR_MESSAGE() AS ErrorMessage;
    END CATCH
END;
GO

SELECT * FROM inventory

-- ✅ Step 3: Execute the procedure
EXEC sp_AddProduct
    @id = 'PROD022',
    @name = 'The Wings of Fire',
    @description = 'Biography of APJ Abdul Kalam',
    @category_id = 'C004', -- Make sure this is a valid category ID (perhaps meant 'CAT004'?)
    @vendor_id = 102,
    @price = 1699.00,
    @sku = 'TWOF-1',
    @discount = 15.00,
    @quantity_in_stock = 2,  -- triggers low stock alert
    @inventory_id = 'INV022';  -- ✅ Added inventory ID


SELECT * FROM products;

-- 2. sp_UpdateProduct - Update product details
CREATE OR ALTER PROCEDURE sp_UpdateProduct
    @id NVARCHAR(50),
    @name NVARCHAR(255) = NULL,
    @description NVARCHAR(MAX) = NULL,
    @category_id NVARCHAR(50) = NULL,
    @price DECIMAL(18,2) = NULL,
    @discount DECIMAL(5,2) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Check if product exists
        IF NOT EXISTS (SELECT 1 FROM products WHERE id = @id)
        BEGIN
            RAISERROR('Product does not exist.', 16, 1);
            RETURN;
        END
        
        -- Check if category exists
        IF @category_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM categories WHERE id = @category_id)
        BEGIN
            RAISERROR('Category does not exist.', 16, 1);
            RETURN;
        END
        
        -- Update product
        UPDATE products
        SET 
            name = ISNULL(@name, name),
            description = ISNULL(@description, description),
            category_id = ISNULL(@category_id, category_id),
            price = ISNULL(@price, price),
            discount = ISNULL(@discount, discount)
        WHERE id = @id;
        
        -- Return success message
        SELECT 'Product updated successfully.' AS Result;
    END TRY
    BEGIN CATCH
        -- Return error information
        SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_SEVERITY() AS ErrorSeverity,
            ERROR_STATE() AS ErrorState,
            ERROR_PROCEDURE() AS ErrorProcedure,
            ERROR_LINE() AS ErrorLine,
            ERROR_MESSAGE() AS ErrorMessage;
    END CATCH
END;
GO

-- 3. sp_ManageInventory - Update product inventory levels
CREATE OR ALTER PROCEDURE sp_ManageInventory
    @product_id NVARCHAR(50),
    @quantity_change INT,
    @action_type VARCHAR(10) -- 'add' or 'remove'
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Check if product exists
        IF NOT EXISTS (SELECT 1 FROM products WHERE id = @product_id)
        BEGIN
            RAISERROR('Product does not exist.', 16, 1);
            RETURN;
        END
        
        -- Check if inventory exists for the product
        IF NOT EXISTS (SELECT 1 FROM inventory WHERE product_id = @product_id)
        BEGIN
            RAISERROR('Inventory record does not exist for this product.', 16, 1);
            RETURN;
        END
        
        DECLARE @current_quantity INT;
        SELECT @current_quantity = quantity_in_stock FROM inventory WHERE product_id = @product_id;
        
        -- Update inventory based on action type
        IF @action_type = 'add'
        BEGIN
            UPDATE inventory
            SET quantity_in_stock = quantity_in_stock + @quantity_change
            WHERE product_id = @product_id;
            
            -- If stock was critically low but now above threshold, resolve alerts
            IF @current_quantity < 5 AND (@current_quantity + @quantity_change) >= 5
            BEGIN
                UPDATE alerts
                SET is_resolved = 1, resolved_time = GETDATE()
                WHERE product_id = @product_id AND alert_type = 'Low Stock' AND is_resolved = 0;
            END
        END
        ELSE IF @action_type = 'remove'
        BEGIN
            -- Check if there's enough stock
            IF @current_quantity < @quantity_change
            BEGIN
                RAISERROR('Not enough stock available.', 16, 1);
                RETURN;
            END
            
            UPDATE inventory
            SET quantity_in_stock = quantity_in_stock - @quantity_change
            WHERE product_id = @product_id;
            
            -- Create alert if stock is now low
            IF (@current_quantity >= 5) AND (@current_quantity - @quantity_change) < 5
            BEGIN
                INSERT INTO alerts (alert_type, product_id, alert_message)
                SELECT 'Low Stock', @product_id, CONCAT('Stock for ', name, ' is below 5 units. Restock needed.')
                FROM products WHERE id = @product_id;
            END
            
            -- Create alert if stock is now zero
            IF (@current_quantity - @quantity_change) = 0
            BEGIN
                INSERT INTO alerts (alert_type, product_id, alert_message)
                SELECT 'Out of Stock', @product_id, CONCAT(name, ' is now out of stock.')
                FROM products WHERE id = @product_id;
            END
        END
        ELSE
        BEGIN
            RAISERROR('Invalid action type. Use "add" or "remove".', 16, 1);
            RETURN;
        END
        
        COMMIT;
        
        -- Return updated quantity
        SELECT quantity_in_stock AS UpdatedQuantity 
        FROM inventory 
        WHERE product_id = @product_id;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;
            
        -- Return error information
        SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_SEVERITY() AS ErrorSeverity,
            ERROR_STATE() AS ErrorState,
            ERROR_PROCEDURE() AS ErrorProcedure,
            ERROR_LINE() AS ErrorLine,
            ERROR_MESSAGE() AS ErrorMessage;
    END CATCH
END;
GO

-- 4. sp_DiscontinueProduct - Mark products as discontinued
CREATE OR ALTER PROCEDURE sp_DiscontinueProduct
    @product_id NVARCHAR(50),
    @reason NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Check if product exists
        IF NOT EXISTS (SELECT 1 FROM products WHERE id = @product_id)
        BEGIN
            RAISERROR('Product does not exist.', 16, 1);
            RETURN;
        END
        
        -- First we need to add a discontinued column to the products table if it doesn't exist
        IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('products') AND name = 'is_discontinued')
        BEGIN
            ALTER TABLE products ADD is_discontinued BIT DEFAULT 0;
            ALTER TABLE products ADD discontinued_reason NVARCHAR(500) NULL;
            ALTER TABLE products ADD discontinued_date DATETIME NULL;
        END
        
        -- Mark product as discontinued
        UPDATE products
        SET 
            is_discontinued = 1,
            discontinued_reason = @reason,
            discontinued_date = GETDATE()
        WHERE id = @product_id;
        
        -- Create alert about product discontinuation
        INSERT INTO alerts (alert_type, product_id, alert_message)
        SELECT 'Product Discontinued', @product_id, CONCAT(name, ' has been discontinued.')
        FROM products WHERE id = @product_id;
        
        COMMIT;
        
        -- Return success message
        SELECT 'Product marked as discontinued.' AS Result;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;
            
        -- Return error information
        SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_SEVERITY() AS ErrorSeverity,
            ERROR_STATE() AS ErrorState,
            ERROR_PROCEDURE() AS ErrorProcedure,
            ERROR_LINE() AS ErrorLine,
            ERROR_MESSAGE() AS ErrorMessage;
    END CATCH
END;
GO

-- 5. sp_AddProductCategory - Add new category with optional parent
CREATE OR ALTER PROCEDURE sp_AddProductCategory
    @id NVARCHAR(50),
    @name NVARCHAR(255),
    @parent_category_id NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Check if category already exists
        IF EXISTS (SELECT 1 FROM categories WHERE id = @id)
        BEGIN
            RAISERROR('Category ID already exists.', 16, 1);
            RETURN;
        END
        
        -- Check if parent category exists
        IF @parent_category_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM categories WHERE id = @parent_category_id)
        BEGIN
            RAISERROR('Parent category does not exist.', 16, 1);
            RETURN;
        END
        
        -- Insert category
        INSERT INTO categories (id, name, parent_category_id)
        VALUES (@id, @name, @parent_category_id);
        
        -- Return success message
        SELECT 'Category added successfully.' AS Result;
    END TRY
    BEGIN CATCH
        -- Return error information
        SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_SEVERITY() AS ErrorSeverity,
            ERROR_STATE() AS ErrorState,
            ERROR_PROCEDURE() AS ErrorProcedure,
            ERROR_LINE() AS ErrorLine,
            ERROR_MESSAGE() AS ErrorMessage;
    END CATCH
END;
GO

-- 6. sp_UpdateProductCategory - Update category information
CREATE OR ALTER PROCEDURE sp_UpdateProductCategory
    @id NVARCHAR(50),
    @name NVARCHAR(255) = NULL,
    @parent_category_id NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Check if category exists
        IF NOT EXISTS (SELECT 1 FROM categories WHERE id = @id)
        BEGIN
            RAISERROR('Category does not exist.', 16, 1);
            RETURN;
        END
        
        -- Check if parent category exists
        IF @parent_category_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM categories WHERE id = @parent_category_id)
        BEGIN
            RAISERROR('Parent category does not exist.', 16, 1);
            RETURN;
        END
        
        -- Check for circular reference
        IF @parent_category_id = @id
        BEGIN
            RAISERROR('Cannot set a category as its own parent.', 16, 1);
            RETURN;
        END
        
        -- Update category
        UPDATE categories
        SET 
            name = ISNULL(@name, name),
            parent_category_id = @parent_category_id
        WHERE id = @id;
        
        -- Return success message
        SELECT 'Category updated successfully.' AS Result;
    END TRY
    BEGIN CATCH
        -- Return error information
        SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_SEVERITY() AS ErrorSeverity,
            ERROR_STATE() AS ErrorState,
            ERROR_PROCEDURE() AS ErrorProcedure,
            ERROR_LINE() AS ErrorLine,
            ERROR_MESSAGE() AS ErrorMessage;
    END CATCH
END;
GO