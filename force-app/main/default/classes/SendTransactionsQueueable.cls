public with sharing class SendTransactionsQueueable implements Queueable, Database.AllowsCallouts {
    private Set<Id> transactionIds;
    public final static String ENDPOINT = 'callout:KatzionCallouts';
    public final static String HEADER_CT = 'Content-Type';
    public final static String HEADER_JSON = 'application/json';
    public final static String POST = 'POST';

    public SendTransactionsQueueable(Set<Id> transactionIds) {
        this.transactionIds = transactionIds;
    }

    public void execute(QueueableContext qc) {
        List<Transaction__c> transactions = [SELECT Id, Total_Cost__c, Total_Discount__c, Transaction_Count__c, (SELECT Id, Name, Item_Cost__c FROM Transaction_Items__r) 
                                            FROM Transaction__c WHERE Id IN :transactionIds WITH SECURITY_ENFORCED];
        List<Transaction_Item__c> transactionItems = new List<Transaction_Item__c>();
        for(Transaction__c trans: transactions) {
            for(Transaction_Item__c transItem: trans.Transaction_Items__r) {
                transactionItems.add(transItem);
            }
        }

        transactionItemsCallout(transactionItems, transactions);
    }

    @TestVisible
    private static HttpResponse transactionItemsCallout(List<Transaction_Item__c> transactionItems, List<Transaction__c> transactions) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(ENDPOINT);
        req.setMethod(POST);
        req.setHeader(HEADER_CT, HEADER_JSON); 
        req.setBody(wrapTransactionItems(transactionItems));
        Http http = new Http();
        HttpResponse res;
        try {
            res = http.send(req);
            if (res.getStatusCode() != 201) {
                System.debug('The status code returned was not expected: ' + res.getStatusCode() + ' ' + res.getStatus());
            }
            else {
                for(Transaction__c trans: transactions) {
                    transactionCallout(trans);
                }
            }
        }
        catch(System.CalloutException ex) {
            System.debug('Callout error: ' + ex);
        }
        return res;
    }

    @TestVisible
    private static HttpResponse transactionCallout(Transaction__c trans) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(ENDPOINT);
        req.setMethod(POST);
        req.setHeader(HEADER_CT, HEADER_JSON);
        req.setBody(wrapTransactions(trans));
        Http http = new Http();
        HttpResponse res;
        try {
            res = http.send(req);
            if (res.getStatusCode() != 201) {
                System.debug('The status code returned was not expected: ' + res.getStatusCode() + ' ' + res.getStatus());
            }
        }
        catch(System.CalloutException ex) {
            System.debug('Callout error: ' + ex);
        }
        return res;
    }

    private static String wrapTransactionItems(List<Transaction_Item__c> transactionItems) {
        List<TransactionItemJSONWrapper.TransactionItem> result = new List<TransactionItemJSONWrapper.TransactionItem>();
        for(Transaction_Item__c transactionItem: transactionItems) {
            TransactionItemJSONWrapper.TransactionItem transItem = new TransactionItemJSONWrapper.TransactionItem();
            TransactionItemJSONWrapper.Keys keys = new TransactionItemJSONWrapper.Keys();
            TransactionItemJSONWrapper.Values values = new TransactionItemJSONWrapper.Values();

            transItem.keys.transactionItemID = transactionItem.Id;
            transItem.values.itemCost = transactionItem.Item_Cost__c;
            transItem.values.itemName = transactionItem.Name;

            result.add(transItem);
        }
        //for demo
        System.debug('result::');
        System.debug(JSON.serialize(result));
        return JSON.serialize(result);
    }

    private static String wrapTransactions(Transaction__c trans) {
        TransactionJSONWrapper wrapper = new TransactionJSONWrapper();
        TransactionJSONWrapper.Keys keys = new TransactionJSONWrapper.Keys();
        TransactionJSONWrapper.Values values = new TransactionJSONWrapper.Values();
        keys.transactionID = trans.Id;
        values.totalCost = trans.Total_Cost__c;
        values.totalDiscount = trans.Total_Discount__c;
        values.transactionDate = Date.today();
        wrapper.keys = keys;
        wrapper.values = values;
        //for demo
        System.debug('wrapper:: ');
        System.debug(JSON.serialize(wrapper));
        return JSON.serialize(wrapper);
    }
}
