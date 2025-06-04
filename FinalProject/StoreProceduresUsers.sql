-- =================================================================
-- sp_CreateUser - Register new users
-- =================================================================

CREATE OR ALTER FUNCTION ValidateEmail
(
    @email NVARCHAR(320) = NULL
)
RETURNS BIT
AS
BEGIN
    DECLARE @Result BIT = 0;

    -- Check Length + Start of email
    IF @email IS NULL OR LEN(@email) > 320 OR CHARINDEX(' ', @email) > 0
        RETURN 0;

    -- Must contain exactly one @
    IF LEN(@email) - LEN(REPLACE(@email, '@', '')) != 1
        RETURN 0;

    DECLARE @localPart NVARCHAR(64);
    DECLARE @domainPart NVARCHAR(255);
    DECLARE @lastDot INT;
    DECLARE @tld NVARCHAR(10);

    SET @localPart = LEFT(@email, CHARINDEX('@', @email) - 1);
    SET @domainPart = RIGHT(@email, LEN(@email) - CHARINDEX('@', @email));

    -- Local part and domain must not be empty
    IF LEN(@localPart) = 0 OR LEN(@domainPart) = 0
        RETURN 0;

    -- Domain must contain at least one dot
    IF CHARINDEX('.', @domainPart) = 0
        RETURN 0;

     -- Local part allowed characters check (basic)
    IF PATINDEX('%[^a-zA-Z0-9._%+-]%', @localPart) > 0
        RETURN 0;

    -- Domain part allowed characters check
    IF PATINDEX('%[^a-zA-Z0-9.-]%', @domainPart) > 0
        RETURN 0;

    -- No starting or ending dot in local part
    IF LEFT(@localPart, 1) = '.' OR RIGHT(@localPart, 1) = '.'
        RETURN 0;

    -- Domain must not start or end with dot or hyphen
    IF LEFT(@domainPart, 1) IN ('.', '-') OR RIGHT(@domainPart, 1) IN ('.', '-')
        RETURN 0;

    -- Check for consecutive dots
    IF CHARINDEX('..', @email) > 0
        RETURN 0;

    -- Extract and validate TLD (after the last dot)
    SET @lastDot = LEN(@domainPart) - CHARINDEX('.', REVERSE(@domainPart)) + 1;
    SET @tld = RIGHT(@domainPart, LEN(@domainPart) - @lastDot);

    IF LEN(@tld) < 2 OR LEN(@tld) > 24
        RETURN 0;

    SET @Result = 1;
    RETURN @Result;
END
GO

 


CREATE OR ALTER PROCEDURE sp_CreateUser  
    @Name NVARCHAR(255) = NULL,
    @Email NVARCHAR(255) = NULL,
    @Password NVARCHAR(255) = NULL,
    @PhoneNumber NVARCHAR(20) = NULL,
    @Gender NVARCHAR(10) = NULL,
    @DateOfBirth DATETIME = NULL,
    @UserType NVARCHAR(50) = NULL,
    @Address NVARCHAR(500) = NULL,
    @PaymentDetails NVARCHAR(1000) = 'COD',
    @PinCode INT = NULL,
    @Age INT = NULL,
    @GSTnumber NVARCHAR(50) = NULL -- For vendors
