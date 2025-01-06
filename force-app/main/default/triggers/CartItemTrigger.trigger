trigger CartItemTrigger on Cart_Item__c (after insert) {
    CartItemHandler.updateProductStock(Trigger.new);
}