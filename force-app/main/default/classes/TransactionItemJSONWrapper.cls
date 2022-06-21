public with sharing class TransactionItemJSONWrapper {

    public class TransactionItem {
        public Keys keys;
        public Values values;

        public TransactionItem() {
            this.keys = new Keys();
            this.values = new Values();
        }
    }
    public class Keys {
        public String transactionItemID;//00Q0p000001PvpZ
    }
    public class Values {
        public Decimal itemCost;	//200.00
        public String itemName;	//TI-01
    }
}