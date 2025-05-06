-- CustomerProfileView - Customer information for user profiles
CREATE OR ALTER VIEW vw_CustomerProfile AS
SELECT 
    u.id AS UserID,
    u.name AS CustomerName,
    u.email AS Email,
    u.phone_number AS PhoneNumber,
    u.gender AS Gender,
    u.DateOfBirth AS DateOfBirth,
    u.country AS Country,
    c.id AS CustomerID,
    c.paymentDetails AS PaymentDetails,
    c.age AS Age,
    c.address AS Address,
    c.pinCode AS PinCode,
    COUNT(DISTINCT o.id) AS TotalOrders,
    SUM(o.total_amount) AS TotalSpent
FROM 
    users u
    INNER JOIN customers c ON u.id = c.userId
    LEFT JOIN orders o ON u.id = o.user_id
WHERE 
    u.user_type = 'customer'
GROUP BY 
    u.id, u.name, u.email, u.phone_number, u.gender, u.DateOfBirth, u.country,
    c.id, c.paymentDetails, c.age, c.address, c.pinCode;
GO

SELECT * FROM vw_CustomerProfile;



SELECT * FROM users;
-- PRODUCT reviews VIEW

CREATE VIEW vw_productReview AS
SELECT 
	r.id as reviewID,
	r.rating as productRating,
	r.comment as Comment,
	r.review_date as reviewDate,
	p.id as productId,
	p.name as productName,
	u.id as userId,
	u.name as userName

	FROM reviews r 
	INNER JOIN products p ON r.product_id = p.id
	INNER JOIN users u ON r.user_id = u.id


SELECT * FROM vw_productReview;



CREATE OR ALTER VIEW vw_VendorProfile AS
SELECT 
    u.id AS UserID,
    u.name AS VendorName,
    u.email AS Email,
    u.phone_number AS PhoneNumber,
    v.id AS VendorID,
    v.address AS Address,
    v.pinCode AS PinCode,
    v.GSTnumber AS GSTNumber,
    COUNT(DISTINCT p.id) AS TotalProducts,
    SUM(i.quantity_in_stock) AS TotalInventory
FROM 
    users u
    INNER JOIN vendors v ON u.id = v.userId
    LEFT JOIN products p ON v.id = p.vendor_id
    LEFT JOIN inventory i ON p.id = i.product_id
WHERE 
    u.user_type = 'vendor'
GROUP BY 
    u.id, u.name, u.email, u.phone_number, v.id, v.address, v.pinCode, v.GSTnumber;
GO


WITH CategoryCTE AS (
    SELECT 
        id,
        name,
        parent_category_id,
        0 AS Level,
        CAST(name AS NVARCHAR(MAX)) AS Hierarchy
    FROM 
        categories
    WHERE 
        parent_category_id IS NULL
    
    UNION ALL
    
    SELECT 
        c.id,
        c.name,
        c.parent_category_id,
        cte.Level + 1,
        CAST(cte.Hierarchy + ' > ' + c.name AS NVARCHAR(MAX))
    FROM 
        categories c
        INNER JOIN CategoryCTE cte ON c.parent_category_id = cte.id
)
SELECT 
    id AS CategoryID,
    name AS CategoryName,
    parent_category_id AS ParentCategoryID,
    Level AS HierarchyLevel,
    Hierarchy AS CategoryPath
FROM 
    CategoryCTE;
SELECT *  FROM sys.tables;

SELECT * FROM products;
SELECT * FROM categories;

SELECT * FROM reviews;
SELECT * FROM users;

