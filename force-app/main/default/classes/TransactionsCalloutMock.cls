@isTest
public class TransactionsCalloutMock implements HttpCalloutMock {
    private String body = '';
    public TransactionsCalloutMock(String body) {
        this.body = body;
    }
    // Implement this interface method
    public HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody(this.body);
        response.setStatusCode(200);
        return response; 
    }
}