/*
* @author Emre Altan
* @date Feb 17, 2021
* @name PrimaryContactPhoneUpdateTest
* @description test file for PrimaryContactPhoneUpdateBatch
*/
@isTest
private class PrimaryContactPhoneUpdateTest {
    /*
    * @author Emre Altan
    * @date Feb 17, 2021
    * @name testPrimaryContactPhoneUpdate
    * @description test method for PrimaryContactPhoneUpdateBatch methods
    * @param null
    * @return void
    */
    static testmethod void testPrimaryContactPhoneUpdate() {
        Account addedAccount = new Account(Name='Primary Contact Account Test');
        insert addedAccount;

        Contact primaryContact = new Contact(
            AccountId = addedAccount.Id, 
            FirstName = 'Primary', 
            LastName = 'TestContact1', 
            Phone = '1111111111', 
            Email = 'emre.altan+1@osf.digital', 
            Is_Primary_Contact__c = true
        );

        insert primaryContact;

        Contact newContact = new Contact(
            AccountId = addedAccount.Id, 
            FirstName = 'New', 
            LastName = 'TestContact2', 
            Phone = '1111111112', 
            Email = 'emre.altan+2@osf.digital', 
            Is_Primary_Contact__c = false
        );

        insert newContact;

        Test.startTest();

        ApexPages.StandardController sc = new ApexPages.StandardController(addedAccount);

        Test.setCurrentPageReference(new PageReference('Page.myPage')); 
        System.currentPageReference().getParameters().put('account', addedAccount.Id);
        
        RelatedContactListController controller = new RelatedContactListController(sc);
        
        //check if primary contact has changed
        controller.setPrimaryId(newContact.Id);
        controller.setAsPrimary();
        List<Contact> primaryContacts = [select Id, FirstName from Contact where Is_Primary_Contact__c = true and AccountId = :addedAccount.Id];
        System.assertEquals(1, primaryContacts.size());
        System.assertEquals('New', primaryContacts[0].FirstName);

        // check apex batch is in the job list
        List<AsyncApexJob> jobsApexBatch = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob 
            where JobType = 'BatchApex' and ApexClass.Name = 'PrimaryContactPhoneUpdateBatch'];

        System.assertEquals(2, jobsApexBatch.size(), 'expecting apex batch job called "PrimaryContactPhoneUpdateBatch"');

        Test.stopTest();
    }
}
