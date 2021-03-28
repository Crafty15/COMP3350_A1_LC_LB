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
	BEGIN TRANSACTION
		-- test whether order is feasible -> check against ingredient's stock level
		

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
		IF(@discountCode IS NULL)
			SET @discountPercentage = 0
		ELSE
		BEGIN
			SET @discountPercentage = 
				(
					SELECT	discountPercentage
					FROM	DiscountProgram
					WHERE	discountCode = @discountCode
				)
		END
		
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

		------>
		-- add order in order table
		INSERT INTO FoodOrder(orderDateTime, discountAmount, tax, totalAmountDue, status, description, fulfillmentDateTime, completeDateTime, isDelivery,
							  orderType, paymentMethod, paymentApprovalNumber, discountCode, customerID, workerID, driverID)
		VALUES
			(@orderDateTime, @discountAmount, @taxAmount, @totalCost, 'complete', 'something', @dateTimeOrderNeedsFulfilling, @dateTimeOrderComplete, @isDelivery, @type, 'card', @paymentConfirmation, @discountCode, @customerID, @orderTakeBy, @driverID)
	
		-- get back automatically created order id to map to menu items ordered
		DECLARE @orderID INT
		SET @orderID =
			(
				SELECT	orderID
				FROM	FoodOrder
				WHERE	customerID = @customerID
					AND	orderDateTime = @orderDateTime
			)

		------------------

		-- add mapping in OrderMenuItemRelation and update ingredient's suggestedCurrentStockLevel
		-- step through list of items again
		-- open and populate cursor
		OPEN itemCursor

		-- get first row
		FETCH NEXT FROM itemCursor INTO @itemNumber, @quantityOrdered

		-- set up list of ingredients associated with specific item
		DECLARE @ingredientList MenuItemIngredientType

		-- get item by item from cursor
		-- while still more rows
		WHILE @@FETCH_STATUS = 0
		BEGIN
			-- calculate subtotal for that item
			DECLARE @subtotal SMALLMONEY

			SET @itemPrice =
					(
						SELECT	price
						FROM	MenuItem
						WHERE	itemCode = @itemNumber
					)
			SET @subtotal = @itemPrice * @quantityOrdered

			-- insert into table for each item
			INSERT INTO OrderMenuItemRelation(orderID, itemCode, quantity, subtotal)
			VALUES	(@orderID, @itemNumber, @quantityOrdered, @subtotal)

			------------
			-- also for each item, check which ingredients are needed
			-- get all the ingredients mapped to that ordered menu item
			DELETE @ingredientList
			INSERT INTO @ingredientList
					SELECT	ingrCode, quantity
					FROM	MenuItemIngredientRelation
					WHERE	itemCode = @itemNumber

			-- declare cursor to access rows of ingredients of a menuitem one by one
			DECLARE ingredientCursor CURSOR
			FOR
				SELECT	*
				FROM	@ingredientList
			FOR READ ONLY

				-- declare variables to fetch individual rows
				DECLARE @ingrCode INT
				DECLARE @ingrQuantity INT

				-- open and populate cursor
				OPEN ingredientCursor

				-- get first row
				FETCH NEXT FROM ingredientCursor INTO @ingrCode, @ingrQuantity

				-- get ingredient by ingredient from cursor
				-- while still more rows
				WHILE @@FETCH_STATUS = 0
				BEGIN
					-- calculate needed number of ingredients
					DECLARE @stockDecrease INT
					SET @stockDecrease = @ingrQuantity * @quantityOrdered
					
					/*
					PRINT @itemNumber
					PRINT @ingrCode
					PRINT @quantityOrdered
					PRINT @ingrQuantity
					PRINT @stockdecrease
					*/

					-- update ingredient's suggestedCurrentStockLevel
					UPDATE	Ingredient
					SET		suggestedCurrentStockLevel = suggestedCurrentStockLevel - @stockDecrease
					WHERE	ingrCode = @ingrCode

					-- fetch next row
					FETCH NEXT FROM ingredientCursor INTO @ingrCode, @ingrQuantity
				END

				-- close cursor
				CLOSE ingredientCursor

			-- removes the cursor reference
			DEALLOCATE ingredientCursor

			-- fetch next row
			FETCH NEXT FROM itemCursor INTO @itemNumber, @quantityOrdered
		END

		-- close cursor
		CLOSE itemCursor

	COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
			DECLARE @error NVARCHAR(120)
			SET @error = ERROR_MESSAGE();
			RAISERROR (@error, 10, 1)
			PRINT 'Hi Liam'

			
			IF(@@TRANCOUNT > 0)
			BEGIN
				ROLLBACK TRANSACTION
			END

	END CATCH


	-- removes the cursor reference
	DEALLOCATE itemCursor
END
GO




