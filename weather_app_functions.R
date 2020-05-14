### weather_app in R Shiny ###

library(httr)
library(jsonlite)
library(dplyr)
library(leaflet)
library(mapview)
library(magick)
library(tidygeocoder)

# tidygeocoder::geo_osm() uses a string with an address as input and returns
# the latitude and longitude of the location. 

# You will need an API key to access the data from openweathermaps.org 
# you have to sign up for a free account to get the api key 
# the api key is private and should not be shared with other people

myApiKey <- "insert your api key here" 


# The following function takes the location (in string format) and your apiKey (in string format) as input.
# The function returns the weather data for a specific location as a list.
# The weather data are provided by www.openweathermap.org

getWeather <- function(location, apiKey){
  
  # first, we need to use tidygeocoder::geo_osm to get the longitude and the latitude of the desired location. 
  
  latitude <- tidygeocoder::geo_osm(location)$lat[1]
  longitude <- tidygeocoder::geo_osm(location)$long[1]
  
  # now, we access www.openweatherapp.org and retrieve the weather data. 
  
  myurl <- paste0("https://api.openweathermap.org/data/2.5/onecall?lat=", latitude, "&lon=", longitude,
                  "&exclude=FALSE&appid=", apiKey)
  
  # the data are in JSON format, they have to be transformed before we can use them. 
  myRawResults <- httr::GET(myurl)
  
  mycontent <- httr::content(myRawResults, as = "text")
  
  myContentFromJson <- jsonlite::fromJSON(mycontent)
  
  return(myContentFromJson)
  
}

## Example for getWeather ##
getWeather("Amsterdam, Niederlande", Sys.getenv("MY_API"))



# This function gets as input whether the user wants the current weather forecast, the hourly forecast, 
# or the daily forecast, the location of interest and the apiKey. It returns a list with the desired wheather information.

yourForecast <- function(currentHourlyDaily = current, location, apiKey){
  
  fullWeather <- getWeather(location, apiKey)
  
  if(currentHourlyDaily == "current"){
    
    weather <- fullWeather$current 
    
  } else if(currentHourlyDaily == "hourly"){
    
    weather <- fullWeather$hourly
    
  } else if(currentHourlyDaily == "daily"){
    
    weather <- fullWeather$daily
    
  }
  
  return(weather)
  
}

## Example for yourForecast()
yourForecast("hourly", "Amsterdam, Niederlande", sys.getenv(MY_API))
  

# This function get a location (as a string) as input and returns and saves a map of this location using leaflet::leaflet().  

getMap <- function(location){
  
  latitude <- tidygeocoder::geo_osm(location)$lat[1]
  longitude <- tidygeocoder::geo_osm(location)$long[1]
  
  map <- leaflet::leaflet() %>% 
    leaflet::setView(lng = longitude, lat = latitude, zoom = 11) %>%
    leaflet::addProviderTiles(providers$Stamen.TonerLite, options = providerTileOptions(noWrap = TRUE))
  mapview::mapshot(map, file = "App-1/Rplot.png")
  map <- image_read("App-1/Rplot.png")
  
  return(map)
  
}

## Example for getMap()
getMap("Amsterdam, Niederlande")

# This function gets a location and an apiKey as input. It looks for the current weather for the specified location and 
# saves and returns a map of the location.
# The map includes icons that correspond to the current weather forecast for this location. 

getIconMap <- function(location, apiKey){
  
  latitude <- tidygeocoder::geo_osm(location)$lat[1]
  longitude <- tidygeocoder::geo_osm(location)$long[1]
  
  map <- leaflet() %>% 
    setView(lng = longitude, lat = latitude, zoom = 12) %>%
    addProviderTiles(providers$Stamen.TonerLite, options = providerTileOptions(noWrap = TRUE))
  mapshot(map, file = "App-1/Rplot.png")
  
  myWeather <- getWeather(location, apiKey)
  
  mymap <- image_scale(image_read(path = "App-1/Rplot.png"), "x400")
  imageName <- paste("App-1/www/",myWeather$current$weather$icon,".png", sep = "")
  icon <- image_scale(image_read("App-1/www/02d.png"), "x100")
  
  img <- c(mymap, icon)
  myMapImage <- image_mosaic(img)
  
  image1 <- image_composite(mymap, icon, offset = "+20+20")
  image2 <-image_composite(image1, icon, offset = "+280+180")
  
  image_write(myMapImage, path = "myWeather.png", format = "png")
  image_write(image2, path = "myWeather2.png", format = "png")
  
  return(myMapImage)
  
}

