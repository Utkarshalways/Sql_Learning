use practice;


create table identitycheck(
id int identity(1,1) PRIMARY KEY,
name varchar(20));


insert into identitycheck values ('utkarsh'),('mohit');

SELECT * from identitycheck

DELETE FROM identitycheck where id = 2

insert into identitycheck values ('harsh')

SELECT @@IDENTITY AS LastIdentityValue;  -- same session and same scope

SELECT SCOPE_IDENTITY() AS LastIdentityValue; -- same session any scope

SELECT IDENT_CURRENT('identitycheck')  -- any session any scope


/* We can use the Current Identity as the LastIdentityValue to generate a unique id
 and that is being showed to the user. */

/* For Example every UPI transaction has a unique number which is generated and it
 can be generated through the identity and can be return through this to the system and can be used later if required */