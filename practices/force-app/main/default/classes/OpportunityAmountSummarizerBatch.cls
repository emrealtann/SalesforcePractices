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
        // process each batch of records
        List<Id> accountIds = new List<Id>();
        Boolean addedToList = false;
        String emailContent = '<table border="1" style="border-collapse: collapse"><tr><th>Account</th><th>Stage</th><th>Amount</th></tr>';
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();

        for (sObject s : records) {
            AggregateResult ar = (AggregateResult) s;
            Id accountId = (Id) ar.get('AccountId');
            String accountName = (String) ar.get('AccountName');
            String stageName = (String) ar.get('StageName');
            String sumAmount = (String) ar.get('SumAmount');

            //check if account id has changed (for grouping table rows)
            if (accountIds.contains(accountId) || !addedToList) {
                String row = '<tr><td>' + accountName + '</td><td>' + stageName + '</td><td>' + sumAmount + '</td></tr>';
                System.debug(row);
                addedToList = true;
                emailContent += row;
            } else {
                //finish formatting and send email
                addedToList = false;
                emailContent = '<p>Below is a table of opportunities related to the account: ' + accountName + '</p>' + emailContent;
                emailContent += '</table>';
                System.debug(emailContent);

                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.setToAddresses(
                    new List<string>{ accountPrimaryEmailMap.get(accountId) }
                );
                message.setSubject('Opportunity Summary');
                message.setHtmlBody(emailContent);
                mails.add(message);
            }
        }

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