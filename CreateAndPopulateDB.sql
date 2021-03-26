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
	discountCode INT IDENTITY(1,1) NOT NULL,

	PRIMARY KEY (discountCode),
);
GO

CREATE TABLE Customer
(
	
);
GO

CREATE TABLE CustomerOnlineCustomer
(
	
);
GO

CREATE TABLE CustomerGuest
(
	
);
GO

CREATE TABLE CustomerPhoneCustomer
(
	
);
GO

CREATE TABLE Bank
(
	
);
GO

CREATE TABLE Employee
(
	
);
GO

CREATE TABLE EmployeeInShopWorker
(
	
);
GO

CREATE TABLE EmployeeDeliveryDriver
(
	
);
GO

CREATE TABLE Shift
(
	
);
GO

CREATE TABLE Order
(
	
);
GO

CREATE TABLE MenuItem 
(
	
);
GO

CREATE TABLE OrderMenuItemRelation 
(
	
);
GO

CREATE TABLE Ingredient 
(
	
);
GO

CREATE TABLE MenuItemIngredientRelation 
(
	
);
GO

CREATE TABLE Supplier 
(
	
);
GO

CREATE TABLE SupplierOrder
(
	
);
GO


-- 3.2 populate with sufficient sample data

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
