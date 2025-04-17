create table data (
id int ,
Name varchar(20),
phn_number int
);
 
insert into data 
values
(1,'Rydam',941),
(2,'Arpit',885),
(3,'Naman',875),
(3,'Naman',875),
(3,'Naman',875),
(2,'Arpit',885); 

CREATE VIEW NOTDELETETHESE AS
SELECT id,
ROW_NUMBER() OVER (PARTITION BY id ORDER BY id) AS rn
FROM data

SELECT * FROM NOTDELETETHESE

DELETE FROM NOTDELETETHESE 
WHERE rn >= 2

SELECT * FROM DATA