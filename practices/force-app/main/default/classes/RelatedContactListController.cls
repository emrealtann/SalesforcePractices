public with sharing class RelatedContactListController {
    private Account account;
    private List<Contact> contacts;
    private String accountId = ApexPages.currentPage().getParameters().get('account');
    private integer counter=0;  //keeps track of the offset
    private integer list_size=20; //sets the page size or number of rows
    public integer total_size; //used to show user the total size of the list
    private Id primaryId;
    public String searchString = '';
    ApexPages.StandardController sc;
    
    public RelatedContactListController(ApexPages.StandardController sc) {
        this.sc = sc;
        
        //set the total size in the constructor
        total_size = [select count() from Contact where AccountId = :accountId];
        account = [SELECT id, Name, Phone, Fax, Type, AccountNumber, Active__c
                   FROM Account
                   WHERE id = :accountId];
        
    }
    
    public Account getAccount() {
        return account;
    }
    
    public Id getPrimaryId() {
        return primaryId;
    }
    
    public String getSearchString() {
        return searchString;
    }
    
    public void setSearchString(String searchString) {
        this.searchString = searchString;
    }
    
    public void setPrimaryId(Id primaryId) {
        this.primaryId = primaryId;
    }
    
    public PageReference Beginning() { //user clicked beginning
        counter = 0;
        return null;
    }
    
    public PageReference Previous() { //user clicked previous button
        counter -= list_size;
        return null;
    }
    
    public PageReference Next() { //user clicked next button
        counter += list_size;
        return null;
    }
    
    public PageReference End() { //user clicked end
        counter = total_size - list_size;
        return null;
    }
    
    public Boolean getDisablePrevious() { 
        //this will disable the previous and beginning buttons
        if (counter>0) return false; else return true;
    }
    
    public Boolean getDisableNext() { //this will disable the next and end buttons
        if (counter + list_size < total_size) return false; else return true;
    }
    
    public Integer getTotal_size() {
        return total_size;
    }
    
    public Integer getPageNumber() {
        return counter/list_size + 1;
    }
    
    public Integer getTotalPages() {
        if (math.mod(total_size, list_size) > 0) {
            return total_size/list_size + 1;
        } else {
            return (total_size/list_size);
        }
    }
    
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
            return contacts;
            
        } catch (QueryException e) {
            ApexPages.addMessages(e);   
            return null;
        }
    }
    
    public void setAsPrimary() {
        List<Contact> primaryContacts = [select Id, Is_Primary_Contact__c from Contact where AccountId = :accountId and Is_Primary_Contact__c = true];
        for(Contact primaryContact : primaryContacts) {
            primaryContact.Is_Primary_Contact__c = false;
        }
        update primaryContacts;
        
        Contact c = [select Id, Is_Primary_Contact__c from Contact where Id = :primaryId];
        c.Is_Primary_Contact__c = true;
        update c;
    }
    
    public void save() {
        try {
            update account;
        } catch(DmlException e) {
            ApexPages.addMessages(e);
        }
    }
    
    
    public void cancel() {
        account = [SELECT id, Name, Phone, Fax, Type, AccountNumber, Active__c
                   FROM Account
                   WHERE id = :accountId];
    }   
}