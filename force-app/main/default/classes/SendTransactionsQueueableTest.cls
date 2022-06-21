@isTest
public class SendTransactionsQueueableTest{
    @TestSetup
    static void makeData(){
        TestDataFactory.createTransactionsAndTransactionItems();
    }

    @isTest 
    static void testTransactionItemCallout() {
        List<Transaction__c> transactions = [SELECT Id, Total_Cost__c, Total_Discount__c, Transaction_Count__c, (SELECT Id, Name, Item_Cost__c FROM Transaction_Items__r) 
                                            FROM Transaction__c];
        List<Transaction_Item__c> transactionItems = new List<Transaction_Item__c>();
        for(Transaction__c trans: transactions) {
            for(Transaction_Item__c transItem: trans.Transaction_Items__r) {
                transactionItems.add(transItem);
            }
        }
        Test.startTest();
        // Set mock callout class 
        String expectedValue = '{[{"keys":{"TransactionItemID":"00Q0p000001PvpZ"},"values":{"ItemCost":"200.00","ItemName":"TI-01"}},{"keys":{"TransactionItemID":"00Q0p000001PvhZ"},"values":{"ItemCost":"300.00","ItemName":"TI-02"}}]}';
        Test.setMock(HttpCalloutMock.class, new TransactionsCalloutMock(expectedValue)); 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. transactions.keySet()
        HttpResponse response = SendTransactionsQueueable.transactionItemsCallout(transactionItems, transactions);
        // Verify that the response received contains fake values
        String contentType = response.getHeader('Content-Type');
        System.assert(contentType == 'application/json', 'incorrect content type');
        String actualValue = response.getBody();
        System.assertEquals(expectedValue, actualValue, 'expectedValue did not match actualValue');
        System.assertEquals(200, response.getStatusCode(), 'returned status code is not 200');
        Test.stopTest();
    }

    @isTest 
    static void testTransactionCallout() {
        List<Transaction__c> transactions = [SELECT Id, Total_Cost__c, Total_Discount__c, Transaction_Count__c, (SELECT Id, Name, Item_Cost__c FROM Transaction_Items__r) 
                                            FROM Transaction__c];
        // Set mock callout class 
        String expectedValue = '{"keys":{"TransactionID":"00Q0p000001PvhZ"},"values":{"TotalCost":"100.00","TotalDiscount":"10.00","TransactionDate":"2020-01-20"}}';
        Test.setMock(HttpCalloutMock.class, new TransactionsCalloutMock(expectedValue));
        Test.startTest();
        for(Transaction__c trans: transactions) {
            // This causes a fake response to be sent
            // from the class that implements HttpCalloutMock. transactions.keySet()
            HttpResponse response = SendTransactionsQueueable.transactionCallout(trans);
            // Verify that the response received contains fake values
            String contentType = response.getHeader('Content-Type');
            System.assert(contentType == 'application/json', 'incorrect content type');
            String actualValue = response.getBody();
            System.assertEquals(expectedValue, actualValue, 'expectedValue did not match actualValue');
            System.assertEquals(200, response.getStatusCode(), 'returned status code is not 200');
        }
        Test.stopTest();
    }

}
