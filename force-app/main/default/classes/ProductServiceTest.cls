/**
 * @Author Eyden Enriquez
 * @Since 2024
 * @Description: Test for ProductService Web Service
*/
@IsTest
public with sharing class ProductServiceTest {

    // Test data setup
    @TestSetup
    static void setupTestData() {
        // Create a Catalog
        Catalog__c catalog = new Catalog__c(Name = 'SuperMarket');
        insert catalog;

        // Create some Products
        List<Product2> products = new List<Product2>{
            new Product2(Name = 'Product A', Description = 'Description A', Price__c = 10.5, Quantity__c = 100, Catalog__c = catalog.Id),
            new Product2(Name = 'Product B', Description = 'Description B', Price__c = 20.0, Quantity__c = 50, Catalog__c = catalog.Id)
        };
        insert products;
    }

    // Test for GET method
    @IsTest
    static void testDoGet() {
        Test.startTest();
        // Mock the request
        RestContext.request = new RestRequest();
        RestContext.request.requestURI = '/services/apexrest/product';
        RestContext.request.httpMethod = 'GET';
        RestContext.response = new RestResponse();

        // Call the service
        ProductService.doGet();

        // Assert the response
        String responseBody = RestContext.response.responseBody.toString();
        System.assert(responseBody.contains('Product A'), 'Response should contain Product A');
        System.assert(responseBody.contains('Product B'), 'Response should contain Product B');
        Test.stopTest();
    }

    // Test for POST method
    @IsTest
    static void testDoPost() {
        Test.startTest();
        // Mock the request
        RestContext.request = new RestRequest();
        RestContext.request.requestURI = '/services/apexrest/product';
        RestContext.request.httpMethod = 'POST';

        Map<String, Object> requestBody = new Map<String, Object>{
            'Name' => 'New Product',
            'Description' => 'New Description',
            'Price' => 15,
            'Quantity' => 75
        };
        RestContext.request.requestBody = Blob.valueOf(JSON.serialize(requestBody));
        RestContext.response = new RestResponse();

        // Call the service
        ProductService.doPost();

        // Assert the response
        String responseBody = RestContext.response.responseBody.toString();
        System.assert(responseBody.contains('success'), 'Response should indicate success');
        Test.stopTest();
    }

    // Test for DELETE method
    @IsTest
    static void testDoDelete() {
        // Retrieve an existing product
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];

        Test.startTest();
        // Mock the request
        RestContext.request = new RestRequest();
        RestContext.request.requestURI = '/services/apexrest/product/' + product.Id;
        RestContext.request.httpMethod = 'DELETE';
        RestContext.response = new RestResponse();

        // Call the service
        ProductService.doDelete();

        // Assert the response
        String responseBody = RestContext.response.responseBody.toString();
        System.assert(responseBody.contains('success'), 'Response should indicate success');
        System.assertEquals(0, [SELECT COUNT() FROM Product2 WHERE Id = :product.Id], 'Product should be deleted');
        Test.stopTest();
    }

    // Test for error handling in DELETE with invalid Id
    @IsTest
    static void testDoDeleteErrorHandling() {
         // Retrieve an existing catalog
        Catalog__c catalog = [SELECT Id FROM Catalog__c LIMIT 1];

        Test.startTest();
        // Mock the request with an invalid catalog name
        RestContext.request = new RestRequest();
        RestContext.request.requestURI = '/services/apexrest/product/ ' + catalog.Id;
        RestContext.request.httpMethod = 'DELETE';
        RestContext.response = new RestResponse();

        // Call the service
        ProductService.doDelete();

        // Assert the response
        String responseBody = RestContext.response.responseBody.toString();
        System.assert(responseBody.contains('error'), 'Response should indicate an error');
        Test.stopTest();
    }
}
