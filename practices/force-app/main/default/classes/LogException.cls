public class LogException extends Exception {
    public String StackTrace {get; set;}
    public String ClassName {get; set;}
    public String MethodName {get; set;}
        
    public void log(Exception ex)
    {
     try
        {
            extractExceptionData(ex); 
            writeToObject(ex);
            System.debug(ex.getMessage());            
        }
        catch(Exception e)
        {
            new LogException().log(e);            
        }                 
    }
    
    public void extractExceptionData(Exception ex)
    {
        try
        {
            stackTrace = ex.getStackTraceString()
                         .substringBefore('\n');
            
            className = stackTrace.substringAfter('.')
                        .substringBefore('.'); 
            
            methodName = stackTrace.substringBefore(':')
                         .substringAfter(className)
                         .substringAfter('.');    
        }
        catch(Exception e)
        {
            new LogException().log(e); 
        }                      
    }
    
    public void writeToObject(Exception ex)
    {
     try
        {
            Error_Log__c logger = new Error_Log__c();
            logger.Stack_Trace__c = ex.getStackTraceString();
            logger.Name = className;
            logger.Method_Name__c = methodName;
            logger.Line_Number__c = ex.getLineNumber();
            logger.Exception_Type__c = ex.getTypeName();
            logger.Exception_Cause__c = String.valueOf(ex.getCause());
            
            logger.Exception_Message__c = ex.getMessage();
            
            insert logger;    
        }
        
        catch(Exception e)
        {
            new LogException().log(e);     
        }
        
    }
    
}