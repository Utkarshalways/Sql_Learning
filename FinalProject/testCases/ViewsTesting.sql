SELECT * FROM dbo.vw_AbandonedCarts;


SELECT * FROM vw_ActiveShoppingCarts

SELECT * FROM vw_CategoryPerformance WHERE parent_category_name IS NOT NULL

SELECT * FROM vw_CategoryRevenue  WHERE parent_category_name IS NOT NULL;

SELECT * FROM vw_CustomerDemographics

SELECT * FROM vw_GeographicalSales;

SELECT * FROM vw_LowStockProducts;

SELECT * FROM vw_OrderInvoices;

SELECT * FROM vw_OrdersByCustomer;

SELECT * FROM vw_OrdersByVendor;

SELECT TOP 4 * FROM vw_PopularProducts;

SELECT * FROM vw_ProductCategories

SELECT * FROM vw_ProductDetails

SELECT TOP 10 * FROM vw_ProductRevenue

SELECT * FROM vw_productReview;

SELECT * FROM vw_ProductsWithInventory

SELECT * FROM vw_TopCustomers;

SELECT * FROM vw_TopRatedProducts;

SELECT * FROM vw_VendorPerformance;

SELECT * FROM vw_VendorProducts
