import { LightningElement, api, track } from 'lwc';
import saveCartAndItems from '@salesforce/apex/CartController.saveCartAndItems';
import { showToast } from 'c/utils';


export default class Basket extends LightningElement {
    @api cartItems = [];  
    @api products = []; 
    @track isSaving = false;

    //Calculate the total price dynamically
    get totalPrice() {
        return this.cartItems.reduce((total, item) => total + (item.price * item.quantity), 0).toFixed(2);
    }

    //Check if the basket contains items
    get basketIsEmpty() {
        return this.cartItems.length == 0;
    }

    //Remove product from basket
    removeFromCart = (event) => {
        const productId = event.target.dataset.id;
        const quantity = this.cartItems.find(item => item.productId === productId)?.quantity || 0;
      
        // Remove item from the basket
        const removeEvent = new CustomEvent('updatecart', {
            detail: { productId, quantity, isRemoved: true }

        });

        this.dispatchEvent(removeEvent);
    }

    //Update quantity's cart item and product catalog when quantity changed
    handleQuantityChange = (event) => {
        const productId = event.target.dataset.id;
        const newQuantity = parseInt(event.target.value);
    
        // Find cart item index (in the array)
        const itemIndex = this.cartItems.findIndex(item => item.productId === productId);
        const oldQuantity = this.cartItems[itemIndex].quantity;
        const quantityDifference = oldQuantity - newQuantity;

        // Check if the item isn't found OR the quantity isn't valid
        const isValidQuantity = !isNaN(newQuantity) && newQuantity >= 0 && newQuantity <= this.cartItems[itemIndex].quantityInStock;
        if (itemIndex === -1 || !isValidQuantity ) {
            showToast(this, 'Error', 'Please enter a valid quantity', 'errror');
            return;
        }

        // Update quantity in the basket
        this.dispatchEvent(new CustomEvent('updatecart', {
            detail: { productId, quantity: newQuantity, isRemoved: false }

        }));

        // Update product quantity in  catalog
        this.dispatchEvent(new CustomEvent('updatecatalog', {
            detail: { productId, quantityChange: quantityDifference },
            bubbles: true, // Allows the event to propagate up through the hierarchy. 
            composed: true // Allows the event to cross Shadow DOM boundaries.
        }));
    }    

    //On click on save button
    handleSaveCart = () => {
        if (this.isSaving) return; //Prevent multiple selection on the save button
        this.isSaving = true; // Deactivate the save button

        if (this.cartItems.length === 0) {
            showToast(this, 'Error', 'Your basket is empty. Please add products before saving.', 'errror');
            return;
        }
        this.createCart();
    }

    //Create Cart and items in Salesforce
    createCart = async () => {
        try {
            await saveCartAndItems({ cartItems : this.cartItems });
            showToast(this, 'Success', 'The cart was created successfully', 'success');
            this.cartItems = []; //Empty basket 
        } 
        catch (error) {
            showToast(this, 'Error', `Error saving cart: ${error}`, 'error')
        }
    }
}