global without sharing class ZomatoClass {
   //Used to get entityId and entityType
   @AuraEnabled
   public static String getLocation(String locationName) {   
      //Get the base url of Zomato API from custom label        
       String url = System.Label.Zomato_API_URL;
              url += +'locations';
      //Get the API key of Zomato from custom label
       String userKey = System.Label.ZomatoAPIKey;
       String reponse;
       // Instantiate a new http object
       Http h = new Http();
       url += '?query='+locationName;
       // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
       HttpRequest req = new HttpRequest();
       req.setEndpoint(url);
       req.setHeader('Content-Type', 'application/json');
       req.setHeader('user-key', userKey);
       req.setMethod('GET');
        
       // Send the request, and return a response
       HttpResponse res = h.send(req);
       reponse = res.getBody();
       if(res.getStatusCode() == 200 && res.getBody() != null){
           return reponse; 
       }
       return null;  
   }
}