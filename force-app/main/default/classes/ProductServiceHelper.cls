/**
 * @Author Eyden Enriquez
 * @Since 2024
 * @Description: Helper class for handling operations related to products, including retrieval, creation, update, and deletion.
*/
public with sharing class ProductServiceHelper {

    // Return products list (Optional - By Id/Category Name)
    public static String getProducts(String productId, String catalogName) {
        try {
            //Build query
            String query = 'SELECT Id, Name, Description, Quantity__c, Price__c FROM Product2 WHERE Catalog__c != null AND Quantity__c > 0 ';

            if (!String.isEmpty(productId))
                query += 'AND Id = :productId ';
            if (catalogName != null)
                query += 'AND Catalog__r.Name = :catalogName ';
    
            List<Product2> products = Database.query(query);
            
            //Construct response
            List<Map<String, Object>> productList = new List<Map<String, Object>>();
            for (Product2 p : products) 
                productList.add(fillProductDetails(p));

            return JSON.serialize(productList);
        } 
        catch (Exception e) {
            return createErrorResponse('Error retrieving products: ' + e.getMessage());
        }
    }

    //Create or Update product
    public static String createOrUpdateProduct(Map<String, Object> body) {
        try {
            //Get catalog Id by default
            Id catalogId = [SELECT Id FROM Catalog__c WHERE Name = 'SuperMarket'].Id;

            // Extract data
            String productId = (String) body.get('Id'); 
            String catalog = (String) body.get('Catalog');
            String name = (String) body.get('Name');
            String description = (String) body.get('Description');
            Decimal price = (Decimal) body.get('Price');
            Integer quantity = (Integer) body.get('Quantity');

            // Create/update product
            Product2 product = new Product2();
            product.Catalog__c = catalogId;
            if (name != null) product.Name = name;
            if (description != null) product.Description = description;
            if (price != null) product.Price__c = price;
            if (quantity != null)  product.Quantity__c = quantity;
            //In the case of an update
            if (productId != null) product.Id = productId;

            upsert product; 
            return createSuccessResponse('Product upserted successfully', product.Id);
        } 
        catch (Exception e) {
            return createErrorResponse(e.getMessage());
        }
    }

    // Delete product
    public static String deleteProduct(String productId) {
        try {
            delete new Product2 (Id = productId);
            return createSuccessResponse('Product deleted successfully', productId);
        }
        catch (Exception e) {
            return createErrorResponse('Error deleting products: ' + e.getMessage());
        }
    }

    //Fill products' details
    private static Map<String, Object> fillProductDetails(Product2 p) {
        Map<String, Object> productMap = new Map<String, Object>();
        productMap.put('Id', p.Id);
        productMap.put('Name', p.Name);
        productMap.put('Description', p.Description);
        productMap.put('Price', p.Price__c);
        productMap.put('Quantity', p.Quantity__c);
        return productMap;
    }

    // Sucess Response
    private static String createSuccessResponse(String message, Id productId) {
        return JSON.serialize(new Map<String, Object>{
            'status' => 'success',
            'message' => message,
            'productId' => productId
        });
    }

    // Error response
    private static String createErrorResponse(String message) {
        return JSON.serialize(new Map<String, Object>{
            'status' => 'error',
            'message' => message
        });
    }
}