## Example for getIconMap()
getIconMap("Amsterdam, Niederlande", sys.getenv("MY_API"))


# This function takes a location (string) and an apiKey (string) as input and returns an image that corresponds 
# to the current weather forecast for this location using openweathermap.org

getWeatherImage <- function(location, apiKey){
  
  latitude <- tidygeocoder::geo_osm(location)$lat[1]
  longitude <- tidygeocoder::geo_osm(location)$long[1]
  
  myWeather <- getWeather(location, apiKey)
  
  if(myWeather$current$weather$icon == "01d"){
    
    weatherImage <- image_read("App-1/www/clearSky.jpg")
    image_info(weatherImage)
    weatherImage <- image_crop(weatherImage, "1920x1280")
    
  } else if(myWeather$current$weather$icon == "02d" | myWeather$current$weather$icon == "03d" | myWeather$current$weather$icon == "04d"){
    
    weatherImage <- image_read("App-1/www/clouds.jpg")
    weatherImage <- image_crop(weatherImage, "1920x1280")
    
  } else if(myWeather$current$weather$icon == "09d" | myWeather$current$weather$icon == "10d"){
    
    weatherImage <- image_read("App-1/www/rain.jpg")
    
  } else if(myWeather$current$weather$icon == "11d"){
    
    weatherImage <- image_read("App-1/www/thunder2.jpg")
    
  } else if(myWeather$current$weather$icon == "13d"){
    
    weatherImage <- image_read("App-1/www/snow.jpg")
    
  } else if(myWeather$current$weather$icon == "50d"){
    
    weatherImage <- image_read("App-1/www/misty.jpg")
    
  }
    
  return(weatherImage) 

}


# write a function that returns a GIF with weather icons that fly over the map of the users chosen location 
# TO BE CONTINUED 

getWeatherGif <- function(location, apiKey){
  
  myWeather <- getWeather(location, apiKey)
  
  ## create a map and overlay it with the weather icon for the current weather
  
  # get the map and scale the png file
  map <- getMap(location)
  map <- image_scale(map, "x500")
  
  # get the icon and scale it
  icon <- image_read(paste("App-1/www/", myWeather$current$weather$icon,".png", sep=""))
  icon <- image_scale(icon, "x200")
  
  # create different png files that will make up the GIF
  image1 <- image_composite(map, icon, offset = "+40+20")
  image11 <- image_composite(image1, icon, offset = "+20+250")
  image2 <- image_composite(map, icon, offset = "+120+20")
  image22 <- image_composite(image2, icon, offset = "+100+250")
  image3 <- image_composite(map, icon, offset = "+200+20")
  image33 <- image_composite(image3, icon, offset = "+180+250")
  image4 <- image_composite(map, icon, offset = "+280+20")
  image44 <- image_composite(image4, icon, offset = "+260+250")
  image5 <- image_composite(map, icon, offset = "+360+20")
  image55 <- image_composite(image5, icon, offset = "+340+250")
  
  # put the different images together to create and interactive GIF
  img <- c(image11, image22, image33, image44, image55)
  animation <- image_animate(image_scale(img, "800x800"), fps = 1, dispose = "previous")
  
  # save the GIF 
  image_write(animation, "myWeather.gif")
  
  return(animation)
  
}


####################################################
#### test functions ################################
####################################################

myApi <- apiKey

getWeatherGif("Marl, Deutschland", myApi)

### here some raw things to test my function ###
