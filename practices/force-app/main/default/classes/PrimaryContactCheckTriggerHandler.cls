public with sharing class PrimaryContactCheckTriggerHandler {

    public void OnBefore(Contact[] newContacts) {
        for (Contact c : newContacts) {
            if (c.Is_Primary_Contact__c) {
                //check if there is another primary contact
                Integer primaryCount = [
                    SELECT COUNT()
                    FROM Contact
                    WHERE
                        AccountId = :c.AccountId
                        AND Id != :c.Id
                        AND Is_Primary_Contact__c = TRUE
                ];
                if (primaryCount > 0) {
                    c.addError('There is primary contact that already exists.');
                }
            }
        }
    }

    public void OnAfterInsert(Contact[] newContacts) {
        // EXECUTE AFTER INSERT LOGIC

        for (Contact c : newContacts) {
            if (c.Is_Primary_Contact__c) {
                //update primary contact phone fields of all related contacts
                Database.executeBatch(new PrimaryContactPhoneUpdateBatch(c.AccountId));
            }
        }
    }

    public void OnAfterUpdate(Contact[] oldContacts, Contact[] newContacts) {
        // AFTER UPDATE LOGIC
        for (Integer i = 0; i < newContacts.size(); i++) {
            Contact newContact = newContacts[i];
            Contact oldContact = oldContacts[i];

            //check if primary contact has changed
            if (
                newContact.Is_Primary_Contact__c &&
                !oldContact.Is_Primary_Contact__c
            ) {
                //update primary contact phone fields of all related contacts
                Database.executeBatch(new PrimaryContactPhoneUpdateBatch(newContact.AccountId));
            }
        }
    }
}