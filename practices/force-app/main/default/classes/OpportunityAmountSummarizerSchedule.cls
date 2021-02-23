/*
* @author Emre Altan
* @date Feb 19, 2021
* @name OpportunityAmountSummarizerSchedule
* @description schedule class to calculate and send opportunity summary emails by using a batch in some specific periods
*/
global inherited sharing class OpportunityAmountSummarizerSchedule implements Schedulable {
    @ReadOnly
    global void execute(SchedulableContext ctx) {

        List<Contact> primaryContacts = [select Id, AccountId, Email from Contact where Is_Primary_Contact__c = true];
        
        //fill map object
        Map<Id,String> accountPrimaryEmailMap = new Map<Id,String>();
        for(Contact c : primaryContacts) {
            if(!accountPrimaryEmailMap.containsKey(c.AccountId)) {
                accountPrimaryEmailMap.put(c.AccountId, c.Email);
            }
        }

        //will use this in where clause. there is no need to summarize all account opportunities. just get who has a primary contact.
        Set<Id> accountIdSet = accountPrimaryEmailMap.keySet();
        
        //time filter
        DateTime nowDate = System.now();
        Date startDate = Date.newinstance(nowDate.year(), nowDate.month(), 1);
        System.debug('Schedule start for: ' + string.valueOfGmt(startDate));

        List<AggregateResult> result = [select AccountId, Account.Name AccountName, StageName, format(sum(Amount)) SumAmount 
            from Opportunity 
            where AccountId in :accountIdSet 
            and (CreatedDate >= :startDate or LastModifiedDate >= :startDate)
            group by AccountId, Account.Name, StageName order by AccountId];

        //execute batch
        OpportunityAmountSummarizerBatch batch = new OpportunityAmountSummarizerBatch(accountPrimaryEmailMap, result);
        Database.executeBatch(batch);
    }
}

/****************SCHEDULE CALL SCRIPT*********************/
/* OpportunityAmountSummarizerSchedule summarizerSchedule = new OpportunityAmountSummarizerSchedule();
// Seconds Minutes Hours Day_of_month Month Day_of_week optional_year

//daily at 10:00 AM
String sch = '0 0 10 * * ?';
String jobID = System.schedule('Opportunity Amount Summarizer', sch, summarizerSchedule);

//once a week (Friday at 1:00 PM)
String sch2 = '0 0 13 ? * 6';
String jobID2 = System.schedule('Opportunity Amount Summarizer', sch2, summarizerSchedule);

//once a month(Last Friday of the Month at 6:00 PM)
String sch3 = '0 0 18 L * 6';
String jobID3 = System.schedule('Opportunity Amount Summarizer', sch3, summarizerSchedule); */
/****************SCHEDULE CALL SCRIPT*********************/

/* OpportunityAmountSummarizerSchedule s = new OpportunityAmountSummarizerSchedule();
s.execute(null); */