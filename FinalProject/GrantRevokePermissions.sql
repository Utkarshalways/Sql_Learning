CREATE LOGIN VendorUser WITH PASSWORD = 'vendor@123';
CREATE LOGIN CustomerUser WITH PASSWORD = 'customer@123';
 
-- Database users
CREATE USER Vendor_User FOR LOGIN VendorUser;
CREATE USER Customer_User FOR LOGIN CustomerUser;
 
GRANT select, update, delete, insert on user_table to Customer_User
GRANT select, update, delete, insert on customer to Customer_User
GRANT select, update, delete, insert on review to Customer_User
GRANT select, update, delete, insert on wishlist to Customer_User
 
GRANT select, update, delete, insert on user_table to Vendor_User
GRANT select, update, delete, insert on vendor to Vendor_User
GRANT select, update, delete, insert on products to Vendor_User
GRANT select, update, delete, insert on brand to Vendor_User
GRANT select, update, delete, insert on category to Vendor_User
 
 
execute as user='vendor_user'
 
select * from sys.tables
 
revert
 
select CURRENT_USER
 
select * from user_role
 
select * from sys.triggers
select * from sys.views
select * from sys.tables
 
select * from user_log