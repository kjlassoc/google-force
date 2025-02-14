public class GoogleForce {

    public class ServiceAcctException extends Exception {}

    private Google_Service_Account__mdt serviceAcct;
    private Google_SA_Token__c serviceAcctToken;
    private Boolean updateToken;

    public GoogleForce(String serviceAcctName) {

        List<Google_Service_Account__mdt> saQueryResult = [
            select Id, Client_Email__c, Private_Key__c, Scope__c, Services_Spreadsheet_Id__c, Master_Spreadsheet_Id_c__c
            from Google_Service_Account__mdt
            where MasterLabel = :serviceAcctName
            limit 1];

        if (saQueryResult.size() == 0) {
            saQueryResult = [
                select Id, Client_Email__c, Private_Key__c, Scope__c, Services_Spreadsheet_Id__c, Master_Spreadsheet_Id_c__c
                from Google_Service_Account__mdt
                where DeveloperName = :serviceAcctName
            limit 1];
        }

        if (saQueryResult.size() == 0) {
            throw new ServiceAcctException('Service account not found');
        }
        this.serviceAcct = saQueryResult.get(0);

        this.serviceAcctToken = Google_SA_Token__c.getValues(serviceAcct.Id);
        if (this.serviceAcctToken == null) {
            this.serviceAcctToken = new Google_SA_Token__c(
                Name = serviceAcct.Id,
                Value__c = null,
                Value2__c = null,
                Value3__c = null,
                Value4__c = null,
                Value5__c = null,
                Value6__c = null,
                Timestamp__c = null);
        }
        updateToken = false;
    }

    private class JwtHeader {
        public String alg;
        public String typ;

        public JwtHeader() {
            alg = 'RS256';
            typ = 'JWT';
        }
    }

    private class JwtClaim {
        public String iss;
        public String scope;
        public String aud;
        public Long exp;
        public Long iat;

        public JwtClaim (Google_Service_Account__mdt sa) {
            Datetime currDt = Datetime.now();

            iss = sa.Client_Email__c;
            scope = sa.Scope__c;
            aud = 'https://www.googleapis.com/oauth2/v4/token';
            iat = currDt.getTime()/1000;
            exp = iat + 60;
        }
    }

    private class JwtSignature {
        public Blob privateKeyBlob;

        public JwtSignature(Google_Service_Account__mdt sa) {
            privateKeyBlob = EncodingUtil.base64Decode(
                sa.Private_Key__c.unescapeJava());
        }
    }

    public HttpResponse sendRequest(Map<String, String> params) {
        getAccessToken();

        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', 'Bearer ' + serviceAcctToken.Value__c + serviceAcctToken.Value2__c + serviceAcctToken.Value3__c + serviceAcctToken.Value4__c + serviceAcctToken.Value5__c + serviceAcctToken.Value6__c);
        req.setEndpoint(params.get('endpoint'));
        req.setMethod(params.get('method'));
        req.setTimeout(15 * 1000);

        if (params.get('body') != null) {
            req.setHeader('Content-Type', 'application/json; charset=UTF-8');
            req.setBody(params.get('body'));
        }

        if (params.get('contentType') != null) {
            req.setHeader('Content-Type', params.get('contentType'));
        }

        HttpResponse res = new Http().send(req);
        //System.debug(res.getBody());

        return res;
    }

    public String handleResponse(HttpResponse res) {

        if (res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
            return res.getBody();
        }

        CalloutException respErr = new CalloutException();
        respErr.setMessage(res.getBody());
        throw respErr;
    }

    public Google_SA_Token__c getAccessToken() {

        if (isTokenExpired()) {
            serviceAcctToken = requestAccessToken();
            updateToken = true;
        }
        return serviceAcctToken;
    }

    public void updateToken() {
        if (updateToken) {
            upsert serviceAcctToken Name;
        }
    }

    public Boolean isTokenExpired() {
        if (serviceAcctToken.Value__c == null) { return true; }

        // Divide by 1000 to convert to seconds and divide by 60 to convert
        // to minutes. Therefore, we divide by 60,000
        Long elapsedMin = (Datetime.now().getTime()
            - serviceAcctToken.Timestamp__c.getTime())/60000;

        if (elapsedMin >= 58) {
            return true;
        }
        return false;
    }

    public String getServicesSpreadsheetId() {
        if (serviceAcct != null) {
            return serviceAcct.Services_Spreadsheet_Id__c;
        }

        return null;
    }

    private Google_SA_Token__c requestAccessToken() {

        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setEndpoint('https://www.googleapis.com/oauth2/v4/token');
        req.setMethod('POST');
        req.setTimeout(15 * 1000);
        req.setBody(
            'grant_type=' + EncodingUtil.urlEncode(
                'urn:ietf:params:oauth:grant-type:jwt-bearer', 'UTF-8')
            + '&assertion=' + EncodingUtil.urlEncode(createJWT(), 'UTF-8'));

        HttpResponse res = new Http().send(req);
        String respParam = handleResponse(res);

        Map<String, Object> respParams = (Map<String, Object>)
            JSON.deserializeUntyped(res.getBody());

        if (respParams != null) {
            String accessToken = (String) respParams.get('access_token');
            if (accessToken != null) {
                Integer substringLength = (accessToken.length() > 255 ? 255 : accessToken.length());
                serviceAcctToken.Value__c = accessToken.substring(0, substringLength);
                if (accessToken.length() > 255) {
                    if (accessToken.length() > 510) {
                        serviceAcctToken.value2__c = accessToken.substring(255, 510);
                    } else {
                        serviceAcctToken.value2__c = accessToken.substring(255);
                    }
                }
                if (accessToken.length() > 510) {
                    if (accessToken.length() > 765) {
                        serviceAcctToken.value3__c = accessToken.substring(510, 765);
                    } else {
                        serviceAcctToken.value3__c = accessToken.substring(510);
                    }
                }
                if (accessToken.length() > 765) {
                    if (accessToken.length() > 1020) {
                        serviceAcctToken.value4__c = accessToken.substring(765, 1020);
                    } else {
                        serviceAcctToken.value4__c = accessToken.substring(765);
                    }
                }
                if (accessToken.length() > 1020) {
                    if (accessToken.length() > 1275) {
                        serviceAcctToken.value5__c = accessToken.substring(1020, 1275);
                    } else {
                        serviceAcctToken.value5__c = accessToken.substring(1020);
                    }
                }
                if (accessToken.length() > 1275) {
                    if (accessToken.length() > 1530) {
                        serviceAcctToken.value6__c = accessToken.substring(1275, 1530);
                    } else {
                        serviceAcctToken.value6__c = accessToken.substring(1275);
                    }
                }
            }
        }
        serviceAcctToken.Timestamp__c = Datetime.now();

        return serviceAcctToken;
    }

    private String createJWT() {

        String input = encodeComponent(JSON.serialize(new JwtHeader())) + '.' +
            encodeComponent(JSON.serialize(new JwtClaim(serviceAcct)));

        JwtSignature jwtSig = new JwtSignature(serviceAcct);

        String signature = '';
        if (!Test.isRunningTest()) {
            signature = encodeComponent(Crypto.sign(
                'RSA-SHA256',
                Blob.valueOf(input),
                jwtSig.privateKeyBlob));
        }

        return input + '.' + signature;
    }

    private String encodeComponent(String component) {
        return encodeComponent(Blob.valueOf(component));
    }

    private String encodeComponent(Blob component) {
        return EncodingUtil.base64Encode(component);
    }
}