AS
BEGIN
    SET NOCOUNT ON;
	BEGIN TRY
        BEGIN TRANSACTION;

    DECLARE @ErrorMessage NVARCHAR(4000);

    -- Basic validations
    IF @Name IS NULL OR @Password IS NULL OR @UserType IS NULL
    BEGIN
        SET @ErrorMessage = 'Required parameters (Name, Password, UserType) cannot be null';
        THROW 50001, @ErrorMessage, 1;
    END

	IF @PhoneNumber IS NULL
	BEGIN 
		 SET @ErrorMessage = 'Required parameter (Phone Number) cannot be null';
        THROW 50001, @ErrorMessage, 1;
	END

    IF @Gender IS NULL 
    BEGIN 
        SET @ErrorMessage = 'Required parameter (Gender) cannot be null';
        THROW 50001, @ErrorMessage, 1;
    END

    IF @UserType NOT IN ('customer', 'vendor')
    BEGIN
        SET @ErrorMessage = 'User  Type must be either "customer" or "vendor"';
        THROW 50001, @ErrorMessage, 1;
    END

    IF @Email IS NOT NULL AND DBO.ValidateEmail(@Email) = 0
    BEGIN
        SET @ErrorMessage = 'Invalid email format';
        THROW 50001, @ErrorMessage, 1;
    END

	IF LEN(@PhoneNumber) <> 10 
	BEGIN 
		 SET @ErrorMessage = 'Invalid phone number';
        THROW 50001, @ErrorMessage, 1;
    END

	IF @Password IS NULL OR LEN(@Password) < 8 OR 

           PATINDEX('%[' + CHAR(97) + '-' + CHAR(122) + ']%', @Password COLLATE Latin1_General_BIN) <= 0 OR

           PATINDEX('%[' + CHAR(65) + '-' + CHAR(90) + ']%', @Password COLLATE Latin1_General_BIN) <= 0 OR 

           @Password NOT LIKE '%[0-9]%' OR 

           @Password NOT LIKE '%[^a-zA-Z0-9]%'

		    BEGIN
			
            SET @ErrorMessage = 'Password must be at least 8 characters long, contain at least one uppercase letter, one lowercase letter, one digit, and one special character.';

            THROW 50008, @ErrorMessage, 1;

        END
 
		
        -- Generate the new User ID
        DECLARE @UserId NVARCHAR(50);
        DECLARE @MaxUserId NVARCHAR(50);
        DECLARE @NewUserNumber INT;

        -- Get the maximum user ID
        SELECT @MaxUserId = MAX(id) FROM users;

        -- Extract the numeric part and increment it
        IF @MaxUserId IS NOT NULL 
        BEGIN
            SET @NewUserNumber = CAST(SUBSTRING(@MaxUserId, 4, LEN(@MaxUserId) - 3) AS INT) + 1;
        END
        ELSE
        BEGIN
            SET @NewUserNumber = 1;  -- Start from 1 if no users exist or format doesn't match
        END

        SET @UserId = 'USR' + CAST(@NewUserNumber AS NVARCHAR(20));

        -- Duplicate check
        IF EXISTS (
            SELECT 1 FROM users
            WHERE id = @UserId
               OR (@Email IS NOT NULL AND email = @Email)
               OR (@PhoneNumber IS NOT NULL AND phone_number = @PhoneNumber)
        )
        BEGIN
            SET @ErrorMessage = 'User  with this ID, email, or phone number already exists';
            THROW 50001, @ErrorMessage, 1;
        END

        -- Insert into users
        INSERT INTO users (id, name, email, password, phone_number, gender, DateOfBirth, user_type)
        VALUES (
            @UserId,
            @Name,
            @Email,
            HASHBYTES('SHA2_256', CONVERT(VARBINARY, @Password)),
            @PhoneNumber,
            @Gender,
            @DateOfBirth,
            @UserType
        );
	
        -- Address (user_addresses)
        IF @Address IS NOT NULL
        BEGIN
            INSERT INTO user_addresses (user_id, address_line, address_type, is_primary)
            VALUES (@UserId, @Address, 'Home', 1);
        END

        -- Insert into customers
        IF @UserType = 'customer'
        BEGIN
            DECLARE @CustomerId BIGINT = ISNULL((SELECT MAX(id) + 1 FROM customers), 1);

            INSERT INTO customers (id, userId, paymentDetails, age, address, pinCode)
            VALUES (@CustomerId, @UserId, @PaymentDetails, @Age, @Address, @PinCode);
        END

        -- Insert into vendors
        IF @UserType = 'vendor'
        BEGIN
            DECLARE @VendorId BIGINT = ISNULL((SELECT MAX(id) + 1 FROM vendors), 1);

            IF @GSTnumber IS NULL
            BEGIN
                SET @ErrorMessage = 'GST number is required for vendors';
                THROW 50001, @ErrorMessage, 1;
            END

            INSERT INTO vendors (id, userId, paymentReceivingDetails, address, pinCode, GSTnumber)
            VALUES (@VendorId, @UserId, @PaymentDetails, @Address, @PinCode, @GSTnumber);
        END

        COMMIT TRANSACTION;

        SELECT 
            @UserId AS UserId,
            @Name AS UserName,
            @UserType AS UserType,
            'User  created successfully' AS Message;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @ErrorMessage  = ERROR_MESSAGE();
        PRINT @ErrorMessage; -- You can also use THROW to re-throw the error
    END CATCH
