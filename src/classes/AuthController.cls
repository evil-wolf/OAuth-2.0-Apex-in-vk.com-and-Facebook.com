public with sharing class AuthController {

    public String service { get; set; }
    
    public String authUrl { get; set; }
    
    public boolean authSuccess { get; set; }

    public String message { get; set; }
    
    public string code;

    public List<SelectOption> services {
        get {
            if(services==null) {
                List<OAuthService__c> l = [SELECT name FROM OAuthService__c];
                services = new List<SelectOption>();
                for(OAuthService__c obj : l) {
                    services.add(new SelectOption(obj.name,obj.name));
                    System.debug('service: '+obj.name);
                }
            }
            return services;
        }
        set;
    }
    
    public PageReference authorize() { 
        OAuth oa = new OAuth();
        authUrl = oa.newAuthorization(service);
        setCookie('service', service);
        System.debug(authUrl);
        if(authUrl==null) {
        	this.message = oa.message;
        	return null;
        } else {
        	return new PageReference(authUrl);
        	//transition(authUrl);
        	//transition(authUrl);
        }
        /*
        authUrl = oa.accessToken(ApexPages.currentPage().getHeaders().get('code')); 
        System.debug(authUrl);
        if(authUrl==null) {
            this.message = oa.message;
            //return null;
        } else {
            //PageReference(authUrl);
            //return new PageReference(authUrl);
            transition(authUrl);
        }*/
    }
    
    public PageReference accessToken() {
    	OAuth oa = new OAuth();
    	String serviceCookie = null;
    	Cookie cookie = ApexPages.currentPage().getCookies().get('service');
    	if (cookie != null) {
            serviceCookie = cookie.getValue();        
        }
        string code = ApexPages.currentPage().getParameters().get('code');
        string stateService = ApexPages.currentPage().getParameters().get('state');
        system.debug('oa.accessTokenHTTP(code,stateService);');
    	//authUrl = oa.accessToken(code,stateService);
    	authUrl = oa.accessTokenHTTP(code,stateService);
    	string host = 'https://' + URL.getSalesforceBaseURL().getHost() + '/apex/AuthPage';
    	return new PageReference(authUrl);
    }
    
    
    public AuthController(){
        system.debug('AuthController');
    }
    
    public static void setCookie(String name, String meaning){
        
        Cookie userCookie = new Cookie(name, meaning, null, 315569260, false); //Here 315569260 represents cookie expiry date = 10 years. You can set this to what ever expiry date you want. Read apex docs for more details.
        ApexPages.currentPage().setCookies(new Cookie[] {
            userCookie
            });
    }
    /*
    public PageReference completeAuthorization() {
        String token = ApexPages.currentPage().getParameters().get('oauth_token');
        if(token!=null)
        {
            String verifier = ApexPages.currentPage().getParameters().get('oauth_verifier');
            OAuth oa = new OAuth();
            authSuccess = oa.completeAuthorization(token,verifier);
            this.message = oa.message;
        }
        else {
            message = 'Invalid request. Missing parameter oauth_token';
        }
        return null;
    }
    */
}