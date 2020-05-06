# weather_app
## Weather-App project

What will you implement first?
* I will first try to get weather data using the API by https://openweathermap.org.
What is the goal?
* The goal is to create a weather app where users can get weather forecasts for a location of their choice. They can choose to get information about the current weather, the hourly weather forecast for the next 24 hours, or the daily weather forecast for the next 7 days.  
What do you cut if you’re short on time?
* I could cut the possibility that users choose between the current weather, an hourly forecast and a daily forecast. Then, the users would always get the current weather and an hourly forecast for the next 24 hours.
What do you extend if you have extra time?
* I will try to implement a map of the specified location with symbols on the map that are corresponding to the weather forecast for this specific location.   
* I could try to implement my own function that gets the latitude and longitude of a location (instead of using the package tidygeocoder)


The code:
Will you use R or Python?
* I will use R and R Shiny
Which packages will you use?
* I will use the packages httr, jsonlite, dplyr, shiny, tidygeocoder
Which functions will you create? (A rough flowchart, nothing too detailed)
* First, the user opens the Shiny App.
* Then, they type in the location they are interested in and they choose what kind of weather forecast they would like to have (current weather, hourly forecast, daily forecast, there will be a drop down menu for the options).
* The user press the button "search" to start the search for the weather data.
* Then, the function tidygeocoder::geo_osm() will search for the longitude and latitude of this location and save it in an output file.
* The output will be used in the function getWeather(longitude, latitude) to access the openweathermap.org API, to retrieve the weather data for the location, transform it to usable data format and save it as a file.
* with an ifelse statement, the app will check if there is actually weather data in the output we got from getWeather(). If not, an error message will be shown to the user. "The location you entered could not be found. Please check the location for spelling mistakes."
* If the data retrieved from  is actually valid, the app will create an output table with the information the user was looking for. 
* ![GitHub Logo](/images/logo.png)
Format: ![Alt Text](url)
![GitHub Flowchart](C:/Users/JoeBe/Documents/UvA/1. Programming - Next Step/test.png)

A one-liner for each function to explain its purpose (if you have trouble explaining what a function does in one sentence, the function probably does too much and should be refactored into multiple functions).
*