END;
GO

SELECT DBO.ValidateEmail('Utkarsh@.com')

SELECT * FROM user_addresses;


EXEC sp_CreateUser
    @Name = 'Lakshya Sharma',
    @Email = 'lakshyaSharma@gmail.com',
    @Password = 'lakshya123',
    @PhoneNumber = '9431343226',
    @Gender = 'Male',
    @DateOfBirth = '2003-07-03',
    @UserType = 'customer',
    @Address = '152, Kanakpura, Jaipur',
	@PaymentDetails = 'Paytm UPI: Lakshya@oksbi',
    @Age = 22,
    @PinCode = 302020;

SELECT * FROM users;

DELETE  FROM users WHERE id = 'USR017'


SELECT * FROM customers

SELECT * FROM payments;
SELECT * FROM orders;


SELECT * FROM user_event_log


CREATE OR ALTER PROCEDURE sp_AuthenticateUser
    @email_or_phone NVARCHAR(255),
    @password NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Hash the provided password
    DECLARE @hashedPassword VARBINARY(64);
    SET @hashedPassword = HASHBYTES('SHA2_256', CONVERT(VARBINARY, @password));
    
    -- Check if credentials match
    IF EXISTS (
        SELECT 1 FROM users 
        WHERE (email = @email_or_phone OR phone_number = @email_or_phone)
        AND password = @hashedPassword
    )
    BEGIN
        -- User is authenticated, return user info
        SELECT id, name, email, phone_number, user_type 
        FROM users
        WHERE (email = @email_or_phone OR phone_number = @email_or_phone)
        AND password = @hashedPassword;
        
        -- Log the login event
        INSERT INTO user_event_log (user_id, event_type, action_description)
        SELECT id, 'Login', 'User logged in successfully.'
        FROM users
        WHERE (email = @email_or_phone OR phone_number = @email_or_phone)
        AND password = @hashedPassword;
    END
    ELSE
    BEGIN
		--SELECT @email_or_phone
		--SELECT @hashedPassword as hashedpassword
		--SELECT password FROM users where email = @email_or_phone
        PRINT 'Invalid credentials.';
    END
END;
GO

SELECT * FROM users;

EXEC sp_AuthenticateUser
@email_or_phone = 'lakshyaSharma@gmail.com',@password = 'lakshya123'


