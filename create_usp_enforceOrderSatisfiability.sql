/*
COMP3350 - Advanced Database
Assignment 1 - Stored Procedure - enforceOrderSatisfiability
Liam Craft		c3339847
Lukas Binninger c3332295
*/

--Enforce order satisfiability

/*
TVP - menu items
for each item
	how many ingredient for each item?
	is assumed stock level - ingredient number > 0?
	no - return false
	yes- return true
*/

USE COMP3350_A1_PizzaDB
GO

DROP PROCEDURE usp_enforceOrderSatisfiability
GO

--Stored procedure to enforce order satisfiability
CREATE PROCEDURE usp_enforceOrderSatisfiability
	--input params
	@itemList ItemsOrderedType READONLY,
	-- output parameters
	@isFeasible BIT OUTPUT
AS
BEGIN
		SET @isFeasible = 1

		-- declare cursor to access rows of items ordered one by one
        DECLARE itemCursor CURSOR
        FOR
            SELECT    *
            FROM    @itemList
        FOR READ ONLY

        -- declare variables to fetch individual rows
        DECLARE @itemNumber INT
        DECLARE @quantityOrdered INT
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

					-- get suggested curretn stock level for ingredient
					DECLARE @suggestedCurrentStockLevel INT
					SET @suggestedCurrentStockLevel =
						(
							SELECT	i.suggestedCurrentStockLevel
							FROM	Ingredient i
							WHERE	i.ingrCode = @ingrCode
						)

					-- check if order can be satisfied
					IF(@stockDecrease > @suggestedCurrentStockLevel)
					BEGIN
						-- close cursor and remove reference
						CLOSE ingredientCursor
						DEALLOCATE ingredientCursor
						--return 0 as result is false (= one item infeasible to produce)
						SET @isFeasible = 0
						RETURN 0
					END

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

		-- close cursor and remove reference
		CLOSE itemCursor
		DEALLOCATE itemCursor

		--return 1 as result is true (= feasible)
		RETURN 1
END
GO

