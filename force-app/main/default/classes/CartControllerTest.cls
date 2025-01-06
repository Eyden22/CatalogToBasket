/**
 * @Author Eyden Enriquez
 * @Since 2024
 * @Description: Test class for CartController to validate cart and item creation logic
*/
@isTest
public with sharing class CartControllerTest {

    // Test method to validate CartController.saveCartAndItems
    @isTest
    static void testSaveCartAndItems() {
        List<Map<String, Object>> cartItems = new List<Map<String, Object>>();
        
        // Create a test product record to associate with cart items
        Product2 testProduct = new Product2(Name = 'Test Product', Price__c = 25, Quantity__c= 100);
        insert testProduct;
        
        cartItems.add(createCartItem('Product 1', testProduct.Id, 25, 2));

        // Call the saveCartAndItems method to create a cart and items
        CartController.saveCartAndItems(cartItems);

        // Verify that the Cart__c record was created successfully
        List<Cart__c> createdCarts = [SELECT Id, Status__c FROM Cart__c WHERE Status__c = 'Saved'];
        System.assertEquals(1, createdCarts.size(), 'One cart should be created.');
        System.assertEquals('Saved', createdCarts[0].Status__c, 'Cart status should be Saved.');

        // Verify that the Cart_Item__c records were created successfully
        List<Cart_Item__c> createdCartItems = [SELECT Id, Name, Product__c, Unit_Price__c, Quantity__c FROM Cart_Item__c];
        System.assertEquals(1, createdCartItems.size(), 'One cart item should be created.');
        System.assertEquals('Product 1', createdCartItems[0].Name, 'Cart item name should be Product 1.');
        System.assertEquals(testProduct.Id, createdCartItems[0].Product__c, 'Cart item product ID should match.');
        System.assertEquals(25, createdCartItems[0].Unit_Price__c, 'Cart item price should be 25.');
    }

    //  Method to create a cart item map for testing.
    private static Map<String, Object> createCartItem(String name, Id productId, Decimal price, Integer quantity) {
        Map<String, Object> cartItem = new Map<String, Object>();
        cartItem.put('name', name);
        cartItem.put('productId', productId);
        cartItem.put('price', price);
        cartItem.put('quantity', quantity);
        return cartItem;
    }
}
