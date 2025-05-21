-- Test Case 1: Successful User Creation (Customer)
EXEC sp_CreateUser
    @Name = 'Lakshya Sharma',
    @Email = 'lakshyaSharma@gmail.com',
    @Password = 'lakshya123',
    @PhoneNumber = '9431343226',
    @Gender = 'Male',
    @DateOfBirth = '2003-07-03',
    @Country = 'India',
    @UserType = 'customer',
    @Address = '152, Kanakpura, Jaipur',
	@PaymentDetails = 'Paytm UPI: Lakshya@oksbi',
    @Age = 22,
    @PinCode = 302020;
GO

-- Test Case 2: Successful User Creation (Vendor)
EXEC sp_CreateUser  
    @Name = 'Jane Smith',
    @Email = 'jane.smith@example.com',
    @Password = 'securepassword',
    @PhoneNumber = '0987654321',
    @Gender = 'Female',
    @DateOfBirth = '1985-05-15',
    @Country = 'Canada',
    @UserType = 'vendor',
    @Address = '456 Elm St',
    @PaymentDetails = 'Bank Transfer',
    @PinCode = 654321,
    @GSTnumber = 'GST123456789';
GO

-- Test Case 3: Missing Required Parameters (Expect error)
    EXEC sp_CreateUser  
        @Name = NULL,
        @Email = 'missing.name@example.com',
        @Password = 'password',
        @PhoneNumber = '1234567890',
        @Gender = 'Male',
        @DateOfBirth = '1990-01-01',
        @Country = 'USA',
        @UserType = 'customer';

GO

-- Test Case 4: Invalid User Type (Expect error)
BEGIN TRY
    EXEC sp_CreateUser  
        @Name = 'Invalid User',
        @Email = 'invalid.user@example.com',
        @Password = 'password',
        @PhoneNumber = '1234567890',
        @Gender = 'Male',
        @DateOfBirth = '1990-01-01',
        @Country = 'USA',
        @UserType = 'invalid_type';
END TRY
BEGIN CATCH
    PRINT 'Test Case 4 Error: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Test Case 5: Invalid Email Format (Expect error)
BEGIN TRY
    EXEC sp_CreateUser  
        @Name = 'Invalid Email User',
        @Email = 'invalid-email-format',
        @Password = 'password',
        @PhoneNumber = '1234567890',
        @Gender = 'Male',
        @DateOfBirth = '1990-01-01',
        @Country = 'USA',
        @UserType = 'customer';
END TRY
BEGIN CATCH
    PRINT 'Test Case 5 Error: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Test Case 6: Duplicate User Creation (Email) (Expect error on second insert)
-- First create a user
EXEC sp_CreateUser  
    @Name = 'John Doe',
    @Email = 'duplicate@example.com',
    @Password = 'password123',
    @PhoneNumber = '1234567890',
    @Gender = 'Male',
    @DateOfBirth = '1990-01-01',
    @Country = 'USA',
    @UserType = 'customer';
GO

-- Attempt to create another user with the same email
BEGIN TRY
    EXEC sp_CreateUser  
        @Name = 'Another User',
        @Email = 'duplicate@example.com',
        @Password = 'anotherpassword',
        @PhoneNumber = '0987654321',
        @Gender = 'Female',
        @DateOfBirth = '1992-02-02',
        @Country = 'USA',
        @UserType = 'vendor';
END TRY
BEGIN CATCH
    PRINT 'Test Case 6 Error: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Test Case 7: Missing GST Number for Vendor (Expect error)
BEGIN TRY
    EXEC sp_CreateUser  
        @Name = 'Vendor User',
        @Email = 'vendor@example.com',
        @Password = 'vendorpassword',
        @PhoneNumber = '1234567890',
        @Gender = 'Male',
        @DateOfBirth = '1990-01-01',
        @Country = 'USA',
        @UserType = 'vendor',
        @GSTnumber = NULL; -- GST number is required
END TRY
BEGIN CATCH
    PRINT 'Test Case 7 Error: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Test Case 8: Duplicate User Creation (Phone Number) (Expect error on second insert)
-- First create a user
EXEC sp_CreateUser
    @Name = 'Lakshya Sharma',
    @Email = 'lakshyaSharma@gmail.com',
    @Password = 'lakshya123',
    @PhoneNumber = '9431343226',
    @Gender = 'Male',
    @DateOfBirth = '2003-07-03',
    @Country = 'India',
    @UserType = 'customer',
    @Address = '152, Kanakpura, Jaipur',
	@PaymentDetails = 'Paytm UPI: Lakshya@oksbi',
    @Age = 22,
    @PinCode = 302020;

GO

-- Attempt to create another user with the same phone number
BEGIN TRY
    EXEC sp_CreateUser  
        @Name = 'Another User',
        @Email = 'another@example.com',
        @Password = 'anotherpassword',
        @PhoneNumber = '1234567890', -- Duplicate phone number
        @Gender = 'Female',
        @DateOfBirth = '1992-02-02',
        @Country = 'USA',
        @UserType = 'vendor';
END TRY
BEGIN CATCH
    PRINT 'Test Case 8 Error: ' + ERROR_MESSAGE();
END CATCH;
GO
