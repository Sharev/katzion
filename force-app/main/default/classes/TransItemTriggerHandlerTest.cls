@IsTest
public class TransItemTriggerHandlerTest {
    @TestSetup
    static void makeData(){
        TestDataFactory.createTransactionsAndTransactionItems();
    }

    @IsTest
    static void testGetItemsPerTransaction() {
        List<Transaction__c> transactions = [SELECT Id, Total_Cost__c, Total_Discount__c, Transaction_Count__c FROM Transaction__c];
        Set<Id> transactionIds = new Set<Id>();
        for(Transaction__c trans: transactions) {
            transactionIds.add(trans.Id);
        }
        Test.startTest();
        Map<Id, Integer> itemCountByTransaction = TransItemTriggerHandler.getItemsPerTransaction(transactionIds);
        Test.stopTest();
        System.assertEquals(transactions[0].Transaction_Count__c, itemCountByTransaction.get(transactions[0].Id), 'Incorrect value for transaction count');
    }

    @IsTest
    static void testOnAfterInsert() {
        Map<Id, Transaction_Item__c> transactionItems = new Map<ID, Transaction_Item__c> ([SELECT Id, Transaction__r.Transaction_Count__c FROM Transaction_Item__c]);
        Test.startTest();
        Set<Id> transactionIds = TransItemTriggerHandler.onAfterInsert(transactionItems);
        Test.stopTest();
        System.assertEquals(2, transactionIds.size(), 'Should be 2 transaction ids');
    }
}
