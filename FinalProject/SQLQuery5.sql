CREATE TRIGGER trg_alert_low_stock
ON inventory
AFTER UPDATE
AS
BEGIN
    INSERT INTO alerts (product_id, alert_type, message)
    SELECT i.product_id, 'Low Stock', 
           'Stock for product ' + p.name + ' is critically low (' + CAST(i.quantity_in_stock AS NVARCHAR) + ' units).'
    FROM inserted i
    JOIN products p ON i.product_id = p.id
    WHERE i.quantity_in_stock < 3;
END;


SELECT * FROM products;