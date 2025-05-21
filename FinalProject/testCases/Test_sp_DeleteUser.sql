-- Test Case 1: Successful User Deletion
EXEC sp_DeleteUser   
    @Id = 'USR1';  -- Assuming this user exists
GO

-- Test Case 2: Delete Non-Existent User
BEGIN TRY
    EXEC sp_DeleteUser   
        @Id = 'USR999';  -- Assuming this user does not exist
END TRY
BEGIN CATCH
    PRINT 'Test Case 2 Error: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Test Case 3: Delete User with Null ID
BEGIN TRY
    EXEC sp_DeleteUser   
        @Id = NULL;
END TRY
BEGIN CATCH
    PRINT 'Test Case 3 Error: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Test Case 4: Delete User with Related Shopping Cart Items
-- First create a user with shopping cart items
EXEC sp_CreateUser   
    @Name = 'Test User', 
    @Email = 'test.user@example.com', 
    @Password = 'password123', 
    @PhoneNumber = '1234567890', 
    @Gender = 'Female', 
    @DateOfBirth = '1995-01-01', 
    @Country = 'USA', 
    @UserType = 'customer';
GO

-- Add shopping cart items for the user
INSERT INTO shopping_cart (user_id, product_id, quantity) VALUES ('USR1', 'PROD1', 2);
GO

-- Now delete the user
EXEC sp_DeleteUser   
    @Id = 'USR1';  -- Assuming this user exists
GO

-- Test Case 5: Delete User with Related Wishlist Items
-- First create a user with wishlist items
EXEC sp_CreateUser   
    @Name = 'Test User', 
    @Email = 'test.user@example.com', 
    @Password = 'password123', 
    @PhoneNumber = '1234567890', 
    @Gender = 'Female', 
    @DateOfBirth = '1995-01-01', 
    @Country = 'USA', 
    @UserType = 'customer';
GO

-- Add wishlist items for the user
INSERT INTO wishlist (user_id, product_id) VALUES ('USR1', 'PROD1');
GO

-- Now delete the user
EXEC sp_DeleteUser   
    @Id = 'USR1';  -- Assuming this user exists
GO

-- Test Case 6: Delete User with Reviews
-- First create a user with reviews
EXEC sp_CreateUser   
    @Name = 'Test User', 
    @Email = 'test.user@example.com', 
    @Password = 'password123', 
    @PhoneNumber = '1234567890', 
    @Gender = 'Female', 
    @DateOfBirth = '1995-01-01', 
    @Country = 'USA', 
    @UserType = 'customer';
GO

-- Add a review for the user
INSERT INTO reviews (user_id, product_id, rating, comment) VALUES ('USR1', 'PROD1', 5, 'Great product!');
GO

-- Now delete the user
EXEC sp_DeleteUser   
    @Id = 'USR1';  -- Assuming this user exists
GO
