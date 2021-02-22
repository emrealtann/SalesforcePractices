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
        
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        System.debug('records size: ' + records.size());

        //compose mail contents and group rows by account IDs
        Map<Id,String> mailContents = new Map<Id,String>();
        for (sObject s : records) {
            AggregateResult ar = (AggregateResult) s;
            Id accountId = (Id) ar.get('AccountId');
            String accountName = (String) ar.get('AccountName');
            String stageName = (String) ar.get('StageName');
            String sumAmount = (String) ar.get('SumAmount');

            String content = mailContents.get(accountId);
            if(String.isBlank(content)) {
                content = '<p>Below is a table of opportunities related to the account: ' +
                accountName + '</p>' + 
                '<table border="1" style="border-collapse: collapse;font-family: Helvetica;" cellpadding="7px">' + 
                '<tr style="background: #ddd;"><th>Account</th><th>Stage</th><th>Amount</th></tr>';
            }

            content += '<tr><td>' + accountName + '</td><td>' + stageName + '</td><td>' + sumAmount + '</td></tr>';
            mailContents.put(accountId, content);
        }

        //create each email and add them to the list
        for (Id accountId : mailContents.keySet()) {
            String mailContent = mailContents.get(accountId);
            mailContent += '</table>';
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setToAddresses(
                new List<string>{ accountPrimaryEmailMap.get(accountId) }
            );
            message.setSubject('Opportunity Summary');
            message.setHtmlBody(mailContent);
            mails.add(message);
        }

        //send all emails
        Messaging.sendEmail(mails);

        // String response = '';
        // try {
        //     Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(mails);

        //     if (!resultMail[0].isSuccess()) {
        //         response = resultMail[0].getErrors().get(0).getMessage();
        //     }
        // } catch (System.EmailException ex) {
        //     response = ex.getMessage();
        // }
        // System.debug('Send Email Error: ' + response);
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
