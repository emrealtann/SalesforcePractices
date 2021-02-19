public inherited sharing class OpportunityAmountSummarizerBatch implements Database.Batchable<sObject>, Database.Stateful {
    private Map<Id,String> accountPrimaryEmailMap;

    public OpportunityAmountSummarizerBatch() {

    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        //get primary contacts
        List<Contact> primaryContacts = [select Id, AccountId, Email from Contact where Is_Primary_Contact__c = true];
        
        //fill map object
        for(Contact c : primaryContacts) {
            if(!accountPrimaryEmailMap.containsKey(c.AccountId)) {
                accountPrimaryEmailMap.put(c.AccountId, c.Email);
            }
        }

        //will use this in where clause. there is no need to summarize all account opportunities. just get who has a primary contact.
        String accountIdJoin = String.join(accountPrimaryEmailMap.keySet(), '\',\'');
        accountIdJoin = '\'' + accountIdJoin + '\'';

        return Database.getQueryLocator('select AccountId, Account.Name AccountName, StageName, sum(Amount) SumAmount from Opportunity where AccountId in ' 
            + accountIdJoin  + ' group by AccountId, Account.Name, StageName order by AccountId');
    }

    public void execute(Database.BatchableContext bc, List<sObject> records){
        // process each batch of records
        List<Id> accountIds = new List<Id>(); 
        String emailContent = '<table border="1" style="border-collapse: collapse"><tr><th>Account</th><th>Stage</th><th>Amount</th></tr>';

        for(sObject s : records) {
        	AggregateResult ar = (AggregateResult)s;
            Id accountId = (Id)ar.get('AccountId');
            String accountName = (String)ar.get('AccountName');
            String stageName = (String)ar.get('StageName');
            Decimal sumAmount = (Decimal)ar.get('SumAmount');
            
            if(accountIds.contains(accountId)) {

            }
            else {
                //finish formatting and send email
                emailContent = '<p>Below is a table of opportunities related to the account: ' + accountName + '</p>' + emailContent;
                emailContent += '</table>';

                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.setToAddresses(new List<string> { accountPrimaryEmailMap.get(accountId) });
                message.setHtmlBody(emailContent);
            }
        }

        update records;
    }
    public void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }
}
