import { LightningElement, api } from 'lwc';

export default class ModalComponent extends LightningElement {
    @api isOpen = false;
    @api header = '';
    error = '';
    _product;
    isDisabled = false;

    productFields = {
        Name: '',
        Description: '',
        Price: '',
        Quantity: '',
        Id: ''
    };

    @api
    get product() {
        return this._product;
    }

    set product(value) {
        this._product = value;
        this.updateProductFields();
    }

    // Open modal
    @api
    openModal() {
        this.error = '';
        this.isOpen = true;
    }

    // Update modal's fields with fields' product
    updateProductFields = () => {
        if (this._product) {
            this.productFields = {
                Name: this._product.Name || '',
                Description: this._product.Description || '',
                Price: this._product.Price || '',
                Quantity: this._product.Quantity || '',
                Id: this._product.Id || ''
            };
        }
    }

    // Close modal
    closeModal = () => {
        this.dispatchEvent(new CustomEvent('close'));
    }

    // Called when any change is done
    handleInputChange = (event) => {
        const field = event.target.dataset.field;
        this.productFields[field] = event.target.value;
        this.error = ''; // Reset error
    }

    // Save the product
    saveProduct = () => {
        if (this.isFormValid()) {
            const { Name, Description, Price, Quantity, Id } = this.productFields;

            this.dispatchEvent(new CustomEvent('productadd', {
                detail: {
                    Id: Id || null, 
                    Name,
                    Description,
                    Price: parseFloat(Price),
                    Quantity: parseInt(Quantity, 10),
                }
            }));

            this.closeModal();
        }
    }

    // Check form validity
    isFormValid = () => {
        const { Name, Description, Price, Quantity } = this.productFields;
        if (!Name || !Description || !Price || !Quantity) {
            this.error = 'Please fill all fields.';
            return false;
        }
        return true;
    }
}
