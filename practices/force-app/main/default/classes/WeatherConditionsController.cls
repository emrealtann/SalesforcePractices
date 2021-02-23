/*
 * @author Emre Altan
 * @date Feb 23, 2021
 * @name WeatherConditionsController
 * @description controller class for the WeatherConditions visualforce page
 */
public inherited sharing class WeatherConditionsController{
	ApexPages.StandardController sc;
    private Account account;
    private String accountId = ApexPages.currentPage().getParameters().get('account');
    private String apiKey = 'da6c48f164d48aa5a2568cf7fc13c7a3';
    private String description = '';
    private Decimal temperature;
    private String imageCode = '';
    private String city = '';

	public WeatherConditionsController(ApexPages.StandardController sc){
		this.sc = sc;
        account = [select Id, Name, ShippingCity from Account WHERE id = :accountId];
        city = account.ShippingCity;

        if(!String.isBlank(city)) {
            getWeatherConditions();
        }
	}

	public void getWeatherConditions(){
		Http http = new Http();
		HttpRequest request = new HttpRequest();
		request.setEndpoint('https://api.openweathermap.org/data/2.5/weather?q=' + account.ShippingCity + '&appid=' + apiKey);
		request.setMethod('GET');
		HttpResponse response = http.send(request);
		// If the request is successful, parse the JSON response.
		if (response.getStatusCode() == 200){

			// Deserialize the JSON string into collections of primitive data types.
			WeatherWrapper wrapper = (WeatherWrapper)JSON.deserialize(response.getBody(), WeatherWrapper.class);
			// Cast the values in the 'animals' key as a list
			List<WeatherDetails> weathers = (List<WeatherDetails>)wrapper.weather;
			for (WeatherDetails weather : weathers){
				System.debug(weather);
                description = weather.description;
                imageCode = weather.icon;
			}

            temperature = wrapper.main.temp;
		}
	}

    public String getCity() {
        return city;
    }

    public String getDescription() {
        return description;
    }
    
    public Decimal getTemperature() {
        return temperature;
    }

    public String getImageCode() {
        return imageCode;
    }
}