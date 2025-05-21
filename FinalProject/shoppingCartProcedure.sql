
-- =========================================
-- SHOPPING CART PROCEDURES
-- =========================================

-- 1. Add product to user's cart
CREATE OR ALTER PROCEDURE sp_AddToCart
    @UserId NVARCHAR(50),
    @ProductId NVARCHAR(50),
    @Quantity INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Check if product exists in inventory with sufficient quantity
        IF NOT EXISTS (SELECT 1 FROM inventory WHERE product_id = @ProductId AND quantity_in_stock >= @Quantity)
        BEGIN
            RAISERROR('Product does not exist or insufficient inventory', 16, 1);
            RETURN;
        END
        
        -- Check if the product is already in the cart
        IF EXISTS (SELECT 1 FROM shopping_cart WHERE user_id = @UserId AND product_id = @ProductId)
        BEGIN
            -- Update the quantity
            UPDATE shopping_cart
            SET 
                quantity = quantity + @Quantity,
                updated_at = GETDATE()
            WHERE user_id = @UserId AND product_id = @ProductId;
        END
        ELSE
        BEGIN
            -- Add new item to cart
            INSERT INTO shopping_cart (user_id, product_id, quantity)
            VALUES (@UserId, @ProductId, @Quantity);
        END
        
        -- Log the event
        INSERT INTO user_event_log (user_id, event_type, action_description)
        VALUES (@UserId, 'AddToCart', 'Added ' + CAST(@Quantity AS NVARCHAR(10)) + ' of product ' + @ProductId + ' to cart');
    END TRY
    BEGIN CATCH
        -- Log the error
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
		PRINT @ErrorMessage;
    END CATCH;
END;
GO

SELECT * FROM users;
SELECT * FROM products;

EXEC sp_AddToCart @UserId = 'USR19', @ProductId = 'PROD001', @Quantity = 1;
EXEC sp_AddToCart @UserId = 'USR19', @ProductId = 'PROD006', @Quantity = 1;
EXEC sp_AddToCart @UserId = 'USR19', @ProductId = 'PROD013', @Quantity = 1;

SELECT * FROM shopping_cart WHERE user_id = 'USR19';
-- 2. Update product quantity in cart

SELECT * FROM reviews;
SELECT * FROM sys.procedures;

CREATE OR ALTER PROCEDURE sp_UpdateCartQuantity
    @UserId NVARCHAR(50) = NULL,
    @ProductId NVARCHAR(50) = NULL,
    @NewQuantity INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY        
		-- If quantity is 0 or negative, remove from cart
		IF @UserId IS NULL
		BEGIN 
			RAISERROR('User Id is NULL',16,1);
			RETURN
		END
		IF @ProductId = NULL 
			BEGIN
			RAISERROR('Product Id is NULL',16,1);
			RETURN
			END
		IF @NewQuantity IS NULL
			BEGIN 
			RAISERROR('NEWQUANTITY can not be NULL',16,1);
			RETURN
			END
		
			
        IF @NewQuantity <= 0
        BEGIN
            EXEC sp_RemoveFromCart @UserId, @ProductId;
            RETURN;
        END
        
        -- Check inventory
        IF NOT EXISTS (SELECT 1 FROM inventory WHERE product_id = @ProductId AND quantity_in_stock >= @NewQuantity)
        BEGIN
            RAISERROR('Insufficient inventory for requested quantity', 16, 1);
            RETURN;
        END
        
        -- Update the quantity
        UPDATE shopping_cart
        SET 
            quantity = @NewQuantity,
            updated_at = GETDATE()
        WHERE user_id = @UserId AND product_id = @ProductId;
        
        -- Log the event
        INSERT INTO user_event_log (user_id, event_type, action_description)
        VALUES (@UserId, 'UpdateCart', 'Updated quantity of product ' + @ProductId + ' to ' + CAST(@NewQuantity AS NVARCHAR(10)));

    END TRY
    BEGIN CATCH
        -- Log the error
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        PRINT @ErrorMessage
    END CATCH;
END;
GO


EXEC sp_UpdateCartQuantity @Userid = 'USR001', @ProductId = 'PROD001' ,@NewQuantity = 5;

SELECT * FROM user_event_log WHERE user_id = 'USR002';

-- 3. Remove product from cart
CREATE OR ALTER PROCEDURE sp_RemoveFromCart
    @UserId NVARCHAR(50),
    @ProductId NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Delete the cart item
        DELETE FROM shopping_cart
        WHERE user_id = @UserId AND product_id = @ProductId;
        
        -- Log the event
        INSERT INTO user_event_log (user_id, event_type, action_description)
        VALUES (@UserId, 'RemoveFromCart', 'Removed product ' + @ProductId + ' from cart');
    END TRY
    BEGIN CATCH
        -- Log the error
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT @ErrorMessage;
    END CATCH;
END;
GO
EXEC sp_RemoveFromCart @UserId = 'USR19', @ProductId = 'PROD013'


SELECT * FROM shopping_cart WHERE user_id = 'USR19';

SELECT * FROM user_event_log WHERE user_id = 'USR19';

SELECT * FROM shopping_cart WHERE user_id = 'USR19' AND product_id = 'PR0D013';


-- 4. Empty user's cart
CREATE OR ALTER PROCEDURE sp_ClearCart
    @UserId NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Delete all items from the user's cart
        DELETE FROM shopping_cart
        WHERE user_id = @UserId;
        
        -- Log the event
        INSERT INTO user_event_log (user_id, event_type, action_description)
        VALUES (@UserId, 'ClearCart', 'Cleared shopping cart');
    END TRY
    BEGIN CATCH
        -- Log the error
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT @ErrorMessage
    END CATCH;
END;
GO

EXEC sp_ClearCart @UserId = 'USR19'

