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

	PRIMARY KEY (itemNumber, quantityOrdered)
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
	-- create order in order table
	BEGIN TRY
		DECLARE @discountPercentage DECIMAL
		SET @discountPercentage = 
			(
				SELECT	discountPercentage
				FROM	DiscountProgram
				WHERE	discountCode = @discountCode
			)



		INSERT INTO FoodOrder(orderDateTime, discountAmount, tax, totalAmountDue, status, description, fulfillmentDateTime, completeDateTime, isDelivery,
				orderType, paymentMethod, paymentApprovalNumber, discountCode, customerID, workerID, driverID)
		VALUES
			(@orderDateTime, 10.00, 8.00, 50.12, 'complete', 'something', @dateTimeOrderNeedsFulfilling, '2021-01-01 11:10:11', 0, 'phone', 'card', 021, @discountCode, 4, 4, null),
	END TRY
	BEGIN CATCH
			DECLARE @error NVARCHAR(120)
			SET @error = ERROR_MESSAGE();
			RAISERROR (@error, 10, 1)
	END CATCH


	-- declare cursor to access rows of items ordered one by one
	DECLARE itemCursor CURSOR
	FOR
		SELECT	*
		FROM	@items
	FOR READ ONLY

	-- open and populate cursor
	OPEN itemCursor

	-- declare variables to fetch individual rows
	DECLARE @itemNumber INT
	DECLARE @quantityOrdered INT

	FETCH NEXT FROM itemCursor INTO @itemNumber, @quantityOrdered

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
		FETCH NEXT FROM itemCursor INTO @rowStdNo, @rowCourseID, @rowSemesterID
		
	END

	-- close cursor
	CLOSE itemCursor

	-- removes the cursor reference
	DEALLOCATE itemCursor
END
GO




