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
	-- create order in order table, add entries in order menuItem table and decrease stock level in ingredients
	BEGIN TRY

		-- declare cursor to access rows of items ordered one by one
		DECLARE itemCursor CURSOR
		FOR
			SELECT	*
			FROM	@items
		FOR READ ONLY

		-- declare variables to fetch individual rows
		DECLARE @itemNumber INT
		DECLARE @quantityOrdered INT

		-- calculate total price of order
			DECLARE @totalCost SMALLMONEY
			SET @totalCost = 0

			-- open and populate cursor
			OPEN itemCursor

			-- get first row
			FETCH NEXT FROM itemCursor INTO @itemNumber, @quantityOrdered

			DECLARE @itemPrice SMALLMONEY

			-- get item by item from cursor
			-- while still more rows
			WHILE @@FETCH_STATUS = 0
			BEGIN
				-- get the price for each item, multiply with quantity and add it to total
				SET @itemPrice =
					(
						SELECT	price
						FROM	MenuItem
						WHERE	itemCode = @itemNumber
					)
				SET @totalCost = @totalCost + (@itemPrice * @quantityOrdered)

				-- fetch next row
				FETCH NEXT FROM itemCursor INTO @itemNumber, @quantityOrdered
			END

			-- close cursor
			CLOSE itemCursor

		
		-- calcluate discount
		DECLARE @discountPercentage DECIMAL
		SET @discountPercentage = 
			(
				SELECT	discountPercentage
				FROM	DiscountProgram
				WHERE	discountCode = @discountCode
			)
		DECLARE @discountAmount SMALLMONEY
		SET @discountAmount = @discountPercentage/100 * @totalCost

		-- calculate tax
		DECLARE @taxAmount SMALLMONEY
		SET @taxAmount = 0.1 * @totalCost

		-- check whether is delivery
		DECLARE @isDelivery BIT
		DECLARE @driverID INT
		IF(@deliveryMode = 'delivery')
		BEGIN
			SET @isDelivery = 1
			SET @driverID = 2
		END
		ELSE
		BEGIN
			SET @isDelivery = 0
			SET @driverID = NULL
		END

		----------------------------
		-- add order in order table
		INSERT INTO FoodOrder(orderDateTime, discountAmount, tax, totalAmountDue, status, description, fulfillmentDateTime, completeDateTime, isDelivery,
							  orderType, paymentMethod, paymentApprovalNumber, discountCode, customerID, workerID, driverID)
		VALUES
			(@orderDateTime, @discountAmount, @taxAmount, @totalCost, 'complete', 'something', @dateTimeOrderNeedsFulfilling, @dateTimeOrderComplete, @isDelivery, @type, 'card', @paymentConfirmation, @discountCode, @customerID, @orderTakeBy, @driverID)
	
		-- get back automatically created order id to map to menu items ordered
		DECLARE @orderID INT
		SET @orderID =
			(
				SELECT	*
				FROM	FoodOrder
				WHERE	customerID = @customerID
					AND	orderDateTime = @orderDateTime
			)

		--


	END TRY
	BEGIN CATCH
			DECLARE @error NVARCHAR(120)
			SET @error = ERROR_MESSAGE();
			RAISERROR (@error, 10, 1)
	END CATCH


	-- removes the cursor reference
			DEALLOCATE itemCursor
END
GO




