/*
COMP3350 - Advanced Database
Assignment 1 - Stored Procedure - Create an order
Liam Craft		c3339847
Lukas Binninger c3332295
*/

-- Create new customer order

/*
INPUTS: 
customerID 
TVP of items(itemCode, quantity) 
discountCode
orderType
orderDateTime
fulfillmentDateTime
isDelivery
address (if delivery)
paymentApprovalNumber
empNumber (if phone or in-store)

Functionality:
Create new order with input params - ensure tax is calculated at 10% of totalAmountDue
Get the ingredients used in each menu item from ingredient table (through MenuItemIngredientRelation)
Deduct the quantity used to make each item from the suddested current stock level in ingredient table
return the new order number
raise error if there is one???

*/

USE COMP3320_A1_PizzaDB
GO

-- some cleanup
DROP PROCEDURE usp_createCustomerOrder
GO

DROP TYPE ItemsOrderedType
GO

-- set up TVP for items ordered
CREATE TYPE ItemsOrderedType AS TABLE
(
	itemNumber INT,
	quantityOrdered INT,

	PRIMARY KEY (itemNUmber, quantityOrdered)
)
GO

-- create stored procedure to add a customer order
CREATE PROCEDURE usp_createCustomerOrder
	@customerID INT,
	@items ItemsOrderedType READONLY,
	@discountCode VARCHAR(30),
	@type VARCHAR(10),
	@orderDateTime DATETIME,
	@dateTimeOrderNeedsFulfilling DATETIME,
	@dateTimeOrderComplete DATETIME,
	@deliveryMode VARCHAR(8),
	@deliveryAddress VARCHAR(70),
	@paymentConfirmation INT,
	@orderTakeBy INT
AS
BEGIN
	-- declare cursor to access rows of items ordered one by one
	DECLARE myCursor CURSOR
	FOR
		SELECT	*
		FROM	@newRegistrations
	FOR READ ONLY

	-- open and populate cursor
	OPEN myCursor

	-- declare variables to fetch individual rows
	DECLARE @rowStdNo CHAR(5)
	DECLARE @rowCourseID CHAR(8)
	DECLARE @rowSemesterID INT

	FETCH NEXT FROM myCursor INTO @rowStdNo, @rowCourseID, @rowSemesterID

	-- insert row by row from cursor
	-- while still more rows
	WHILE @@FETCH_STATUS = 0
	BEGIN
		BEGIN TRY
			-- insert that row
			INSERT INTO Register (stdNo, courseID, semesterID)
				VALUES (@rowStdNo, @rowCourseID, @rowSemesterID)
		END TRY
		BEGIN CATCH
			DECLARE @error NVARCHAR(120)
			SET @error = ERROR_MESSAGE();
			RAISERROR (@error, 10, 1)
		END CATCH

		-- fetch next row
		FETCH NEXT FROM myCursor INTO @rowStdNo, @rowCourseID, @rowSemesterID
		
	END

	-- close cursor
	CLOSE myCursor

	-- removes the cursor reference
	DEALLOCATE myCursor
END
GO




