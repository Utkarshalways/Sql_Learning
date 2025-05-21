-- Test Case 1: Basic successful execution
-- Setup: Ensure a test user exists
IF NOT EXISTS (SELECT 1 FROM users WHERE id = 'user-test-001')
BEGIN
    INSERT INTO users (id, username) VALUES ('user-test-001', 'testuser');
END

-- Execute with basic parameters
EXEC sp_AddUserAddress 
@UserId = 'USR018',
@AddressLine = '100,gopalpura bypass, Jaipur',
@AddressType = 'Home',
@IsPrimary = 0

-- Test Case 2: Set as primary address
-- This should mark all other addresses as non-primary
EXEC sp_AddUserAddress 
    @UserId = 'user-test-001',
    @AddressLine = '456 Main Avenue, Another City, 67890',
    @AddressType = 'Work',
    @IsPrimary = 1;

-- Verify all other addresses are non-primary
SELECT * FROM user_addresses 
WHERE user_id = 'user-test-001' 
ORDER BY is_primary DESC;
GO

-- Test Case 3: Test default parameter values

EXEC sp_AddUserAddress 
    @UserId = 'user-test-001',
    @AddressLine = '789 Secondary Road, Third City, 54321';

-- Verify the address was added with default values
SELECT TOP 1 * FROM user_addresses 
WHERE user_id = 'user-test-001' AND address_line = '789 Secondary Road, Third City, 54321';
GO

-- Test Case 4: Validation for NULL UserId
BEGIN TRY
    EXEC sp_AddUserAddress 
        @UserId = NULL,
        @AddressLine = '123 Error Street, Error City, 99999';
    
    PRINT 'ERROR: Test failed - procedure did not raise error for NULL UserId';
END TRY
BEGIN CATCH
    PRINT 'SUCCESS: Expected error caught for NULL UserId: ' + ERROR_MESSAGE();
END CATCH
GO

-- Test Case 5: Validation for NULL AddressLine
BEGIN TRY
    EXEC sp_AddUserAddress 
        @UserId = 'user-test-001',
        @AddressLine = NULL;
    
    PRINT 'ERROR: Test failed - procedure did not raise error for NULL AddressLine';
END TRY
BEGIN CATCH
    PRINT 'SUCCESS: Expected error caught for NULL AddressLine: ' + ERROR_MESSAGE();
END CATCH
GO

-- Test Case 6: Non-existent user
BEGIN TRY
    EXEC sp_AddUserAddress 
        @UserId = 'non-existent-user',
        @AddressLine = '123 Missing User Road, Nowhere, 00000';
    
    PRINT 'ERROR: Test failed - procedure did not raise error for non-existent user';
END TRY
BEGIN CATCH
    PRINT 'SUCCESS: Expected error caught for non-existent user: ' + ERROR_MESSAGE();
END CATCH
GO


-- Test Case 8: Multiple addresses for same user
-- Add several addresses and verify all are stored correctly
EXEC sp_AddUserAddress 
    @UserId = 'user-test-001',
    @AddressLine = 'Address 1 for multiple test',
    @AddressType = 'Home',
    @IsPrimary = 0;

EXEC sp_AddUserAddress 
    @UserId = 'user-test-001',
    @AddressLine = 'Address 2 for multiple test',
    @AddressType = 'Work',
    @IsPrimary = 0;

EXEC sp_AddUserAddress 
    @UserId = 'user-test-001',
    @AddressLine = 'Address 3 for multiple test',
    @AddressType = 'Other',
    @IsPrimary = 0;

-- Verify all three addresses were added
SELECT COUNT(*) as MultipleAddressCount FROM user_addresses 
WHERE user_id = 'user-test-001' AND address_line LIKE 'Address % for multiple test';
GO

-- Test Case 9: Transaction rollback verification
-- Create a temp table to track transaction status
CREATE TABLE #TransactionTest (TestStatus NVARCHAR(50));

BEGIN TRY
    BEGIN TRANSACTION;
    
    INSERT INTO #TransactionTest VALUES ('Started');
    
    -- This should fail with a non-existent user
    EXEC sp_AddUserAddress 
        @UserId = 'another-non-existent-user',
        @AddressLine = 'Transaction Test Address';
    
    INSERT INTO #TransactionTest VALUES ('Should not reach here');
    
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    
    INSERT INTO #TransactionTest VALUES ('Caught error and rolled back');
END CATCH

-- Check what happened in our transaction
SELECT * FROM #TransactionTest;
DROP TABLE #TransactionTest;
GO

-- Test Case 10: Cleanup Test Data
-- Delete the test data after running all tests
DELETE FROM user_addresses WHERE user_id = 'user-test-001';
DELETE FROM users WHERE id = 'user-test-001';

-- Verify cleanup was successful
IF NOT EXISTS (SELECT 1 FROM user_addresses WHERE user_id = 'user-test-001')
   AND NOT EXISTS (SELECT 1 FROM users WHERE id = 'user-test-001')
BEGIN
    PRINT 'Test cleanup successful';
END
ELSE
BEGIN
    PRINT 'Test cleanup failed - some test data remains';
END
GO