public with sharing class TestDataFactory {
    public static void createTransactionsAndTransactionItems() {
        List<Transaction__c> transactionList = new List<Transaction__c>();
        Transaction__c transaction1 = new Transaction__c(Total_Cost__c=2000, Total_Discount__c = 100, Transaction_Count__c = 1);
        Transaction__c transaction2 = new Transaction__c(Total_Cost__c=3000, Total_Discount__c = 200, Transaction_Count__c = 2);
        transactionList.add(transaction1);
        transactionList.add(transaction2);
        insert transactionList;

        List<Transaction_Item__c> transactionItemList = new List<Transaction_Item__c>();
        Transaction__c transactionListRetrieved1 = [SELECT Id FROM Transaction__c WHERE Total_Cost__c=2000];
        Transaction__c transactionListRetrieved2 = [SELECT Id FROM Transaction__c WHERE Total_Cost__c=3000];
        Transaction_Item__c transactionItem1 = new Transaction_Item__c(Item_Cost__c= 2000, Transaction__c = transactionListRetrieved1.Id);
        Transaction_Item__c transactionItem2 = new Transaction_Item__c(Item_Cost__c= 2000, Transaction__c = transactionListRetrieved2.Id);
        Transaction_Item__c transactionItem3 = new Transaction_Item__c(Item_Cost__c= 1000, Transaction__c = transactionListRetrieved2.Id);
        transactionItemList.add(transactionItem1);
        transactionItemList.add(transactionItem2);
        transactionItemList.add(transactionItem3);
        insert transactionItemList;
    }
}
