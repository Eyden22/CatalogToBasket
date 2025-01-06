/**
 * @Author Eyden Enriquez
 * @Since 2024
 * @Description: Web Service to manage products
*/
@RestResource(urlMapping='/product/*')
global with sharing class ProductService {

    @HttpGet
    global static void doGet() {

        //Get query params & path param
        String productId = RestContext.request.requestURI.substringAfter('/product/');
        String catalogName = RestContext.request.params.get('catalogName');

        //Format the response to JSON
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(ProductServiceHelper.getProducts(productId, catalogName));
    }

    @HttpPost
    global static void doPost() {

        // Parse JSON body
        Map<String, Object> body = (Map<String, Object>) JSON.deserializeUntyped(RestContext.request?.requestBody?.toString());

        //Format the response to JSON
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(ProductServiceHelper.createOrUpdateProduct(body));
    }

    @HttpDelete
    global static void doDelete() {
        
        // Get path param
        String productId = RestContext.request.requestURI.substringAfter('/product/');

        //Format the response to JSON
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(ProductServiceHelper.deleteProduct(productId));
    }
}