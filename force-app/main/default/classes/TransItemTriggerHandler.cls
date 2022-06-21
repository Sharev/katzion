public with sharing class TransItemTriggerHandler {

    public static Set<Id> onAfterInsert(Map<Id, Transaction_Item__c> newTransactionItemMap) {
        Set<Id> transactionIdsForCallout = new Set<Id>();
        Set<Id> transactionIds = new Set<Id>();

        for(Transaction_Item__c transItem: newTransactionItemMap.values()) {
            transactionIds.add(transItem.Transaction__c);
        }
        Map<Id, Integer> itemCountByTransaction = getItemsPerTransaction(transactionIds);

        for(Transaction_Item__c transItem: [SELECT Transaction__c, Transaction__r.Transaction_Count__c FROM Transaction_Item__c WHERE Id IN: newTransactionItemMap.keySet() WITH SECURITY_ENFORCED]) {
            if(itemCountByTransaction.containsKey(transItem.Transaction__c) && 
                transItem.Transaction__r.Transaction_Count__c == itemCountByTransaction.get(transItem.Transaction__c)) {
                transactionIdsForCallout.add(transItem.Transaction__c);
            }
        }

        if(!Test.isRunningTest() && transactionIdsForCallout.size() > 0) {
            System.enqueueJob(new SendTransactionsQueueable(transactionIdsForCallout));
        }

        return transactionIdsForCallout;
    }

    @TestVisible
    private static Map<Id, Integer> getItemsPerTransaction(Set<Id> transactionIds) {
        Map<Id, Integer> itemCountByTransaction = new Map<Id, Integer>();

        for(AggregateResult ag: [SELECT Count(Id), Transaction__c FROM Transaction_Item__c 
                                WHERE Transaction__c IN  :transactionIds WITH SECURITY_ENFORCED GROUP BY Transaction__c]) {
            itemCountByTransaction.put((Id)ag.get('Transaction__c'), (Integer)ag.get('expr0'));
        }       
        return itemCountByTransaction;
    }
}
