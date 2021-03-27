/*
COMP3350 - Advanced Database
Assignment 1 - Database Design & Implementation
Liam Craft		c3339847
Lukas Binninger c3332295
*/


-- Section 3: Database Implementation - Database Script

-- 3.1 Create normalised database

-- if the database must be created first
-- create database
USE master
GO

IF EXISTS (SELECT * FROM sysdatabases WHERE name='COMP3320_A1_PizzaDB')
BEGIN
	DROP DATABASE COMP3320_A1_PizzaDB
END
GO

CREATE DATABASE COMP3320_A1_PizzaDB
GO

USE COMP3320_A1_PizzaDB
GO

-- in case you want to use your own database and just add the tables,
-- uncomment the drop table section and comment out the above create database section
-- cleanup: drop tables
/*
DROP TABLE SupplierOrder
DROP TABLE Supplier
DROP TABLE MenuItemIngredientRelation
DROP TABLE Ingredient
DROP TABLE OrderMenuItemRelation
DROP TABLE MenuItem
DROP TABLE Order
DROP TABLE Shift
DROP TABLE EmployeeDeliveryDriver
DROP TABLE EmployeeInShopWorker
DROP TABLE Employee
DROP TABLE Bank
DROP TABLE CustomerPhoneCustomer
DROP TABLE CustomerGuest
DROP TABLE CustomerOnlineCustomer
DROP TABLE Customer
DROP TABLE DiscountProgram
GO
*/

-- create tables

CREATE TABLE DiscountProgram
(
	discountCode VARCHAR(30) NOT NULL,
	description TEXT NOT NULL,
	startDate DATETIME NOT NULL,
	endDate DATETIME NOT NULL,
	requirements TEXT,
	discountPercentage DECIMAL NOT NULL,

	PRIMARY KEY (discountCode),
);
GO

CREATE TABLE Customer
(
	customerID INT IDENTITY(1,1) NOT NULL,
	firstName VARCHAR(30) NOT NULL,
	lastName VARCHAR(30) NOT NULL,
	street VARCHAR(30) NOT NULL,
	suburb VARCHAR(30) NOT NULL,
	postcode INT NOT NULL CHECK (postcode < 10000),

	PRIMARY KEY (customerID),
);
GO

CREATE TABLE CustomerOnlineCustomer
(
	customerID INT NOT NULL,
	email VARCHAR(50) NOT NULL,
	password VARCHAR(50) NOT NULL,
	phone VARCHAR(30),

	PRIMARY KEY (customerID),
	FOREIGN KEY (customerID) REFERENCES Customer(customerID) ON UPDATE CASCADE ON DELETE NO ACTION,
);
GO

CREATE TABLE CustomerGuest
(
	customerID INT NOT NULL,
	email VARCHAR(50) NOT NULL,
	phone VARCHAR(30) NOT NULL,

	PRIMARY KEY (customerID),
	FOREIGN KEY (customerID) REFERENCES Customer(customerID) ON UPDATE CASCADE ON DELETE CASCADE,
);
GO

CREATE TABLE CustomerPhoneCustomer
(
	customerID INT NOT NULL,
	phone VARCHAR(30) NOT NULL,

	PRIMARY KEY (customerID),
	FOREIGN KEY (customerID) REFERENCES Customer(customerID) ON UPDATE CASCADE ON DELETE NO ACTION,
);
GO

CREATE TABLE Bank
(
	bankCode VARCHAR(10) NOT NULL,
	bankName VARCHAR(40) NOT NULL,

	PRIMARY KEY (bankCode),
);
GO

CREATE TABLE Employee
(
	empNumber INT IDENTITY(1,1) NOT NULL,
	firstName VARCHAR(30) NOT NULL,
	lastName VARCHAR(30) NOT NULL,
	street VARCHAR(30) NOT NULL,
	suburb VARCHAR(30) NOT NULL,
	postcode INT CHECK (postcode < 10000),
	contactNumber VARCHAR(30) NOT NULL,
	taxFileNumber VARCHAR(10) NOT NULL,
	bankCode VARCHAR(10) NOT NULL,
	accountNumber INT NOT NULL,
	status VARCHAR(30) NOT NULL,
	description TEXT,

	PRIMARY KEY (empNumber),
	FOREIGN KEY (bankCode) REFERENCES Bank(bankCode) ON UPDATE CASCADE ON DELETE NO ACTION,
);
GO

