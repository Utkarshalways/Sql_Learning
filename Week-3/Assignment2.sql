-- QUESTION 4
DECLARE @name VARCHAR(20) = 'sharma, utkarsh'
SELECT @name
SELECT CONCAT(SUBSTRING(@name,CHARINDEX(' ',@name,1),LEN(@name)),' ',SUBSTRING(@name,1,charINDEX(',',@name,1)-1))

-- QUESTION 5

-- QUESTION 6
DECLARE @invoice1 VARCHAR(10) = '--';
DECLARE @invoice2 VARCHAR(10) = NULL;
DECLARE @invoice3 VARCHAR(10) = '10201';
SELECT @invoice1,@invoice2,@invoice3 
SELECT 
CASE 
WHEN TRY_CAST(@invoice1 as int) IS NULL THEN 0.0
ELSE TRY_CAST(@invoice1 as int) END AS invoice1,
CASE 
WHEN TRY_CAST(@invoice2 as int) IS NULL THEN 0.0
ELSE TRY_CAST(@invoice2 as int) END AS invoice2,
CASE 
WHEN TRY_CAST(@invoice3 as int) IS NULL THEN 0.0
ELSE TRY_CAST(@invoice3 as int) END AS invoice3



-- QUESTION 7 


-- QUESTION 8
DECLARE @DATE DATE = '2004-01-04';
SELECT @DATE AS DATE
SELECT DATEDIFF(YEAR,@DATE,GETDATE()) AS AGE

-- QUESTION 9

 

-- QUESTION 10

DECLARE @name VARCHAR(30) = 'joe     doe';
SELECT @name;
SELECT STUFF(REPLACE(TRIM(@name),' ',''),CHARINDEX(' ',trim(@name),0),0,' ')
-- QUESTION 11

SELECT employee_id, salary, effective_date FROM
( SELECT *,
ROW_NUMBER() OVER(PARTITION BY employee_id ORDER BY effective_date desc) 
FROM empDetails
) as RankedRow

-- QUESTION 12
SELECT TOP 1 product_id,review_date,review_text 
FROM products 
WHERE LEN(review_text) = 
(
SELECT MAX(LEN(review_text)) 
FROM products
)


-- QUESTION 13

DECLARE @date_time DATETIME = '2025-04-14 14:00:11'
SELECT @date_time
SELECT FORMAT(@date_time,'hh:mm tt')

-- QUESTION 14
DECLARE @ORDERDate DATE= '2025-04-01'
DECLARE @delivery_date DATE = '2025-04-14'
SELECT CASE
WHEN DATEDIFF(DAY,@ORDERDate,@delivery_date) >= 10 THEN 'MORE THAN 10 DAYS'
ELSE 'LESS THAN 10 DAYS'
END as Result

-- QUESTION 15

SELECT IIF(LOWER('Test@Mail.com') = LOWER('test@mail.com'),'duplicate','NOT duplicate') as DuplicateORNot;