global class OAuth {

	private Map<String,String> parameters = new Map<String,String>();
	
	public String message { get; set; }
	public String callbackUrl {get; set; }

    private OAuthService__c service;

	public String newAuthorization(String serviceName) {

		service = [SELECT app_id__c, Client_Secret__c, Access_Token_URL__c, 
						  Authorization_URL__c, Name FROM OAuthService__c WHERE name = :serviceName];
		
		if(service==null) {
			System.debug('Couldn\'t find Oauth Service '+serviceName);
			message = 'Service '+serviceName+' was not found in the local configuration';
			return null;
		}

		string host = 'https://' + URL.getSalesforceBaseURL().getHost() + '/apex/accessToken';
        system.debug(service.authorization_url__c+'client_id='+EncodingUtil.urlDecode(service.app_id__c,'UTF-8')+'&redirect_uri=' + 'https://' + URL.getSalesforceBaseURL().getHost() + '/apex/AccessToken');
	    return service.authorization_url__c+'?client_id=' + service.app_id__c+'&redirect_uri='  + host + '&state=' + serviceName;
		
	}
	
	public string accessToken(string code, string serviceName){
		string host = 'https://' + URL.getSalesforceBaseURL().getHost() + '/apex/accessToken';
		service = [SELECT app_id__c, Client_Secret__c, Access_Token_URL__c, 
                          Authorization_URL__c, Name FROM OAuthService__c WHERE name = :serviceName];
        //accessTokenHTTP(code, serviceName);
	    return service.Access_Token_URL__c + '?client_id=' + service.app_id__c + '&client_secret=' + service.Client_Secret__c + '&code=' + code + '&redirect_uri=' + host;
	}
	
	
	public string accessTokenHTTP(string code, string serviceName){
		System.debug('accessTokenHTTP');

        string host = 'https://' + URL.getSalesforceBaseURL().getHost() + '/apex/accessToken';
        service = [SELECT app_id__c, Client_Secret__c, Access_Token_URL__c, 
                          Authorization_URL__c, Name, Access_Token__c FROM OAuthService__c WHERE name = :serviceName];
        string endPoint = service.Access_Token_URL__c + '?client_id='+EncodingUtil.urlEncode(service.app_id__c, 'UTF-8')+'&client_secret='+EncodingUtil.urlEncode(service.Client_Secret__c, 'UTF-8')+ '&code=' + EncodingUtil.urlEncode(code, 'UTF-8')+'&redirect_uri='+EncodingUtil.urlEncode(host, 'UTF-8');
        Http httpProtocol = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndPoint(endPoint);
        request.setMethod('POST');
        request.setHeader('Content-Length', String.valueOf(request.getBody().length()));
        HttpResponse response = httpProtocol.send(request);
        
        System.debug(response.getBody());
        
        JSONParser parser = JSON.createParser(response.getBody());
        string accesstoken ;
        integer expiresIn;
        string userId;
        system.debug(response.getBody());
        
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
		        String fieldName = parser.getText();
		        parser.nextToken();
		        if(fieldName == 'access_token') {
		            accesstoken = parser.getText();
		        } else if(fieldName == 'expires_in'){
		            expiresIn = parser.getIntegerValue();
		        } else if(fieldName == 'user_id'){
                    userId = parser.getText();
                }
            }
        System.debug('access_token: ' + accesstoken);
        System.debug('expires_in: ' + string.valueOf(expiresIn));
        
        }
        service.Access_Token__c = accesstoken;
        service.expires_in__c = DateTime.newInstance(((DateTime.now().getTime()/1000) + expiresIn)*1000);
        service.user_id__c = userId;
        update service;
        host = 'https://' + URL.getSalesforceBaseURL().getHost() + '/apex/AuthPage';
        return host;
    }
    
    public OAuth(){
        System.debug('accessTokenHTTP');
    }
}