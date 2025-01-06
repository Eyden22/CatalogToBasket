/**
 * @Author Eyden Enriquez
 * @Since 2024
 * @Description: Apex Class manage functions during cart item insertion/update/deletion
*/
public with sharing class CartItemHandler {

    //Update product's stock according to the quantity of cart items inserted
    public static void updateProductStock(List<Cart_Item__c> newList){
        Map<Id, Integer> productStockChanges = new Map<Id, Integer>();
        List<Product2> productsToUpdate = new List<Product2>();

        for (Cart_Item__c cartItem : newList) {
            if (cartItem.Product__c != null) {
                // For each product save the quantity already saved in the cart
                if (!productStockChanges.containsKey(cartItem.Product__c)) {
                    productStockChanges.put(cartItem.Product__c, (Integer) cartItem.Quantity__c);
                } else {
                    productStockChanges.put(cartItem.Product__c, productStockChanges.get(cartItem.Product__c) + (Integer) cartItem.Quantity__c);
                }
            }
        }

        //Get products
        List<Product2> products = [SELECT Id, Quantity__c FROM Product2 WHERE Id IN :productStockChanges.keySet()];

        //Update product with the new quantity
        for (Product2 prod : products) {
            prod.Quantity__c -= productStockChanges.get(prod.Id);
            productsToUpdate.add(prod);
        }

        if (!productsToUpdate.isEmpty()) {
            update productsToUpdate;
        }
    }
}