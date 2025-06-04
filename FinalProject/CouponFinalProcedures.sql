CREATE OR ALTER PROCEDURE sp_GetAllAvailableCoupons
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @DefaultOrderAmount DECIMAL(18,2) = 1000; -- Adjust this as needed

    SELECT 
        c.id AS CouponId,
        c.code AS CouponCode,
        c.description,
        c.discount_type,
        c.discount_value,
        c.min_order_value,
        c.max_discount_amount,
        c.start_date,
        c.end_date,
        c.is_active,
        c.usage_limit,
        c.usage_count,
        CASE 
            WHEN c.discount_type = 'PERCENTAGE' THEN 
                IIF(c.max_discount_amount IS NOT NULL AND (@DefaultOrderAmount * c.discount_value / 100) > c.max_discount_amount,
                    c.max_discount_amount,
                    ROUND(@DefaultOrderAmount * c.discount_value / 100, 2)
                )
            ELSE 
                IIF(c.discount_value > @DefaultOrderAmount, @DefaultOrderAmount, c.discount_value)
        END AS EstimatedDiscountAmount
    FROM coupons c
    WHERE 
        c.is_active = 1
        AND GETDATE() BETWEEN c.start_date AND c.end_date
        AND (c.usage_limit IS NULL OR c.usage_count < c.usage_limit)
    ORDER BY c.start_date DESC;
END;
GO
