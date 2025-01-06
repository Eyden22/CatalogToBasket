/**
 * @Author Eyden Enriquez
 * @Since 2024
 * @Description: Test Class for CartItemHandler methods
*/
@isTest
public with sharing class CartItemHandlerTest {

    // Test method to validate CartItemHandler.updateProductStock
    @isTest
    static void testUpdateProductStock() {
        
        // Create test Product records
        Product2 product1 = new Product2(Name = 'Product 1', Quantity__c = 100);
        Product2 product2 = new Product2(Name = 'Product 2', Quantity__c = 50);
        insert new List<Product2>{product1, product2};

        //Create Cart__c record
        Cart__c cart = new Cart__c();
        insert cart;

        // Create test Cart_Item__c records
        Cart_Item__c cartItem1 = new Cart_Item__c(Cart__c = cart.Id, Product__c = product1.Id, Quantity__c = 10);
        Cart_Item__c cartItem2 = new Cart_Item__c(Cart__c = cart.Id, Product__c = product2.Id, Quantity__c = 5);
        insert new List<Cart_Item__c>{cartItem1, cartItem2};

        // Reload products to check stock changes
        product1 = [SELECT Quantity__c FROM Product2 WHERE Id = :product1.Id];
        product2 = [SELECT Quantity__c FROM Product2 WHERE Id = :product2.Id];

        // Assert product stock is updated correctly
        System.assertEquals(90, product1.Quantity__c, 'Product 1 stock should be decreased by 10');
        System.assertEquals(45, product2.Quantity__c, 'Product 2 stock should be decreased by 5');
    }
}
