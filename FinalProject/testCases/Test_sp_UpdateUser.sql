-- Test Case 1: Successful Profile Update (All Fields)
EXEC sp_UpdateUserProfile  
    @Id = 'USR1', 
    @Name = 'John Doe', 
    @Email = 'john.doe@example.com', 
    @PhoneNumber = '1234567890', 
    @Gender = 'Male', 
    @DateOfBirth = '1990-01-01', 
    @Country = 'USA', 
    @Address = '123 Main St', 
    @AddressType = 'Home';
GO

-- Test Case 2: Update with Only Name
EXEC sp_UpdateUserProfile  
    @Id = 'USR1', 
    @Name = 'Jane Doe';
GO

-- Test Case 3: Update with Invalid Email Format
BEGIN TRY
    EXEC sp_UpdateUserProfile  
        @Id = 'USR1', 
        @Email = 'invalid-email-format';
END TRY
BEGIN CATCH
    PRINT 'Test Case 3 Error: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Test Case 4: Update Non-Existent User
BEGIN TRY
    EXEC sp_UpdateUserProfile  
        @Id = 'USR999',  -- Assuming this user does not exist
        @Name = 'Non Existent User';
END TRY
BEGIN CATCH
    PRINT 'Test Case 4 Error: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Test Case 5: Update with Existing Name Conflict
-- First create a user with the name 'Existing User'
EXEC sp_UpdateUserProfile  
    @Id = 'USR2', 
    @Name = 'Existing User', 
    @Email = 'existing.user@example.com';
GO
BEGIN TRY
    -- Attempt to update another user to the same name
    EXEC sp_UpdateUserProfile  
        @Id = 'USR1', 
        @Name = 'Existing User';  -- Assuming 'USR2' has this name
END TRY
BEGIN CATCH
    PRINT 'Test Case 5 Error: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Test Case 6: Update with Existing Email Conflict
-- First create a user with the email 'existing.email@example.com'
EXEC sp_UpdateUserProfile  
    @Id = 'USR2', 
    @Email = 'existing.email@example.com';
GO
BEGIN TRY
    -- Attempt to update another user to the same email
    EXEC sp_UpdateUserProfile  
        @Id = 'USR1', 
        @Email = 'existing.email@example.com';  -- Assuming 'USR2' has this email
END TRY
BEGIN CATCH
    PRINT 'Test Case 6 Error: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Test Case 7: Update with Existing Phone Number Conflict
-- First create a user with the phone number '0987654321'
EXEC sp_UpdateUserProfile  
    @Id = 'USR2', 
    @PhoneNumber = '0987654321';
GO
BEGIN TRY
    -- Attempt to update another user to the same phone number
    EXEC sp_UpdateUserProfile  
        @Id = 'USR1', 
        @PhoneNumber = '0987654321';  -- Assuming 'USR2' has this phone number
END TRY
BEGIN CATCH
    PRINT 'Test Case 7 Error: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Test Case 8: No Fields to Update
BEGIN TRY
    EXEC sp_UpdateUserProfile  
        @Id = 'USR1';  -- No other parameters provided
END TRY
BEGIN CATCH
    PRINT 'Test Case 8 Error: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Test Case 9: Update Address for User with Existing Primary Address
EXEC sp_UpdateUserProfile  
    @Id = 'USR1', 
    @Address = '456 Elm St', 
    @AddressType = 'Home';
GO

-- Test Case 10: Create New Primary Address for User without Existing Address
EXEC sp_UpdateUserProfile  
    @Id = 'USR1', 
    @Address = '789 Oak St', 
    @AddressType = 'Home';
GO

