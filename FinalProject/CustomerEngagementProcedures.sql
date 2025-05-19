 --=========================================
-- CUSTOMER ENGAGEMENT PROCEDURES
-- =========================================

-- 1. Add product to wishlist
CREATE OR ALTER PROCEDURE sp_AddProductToWishlist
    @UserId NVARCHAR(50),
    @ProductId NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Check if the product is already in the wishlist
        IF NOT EXISTS (SELECT 1 FROM wishlist WHERE user_id = @UserId AND product_id = @ProductId)
        BEGIN
            -- Add to wishlist
            INSERT INTO wishlist (user_id, product_id)
            VALUES (@UserId, @ProductId);
            
            -- Log the event
            INSERT INTO user_event_log (user_id, event_type, action_description)
            VALUES (@UserId, 'AddToWishlist', 'Added product ' + @ProductId + ' to wishlist');
        END
    END TRY
    BEGIN CATCH
        -- Log the error
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
GO

-- 2. Remove from wishlist
CREATE OR ALTER PROCEDURE sp_RemoveFromWishlist
    @UserId NVARCHAR(50),
    @ProductId NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Remove from wishlist
        DELETE FROM wishlist
        WHERE user_id = @UserId AND product_id = @ProductId;
        
        -- Log the event
        INSERT INTO user_event_log (user_id, event_type, action_description)
        VALUES (@UserId, 'RemoveFromWishlist', 'Removed product ' + @ProductId + ' from wishlist');
    END TRY
    BEGIN CATCH
        -- Log the error
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
GO

-- 3. Add product review
CREATE OR ALTER PROCEDURE sp_AddProductReview
    @UserId NVARCHAR(50),
    @ProductId NVARCHAR(50),
    @Rating INT,
    @Comment NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Check if the user has purchased the product
        IF NOT EXISTS (
            SELECT 1 
            FROM orders o
            JOIN order_items oi ON o.id = oi.order_id
            WHERE o.user_id = @UserId 
            AND oi.product_id = @ProductId
            AND o.order_status = 'Completed'
        )
        BEGIN
            RAISERROR('Can only review products you have purchased', 16, 1);
            RETURN;
        END
        
        -- Check if user already reviewed this product
        IF EXISTS (SELECT 1 FROM reviews WHERE user_id = @UserId AND product_id = @ProductId)
        BEGIN
            RAISERROR('You have already reviewed this product. Please use update.', 16, 1);
            RETURN;
        END
        
        -- Add the review
        INSERT INTO reviews (id, user_id, product_id, rating, comment, review_date)
        VALUES (CONVERT(NVARCHAR(50), NEWID()), @UserId, @ProductId, @Rating, @Comment, GETDATE());
        
        -- Log the event
        INSERT INTO user_event_log (user_id, event_type, action_description)
        VALUES (@UserId, 'AddReview', 'Added review for product ' + @ProductId);
    END TRY
    BEGIN CATCH
        -- Log the error
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
GO

-- 4. Update existing review
CREATE OR ALTER PROCEDURE sp_UpdateProductReview
    @UserId NVARCHAR(50),
    @ProductId NVARCHAR(50),
    @Rating INT,
    @Comment NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Check if the review exists
        IF NOT EXISTS (SELECT 1 FROM reviews WHERE user_id = @UserId AND product_id = @ProductId)
        BEGIN
            RAISERROR('No existing review found to update', 16, 1);
            RETURN;
        END
        
        -- Update the review
        UPDATE reviews
        SET 
            rating = @Rating,
            comment = @Comment,
            updated_at = GETDATE()
        WHERE user_id = @UserId AND product_id = @ProductId;
        
        -- Log the event
        INSERT INTO user_event_log (user_id, event_type, action_description)
        VALUES (@UserId, 'UpdateReview', 'Updated review for product ' + @ProductId);
    END TRY
    BEGIN CATCH
        -- Log the error
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
GO

SELECT * FROM sys.procedures;
