/**
 * @Author Eyden Enriquez
 * @Since 2024
 * @Description: Apex Class to create cart and it's items
*/
public with sharing class CartController {

    //Create Cart and CartItems with the details given
    @AuraEnabled
    public static void saveCartAndItems(List<Map<String,Object>> cartItems) {
        List<Cart_Item__c> cartItemRecords = new List<Cart_Item__c>();
       
        try {
            // Create the Cart__c record
            Cart__c cart = new Cart__c(Status__c = 'Saved');
            insert cart;

            //Create Cart Items List
            for (Map<String,Object> cartItem : cartItems) {
                Cart_Item__c cartItemToInsert = new Cart_Item__c();
                //Fill cart item fields
                cartItemToInsert.Cart__c = cart.Id;
                cartItemToInsert.Name = (String) cartItem.get('name');
                cartItemToInsert.Product__c = (Id) cartItem.get('productId');
                cartItemToInsert.Unit_Price__c = (Decimal) cartItem.get('price');
                cartItemToInsert.Quantity__c = (Decimal) cartItem.get('quantity');

                cartItemRecords.add(cartItemToInsert);
            }

            //Insert Cart Items
            if (!cartItemRecords.isEmpty()) {
                    insert cartItemRecords;
            }
        }
        catch (Exception e) {
            throw new AuraHandledException('An error occured by inserting Cart and items ' + e.getMessage());
        }
    }
}
