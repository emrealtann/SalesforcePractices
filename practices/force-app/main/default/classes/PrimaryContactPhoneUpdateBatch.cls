public class PrimaryContactPhoneUpdateBatch implements Database.Batchable<sObject>, Database.Stateful {

    private Id accountId;
    private String primaryContactPhone;

    public PrimaryContactPhoneUpdateBatch(Id accountId) {
        this.accountId = accountId;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        // collect the batches of records or objects to be passed to execute
        List<Contact> primaries = [select Id, Phone from Contact where AccountId = :accountId and Is_Primary_Contact__c = true LIMIT 1];
        if(!primaries.IsEmpty()) {
            primaryContactPhone = primaries[0].Phone;
        }

        return Database.getQueryLocator('select Id, Is_Primary_Contact__c, Primary_Contact_Phone__c from Contact where AccountId = \'' + accountId + '\'');
    }
    public void execute(Database.BatchableContext bc, List<Contact> records){
        // process each batch of records
        for(Contact c : records) {
            c.Primary_Contact_Phone__c = primaryContactPhone;
        }

        update records;
    }
    public void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }
}
