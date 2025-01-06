import { ShowToastEvent } from 'lightning/platformShowToastEvent';

//Endpoint to get/create/update/delete products
export const API_URL = 'https://resourceful-badger-9pqdgs-dev-ed.trailblaze.my.salesforce.com/services/apexrest/product';

//Display error/success toast
export function showToast (component, title, message, variant) {
    component.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        }));
    }
