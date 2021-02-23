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

        List<Contact> contacts = new List<Contact>();
        for(Integer i = 0; i < 49; i++) {
            Contact newContact = new Contact(
                AccountId = addedAccount.Id, 
                FirstName = 'New', 
                LastName = 'TestContact' + i, 
                Phone = '111111111' + i, 
                Email = 'emre.altan+' + i + '@osf.digital', 
                Is_Primary_Contact__c = false
            );

            contacts.add(newContact);
        }

        insert contacts;

        // Get the IDs of the contacts we just inserted
        Map<Id, Contact> contactsMap = new Map<Id, Contact>(contacts);

        Test.startTest();

        ApexPages.StandardController sc = new ApexPages.StandardController(addedAccount);

        Test.setCurrentPageReference(new PageReference('Page.myPage')); 
        System.currentPageReference().getParameters().put('account', addedAccount.Id);
        
        RelatedContactListController controller = new RelatedContactListController(sc);
        
        //contact count test
        List<Contact> pageContacts = controller.getContacts();
        System.assertEquals(20, pageContacts.size());

        // //get refresh page test
        // Boolean refreshPage = controller.getRefreshPage();
        // System.assertEquals(true, refreshPage);

        //set primary contact test
        controller.setPrimaryId(contacts[0].Id);
        controller.setAsPrimary();
        List<Contact> primaryContacts = [select Id, FirstName from Contact where Is_Primary_Contact__c = true and AccountId = :addedAccount.Id];
        System.assertEquals(1, primaryContacts.size());
        System.assertEquals('New', primaryContacts[0].FirstName);

        //page number test
        Integer pageNumber = controller.getPageNumber();
        System.assertEquals(1, pageNumber);

        //total page count test
        Integer totalPages = controller.getTotalPages();
        System.assertEquals(3, totalPages);

        controller.Next();
        pageNumber = controller.getPageNumber();
        System.assertEquals(2, pageNumber);

        controller.End();
        pageNumber = controller.getPageNumber();
        System.assertEquals(2, pageNumber);

        //disable next test
        Boolean disableNext = controller.getDisableNext();
        System.assertEquals(true, disableNext);

        controller.Previous();
        pageNumber = controller.getPageNumber();
        System.assertEquals(1, pageNumber);

        controller.Beginning();
        pageNumber = controller.getPageNumber();
        System.assertEquals(1, pageNumber);

        //disable previous test
        Boolean disablePrev = controller.getDisablePrevious();
        System.assertEquals(true, disablePrev);

        //set search string test
        controller.setSearchString('Primary');
        List<Contact> filteredContacts = controller.getContacts();
        System.assertEquals(1, filteredContacts.size());

        Boolean refreshPage = controller.getRefreshPage();
        System.assertEquals(true, refreshPage);

        Account acc = controller.getAccount();
        controller.cancel();
        Account acc2 = controller.getAccount();
        System.assertEquals(acc, acc2);

        Test.stopTest();
    }
}