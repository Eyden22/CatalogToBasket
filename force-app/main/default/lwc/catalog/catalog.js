import { LightningElement, wire, track } from 'lwc';
import getAccessToken from '@salesforce/apex/Utils.getAccessToken';
import { API_URL } from 'c/utils';
import { showToast } from 'c/utils';


export default class Catalog extends LightningElement {
    @track products;
    selectedProduct;
    isLoading = true;
    isModalOpen = false;

    connectedCallback() {
        //Add listener to update product according to the cart item changes
        window.addEventListener('updatecatalog', this.handleUpdateCatalog.bind(this));
    }

    // ------------Functions to get/create/edit/delete products-----------
    //Get the access token  
    @wire(getAccessToken)
        wiredAccessToken({ error, data }) {
            if (data) {
                this.accessToken = data;
                sessionStorage.setItem('accessToken', this.accessToken); //save access token
                this.fetchProducts();  
            } else if (error) {
                showToast(this, 'Error', 'Failed to retrieve access token', 'error');
            }
    }

    // Retrieve available products from SF
    fetchProducts = async () => {
        if (!sessionStorage.getItem('accessToken')) {
            showToast(this, 'Error', 'Access token is missing', 'error');
            return;
        }
        try {
            const response = await fetch(API_URL, {
                method: 'GET',
                headers: {
                    'Authorization': `Bearer ${sessionStorage.getItem('accessToken')}`,
                    'Content-Type': 'application/json',
                },
            });

            if (!response.ok) { // Check if response is OK 
                showToast(this, 'Error', 'Failed to fetch the products', 'error');
                return;
            }

            const data = await response.json(); //Get response content into json
            if (data.status === 'error') { // Check if the API returned an error
                showToast(this, 'Error', `Failed to fetch products ${data.message}`, 'error');
            } 
            else { // Success
                this.products = data;
                this.isLoading = false;
            }
        } 
        catch (error) { // Catch any errors
            showToast(this, 'Error', `Error fetching products ${error.message}`, 'error');
        }
    };

    // Create/Update Product from SF
    upsertProducts = async (newProduct) => {
        try {
            const response = await fetch(API_URL, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${sessionStorage.getItem('accessToken')}`,
                },
                body: JSON.stringify(newProduct), // Convert data to JSON
            });

            if (!response.ok) { // Check if response is OK 
                showToast(this, 'Error', 'Failed to create/update the product', 'error');
                return;
            }

            const data = await response.json(); // Get response content into json
            if (data.status === 'success') {
                await this.fetchProducts(); //Retieve available products after adding/modifying product
                showToast(this, 'Success', 'Product successfully added/modified!', 'success');
            } 
            else {
                showToast(this, 'Error', data.message, 'error');
            }
        } 
        catch (error) { // Catch any errors
            showToast(this, 'Error', error.message, 'error');
        }
    };

    // Remove product from SF
    removeProduct = async (productId) => {
        try {
            const response = await fetch(`${API_URL}/${productId}`, {
                method: 'DELETE',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${sessionStorage.getItem('accessToken')}`,
                },
            });

            if (!response.ok) { //Check if response is OK 
                showToast(this, 'Error', 'Failed to delete the product', 'error');
                return;
            }

            const data = await response.json(); // Get response content into json
            if (data.status === 'success') {
                await this.fetchProducts(); //Retieve available products after deleting product
                 showToast(this, 'Success', 'Product successfully deleted!', 'success');
            } 
            else {
                showToast(this, 'Error', data.message, 'error');
            }
        } catch (error) { // Catch any errors
            showToast(this, 'Error', `Error deleting product: ${error.message}`, 'error');
        }
    };

    // ------------ Update/delete cart functions-----------
    //On click on 'add to cart' button - notify the basket and update stock
    addToCart = (event) => {
        const productId = event.target.dataset.id;
        const quantity = this.template.querySelector(`input[data-id="${productId}"]`).value;
        const product = this.getProductById(productId);

        // Trigger an event to change the product in the basket (according to the product's changes)
        this.notifyBasket(productId, quantity, product.Name, product.Price, product.Quantity, true, false);

        //Update quantity available for this product
        this.updateQuantityInStock(product, quantity);
    }

    //On click on X icon - remove product from SF and update the basket
    removeProductFromCatalog = (event) => {
        const productId = event.target.dataset.id; //Retrieve the product Id to delete
        const product = this.getProductById(productId);

        //Delete product in Salesforce
        this.removeProduct(productId);

        // Trigger an event to delete the product in the basket (if exists)
        this.notifyBasket(productId, 0, product.Name, product.Price, product.Quantity, true, true);

    }

    // Check if the quantity choosen <= quantity's product
    restrictInput = (event) => {
        const input = event.target;
        const productId = input.dataset.id;
        const maxQuantity = this.getProductById(productId).Quantity;

        if (parseInt(input.value) > maxQuantity) {
            input.value = maxQuantity; // Limit to maximum quantity of product
        }
    }

    // ------------Modal functions-----------
    //Open modal
    openModal = () => {
        this.isModalOpen = true;
    }

    // Close modal
    closeModal = () => {
        this.isModalOpen = false;
        this.selectedProduct = {};
    }

    //On click on edit icon - open the modal 
    editProduct = (event) => {
        const productId = event.target.dataset.id;
        this.selectedProduct = this.getProductById(productId);
        this.selectedProduct.Id = productId; //Add product Id to upsert the product
        this.openModal();
    }

    //On click on save button (in the modal) - upsert product and update cart items
    handleProductAdd = (event) => {
        const newProduct = event.detail;
        
        //Upsert product in the catalog
        this.upsertProducts(newProduct);

        // Trigger an event to add the product to basket
        this.notifyBasket(newProduct.Id, 0, newProduct.Name, newProduct.Price, newProduct.Quantity, false, false);
    }

    // ------------Help functions-----------
    //Update Quantity in stock according to quantity choosen
    updateQuantityInStock = (product, quantityChoosen) => {
        product.Quantity -= quantityChoosen;
    }
        
    // Get a product by Id
    getProductById = (productId) => {
        return this.products.find(product => product.Id === productId);
    }

    notifyBasket = (productId, quantity,name, price, quantityInStock, pushToBasket, isRemoved) => {
        this.dispatchEvent(new CustomEvent('notifybasket', {
            detail: { productId : productId, 
                      quantity : quantity, 
                      name : name,
                      price : price, 
                      quantityInStock : quantityInStock,
                      pushToBasket : pushToBasket,
                      isRemoved : isRemoved 
                    }
        }));
    }
    
    //Update quantity on product after quantity changed in the cart item
    handleUpdateCatalog = (event) => {
        const { productId, quantityChange } = event.detail;

        // Update quantity for a product
        this.products = this.products.map(product => {
            if (product.Id === productId) {
                product.Quantity += quantityChange; // Adjust quantity
            }
            return product;
        });
    }
}