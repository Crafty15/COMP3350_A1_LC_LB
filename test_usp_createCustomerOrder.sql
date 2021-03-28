/*
COMP3350 - Advanced Database
Assignment 1 - Stored Procedure - Test Script
Liam Craft		c3339847
Lukas Binninger c3332295
*/

USE COMP3350_A1_PizzaDB
GO

-- create variables to hold input data for stored procedure
DECLARE @someCustomerID INT
DECLARE	@someItems ItemsOrderedType
DECLARE	@someDiscountCode VARCHAR(30)
DECLARE	@someType VARCHAR(10)
DECLARE	@someOrderDateTime DATETIME
DECLARE	@someDateTimeOrderNeedsFulfilling DATETIME
DECLARE	@someDateTimeOrderComplete DATETIME
DECLARE	@someDeliveryMode VARCHAR(8)
DECLARE	@someDeliveryAddress VARCHAR(70)
DECLARE	@somePaymentConfirmation INT
DECLARE	@someOrderTakeBy INT

-- #1
-- should be feasible
	-- add some data
	SET @someCustomerID = 1
	DELETE FROM @someItems
	INSERT INTO @someItems
		VALUES
		(1, 2)
	SET	@someDiscountCode = NULL
	SET	@someType = 'online'
	SET	@someOrderDateTime = '2021-03-28 20:08:00'
	SET	@someDateTimeOrderNeedsFulfilling = '2021-03-28 20:08:00'
	SET	@someDateTimeOrderComplete = '2021-03-28 20:38:00'
	SET	@someDeliveryMode = 'delivery'
	SET	@someDeliveryAddress = '123 Street, Lambton, 2299'
	SET	@somePaymentConfirmation = 69
	SET	@someOrderTakeBy = 1

	-- run stored procedure
	EXECUTE usp_CreateCustomerOrder @customerID = @someCustomerID, @items = @someItems, @discountCode = @someDiscountCode, @type = @someType,
									@orderDateTime = @someOrderDateTime, @dateTimeOrderNeedsFulfilling = @someDateTimeOrderNeedsFulfilling,
									@dateTimeOrderComplete = @someDateTimeOrderComplete, @deliveryMode = @someDeliveryMode, @deliveryAddress = @someDeliveryAddress,
									@paymentConfirmation = @somePaymentConfirmation, @orderTakeBy = @someOrderTakeBy

-- #2
-- should not be feasible after #1
	-- add some data
	SET @someCustomerID = 1
	DELETE FROM @someItems
	INSERT INTO @someItems
		VALUES
		(1, 2)
	SET	@someDiscountCode = 'E2021'
	SET	@someType = 'online'
	SET	@someOrderDateTime = '2021-03-28 20:18:00'
	SET	@someDateTimeOrderNeedsFulfilling = '2021-03-28 20:18:00'
	SET	@someDateTimeOrderComplete = '2021-03-28 20:48:00'
	SET	@someDeliveryMode = 'pickup'
	SET	@someDeliveryAddress = NULL
	SET	@somePaymentConfirmation = 70
	SET	@someOrderTakeBy = 1

	-- run stored procedure
	EXECUTE usp_CreateCustomerOrder @customerID = @someCustomerID, @items = @someItems, @discountCode = @someDiscountCode, @type = @someType,
									@orderDateTime = @someOrderDateTime, @dateTimeOrderNeedsFulfilling = @someDateTimeOrderNeedsFulfilling,
									@dateTimeOrderComplete = @someDateTimeOrderComplete, @deliveryMode = @someDeliveryMode, @deliveryAddress = @someDeliveryAddress,
									@paymentConfirmation = @somePaymentConfirmation, @orderTakeBy = @someOrderTakeBy

-- #3
-- should be feasible
	-- add some data
	SET @someCustomerID = 1
	DELETE FROM @someItems
	INSERT INTO @someItems
		VALUES
		(9, 1),
		(12, 2)
	SET	@someDiscountCode = 'Sept2021'
	SET	@someType = 'walk-in'
	SET	@someOrderDateTime = SYSDATETIME()
	SET	@someDateTimeOrderNeedsFulfilling = NULL
	SET	@someDateTimeOrderComplete = SYSDATETIME()
	SET	@someDeliveryMode = 'pickup'
	SET	@someDeliveryAddress = NULL
	SET	@somePaymentConfirmation = 71
	SET	@someOrderTakeBy = 1

	-- run stored procedure
	EXECUTE usp_CreateCustomerOrder @customerID = @someCustomerID, @items = @someItems, @discountCode = @someDiscountCode, @type = @someType,
									@orderDateTime = @someOrderDateTime, @dateTimeOrderNeedsFulfilling = @someDateTimeOrderNeedsFulfilling,
									@dateTimeOrderComplete = @someDateTimeOrderComplete, @deliveryMode = @someDeliveryMode, @deliveryAddress = @someDeliveryAddress,
									@paymentConfirmation = @somePaymentConfirmation, @orderTakeBy = @someOrderTakeBy

-- #4
-- should be invalid data: type is not one of the possible values
	-- add some data
	SET @someCustomerID = 1
	DELETE FROM @someItems
	INSERT INTO @someItems
		VALUES
		(9, 1),
		(12, 2)
	SET	@someDiscountCode = 'Sept2021'
	SET	@someType = 'Cody'
	SET	@someOrderDateTime = SYSDATETIME()
	SET	@someDateTimeOrderNeedsFulfilling = NULL
	SET	@someDateTimeOrderComplete = SYSDATETIME()
	SET	@someDeliveryMode = 'pickup'
	SET	@someDeliveryAddress = NULL
	SET	@somePaymentConfirmation = 71
	SET	@someOrderTakeBy = 1

	-- run stored procedure
	EXECUTE usp_CreateCustomerOrder @customerID = @someCustomerID, @items = @someItems, @discountCode = @someDiscountCode, @type = @someType,
									@orderDateTime = @someOrderDateTime, @dateTimeOrderNeedsFulfilling = @someDateTimeOrderNeedsFulfilling,
									@dateTimeOrderComplete = @someDateTimeOrderComplete, @deliveryMode = @someDeliveryMode, @deliveryAddress = @someDeliveryAddress,
									@paymentConfirmation = @somePaymentConfirmation, @orderTakeBy = @someOrderTakeBy

GO