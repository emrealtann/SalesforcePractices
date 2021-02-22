/*
* @author Emre Altan
* @date Feb 17, 2021
* @name RelatedContactListTest
* @description test file for RelatedContactList visualforce page controller
*/
@isTest
private class RelatedContactListTest {
    /*
    * @author Emre Altan
    * @date Feb 17, 2021
    * @name testPageController
    * @description test method for RelatedContactListController methods
    * @param null
    * @return void
    */
    static testmethod void testPageController() {
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
        
        //contact count test
        List<Contact> contacts = controller.getContacts();
        System.assertEquals(2, contacts.size());

        // //get refresh page test
        // Boolean refreshPage = controller.getRefreshPage();
        // System.assertEquals(true, refreshPage);

        //set search string test
        controller.setSearchString('Primary');
        List<Contact> filteredContacts = controller.getContacts();
        System.assertEquals(1, filteredContacts.size());

        //set primary contact test
        controller.setPrimaryId(newContact.Id);
        controller.setAsPrimary();
        List<Contact> primaryContacts = [select Id, FirstName from Contact where Is_Primary_Contact__c = true and AccountId = :addedAccount.Id];
        System.assertEquals(1, primaryContacts.size());
        System.assertEquals('New', primaryContacts[0].FirstName);

        //disable previous test
        Boolean disablePrev = controller.getDisablePrevious();
        System.assertEquals(true, disablePrev);

        //disable next test
        Boolean disableNext = controller.getDisableNext();
        System.assertEquals(true, disableNext);

        //page number test
        Integer pageNumber = controller.getPageNumber();
        System.assertEquals(1, pageNumber);

        //total page count test
        Integer totalPages = controller.getTotalPages();
        System.assertEquals(1, totalPages);

        Test.stopTest();
    }
}