CREATE TABLE EmployeeInShopWorker
(
	empNumber INT NOT NULL,
	paymentRateHourly SMALLMONEY NOT NULL,

	PRIMARY KEY (empNumber),
	FOREIGN KEY (empNumber) REFERENCES Employee(empNumber) ON UPDATE CASCADE ON DELETE NO ACTION,
);
GO

CREATE TABLE EmployeeDeliveryDriver
(
	empNumber INT NOT NULL,
	driversLicense INT NOT NULL,
	paymentRatePerDelivery SMALLMONEY NOT NULL,

	PRIMARY KEY (empNumber),
	FOREIGN KEY (empNumber) REFERENCES Employee(empNumber) ON UPDATE CASCADE ON DELETE NO ACTION,
);
GO

CREATE TABLE Shift
(
	shiftID INT IDENTITY(1,1) NOT NULL,
	startDateTime DATETIME NOT NULL,
	endDateTime DATETIME NOT NULL,
	numOfDeliveries INT,
	paymentAmount SMALLMONEY,
	paymentSent BIT NOT NULL DEFAULT 0,
	empNumber INT NOT NULL,

	PRIMARY KEY (shiftID),
	FOREIGN KEY (empNumber) REFERENCES Employee(empNumber) ON UPDATE CASCADE ON DELETE NO ACTION,
);
GO

CREATE TABLE FoodOrder
(
	orderID INT IDENTITY(1,1) NOT NULL,
	orderDateTime DATETIME NOT NULL,
	discountAmount SMALLMONEY NOT NULL,
	tax SMALLMONEY NOT NULL,
	totalAmountDue SMALLMONEY NOT NULL,
	status VARCHAR(10) NOT NULL DEFAULT 'processing' CHECK (status IN ('processing', 'complete')),
	description TEXT,
	fulfillmentDateTime DATETIME,
	isDelivery BIT NOT NULL,
	orderType VARCHAR(10) NOT NULL CHECK (orderType IN ('phone', 'online', 'walk-in', 'guest')),
	paymentMethod VARCHAR(10) NOT NULL CHECK (paymentMethod IN ('card', 'cash')),
	paymentApprovalNumber INT,
	discountCode VARCHAR(30),
	customerID INT NOT NULL,
	workerID INT NOT NULL,
	driverID INT,

	PRIMARY KEY (orderID),
	FOREIGN KEY (discountCode) REFERENCES DiscountProgram(discountCode) ON UPDATE CASCADE ON DELETE NO ACTION,
	FOREIGN KEY (customerID) REFERENCES Customer(customerID) ON UPDATE CASCADE ON DELETE NO ACTION,
	-- those two are ultimately coming from the same base table (Employee), which would create two cascading paths. not sure how to fix it apart from this. maybe change employee to one big table with a boolean
	FOREIGN KEY (workerID) REFERENCES Employee(empNumber) ON UPDATE CASCADE ON DELETE NO ACTION,
	FOREIGN KEY (driverID) REFERENCES Employee(empNumber) ON UPDATE NO ACTION ON DELETE NO ACTION,
);
GO

CREATE TABLE MenuItem 
(
	itemCode INT IDENTITY(1,1) NOT NULL,
	name VARCHAR(30) NOT NULL,
	size VARCHAR(6) NOT NULL CHECK (size IN ('small', 'medium', 'large')),
	price SMALLMONEY NOT NULL,

	PRIMARY KEY (itemCode),
);
GO

CREATE TABLE OrderMenuItemRelation 
(
	orderID INT NOT NULL,
	itemCode INT NOT NULL,
	quantity INT NOT NULL,
	subtotal SMALLMONEY NOT NULL,

	PRIMARY KEY (orderID, itemCode),
	FOREIGN KEY (orderID) REFERENCES FoodOrder(orderID) ON UPDATE CASCADE ON DELETE NO ACTION,
	FOREIGN KEY (itemCode) REFERENCES MenuItem(itemCode) ON UPDATE CASCADE ON DELETE NO ACTION,
);
GO

