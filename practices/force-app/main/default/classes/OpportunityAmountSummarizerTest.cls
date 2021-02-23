/*
* @author Emre Altan
* @date Feb 19, 2021
* @name OpportunityAmountSummarizerTest
* @description test file for OpportunityAmountSummarizer schedule and batch classes
*/
@isTest
private class OpportunityAmountSummarizerTest {
    
    /*
    * @author Emre Altan
    * @date Feb 19, 2021
    * @name testScheduledJob
    * @description test method for schedule job
    * @param null
    * @return void
    */
    static testmethod void testScheduledJob() {

        Account addedAccount = new Account(Name='OppSummTest');
        insert addedAccount;

        Contact primaryContact = new Contact(
            AccountId = addedAccount.Id, 
            FirstName = 'OppSumm', 
            LastName = 'TestContact', 
            Phone = '1111111111', 
            Email = 'emre.altan@osf.digital', 
            Is_Primary_Contact__c = true
        );

        insert primaryContact;

        // Create some out of date Opportunity records
        List<Opportunity> opptys = new List<Opportunity>();
        Date closeDate = Date.today().addDays(7);

        List<String> stageNames = new List<String> { 'Prospecting', 'Qualification', 'Needs Analysis', 'Value Proposition' };

        for (Integer i=0; i<10; i++) {
            Opportunity o = new Opportunity(
                Name = 'Opportunity ' + i,
                CloseDate = closeDate,
                StageName = stageNames[math.mod(i, 4)],
                Amount = i * 1000,
                AccountId = addedAccount.Id
            );
            opptys.add(o);
        }
        insert opptys;

        Test.startTest();
            //Execute schedule
            OpportunityAmountSummarizerSchedule s = new OpportunityAmountSummarizerSchedule();
            s.execute(null);
        Test.stopTest();

        // check apex batch is in the job list
        List<AsyncApexJob> jobsApexBatch = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob 
            where JobType = 'BatchApex' and ApexClass.Name = 'OpportunityAmountSummarizerBatch'];

        System.assertEquals(1, jobsApexBatch.size(), 'expecting one specific apex batch job called "OpportunityAmountSummarizerBatch"');
    }
}
