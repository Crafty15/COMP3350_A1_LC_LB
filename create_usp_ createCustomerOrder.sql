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

DROP PROCEDURE usp_createCustomerOrder
GO

DROP TYPE usp_createCustomerOrder
GO




