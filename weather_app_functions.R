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

# you will need an API key to access the data from openweathermaps.org 
# you have to sign up for a free account to get the api key 
# the api key is private and should not be shared with other people

my_api_key <- "insert your api key here" 


# The following function takes the location (in string format) and your apiKey (in string format) as input.
# The function returns the weather data for a specific location as a list.
# The weather data are provided by www.openweathermap.org

get_weather <- function(location, apiKey) {
  
  # first, we need to use tidygeocoder::geo_osm to get the longitude and the latitude of the desired location. 
  
  latitude <- tidygeocoder::geo_osm(location)$lat[1]
  longitude <- tidygeocoder::geo_osm(location)$long[1]
  
  if (is.na(latitude) | is.na(longitude)) {
    
    stop("Please type in a valid location")
    
  }
  
  # now, we access www.openweatherapp.org and retrieve the weather data. 
  
  my_url <- paste0("https://api.openweathermap.org/data/2.5/onecall?lat=", latitude, "&lon=", longitude,
                  "&exclude=FALSE&appid=", apiKey)
  
  # We retrieve the data using the url 
  my_raw_results <- httr::GET(my_url)
  
  # We check whether we successfully retrieved data from the API. 
  
  if(status_code(my_raw_results) != 200){
    
    stop("Something went wrong. You might have put in a wrong location or apiKey. Please check for spelling mistakes and try again.")
    
  }
  
  # And we transform the infromation we retrieved from JSON format into a usable format in R . 
  
  my_content <- httr::content(my_raw_results, as = "text")
  
  my_content_from_json <- jsonlite::fromJSON(my_content)
  
  return(my_content_from_json)
  
}

## Example for get_weather 
get_weather("Amsterdam, Niederlande", Sys.getenv("MY_API"))


# This function gets as input whether the user wants the current weather forecast, the hourly forecast, 
# or the daily forecast, the location of interest and the apiKey. It returns a list with the desired wheather information.

get_your_forecast <- function(cur_hour_day = "current", location, apiKey) {
  
  full_weather <- get_weather(location, apiKey)
  
  weather <- NA
  
  if (cur_hour_day == "current") {
    
    weather <- full_weather$current 
    
  } else if (cur_hour_day == "hourly") {
    
    weather <- full_weather$hourly
    
  } else if (cur_hour_day == "daily") {
    
    weather <- full_weather$daily
    
  } 
  
  return(weather)
  
}

## Example for yourForecast()
get_your_forecast("hourly", "Amsterdam, Niederlande", sys.getenv(MY_API))
  

# This function takes a location (as a string) as input and returns and saves a map of this location using leaflet::leaflet().  

get_map <- function(location) {
  
  latitude <- tidygeocoder::geo_osm(location)$lat[1]
  longitude <- tidygeocoder::geo_osm(location)$long[1]
  
  if (is.na(latitude) | is.na(longitude)) {
    
    stop("Please type in a valid location")
    
  }
  
  # Retrieve an open map and save it in the object "map" and save ot on the computer.
  
  map <- leaflet::leaflet() %>% 
    leaflet::setView(lng = longitude, lat = latitude, zoom = 11) %>%
    leaflet::addProviderTiles(providers$Stamen.TonerLite, options = providerTileOptions(noWrap = TRUE))
  mapview::mapshot(map, file = "App-1/Rplot.png")
  
  # Now open the png of the map again. 
  
  map <- image_read("App-1/Rplot.png")
  
  return(map)
  
}

## Example for get_map()
get_map("Amsterdam, Niederlande")


# This function gets a location and an apiKey as input. It looks for the current weather for the specified location and 
# saves and returns a map of the location.
# The map includes icons that correspond to the current weather forecast for this location. 

get_icon_map <- function(location, apiKey) {
  
  # first, we need to use tidygeocoder::geo_osm to get the longitude and the latitude of the desired location. 
  
  latitude <- tidygeocoder::geo_osm(location)$lat[1]
  longitude <- tidygeocoder::geo_osm(location)$long[1]
  
  if (is.na(latitude) | is.na(longitude)) {
    
    stop("Please type in a valid location")
    
  }
  
  # Then, we use the leafllet() function to retrieve an open map with a specific latitude and longitude and zoom level.
  # And we save it in a file called "App-1/Rplot.png".
  
  map <- leaflet() %>% 
    setView(lng = longitude, lat = latitude, zoom = 12) %>%
    addProviderTiles(providers$Stamen.TonerLite, options = providerTileOptions(noWrap = TRUE))
  mapshot(map, file = "App-1/Rplot.png")
  
  # We retrieve the weather data from the location we are interested in
  
  my_weather <- get_weather(location, apiKey)
  
  # We open the map again, that we previously saved. 
  # And we open the image of an icon that reflects the current weather we are interested in. 
  
  mymap <- image_scale(image_read(path = "App-1/Rplot.png"), "x400")
  imageName <- paste("App-1/www/",my_weather$current$weather$icon,".png", sep = "")
  icon <- image_scale(image_read(imageName), "x100")
  
  # Then we merge the map and the icon and save it in the file myMapImage 
  
  img <- c(mymap, icon)
  myMapImage <- image_mosaic(img)
  
  # And we create another image that uses two instead of one icon on the map.
  
  image1 <- image_composite(mymap, icon, offset = "+20+20")
  image2 <-image_composite(image1, icon, offset = "+280+180")
  
  # And we save both images on the computer. 
  
  image_write(myMapImage, path = "my_weather.png", format = "png")
  image_write(image2, path = "my_weather2.png", format = "png")
  
  return(myMapImage)
  
}

