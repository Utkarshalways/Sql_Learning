-- Test Case 1: Successful Authentication with Email
EXEC sp_AuthenticateUser
@email_or_phone = 'lakshyaSharma@gmail.com',@password = 'lakshya123'

-- Test Case 2: Successful Authentication with Phone Number
EXEC sp_AuthenticateUser  
    @email_or_phone = '9431343226', 
    @password = 'lakshya123';
GO

SELECT * FROM users WHERE phone_number LIKE '9431343226'



-- Test Case 3: Invalid Password

    EXEC sp_AuthenticateUser  
        @email_or_phone = 'john.doe@example.com', 
        @password = 'wrongpassword';
GO

-- Test Case 4: Non-Existent Email

    EXEC sp_AuthenticateUser  
        @email_or_phone = 'nonexistent@example.com', 
        @password = 'password123';


-- Test Case 5: Non-Existent Phone Number

    EXEC sp_AuthenticateUser  
        @email_or_phone = '0000000000', 
        @password = 'password123';


-- Test Case 6: Empty Email/Phone Number

    EXEC sp_AuthenticateUser  
        @email_or_phone = '', 
        @password = 'password123';


-- Test Case 7: Empty Password
    EXEC sp_AuthenticateUser  
        @email_or_phone = 'john.doe@example.com', 
        @password = '';


-- Test Case 8: SQL Injection Attempt

    EXEC sp_AuthenticateUser  
        @email_or_phone = 'john.doe@example.com; DROP TABLE users;', 
        @password = 'password123';

