/**
 * @Author Eyden Enriquez
 * @Since 2024
 * @Description: Test Class for Utils methods
*/
@isTest
public class UtilsTest {

    // Test method to validate UtilsTest.getAccessToken
    @isTest
    static void testGetAccessToken() {
        // Mock HTTP response
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('{"access_token":"mockedAccessToken"}');
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl(mockResponse));

        // Test successful token retrieval
        String accessToken = Utils.getAccessToken();
        System.assertEquals('mockedAccessToken', accessToken);
    }

    @isTest
    static void testGetAccessTokenError() {
        // Mock error response
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(400);
        mockResponse.setBody('{"error":"invalid_grant","error_description":"Invalid credentials"}');
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl(mockResponse));

        // Test error handling
        try {
            Utils.getAccessToken();
        } 
        catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Script-thrown exception'));
        }
    }

    // Mock class for HTTP responses
    class HttpCalloutMockImpl implements HttpCalloutMock{
        private HttpResponse response;
        public HttpCalloutMockImpl(HttpResponse response) {
            this.response = response;
        }
        public HTTPResponse respond(HTTPRequest req) {
            return response;
        }
    }
}