## Example for get_icon_map()
get_icon_map("Amsterdam, Niederlande", sys.getenv("MY_API"))


# This function takes a location (string) and an apiKey (string) as input and returns an image that corresponds 
# to the current weather forecast for this location using openweathermap.org

get_weather_image <- function(location, apiKey) {
  
  # Again, we retrieve the  long/lat of the location and the current weather.
  
  latitude <- tidygeocoder::geo_osm(location)$lat[1]
  longitude <- tidygeocoder::geo_osm(location)$long[1]
  
  if (is.na(latitude) | is.na(longitude)) {
    
    stop("Please type in a valid location")
    
  }
  
  my_weather <- get_weather(location, apiKey)
  
  # Now, depending on the current weather at the location, we save a specific image in the object weather_image. 
  
  # If the weather is sunny, store an image of a clear sky in weather_image.
  
  if (my_weather$current$weather$icon == "01d") {
    
    weather_image <- image_read("App-1/www/clearSky.jpg")
    image_info(weather_image)
    weather_image <- image_crop(weather_image, "1920x1280")
    
    # If the weather is cloudly in any way, store an image of a cloudy sky in weather_image.
    
  } else if (my_weather$current$weather$icon == "02d" | my_weather$current$weather$icon == "03d" | my_weather$current$weather$icon == "04d") {
    
    weather_image <- image_read("App-1/www/clouds.jpg")
    weather_image <- image_crop(weather_image, "1920x1280")
    
    # If the weather is rainy, store an image of rain in weather_image.
    
  } else if (my_weather$current$weather$icon == "09d" | my_weather$current$weather$icon == "10d") {
    
    weather_image <- image_read("App-1/www/rain.jpg")
    
    # If the weather is a thunderstorm, store an image of a thundestorm in weather_image.
    
  } else if (my_weather$current$weather$icon == "11d") {
    
    weather_image <- image_read("App-1/www/thunder2.jpg")
    
    # If the weather is snowy, store an image of a snowy landschape in weather_image.
    
  } else if (my_weather$current$weather$icon == "13d") {
    
    weather_image <- image_read("App-1/www/snow.jpg")
    
    # If the weather is misty, store an image of a misty landschape in weather_image.
    
  } else if (my_weather$current$weather$icon == "50d") {
    
    weather_image <- image_read("App-1/www/misty.jpg")
    
  }
    
  return(weather_image) 

}

## Example for get_weather_image()
get_weather_image("Amsterdam, Niederlande", sys.getenv("MY_API"))


# write a function that returns a GIF with weather icons that fly over the map of the users chosen location 

get_weather_gif <- function(location, apiKey) {
  
  my_weather <- get_weather(location, apiKey)
  
  ## create a map and overlay it with the weather icon for the current weather
  
  # get the map and scale the png file
  map <- get_map(location)
  map <- image_scale(map, "x500")
  
  # get the icon and scale it
  icon <- image_read(paste("App-1/www/", my_weather$current$weather$icon,".png", sep=""))
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
  image_write(animation, "my_weather.gif")
  
  return(animation)
  
}

## Example for get_weather_gif ()
get_weather_gif("Amsterdam, Niederlande", sys.getenv("MY_API"))


####################################################
#### test functions ################################
####################################################

testthat::get_weather()
# shinytest and/or testthat 

apiKey <- Sys.getenv("MY_API")

latitude <- tidygeocoder::geo_osm("Amsterdam, Niederlande")$lat[1]
longitude <- tidygeocoder::geo_osm("Amsterdam, Niederlande")$long[1]

# now, we access www.openweatherapp.org and retrieve the weather data. 

my_url <- paste0("https://api.openweathermap.org/data/2.5/onecall?lat=", latitude, "&lon=", longitude,
                 "&exclude=FALSE&appid=", apiKey)

# the data are in JSON format, they have to be transformed before we can use them. 
my_raw_results <- httr::GET(my_url)

status_code(my_raw_results)
