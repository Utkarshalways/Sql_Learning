use MyDatabase;

SELECT * from sys.tables
				

-- Domain Integrity Constraints

CREATE TABLE Employees(
	empId INT PRIMARY KEY,
	name VARCHAR(40),
	age INT CHECK (age BETWEEN 18 AND 64), -- Restricts the age between 18 and 65
	email VARCHAR(100) UNIQUE 
	);

	INSERT INTO Employees VALUES(1,'utkarsh',22,'utkarsh.sharma@intimetec.com');

	SELECT * FROM Employees;

	DROP TABLE Employees;


	-- Entity Integrity Constraints

	INSERT INTO Employees VALUES(1,'utkarsh',22,'utkarsh.sharma@intimetec.com');

	INSERT INTO Employees VALUES(2,'Jainam',22,'jainam.jain@intimetec.com');
	 
	 -- It will throw Error as the empId(Primary Key) is same for utkarsh and jainam 


	 -- REFERENTIAL INTERGRITY CONSTRAINT
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    Name VARCHAR(50)
	);

INSERT INTO Customers VALUES (1,'utkarsh'),(2,'Sumit'),(3,'Harsh');

SELECT * FROM Customers

CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT NOT NULL,
    OrderDate DATE,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID) -- Ensures valid reference
);

INSERT INTO Orders VALUES (1,1,'2025-03-26');
SELECT * FROM Orders;
INSERT INTO Orders VALUES (2,3,'2025-01-01'); -- WILL GIVE ERROR 

-- CustomerID is not present in the Customers TABLE
DROP TABLE Customers;
DROP TABLE Orders;


-- 4. Unique Constraint (Ensuring Unique Emails)
CREATE TABLE Users (
    UserID INT PRIMARY KEY,
    Email VARCHAR(100) UNIQUE, -- Prevents duplicate emails
    Username VARCHAR(50) UNIQUE -- Prevents duplicate usernames
);

INSERT INTO Users (UserID, Email, Username) VALUES (1, 'user1@example.com', 'user1');

SELECT * FROM Users

INSERT INTO Users (UserID, Email, Username) VALUES (2, 'user2@example.com', 'user2');

DROP TABLE Users;



-- 5. Not Null Constraint

CREATE TABLE Employees_NotNull (
    EmployeeID INT PRIMARY KEY,
    Name VARCHAR(50) NOT NULL, -- Name cannot be NULL
    Salary DECIMAL(10,2) NOT NULL -- Salary must have a value
);

INSERT INTO Employees_NotNull (EmployeeID, Name, Salary) VALUES (1, 'Bob', 12000);


-- 6. Check Constraint (Salary Must be Greater than 0)
CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    Name VARCHAR(50),
    Price DECIMAL(10,2) CHECK (Price > 0) -- Price must be positive
);

INSERT INTO Products (ProductID, Name, Price) VALUES (1, 'Laptop', 1200);



