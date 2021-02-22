/*
* @author Emre Altan
* @date Feb 17, 2021
* @name RelatedContactListController
* @description controller class for the RelatedContactList visualforce page
*/
public with sharing class RelatedContactListController {
    private Account account;
    private List<Contact> contacts;
    private String accountId = ApexPages.currentPage().getParameters().get('account');
    private integer counter=0;  //keeps track of the offset
    private integer list_size=20; //sets the page size or number of rows
    private integer total_size; //used to show user the total size of the list
    private Id primaryId;
    private String searchString = '';
    private Boolean refreshPage {get; set;}
    ApexPages.StandardController sc;
    
    public RelatedContactListController(ApexPages.StandardController sc) {
        this.sc = sc;
        
        //set the total size in the constructor
        total_size = [select count() from Contact where AccountId = :accountId];
        account = [SELECT id, Name, Phone, Fax, Type, AccountNumber, Active__c
                   FROM Account
                   WHERE id = :accountId];
        refreshPage=true;
    }
    
    /*
    * @author Emre Altan
    * @date Feb 17, 2021
    * @name getRefreshPage
    * @description get method for refreshPage parameter
    * @param null
    * @return Boolean refreshPage
    */
    public Boolean getRefreshPage() {
        return refreshPage;
    }
    
    /*
    * @author Emre Altan
    * @date Feb 17, 2021
    * @name getAccount
    * @description get method for account parameter
    * @param null
    * @return Account account
    */
    public Account getAccount() {
        return account;
    }
    
    /*
    * @author Emre Altan
    * @date Feb 17, 2021
    * @name getPrimaryId
    * @description get method for primaryId parameter
    * @param null
    * @return Id primaryId
    */
    public Id getPrimaryId() {
        return primaryId;
    }
        
    /*
    * @author Emre Altan
    * @date Feb 17, 2021
    * @name getSearchString
    * @description get method for searchString parameter
    * @param null
    * @return String searchString
    */
    public String getSearchString() {
        return searchString;
    }
        
    /*
    * @author Emre Altan
    * @date Feb 17, 2021
    * @name setSearchString
    * @description set method for searchString parameter
    * @param String searchString
    * @return void
    */
    public void setSearchString(String searchString) {
        this.searchString = searchString;
    }
        
    /*
    * @author Emre Altan
    * @date Feb 17, 2021
    * @name setPrimaryId
    * @description set method for primaryId parameter
    * @param Id primaryId
    * @return void
    */
    public void setPrimaryId(Id primaryId) {
        this.primaryId = primaryId;
    }
        
    /*
    * @author Emre Altan
    * @date Feb 17, 2021
    * @name Beginning
    * @description user clicked beginning
    * @param null
    * @return PageReference
    */
    public PageReference Beginning() {
        counter = 0;
        refreshPage=true;
        return null;
    }
        
    /*
    * @author Emre Altan
    * @date Feb 17, 2021
    * @name Previous
    * @description user clicked previous button
    * @param null
    * @return PageReference
    */
    public PageReference Previous() { //user clicked previous button
        counter -= list_size;
        refreshPage=true;
        return null;
    }
        
    /*
    * @author Emre Altan
    * @date Feb 17, 2021
    * @name Next
    * @description user clicked next button
    * @param null
    * @return PageReference
    */
    public PageReference Next() { //user clicked next button
        counter += list_size;
        refreshPage=true;
        return null;
    }
        
    /*
    * @author Emre Altan
    * @date Feb 17, 2021
    * @name End
    * @description user clicked end button
    * @param null
    * @return PageReference
    */
    public PageReference End() { //user clicked end
        counter = total_size - list_size;
        refreshPage=true;
        return null;
    }
        
    /*
    * @author Emre Altan
    * @date Feb 17, 2021
    * @name getDisablePrevious
    * @description will disable the previous and beginning buttons
    * @param null
    * @return Boolean
    */
    public Boolean getDisablePrevious() { 
        if (counter>0) return false; else return true;
    }
        
    /*
    * @author Emre Altan
    * @date Feb 17, 2021
    * @name getDisableNext
    * @description will disable the next and end buttons
    * @param null
    * @return Boolean
    */
    public Boolean getDisableNext() {
        if (counter + list_size < total_size) return false; else return true;
    }
        
    /*
    * @author Emre Altan
    * @date Feb 17, 2021
    * @name getPageNumber
    * @description get method for the page number
    * @param null
    * @return Integer
    */
    public Integer getPageNumber() {
        return counter/list_size + 1;
    }
      
    /*
    * @author Emre Altan
    * @date Feb 17, 2021
    * @name getTotalPages
    * @description get method for the total page count
    * @param null
    * @return Integer
    */
    public Integer getTotalPages() {
        if (math.mod(total_size, list_size) > 0) {
            return total_size/list_size + 1;
        } else {
            return (total_size/list_size);
        }
    }
    
    /*
    * @author Emre Altan
    * @date Feb 17, 2021
    * @name getContacts
    * @description get method for the contact list
    * @param null
    * @return List<Contact>
    */
    public List<Contact> getContacts() {
        try {
            String searchTerm = '%' + searchString + '%';
            contacts = [select Id, Name, Title, Phone, Is_Primary_Contact__c
                        from Contact 
                        where AccountId = :accountId
                        and Name like :searchTerm
                        order by Id 
                        limit :list_size 
                        offset :counter];
        	refreshPage=true;
            return contacts;
            
        } catch (QueryException e) {
            ApexPages.addMessages(e);   
            return null;
        }
    }
    
    /*
    * @author Emre Altan
    * @date Feb 17, 2021
    * @name setAsPrimary
    * @description sets the selected contact as primary
    * @param null
    * @return PageReference
    */
    public PageReference setAsPrimary() {
        refreshPage=false;
        List<Contact> primaryContacts = [select Id, Is_Primary_Contact__c from Contact where AccountId = :accountId and Is_Primary_Contact__c = true];
        for(Contact primaryContact : primaryContacts) {
            primaryContact.Is_Primary_Contact__c = false;
        }
        update primaryContacts;
        
        Contact c = [select Id, Is_Primary_Contact__c from Contact where Id = :primaryId];
        c.Is_Primary_Contact__c = true;
        update c;
        
        refreshPage=true;
        return null;
    }

    /*
    * @author Emre Altan
    * @date Feb 17, 2021
    * @name save
    * @description updates account details
    * @param null
    * @return void
    */
    public void save() {
        try {
            update account;
        } catch(DmlException e) {
            ApexPages.addMessages(e);
        }
    }
    
    /*
    * @author Emre Altan
    * @date Feb 17, 2021
    * @name save
    * @description discards account detail updates
    * @param null
    * @return void
    */
    public void cancel() {
        account = [SELECT id, Name, Phone, Fax, Type, AccountNumber, Active__c
                   FROM Account
                   WHERE id = :accountId];
    }   
}