SELECT * FROM user_event_log WHERE user_id = 'USR19';
-- =================================================================
-- sp_UpdateUserProfile - Update user profile information
-- =================================================================
CREATE OR ALTER PROCEDURE sp_UpdateUserProfile
    @Id NVARCHAR(50),
    @Name NVARCHAR(255) = NULL,
    @Email NVARCHAR(255) = NULL,
    @PhoneNumber NVARCHAR(20) = NULL,
    @Gender NVARCHAR(10) = NULL,
    @DateOfBirth DATETIME = NULL,
    @Address NVARCHAR(500) = NULL, -- For updating primary address
    @AddressType NVARCHAR(50) = 'Home' -- Default address type
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
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
        
        -- Build dynamic SQL for user update
        DECLARE @SQL NVARCHAR(MAX);
        SET @SQL = 'UPDATE users SET ';
        
        DECLARE @Updates NVARCHAR(MAX) = '';
        
        IF @Name IS NOT NULL
            SET @Updates = @Updates + 'name = ''' + @Name + ''', ';
        IF @Email IS NOT NULL
            SET @Updates = @Updates + 'email = ''' + @Email + ''', ';
        IF @PhoneNumber IS NOT NULL
            SET @Updates = @Updates + 'phone_number = ''' + @PhoneNumber + ''', ';
        IF @Gender IS NOT NULL
            SET @Updates = @Updates + 'gender = ''' + @Gender + ''', ';
        IF @DateOfBirth IS NOT NULL
            SET @Updates = @Updates + 'DateOfBirth = ''' + CONVERT(NVARCHAR, @DateOfBirth, 121) + ''', ';
        
        -- Add timestamp
        
        -- Check if there are updates for the users table
        IF @Updates = 'updated_at = GETDATE() ' AND 
           @Name IS NULL AND @Email IS NULL AND 
           @PhoneNumber IS NULL AND @Gender IS NULL AND @DateOfBirth IS NULL AND @Address IS NULL
        BEGIN
            RAISERROR('No fields to update provided', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Complete SQL statement for users table if needed
        IF @Updates != 'updated_at = GETDATE() ' OR
           (@Name IS NOT NULL OR @Email IS NOT NULL OR @PhoneNumber IS NOT NULL OR
            @Gender IS NOT NULL OR @DateOfBirth IS NOT NULL)
        BEGIN
            SET @SQL = @SQL + @Updates + 'WHERE id = ''' + @Id + '''';
            
            -- Execute update for users table
            EXEC sp_executesql @SQL;
        END
        
        -- Handle address update
        IF @Address IS NOT NULL
        BEGIN
            -- Check if user has a primary address
            IF EXISTS (SELECT 1 FROM user_addresses WHERE user_id = @Id AND is_primary = 1)
            BEGIN
                -- Update existing primary address
                UPDATE user_addresses 
                SET address_line = @Address, 
                    address_type = @AddressType,
                    modified_at = GETDATE()
                WHERE user_id = @Id AND is_primary = 1;
            END
            ELSE
            BEGIN
                -- Create new primary address
                INSERT INTO user_addresses (user_id, address_line, address_type, is_primary, modified_at)
                VALUES (@Id, @Address, @AddressType, 1, GETDATE());
            END
        END
        
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
        PRINT @ErrorMessage;
    END CATCH
END;
GO



CREATE OR ALTER PROCEDURE sp_ResetPassword
    @UserId NVARCHAR(50),
    @OldPassword NVARCHAR(255),
    @Password NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Validate inputs
        IF @UserId IS NULL OR @OldPassword IS NULL OR @Password IS NULL OR LEN(@Password) = 0
        BEGIN
            RAISERROR('User  ID, old password, and new password must be provided', 16, 1);
            RETURN;
        END
        
        -- Check if user exists and verify old password
        DECLARE @StoredPassword VARBINARY(64);
        
        SELECT @StoredPassword = password 
        FROM users 
        WHERE id = @UserId;
        
        IF @StoredPassword IS NULL
        BEGIN
            RAISERROR('User  not found', 16, 1);
            RETURN;
        END
        
        -- Verify old password
        IF @StoredPassword != HASHBYTES('SHA2_256', CONVERT(VARBINARY, @OldPassword))
        BEGIN
            RAISERROR('Old password is incorrect', 16, 1);
            RETURN;
        END

		IF @Password IS NULL OR LEN(@Password) < 8 OR 

           PATINDEX('%[' + CHAR(97) + '-' + CHAR(122) + ']%', @Password COLLATE Latin1_General_BIN) <= 0 OR

           PATINDEX('%[' + CHAR(65) + '-' + CHAR(90) + ']%', @Password COLLATE Latin1_General_BIN) <= 0 OR 

           @Password NOT LIKE '%[0-9]%' OR 

           @Password NOT LIKE '%[^a-zA-Z0-9]%'

		    BEGIN

            RAISERROR('Password must be at least 8 characters long, contain at least one uppercase letter, one lowercase letter, one digit, and one special character.',16,1);
			END
           
        
        -- Update password
        UPDATE users
        SET password = HASHBYTES('SHA2_256', CONVERT(VARBINARY, @Password))
        WHERE id = @UserId;
        
        -- Optionally, log the password reset event
        INSERT INTO user_event_log (user_id, event_type, action_description)
        VALUES (@UserId, 'PasswordReset', 'User  password was reset');
        
        SELECT 'Password reset successfully' AS Result;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT @ErrorMessage
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
     BEGIN TRY
    -- Validate ID
    IF @Id IS NULL
    BEGIN
        RAISERROR('User ID cannot be null', 16, 1);
        RETURN;
    END
    
    DECLARE @UserType NVARCHAR(50);
    
    -- Begin transaction
   
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
        
        -- Handle user addresses (will be cascaded, but being explicit)
        DELETE FROM user_addresses WHERE user_id = @Id;
        
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
        PRINT @ErrorMessage;
    END CATCH
END;
GO

EXEC sp_DeleteUser @id = 'USR017'


-- =================================================================
-- sp_AddUserAddress - Add a new address for a user
-- =================================================================
CREATE OR ALTER PROCEDURE sp_AddUserAddress
    @UserId NVARCHAR(50),
    @AddressLine NVARCHAR(500),
    @AddressType NVARCHAR(50) = 'Home',
    @IsPrimary BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate input parameters
    IF @UserId IS NULL OR @AddressLine IS NULL
    BEGIN
        RAISERROR('User ID and Address Line are required', 16, 1);
        RETURN;
    END
    
    -- Begin transaction
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Check if user exists
        IF NOT EXISTS (SELECT 1 FROM users WHERE id = @UserId)
        BEGIN
            RAISERROR('User not found', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- If this is set as primary, update all other addresses to non-primary
        IF @IsPrimary = 1
        BEGIN
            UPDATE user_addresses
            SET is_primary = 0
            WHERE user_id = @UserId;
        END
        
        -- Insert new address
        INSERT INTO user_addresses (user_id, address_line, address_type, is_primary, modified_at)
        VALUES (@UserId, @AddressLine, @AddressType, @IsPrimary, GETDATE());
        
        -- Get the new address ID
        DECLARE @NewAddressId INT = SCOPE_IDENTITY();
        
        -- Commit transaction
        COMMIT TRANSACTION;
        
        -- Return success with address details
        SELECT 
            @NewAddressId AS AddressId,
            @UserId AS UserId,
            @AddressLine AS AddressLine,
            @AddressType AS AddressType,
            @IsPrimary AS IsPrimary,
            'Address added successfully' AS Message
        
    END TRY
    BEGIN CATCH
        -- Rollback transaction in case of error
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        -- Return error information
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT @ErrorMessage
    END CATCH
END;
GO


SELECT * FROM user_addresses;

EXEC sp_AddUserAddress 
@UserId = 'USR018',
@AddressLine = '100,gopalpura bypass, Jaipur',
@AddressType = 'Home',
@IsPrimary = 0
-- =================================================================
-- sp_UpdateUserAddress - Update an existing address
-- =================================================================
CREATE OR ALTER PROCEDURE sp_UpdateUserAddress
    @AddressId INT,
    @UserId NVARCHAR(50),
    @AddressLine NVARCHAR(500) = NULL,
    @AddressType NVARCHAR(50) = NULL,
    @IsPrimary BIT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Begin transaction
    BEGIN TRY
    -- Validate input parameters
    IF @AddressId IS NULL OR @UserId IS NULL
    BEGIN
        RAISERROR('Address ID and User ID are required', 16, 1);
        RETURN;
    END
    
        BEGIN TRANSACTION;
        
        -- Check if address exists and belongs to the user
        IF NOT EXISTS (
            SELECT 1 FROM user_addresses 
            WHERE id = @AddressId AND user_id = @UserId
        )
        BEGIN
            RAISERROR('Address not found for this user', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- If this is set as primary, update all other addresses to non-primary
        IF @IsPrimary = 1
        BEGIN
            UPDATE user_addresses
            SET is_primary = 0
            WHERE user_id = @UserId;
        END
        
        -- Update the address
        UPDATE user_addresses
        SET 
            address_line = ISNULL(@AddressLine, address_line),
            address_type = ISNULL(@AddressType, address_type),
            is_primary = ISNULL(@IsPrimary, is_primary),
            modified_at = GETDATE()
        WHERE 
            id = @AddressId AND user_id = @UserId;
        
        -- Commit transaction
        COMMIT TRANSACTION;
        
        -- Return success
        SELECT 
            @AddressId AS AddressId,
            @UserId AS UserId,
            'Address updated successfully' AS Message
        
    END TRY
    BEGIN CATCH
        -- Rollback transaction in case of error
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        -- Return error information
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT @ErrorMessage
    END CATCH
END;
GO


EXEC 

-- =================================================================
-- sp_DeleteUserAddress - Delete a user address
-- =================================================================
CREATE OR ALTER PROCEDURE sp_DeleteUserAddress
    @AddressId INT,
    @UserId NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
     -- Begin transaction
    BEGIN TRY
    -- Validate input parameters
    IF @AddressId IS NULL OR @UserId IS NULL
    BEGIN
        RAISERROR('Address ID and User ID are required', 16, 1);
        RETURN;
    END
    
   
        BEGIN TRANSACTION;
        
        -- Check if address exists and belongs to the user
        IF NOT EXISTS (
            SELECT 1 FROM user_addresses 
            WHERE id = @AddressId AND user_id = @UserId
        )
        BEGIN
            RAISERROR('Address not found for this user', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Check if this is the only address for the user
        DECLARE @AddressCount INT;
        SELECT @AddressCount = COUNT(*) FROM user_addresses WHERE user_id = @UserId;
        
        IF @AddressCount = 1
        BEGIN
            RAISERROR('Cannot delete the only address for a user', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Check if we're deleting the primary address
        DECLARE @IsPrimary BIT;
        SELECT @IsPrimary = is_primary FROM user_addresses WHERE id = @AddressId;
        
        -- Delete the address
        DELETE FROM user_addresses WHERE id = @AddressId AND user_id = @UserId;
        
        -- If we deleted the primary address, make another address primary
        IF @IsPrimary = 1
        BEGIN
            -- Get the ID of any remaining address
            DECLARE @NewPrimaryId INT;
            SELECT TOP 1 @NewPrimaryId = id FROM user_addresses WHERE user_id = @UserId;
            
            -- Make it primary
            IF @NewPrimaryId IS NOT NULL
            BEGIN
                UPDATE user_addresses
                SET is_primary = 1, modified_at = GETDATE()
                WHERE id = @NewPrimaryId;
            END
        END
        
        -- Commit transaction
        COMMIT TRANSACTION;
        
        -- Return success
        SELECT 
            @AddressId AS DeletedAddressId,
            @UserId AS UserId,
            'Address deleted successfully' AS Message
        
    END TRY
    BEGIN CATCH
        -- Rollback transaction in case of error
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        -- Return error information
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT @ErrorMessage
    END CATCH
END;
GO

-- =================================================================
-- sp_GetUserAddresses - Get all addresses for a user
-- =================================================================
CREATE OR ALTER PROCEDURE sp_GetUserAddresses
    @UserId NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
	BEGIN TRY
    -- Validate input parameters
    IF @UserId IS NULL
    BEGIN
        RAISERROR('User ID is required', 16, 1);
        RETURN;
    END
    
    -- Check if user exists
    IF NOT EXISTS (SELECT 1 FROM users WHERE id = @UserId)
    BEGIN
        RAISERROR('User not found', 16, 1);
        RETURN;
    END
    
    -- Get all addresses for the user
    SELECT 
        id AS AddressId,
        user_id AS UserId,
        address_line AS AddressLine,
        address_type AS AddressType,
        is_primary AS IsPrimary,
        modified_at AS LastModified
    FROM 
        user_addresses
    WHERE 
        user_id = @UserId
    ORDER BY 
        is_primary DESC, -- Primary address first
        modified_at DESC;
	END TRY
	BEGIN CATCH
		
		DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
		PRINT @ErrorMessage
	END CATCH
END

EXEC sp_GetUserAddresses @UserId = 'USR19'



SELECT * FROM customers;
SELECT * FROM vendors


SELECT * FROM sys.procedures;