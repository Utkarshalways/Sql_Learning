-- =================================================================
-- sp_CreateUser - Register new users with proper password hashing
-- =================================================================
CREATE OR ALTER PROCEDURE sp_CreateUser
    @Id NVARCHAR(50),
    @Name NVARCHAR(255),
    @Email NVARCHAR(255),
    @Password NVARCHAR(255),
    @Address NVARCHAR(500),
    @PhoneNumber NVARCHAR(20),
    @Gender NVARCHAR(10),
    @DateOfBirth DATETIME,
    @Country NVARCHAR(100),
    @UserType NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate input parameters
    IF @Id IS NULL OR @Name IS NULL OR @Password IS NULL OR @UserType IS NULL
    BEGIN
        RAISERROR('Required parameters (Id, Name, Password, UserType) cannot be null', 16, 1);
        RETURN;
    END
    
    -- Validate UserType
    IF @UserType NOT IN ('customer', 'vendor')
    BEGIN
        RAISERROR('UserType must be either "customer" or "vendor"', 16, 1);
        RETURN;
    END
    
    -- Validate Email format (simple validation)
    IF @Email IS NOT NULL AND @Email NOT LIKE '%_@_%.__%'
    BEGIN
        RAISERROR('Invalid email format', 16, 1);
        RETURN;
    END
    
    -- Begin transaction
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Check if user already exists
        IF EXISTS (SELECT 1 FROM users WHERE id = @Id OR name = @Name OR 
                  (@Email IS NOT NULL AND email = @Email) OR 
                  (@PhoneNumber IS NOT NULL AND phone_number = @PhoneNumber))
        BEGIN
            RAISERROR('User with this ID, name, email, or phone number already exists', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Insert new user with properly hashed password
        INSERT INTO users (id, name, email, password, address, phone_number, gender, DateOfBirth, country, user_type)
        VALUES (
            @Id,
            @Name,
            @Email,
            HASHBYTES('SHA2_256', CONVERT(VARBINARY, @Password)),
            @Address,
            @PhoneNumber,
            @Gender,
            @DateOfBirth,
            @Country,
            @UserType
        );
        
        -- Commit transaction
        COMMIT TRANSACTION;
        
        -- Return success
        SELECT @Id AS 'UserId', @Name AS 'UserName', @UserType AS 'UserType', 'User created successfully' AS 'Message';
        
    END TRY
    BEGIN CATCH
        -- Rollback transaction in case of error
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        -- Return error information
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO

-- =================================================================
-- sp_UpdateUserProfile - Update user profile information
-- =================================================================
CREATE OR ALTER PROCEDURE sp_UpdateUserProfile
    @Id NVARCHAR(50),
    @Name NVARCHAR(255) = NULL,
    @Email NVARCHAR(255) = NULL,
    @Address NVARCHAR(500) = NULL,
    @PhoneNumber NVARCHAR(20) = NULL,
    @Gender NVARCHAR(10) = NULL,
    @DateOfBirth DATETIME = NULL,	
    @Country NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate ID
    IF @Id IS NULL
    BEGIN
        RAISERROR('User ID cannot be null', 16, 1);
        RETURN;
    END
    
    -- Validate Email format if provided
    IF @Email IS NOT NULL AND @Email NOT LIKE '%_@_%.__%'
    BEGIN
        RAISERROR('Invalid email format', 16, 1);
        RETURN;
    END
    
    -- Begin transaction
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Check if user exists
        IF NOT EXISTS (SELECT 1 FROM users WHERE id = @Id)
        BEGIN
            RAISERROR('User not found', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Check if name or email already exists for a different user
        IF @Name IS NOT NULL AND EXISTS (SELECT 1 FROM users WHERE name = @Name AND id != @Id)
        BEGIN
            RAISERROR('Username already taken', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        IF @Email IS NOT NULL AND EXISTS (SELECT 1 FROM users WHERE email = @Email AND id != @Id)
        BEGIN
            RAISERROR('Email already in use', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        IF @PhoneNumber IS NOT NULL AND EXISTS (SELECT 1 FROM users WHERE phone_number = @PhoneNumber AND id != @Id)
        BEGIN
            RAISERROR('Phone number already in use', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Build dynamic SQL for update
        DECLARE @SQL NVARCHAR(MAX);
        SET @SQL = 'UPDATE users SET ';
        
        DECLARE @Updates NVARCHAR(MAX) = '';
        
        IF @Name IS NOT NULL
            SET @Updates = @Updates + 'name = ''' + @Name + ''', ';
        IF @Email IS NOT NULL
            SET @Updates = @Updates + 'email = ''' + @Email + ''', ';
        IF @Address IS NOT NULL
            SET @Updates = @Updates + 'address = ''' + @Address + ''', ';
        IF @PhoneNumber IS NOT NULL
            SET @Updates = @Updates + 'phone_number = ''' + @PhoneNumber + ''', ';
        IF @Gender IS NOT NULL
            SET @Updates = @Updates + 'gender = ''' + @Gender + ''', ';
        IF @DateOfBirth IS NOT NULL
            SET @Updates = @Updates + 'DateOfBirth = ''' + CONVERT(NVARCHAR, @DateOfBirth, 121) + ''', ';
        IF @Country IS NOT NULL
            SET @Updates = @Updates + 'country = ''' + @Country + ''', ';
            
        -- Add timestamp
        SET @Updates = @Updates + 'updated_at = GETDATE() ';
        
        -- If nothing to update, raise error
        IF @Updates = 'updated_at = GETDATE() ' AND 
           @Name IS NULL AND @Email IS NULL AND @Address IS NULL AND 
           @PhoneNumber IS NULL AND @Gender IS NULL AND @DateOfBirth IS NULL AND 
           @Country IS NULL
        BEGIN
            RAISERROR('No fields to update provided', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Complete SQL statement
        SET @SQL = @SQL + @Updates + 'WHERE id = ''' + @Id + '''';
        
        -- Execute update
        EXEC sp_executesql @SQL;
        
        -- Commit transaction
        COMMIT TRANSACTION;
        
        -- Return success
        SELECT @Id AS 'UserId', 'User profile updated successfully' AS 'Message';
        
    END TRY
    BEGIN CATCH
        -- Rollback transaction in case of error
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        -- Return error information
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO

-- =================================================================
-- sp_DeleteUser - Handle user deletion with cascading effects
-- =================================================================
CREATE OR ALTER PROCEDURE sp_DeleteUser
    @Id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate ID
    IF @Id IS NULL
    BEGIN
        RAISERROR('User ID cannot be null', 16, 1);
        RETURN;
    END
    
    DECLARE @UserType NVARCHAR(50);
    
    -- Begin transaction
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Check if user exists and get user type
        SELECT @UserType = user_type FROM users WHERE id = @Id;
        
        IF @UserType IS NULL
        BEGIN
            RAISERROR('User not found', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- For safety, manually delete related data not covered by ON DELETE CASCADE
        
        -- Handle shopping cart items
        DELETE FROM shopping_cart WHERE user_id = @Id;
        
        -- Handle wishlist items
        DELETE FROM wishlist WHERE user_id = @Id;
        
        -- Handle reviews (we need to keep reviews for product rating integrity,
        -- but we can anonymize them)
        UPDATE reviews SET user_id = 'DELETED_USER' WHERE user_id = @Id;
        
        -- Now delete the user (this will cascade delete customers/vendors records)
        DELETE FROM users WHERE id = @Id;
        
        -- Commit transaction
        COMMIT TRANSACTION;
        
        -- Return success
        SELECT @Id AS 'DeletedUserId', @UserType AS 'UserType', 'User deleted successfully' AS 'Message';
        
    END TRY
    BEGIN CATCH
        -- Rollback transaction in case of error
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        -- Return error information
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO

-- =================================================================
-- sp_AuthenticateUser - Authenticate user credentials
-- =================================================================
CREATE OR ALTER PROCEDURE sp_AuthenticateUser
    @LoginIdentifier NVARCHAR(255), -- Can be email, username, or phone
    @Password NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate input parameters
    IF @LoginIdentifier IS NULL OR @Password IS NULL
    BEGIN
        RAISERROR('Login identifier and password must be provided', 16, 1);
        RETURN;
    END
    
    -- Hash the provided password for comparison
    DECLARE @HashedPassword VARBINARY(MAX) = HASHBYTES('SHA2_256', CONVERT(VARBINARY, @Password));
    
    -- Try to find user by email, name, or phone number
    DECLARE @UserId NVARCHAR(50);
    DECLARE @UserName NVARCHAR(255);
    DECLARE @UserType NVARCHAR(50);
    
    SELECT @UserId = id, @UserName = name, @UserType = user_type
    FROM users
    WHERE (email = @LoginIdentifier OR name = @LoginIdentifier OR phone_number = @LoginIdentifier)
    AND password = @HashedPassword;
    
    -- Check if user was found
    IF @UserId IS NULL
    BEGIN
        -- For security reasons, don't specify whether user doesn't exist or password is incorrect
        RAISERROR('Invalid login credentials', 16, 1);
        RETURN;
    END
    
    -- Return user information (excluding sensitive data)
    SELECT 
        u.id AS UserId,
        u.name AS UserName,
        u.email AS Email,
        u.user_type AS UserType,
        u.address AS Address,
        u.phone_number AS PhoneNumber,
        u.gender AS Gender,
        u.DateOfBirth AS DateOfBirth,
        u.country AS Country,
        'Authentication successful' AS Message
    FROM 
        users u
    WHERE 
        u.id = @UserId;
    
END;
GO

-- =================================================================
-- sp_CreateCustomer - Create customer profile linked to user
-- =================================================================
CREATE OR ALTER PROCEDURE sp_CreateCustomer
    @UserId NVARCHAR(50),
    @PaymentDetails NVARCHAR(1000) = NULL,
    @Age INT = NULL,
    @Address NVARCHAR(500) = NULL,
    @PinCode INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate input parameters
    IF @UserId IS NULL
    BEGIN
        RAISERROR('User ID cannot be null', 16, 1);
        RETURN;
    END
    
    -- Validate PinCode if provided
    IF @PinCode IS NOT NULL AND @PinCode < 100000
    BEGIN
        RAISERROR('Pin code must be at least 6 digits', 16, 1);
        RETURN;
    END
    
    -- Begin transaction
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Check if user exists and is of type 'customer'
        DECLARE @UserType NVARCHAR(50);
        SELECT @UserType = user_type FROM users WHERE id = @UserId;
        
        IF @UserType IS NULL
        BEGIN
            RAISERROR('User not found', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        IF @UserType != 'customer'
        BEGIN
            RAISERROR('User is not of type customer', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Check if customer profile already exists
        IF EXISTS (SELECT 1 FROM customers WHERE userId = @UserId)
        BEGIN
            RAISERROR('Customer profile already exists for this user', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Generate new customer ID
        DECLARE @NewCustomerId BIGINT;
        SELECT @NewCustomerId = ISNULL(MAX(id), 0) + 1 FROM customers;
        
        -- Insert new customer profile
        INSERT INTO customers (id, userId, paymentDetails, age, address, pinCode)
        VALUES (@NewCustomerId, @UserId, @PaymentDetails, @Age, @Address, @PinCode);
        
        -- Commit transaction
        COMMIT TRANSACTION;
        
        -- Return success with customer details
        SELECT 
            c.id AS CustomerId, 
            c.userId AS UserId, 
            u.name AS UserName,
            c.paymentDetails AS PaymentDetails,
            c.age AS Age,
            c.address AS Address,
            c.pinCode AS PinCode,
            'Customer profile created successfully' AS Message
        FROM 
            customers c
            JOIN users u ON c.userId = u.id
        WHERE 
            c.id = @NewCustomerId;
        
    END TRY
    BEGIN CATCH
        -- Rollback transaction in case of error
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        -- Return error information
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO

-- =================================================================
-- sp_CreateVendor - Create vendor profile linked to user
-- =================================================================
CREATE OR ALTER PROCEDURE sp_CreateVendor
    @UserId NVARCHAR(50),
    @PaymentReceivingDetails NVARCHAR(1000) = NULL,
    @Address NVARCHAR(500) = NULL,
    @PinCode INT = NULL,
    @GSTnumber NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate input parameters
    IF @UserId IS NULL OR @GSTnumber IS NULL
    BEGIN
        RAISERROR('User ID and GST number are required', 16, 1);
        RETURN;
    END
    
    -- Validate PinCode if provided
    IF @PinCode IS NOT NULL AND @PinCode < 100000
    BEGIN
        RAISERROR('Pin code must be at least 6 digits', 16, 1);
        RETURN;
    END
    
    -- Begin transaction
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Check if user exists and is of type 'vendor'
        DECLARE @UserType NVARCHAR(50);
        SELECT @UserType = user_type FROM users WHERE id = @UserId;
        
        IF @UserType IS NULL
        BEGIN
            RAISERROR('User not found', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        IF @UserType != 'vendor'
        BEGIN
            RAISERROR('User is not of type vendor', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Check if vendor profile already exists
        IF EXISTS (SELECT 1 FROM vendors WHERE userId = @UserId)
        BEGIN
            RAISERROR('Vendor profile already exists for this user', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Check if GST number is already in use
        IF EXISTS (SELECT 1 FROM vendors WHERE GSTnumber = @GSTnumber)
        BEGIN
            RAISERROR('GST number is already registered with another vendor', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Generate new vendor ID
        DECLARE @NewVendorId BIGINT;
        SELECT @NewVendorId = ISNULL(MAX(id), 0) + 1 FROM vendors;
        
        -- Insert new vendor profile
        INSERT INTO vendors (id, userId, paymentReceivingDetails, address, pinCode, GSTnumber)
        VALUES (@NewVendorId, @UserId, @PaymentReceivingDetails, @Address, @PinCode, @GSTnumber);
        
        -- Commit transaction
        COMMIT TRANSACTION;
        
        -- Return success with vendor details
        SELECT 
            v.id AS VendorId, 
            v.userId AS UserId, 
            u.name AS UserName,
            v.paymentReceivingDetails AS PaymentReceivingDetails,
            v.address AS Address,
            v.pinCode AS PinCode,
            v.GSTnumber AS GSTnumber,
            'Vendor profile created successfully' AS Message
        FROM 
            vendors v
            JOIN users u ON v.userId = u.id
        WHERE 
            v.id = @NewVendorId;
        
    END TRY
    BEGIN CATCH
        -- Rollback transaction in case of error
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        -- Return error information
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO