/*
* @author Emre Altan
* @date Feb 23, 2021
* @name WeatherConditionsTest
* @description test file for WeatherConditionsTest visualforce page controller
*/
@isTest
private class WeatherConditionsTest {
    /*
    * @author Emre Altan
    * @date Feb 23, 2021
    * @name testWeatherConditions
    * @description test method for WeatherConditionsController methods
    * @param null
    * @return void
    */
    static testmethod void testWeatherConditions() {

        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('GetWeatherResource');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        // Associate the callout with a mock response
        Test.setMock(HttpCalloutMock.class, mock);

        Account addedAccount = new Account(
            Name='Weather Account Test',
            ShippingStreet='123 Ave No:35',
            ShippingCity='Paris',
            ShippingCountry='France'
        );
        insert addedAccount;

        Test.startTest();

        ApexPages.StandardController sc = new ApexPages.StandardController(addedAccount);

        Test.setCurrentPageReference(new PageReference('Page.myPage')); 
        System.currentPageReference().getParameters().put('account', addedAccount.Id);
        
        WeatherConditionsController controller = new WeatherConditionsController(sc);
        
        String city = controller.getCity();
        System.assertEquals('Paris', city);

        String description = controller.getDescription();
        Boolean isDescBlank = String.isBlank(description);
        System.assertNotEquals(true, isDescBlank);

        String imageCode = controller.getImageCode();
        Boolean isImageCodeBlank = String.isBlank(imageCode);
        System.assertNotEquals(true, isImageCodeBlank);

        Decimal temp = controller.getTemperature();
        System.assertNotEquals(0, temp);

        Test.stopTest();
    }
}