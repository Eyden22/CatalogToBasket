import { LightningElement, track } from 'lwc';

export default class shoppingContainer extends LightningElement {
    @track
    cartItems = [];  

    // Handles notify basket by adding/updating/deleting items in cart
    handleNotifyBasket = (event) => {
        const { productId, quantity, name, price, quantityInStock, pushToBasket, isRemoved } = event.detail;

        // Find the existing product in the cart
        const existingIndex = this.cartItems.findIndex(item => item.productId === productId);

        if (existingIndex !== -1 && isRemoved) {
            // Remove the product from the cart if it exists and is flagged for removal
            this.cartItems.splice(existingIndex, 1);
            return;
        }

        //If the product we update doesn't exist in the cart ==> no changes need
        if (existingIndex === -1 && !pushToBasket) {
            return;
        }

        if (existingIndex !== -1) {
            // Update the existing product in the cart
            const existingItem = this.cartItems[existingIndex];
            existingItem.quantity += parseInt(quantity, 10);
            existingItem.price = price || existingItem.price; // Update price if provided
            existingItem.name = name || existingItem.name;   // Update name if provided
        } 
        else {
            // Add a new product to the cart
            this.cartItems.push({
                productId,
                name,
                price,
                quantity: parseInt(quantity),
                quantityInStock: parseInt(quantityInStock),
            });
        }
    }


    //Update cart item in the basket and update catalog if removed
    handleUpdateCart = (event) =>{
        const { productId, quantity, isRemoved } = event.detail;
        if (isRemoved) { //The item is removed
            // Delete the item from the basket
            this.cartItems = this.cartItems.filter(item => item.productId !== productId);

            //Update quantity in catalog
            const updateCatalogEvent = new CustomEvent('updatecatalog', {
                detail: { productId, quantityChange: quantity },
                bubbles: true, // Allows the event to propagate up through the hierarchy. 
                composed: true // Allows the event to cross Shadow DOM boundaries.
            });
        
            this.dispatchEvent(updateCatalogEvent);
        }
        else { //The item is updated
            this.cartItems = this.cartItems.map(item =>
                item.productId === productId ? { ...item, quantity: quantity } : item
            );
        }
    }
}