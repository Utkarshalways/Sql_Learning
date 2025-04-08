-- use of Cast and Convert Functions

-- CAST FUNCTIONS

SELECT CAST('123.1253' AS DECIMAL(5,2));

SELECT CAST (1233 AS VARCHAR);

SELECT CAST (N'👍🤘✌️' AS NVARCHAR);

-- CONVERT FUNCTIONS

SELECT CONVERT(VARCHAR,1234);

SELECT CONVERT(DECIMAL(10,2),'11232.123');

SELECT CONVERT(NVARCHAR,N'🤞');

SELECT CONVERT (VARCHAR,GETDATE(),103);


/* 
Convert Functions are much better option than the cast functions as it also allows the date format to change but only in MsSql
*/

/*
 CAST is part of the ANSI standard and works across different SQL systems, while CONVERT is specific to SQL Server.
 */

 /*
CAST functions can be used when straight forward as they are platform independent and whereas the convert functions are used in date format and there syntax is easy as compare to CAST Functions
 */