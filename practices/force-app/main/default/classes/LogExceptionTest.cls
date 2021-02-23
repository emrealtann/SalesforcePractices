@isTest
private class LogExceptionTest {
    static testmethod void testLogException()
    {
        try
        {
           integer i = 1/0;    
        }
        catch(exception ex)
        {
            new LogException().Log(ex);
        }
        
        try
        {
          Account acc = [SELECT Id, Name FROM Account 
                         WHERE Name =  '7uygft6'];            
        }
        catch(exception ex)
        {
            new LogException().Log(ex);
        }

        Test.startTest();
        List<Error_Log__c> logs = [select Id, Name, CreatedById, Exception_Type__c, Exception_Message__c from Error_Log__c];
        System.assertEquals(2, logs.size());
        Test.stopTest();
    }
}