trigger TransactionItemTrigger on Transaction_Item__c (after insert, after update, before insert, before update) {

    if( Trigger.isInsert ) {
        if(Trigger.isAfter) {
            TransItemTriggerHandler.onAfterInsert(trigger.NewMap);
        }
    }
    else if ( Trigger.isUpdate ) {
    }
}