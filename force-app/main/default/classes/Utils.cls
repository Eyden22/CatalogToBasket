/**
 * @Author Eyden Enriquez
 * @Since 2024
 * @Description: Class wich contains reusable methods
*/
public with sharing class Utils {

    //Return a valid access token
    @AuraEnabled(cacheable=true)
    public static String getAccessToken() {
      
        HttpRequest req = new HttpRequest();
        req.setEndpoint(Constants.ENDPOINT);
        req.setMethod('POST');
 		req.setHeader('Content-Type', 'application/x-www-form-urlencoded');

   		String body = 'grant_type=password' +
                  '&username=' + EncodingUtil.urlEncode(Constants.USERNAME, 'UTF-8') +
                  '&password=' + EncodingUtil.urlEncode(Constants.PASSWORD + Constants.SECURITY_TOKEN, 'UTF-8') +
                  '&client_id=' + EncodingUtil.urlEncode(Constants.CLIENT_ID, 'UTF-8') +
                  '&client_secret=' + EncodingUtil.urlEncode(Constants.CLIENT_SECRET, 'UTF-8');

    	req.setBody(body);  

        
        Http http = new Http();
        HttpResponse res = http.send(req);
        try {
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            
            // Check if there is an error
            if (jsonResponse.containsKey('error')) {
                String errorMessage = (String) jsonResponse.get('error_description'); //Get error message
                throw new AuraHandledException(errorMessage); 
            }
            
            // Get the token
            String accessToken = (String) jsonResponse.get('access_token');
            return accessToken;
        } 
        catch (Exception e) {
            throw new AuraHandledException('Failed to retrieve access token: ' + e.getMessage()); //Send an exception to front side
        }

    }
}