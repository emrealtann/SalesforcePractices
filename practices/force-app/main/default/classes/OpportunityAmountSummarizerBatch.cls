/*
* @author Emre Altan
* @date Feb 19, 2021
* @name PrimaryContactCheckTriggerHandler
* @description batch class to send opportunity summary emails to the primary contact email addresses
*/
global inherited sharing class OpportunityAmountSummarizerBatch implements Database.Batchable<sObject>, Database.Stateful {
    private Map<Id, String> accountPrimaryEmailMap;
    private List<AggregateResult> result;

    global OpportunityAmountSummarizerBatch(
        Map<Id, String> accountPrimaryEmailMap,
        List<AggregateResult> result
    ) {
        this.accountPrimaryEmailMap = accountPrimaryEmailMap;
        this.result = result;
    }

    global Iterable<SObject> start(Database.BatchableContext bc) {
        return result;
    }

    global void execute(Database.BatchableContext bc, List<sObject> records) {
        
        System.debug('records size: ' + records.size());

        //compose mail contents and group rows by account IDs
        Map<Id,String> mailContents = getMailContents(records);

        //create each email and add them to the list
        List<Messaging.SingleEmailMessage> mails = getMails(mailContents);

        //send all emails
        Messaging.sendEmail(mails);
    }

    /*
    * @author Emre Altan
    * @date Feb 19, 2021
    * @name getMailContents
    * @description composes the email contents for each account
    * @param List<sObject> records
    * @return Map<Id,String> mailContents
    */
    private Map<Id,String> getMailContents(List<sObject> records) {
        Map<Id,String> mailContents = new Map<Id,String>();
        for (sObject s : records) {
            AggregateResult ar = (AggregateResult) s;
            Id accountId = (Id) ar.get('AccountId');
            String accountName = (String) ar.get('AccountName');
            String stageName = (String) ar.get('StageName');
            String sumAmount = (String) ar.get('SumAmount');

            String content = mailContents.get(accountId);
            if(String.isBlank(content)) {
                //initialize html content
                content = '<p>Below is a table of opportunities related to the account: ' +
                accountName + '</p>' + 
                '<table border="1" style="border-collapse: collapse;font-family: Helvetica;" cellpadding="7px">' + 
                '<tr style="background: #ddd;"><th>Account</th><th>Stage</th><th>Amount</th></tr>';
            }

            //add row to the table
            content += '<tr><td>' + accountName + '</td><td>' + stageName + '</td><td>' + sumAmount + '</td></tr>';

            //update map item
            mailContents.put(accountId, content);
        }

        return mailContents;
    }

    /*
    * @author Emre Altan
    * @date Feb 19, 2021
    * @name getMails
    * @description creates a SingleEmailMessage object for each account
    * @param Map<Id,String> mailContents
    * @return List<Messaging.SingleEmailMessage> mails
    */
    private List<Messaging.SingleEmailMessage> getMails(Map<Id,String> mailContents) {
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        for (Id accountId : mailContents.keySet()) {
            String mailContent = mailContents.get(accountId);

            //close table tag
            mailContent += '</table>';

            //create new SingleEmailMessage object and add it to the list
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setToAddresses(
                new List<string>{ accountPrimaryEmailMap.get(accountId) }
            );
            message.setSubject('Opportunity Summary');
            message.setHtmlBody(mailContent);
            mails.add(message);
        }

        return mails;
    }

    global void finish(Database.BatchableContext bc) {
        AsyncApexJob a = [
            SELECT
                Id,
                Status,
                NumberOfErrors,
                JobItemsProcessed,
                TotalJobItems,
                CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id = :BC.getJobId()
        ];
        System.debug('********: ' + a.Id);
    }
}