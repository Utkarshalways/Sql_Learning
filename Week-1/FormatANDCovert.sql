-- DATE Styles 


-- Using Convert Functions :--

SELECT CONVERT(varchar,GETDATE(),101);
-- according to usa standards mm-dd-yyyy

SELECT CONVERT (varchar,GETDATE(),103);
-- according to British Standards dd-mm-yyyy

SELECT CONVERT (VARCHAR,GETDATE(),112);
-- according to international Standards yyyymmdd

SELECT CONVERT(VARCHAR,GETDATE(),120);
-- According to ODBC (Open Database Connectivity) Standards yyyy-MM-dd hh-mm-ss


-- using FORMAT Functions :--

SELECT FORMAT(GETDATE(),'dd-MM-yyyy')

SELECT FORMAT(GETDATE(),'MM-dd-yyyy')

SELECT FORMAT(GETDATE(),'yyyy-MM-dd')

SELECT Format (GETDATE(),'dd-MM-yyyy    hh:mm:ss');
