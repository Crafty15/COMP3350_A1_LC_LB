--ASS1 3050, stored proc
/*
Create new customer order

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

