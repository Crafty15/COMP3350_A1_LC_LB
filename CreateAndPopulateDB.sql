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
--ALTER DATABASE COMP3350_A1_PizzaDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
--GO

IF EXISTS (SELECT * FROM sysdatabases WHERE name='COMP3350_A1_PizzaDB')
BEGIN
	DROP DATABASE COMP3350_A1_PizzaDB
END
GO

CREATE DATABASE COMP3350_A1_PizzaDB
GO

USE COMP3350_A1_PizzaDB
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
	address VARCHAR(70) NOT NULL,

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
	UNIQUE (email),
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
	status VARCHAR(30) NOT NULL CHECK (status IN ('active', 'onLeave', 'onProbation', 'inactive')) DEFAULT 'active',
	description TEXT,

	PRIMARY KEY (empNumber),
	UNIQUE (taxFileNumber),
	UNIQUE (bankCode, accountNumber),
	UNIQUE (firstName, lastName, street, suburb, postcode),
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
	UNIQUE (driversLicense),
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
	UNIQUE (empNumber, startDateTime, endDateTime),
	FOREIGN KEY (empNumber) REFERENCES Employee(empNumber) ON UPDATE CASCADE ON DELETE NO ACTION,
);
GO

CREATE TABLE FoodOrder
(
	orderID INT IDENTITY(1,1) NOT NULL,
	orderDateTime DATETIME NOT NULL,
	discountAmount SMALLMONEY NOT NULL DEFAULT 0.00,
	tax SMALLMONEY NOT NULL,
	totalAmountDue SMALLMONEY NOT NULL,
	status VARCHAR(10) NOT NULL CHECK (status IN ('processing', 'complete')) DEFAULT 'processing' ,
	description TEXT,
	fulfillmentDateTime DATETIME,
	completeDateTime DATETIME,
	isDelivery BIT NOT NULL,
	orderType VARCHAR(10) NOT NULL CHECK (orderType IN ('phone', 'online', 'walk-in', 'guest')),
	paymentMethod VARCHAR(10) NOT NULL CHECK (paymentMethod IN ('card', 'cash')),
	paymentApprovalNumber INT,
	discountCode VARCHAR(30),
	customerID INT NOT NULL,
	workerID INT NOT NULL,
	driverID INT,

	PRIMARY KEY (orderID),
	UNIQUE (orderDateTime, customerID),
	UNIQUE (orderDateTime, workerID),
	FOREIGN KEY (discountCode) REFERENCES DiscountProgram(discountCode) ON UPDATE CASCADE ON DELETE NO ACTION,
	FOREIGN KEY (customerID) REFERENCES Customer(customerID) ON UPDATE CASCADE ON DELETE NO ACTION,
	-- sql server sees there are two cascading paths which MIGHT create a cycle. won't test whether it actually creates one.
	FOREIGN KEY (workerID) REFERENCES EmployeeInShopWorker(empNumber) ON UPDATE CASCADE ON DELETE NO ACTION,
	FOREIGN KEY (driverID) REFERENCES EmployeeDeliveryDriver(empNumber) ON UPDATE NO ACTION ON DELETE NO ACTION,
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

-- some sample so we have a format
INSERT INTO DiscountProgram(discountCode, description, startDate, endDate, requirements, discountPercentage)
VALUES
	('E2021', 'Easter weekend sale', '2021-03-02 08:00:00', '2021-03-04 21:59:59', 'none', 50.00),
	('Thurs2021', 'Hungry Thursdays', '2021-01-01 08:00:00', '2021-12-31 21:59:59', 'Only on Thursdays!', 25.00),
	('Sept2021', 'September memorial sale', '2021-09-11 08:00:00', '2021-09-11 21:59:59', 'none', 69.00),
	('nov2021', 'Liams birthday sale', '2021-11-15 08:00:00', '2021-09-11 21:59:59', 'none', 42.00),
	('oct2021', 'OctoberFest', '2021-10-01 08:00:00', '2021-10-08 21:59:59', 'In store customers only. Must greet server in Deutsche', 80.00)
GO


INSERT INTO Customer(firstName, lastName, address)
VALUES
	('Cleetus', 'McFarlane', '123 Redneck St, Daytona 5432'),
	('Phil', 'McCrackin', '89 First St, Boolaroo 2284'),
	('Steph', 'Smith', '1 Hill Rd, Lambton 2267'),
	('Jill', 'Qwerty', '222 School Rd, Newcastle 1123'),
	('Fred', 'Fredson', '67 Test St, TestTown 4444'),
	('Hayden', 'Milkson', '567 Latte rd, Ourimbah 3211')
GO

INSERT INTO CustomerOnlineCustomer(customerID, email, password, phone)
VALUES
	(1, 'cleetus@email.com', 'samplePW', '0404123123'),
	(2, 'legend@email.com', 'mydogsname', '(02)49753344'),
	(6, 'Haydo@soybeans.com', 'noswearing', '0411009009'),
	(5, 'dogecoin@email.com', 'toTheMoon', '0499321321')
GO

INSERT INTO CustomerGuest(customerID, email, phone)
VALUES
	(3, 'steph@email.com', '0412345345')
GO

INSERT INTO CustomerPhoneCustomer(customerID, phone)
VALUES
	(4, '0404998877')
GO

INSERT INTO Bank(bankCode, bankName)
VALUES
	('666334', 'Bank of Newcastle'),
	('444123', 'Callghan Building Society')
GO

--NOTE: default status is used for employee
INSERT INTO Employee(firstName, lastName, street, suburb, postcode, contactNumber, taxFileNumber, bankCode, accountNumber, description)
VALUES
	('Yuji', 'Ishikawa', '25 Lambton Rd', 'Lambton', 3345, '0404998877', '1234567890', '666334', 111112300, 'The man from Japan'),
	('Lukas', 'Binninger', '12 LearningLounge Rd', 'Auchmuty', 2243, '0452123123', '1234567666', '444123',111222300, 'Specialty: Schnitzel supreme pizza'),
	('Liam', 'Craft', '86 SeydaNeen St', 'Morrowind', 1111, '0499000111', '1234567000', '666334', 111333300, 'Permanent mop duties'),
	('Nathan', 'Gervasoni', '112 Mamamia Drive', 'MarioLand', 2222, '0455654654', '1234567111', '444123', 111444300, 'Actually Italian')
GO

INSERT INTO EmployeeInShopWorker(empNumber, paymentRateHourly)
VALUES
	(1, 22.00),
	(4, 22.00)
GO

INSERT INTO EmployeeDeliveryDriver(empNumber, driversLicense, paymentRatePerDelivery)
VALUES
	(2, 555222, 5.00),
	(3, 555888, 5.00)
GO

INSERT INTO Shift(startDateTime, endDateTime, numOfDeliveries, paymentAmount, paymentSent, empNumber)
VALUES
	('2021-03-01 08:00:00','2021-03-01 20:00:00', 15, 75.00, 1, 2),
	('2021-03-01 08:00:00','2021-03-01 20:00:00', 13, 65.00, 1, 3),
	('2021-03-01 08:00:00','2021-03-01 20:00:00', null, 176.00, 1, 1),
	('2021-03-01 08:00:00','2021-03-01 20:00:00', null, 176.00, 1, 4)
GO

INSERT INTO FoodOrder(orderDateTime, discountAmount, tax, totalAmountDue, status, description, fulfillmentDateTime, completeDateTime, isDelivery,
				orderType, paymentMethod, paymentApprovalNumber, discountCode, customerID, workerID, driverID)
VALUES
	('2021-01-01 11:00:00', 10.00, 8.00, 50.12, 'complete', 'All pinapple', '2021-01-01 11:15:11', '2021-01-01 11:10:11', 0, 'phone', 'card', 021, 'oct2021', 4, 4, null),
	('2021-02-11 09:00:00', 00.00, 2.00, 18.58, 'complete', 'Vegan', '2021-02-01 09:15:55', '2021-02-01 09:10:55', 1, 'online', 'cash', null, null, 6, 1, 2),
	('2021-02-11 13:00:00', 15.00, 12.00, 133.50, 'complete', 'Gluten free', '2021-02-01 13:15:55', '2021-02-01 13:10:55', 0, 'walk-in', 'card', 003, 'nov2021', 3, 1, null),
	('2021-03-01 10:00:00', 12.00, 2.00, 66.50, 'complete', 'All pepperoni', '2021-03-01 10:15:55', '2021-03-01 10:10:55', 1, 'guest', 'card', 002, 'Thurs2021', 3, 1, 3),
	('2021-03-01 08:00:00', 20.00, 05.00, 40.00, 'complete', 'Extra cheese', '2021-03-01 09:30:00', '2021-03-01 09:30:00', 1, 'online', 'card', 001, 'E2021', 1, 4, 2),
	(SYSDATETIME(), 00.00, 10.00, 100.00, DEFAULT, 'No nuts plz', SYSDATETIME(), null, 0, 'phone', 'cash', null, null, 4, 1, null),
	('2021-03-28 17:22:00', 5.00, 10.00, 60.00, DEFAULT, 'Extra banana', '2021-03-28 17:42:00', null, 1, 'guest', 'cash', null, 'Sept2021', 1, 4, null),
	(SYSDATETIME(), 11.00, 10.00, 110.00, DEFAULT, 'No toppings', SYSDATETIME(), null, 0, 'walk-in', 'cash', null,'Sept2021', 1, 4, null)
GO

INSERT INTO MenuItem(name, size, price) 
VALUES
	('Vegan', 'large', 35.00),
	('Vegan', 'medium', 25.00),
	('Vegan', 'small', 15.00),
	('Vegetarian', 'large', 11.00),
	('Vegetarian', 'medium', 9.00),
	('Vegetarian', 'small', 8.00),
	('Meat eater', 'large', 16.00),
	('Meat eater', 'medium', 13.00),
	('Meat eater', 'small', 11.00),
	('Hawaiian', 'large', 15.00),
	('Hawaiian', 'medium', 12.00),
	('Hawaiian', 'small', 10.00)
GO

INSERT INTO OrderMenuItemRelation(orderID, itemCode, quantity, subtotal)
VALUES
	(5, 12, 4, 40.00),
	(4, 9, 4, 44.00),
	(4, 11, 3, 33.00),
	(3, 1, 4, 140),
	(2, 6, 1, 08.00),
	(2, 9, 1, 11.00),
	(1, 2, 2, 50.00),
	(1, 6, 1, 08.00)
GO

INSERT INTO Ingredient(name, type, description, stockLevel, dateTimeLastStockTake, suggestedCurrentStockLevel, reorderLevel)
VALUES
	('pizza dough', 'baking', 'Bulk pizza dough, ready to roll and bake', 25, '2021-01-01 11:00:00',25, 2),
	('mozzarella', 'dairy', 'Bulk mozzarella', 25, '2021-01-01 11:00:00',25, 2),
	('pepperoni', 'cured meats', 'Bulk pepperoni', 50, '2021-01-01 11:00:00', 40, 8),
	('vegetables', 'fresh produce', 'bulk vegetables already prepared for toppings', 8, '2021-01-01 11:00:00', 6, 2),
	('pinapple', 'fresh produce', 'tins of pinapple chunks', 10, '2021-01-01 11:00:00', 6, 2)
GO

INSERT INTO MenuItemIngredientRelation(itemCode, ingrCode, quantity)
VALUES
	(1, 1, 3),
	(1, 4, 3),
	(1, 5, 3),
	(2, 1, 2),
	(2, 4, 2),
	(2, 5, 2),
	(3, 1, 1),
	(3, 4, 1),
	(3, 5, 1),
	(4, 1, 3),
	(4, 2, 3),
	(4, 4, 3),
	(5, 1, 2),
	(5, 2, 2),
	(5, 4, 2),
	(6, 1, 1),
	(6, 2, 1),
	(6, 4, 1),
	(7, 1, 3),
	(7, 2, 3),
	(7, 3, 3),
	(8, 1, 2),
	(8, 2, 2),
	(8, 3, 2),
	(9, 1, 1),
	(9, 2, 1),
	(9, 3, 1),
	(10, 1, 3),
	(10, 2, 3),
	(10, 3, 3),
	(11, 1, 2),
	(11, 2, 2),
	(11, 3, 3),
	(12, 1, 3),
	(12, 2, 3),
	(12, 3, 3)
GO

INSERT INTO Supplier(supplierName)
VALUES
	('Dingleberries fruit'),
	('Mr Meats'),
	('Doughboys'),
	('Pams produce')
GO

INSERT INTO SupplierOrder(ingrCode, supplierID, dateTime)
VALUES
	(1, 3, '2020-12-01 11:00:00'),
	(2, 4, '2020-12-01 11:00:00'),
	(3, 2, '2020-12-01 11:00:00'),
	(4, 4, '2020-12-01 11:00:00'),
	(5, 1, '2020-12-01 11:00:00'),
	(1, 3, '2021-12-01 11:00:00'),
	(2, 4, '2021-12-01 11:00:00'),
	(3, 2, '2021-12-01 11:00:00'),
	(4, 4, '2021-12-01 11:00:00'),
	(5, 1, '2021-12-01 11:00:00')
GO


-- set up some TVPs we need
DROP TYPE ItemsOrderedType
GO
DROP TYPE MenuItemIngredientType
GO

-- set up TVP for items ordered
CREATE TYPE ItemsOrderedType AS TABLE
(
	itemNumber INT,
	quantityOrdered INT,

	PRIMARY KEY (itemNumber, quantityOrdered)
)
GO

-- set up TVP for list of menuItem - ingredients mapping
CREATE TYPE MenuItemIngredientType AS TABLE
(
	ingrCode INT,
	quantity INT,

	PRIMARY KEY (ingrCode, quantity)
)
GO