CREATE TABLE Ingredient 
(
	ingrCode INT IDENTITY(1,1) NOT NULL,
	name VARCHAR(30) NOT NULL,
	type VARCHAR(30) NOT NULL,
	description TEXT NOT NULL,
	stockLevel INT NOT NULL,
	dateTimeLastStockTake DATETIME NOT NULL,
	suggestedCurrentStockLevel INT NOT NULL,
	reorderLevel INT NOT NULL,

	PRIMARY KEY (ingrCode),
);
GO

CREATE TABLE MenuItemIngredientRelation 
(
	itemCode INT NOT NULL,
	ingrCode INT NOT NULL,
	quantity INT NOT NULL,

	PRIMARY KEY (itemCode, ingrCode),
	FOREIGN KEY (itemCode) REFERENCES MenuItem(itemCode) ON UPDATE CASCADE ON DELETE NO ACTION,
	FOREIGN KEY (ingrCode) REFERENCES Ingredient(ingrCode) ON UPDATE CASCADE ON DELETE NO ACTION,
);
GO

CREATE TABLE Supplier 
(
	supplierID INT IDENTITY(1,1) NOT NULL,
	supplierName VARCHAR(30) NOT NULL,

	PRIMARY KEY (supplierID),
);
GO

CREATE TABLE SupplierOrder
(
	ingrCode INT NOT NULL,
	supplierID INT NOT NULL,
	dateTime DATETIME NOT NULL,

	PRIMARY KEY (ingrCode, supplierID, dateTime),
	FOREIGN KEY (ingrCode) REFERENCES Ingredient(ingrCode) ON UPDATE CASCADE ON DELETE NO ACTION,
	FOREIGN KEY (supplierID) REFERENCES Supplier(supplierID) ON UPDATE CASCADE ON DELETE NO ACTION,
);
GO


-- 3.2 populate with sufficient sample data
/*
-- some sample so we have a format
INSERT INTO DiscountProgram(discountCode, description, startDate, endDate, requirements, discountPercentage)
VALUES
	-- students
	('Yuji', 'Ishikawa', '69', 'Mint Chocolate Road', 'Fukuoaka', 1504, '+81123123', 'kamikaze@battleship.jp', 'Loves Algorithms'),
	('Liam', 'Craft', '3', 'Under the Bridge', 'Toronto', 1511, '+61123123', 'maurie@mole.com', 'Leader of Barbecue Society'),
	('Ayami', 'Nonaka', '69', 'Mint Chocolate Road', 'Fukuoaka', 1504, '+81321321', 'friedchicken@gmail.jp', 'Leader of Japanese Club'),
	-- staff
	('Nathan', 'Gervasoni', '68', 'Rainbow Road', 'Callaghan', 1212, '+61555666', 'goleo@gmail.com', 'University Mascot'),
	('Healthy', 'Harold', '2', 'Special Street', 'Mayfield', 2304, '+61333222', 'giraffe@gmail.com', 'Health Advisor'),
	('Jeff', 'Jefferson', '1/1A', 'Jeff Drive', 'Jefftown', 3332, '+61444222', 'jeff.jefferson@gmail.com', 'Oldest lecturer at university')
GO


INSERT INTO Customer()
VALUES
	--
	()
GO

INSERT INTO CustomerOnlineCustomer()
VALUES
	--
	()
GO

INSERT INTO CustomerGuest()
VALUES
	--
	()
GO

INSERT INTO CustomerPhoneCustomer()
VALUES
	--
	()
GO

INSERT INTO Bank()
VALUES
	--
	()
GO

INSERT INTO Employee()
VALUES
	--
	()
GO

INSERT INTO EmployeeInShopWorker()
VALUES
	--
	()
GO

INSERT INTO EmployeeDeliveryDriver()
VALUES
	--
	()
GO

INSERT INTO Shift()
VALUES
	--
	()
GO

INSERT INTO Order()
VALUES
	--
	()
GO

INSERT INTO MenuItem() 
VALUES
	--
	()
GO

INSERT INTO OrderMenuItemRelation()
VALUES
	--
	()
GO

INSERT INTO Ingredient()
VALUES
	--
	()
GO

INSERT INTO MenuItemIngredientRelation()
VALUES
	--
	()
GO

INSERT INTO Supplier()
VALUES
	--
	()
GO

INSERT INTO SupplierOrder()
VALUES
	--
	()
GO
*/