### weather_app in R Shiny ###

library(httr)
library(jsonlite)
library(dplyr)
library(leaflet)
library(mapview)
library(magick)
library(stringr)


# you will need an API to use all the functions listed here.
# to get an api key, you have to sign up at www.openweathermap.org for a free account.
# the api key is private and should not be shared with other people

# my_api_key <- "insert your api key here"



#' Geocode gets the longitude and latitude of a chosen location.
#'
#' The function \emph{geocode} retrieves the longitude and the latitude of a location through www.openstreetmap.org.
#'
#' @param location String that describes a geographic location.
#'
#' @return A data frame with the input string (location), the longitude and the latitude.
#'
#' @examples
#' long_lat <- geocode("Amsterdam, Netherlands")
#'
#' @export
geocode <- function(location){

  # split the location string, that the function got as input, into the different words.
  my_location <- stringr::str_split(location, boundary("word"))
  my_location_string <- my_location[[1]][1]

  for(i in 2:length(my_location[[1]])){
    my_location_string <- paste0(my_location_string, "+", my_location[[1]][i])
  }

  # Write down the url that retrieves the long/lat information from openstreetmap.org

  my_url <- paste0("https://nominatim.openstreetmap.org/search?q=", my_location_string,
                  "&format=json&limit=1")

  # call the Url, retrieve the data and check if it was successful.
  my_raw_results <- httr::GET(my_url)

  if (status_code(my_raw_results)[[1]] != 200) {
    stop("Please enter a valid location!")
  }

  # Transform the JSON data into useable format.
  my_content <- httr::content(my_raw_results, as = "text")

  my_content_from_json <- jsonlite::fromJSON(my_content)

  # check if data retrieval was successful
  if(length(my_content_from_json) == 0)  {
    stop("Something went wrong. Please check your input location")
  }

  # Save the longitude latitude data in an object and return it.
  geocode_data <- data.frame(3)
  geocode_data$location <- my_content_from_json$display_name
  geocode_data$latitude <- my_content_from_json$lat
  geocode_data$longitude <- my_content_from_json$lon

  return(geocode_data)

}




#' Retrieves weather data for an input location
#'
#' The function \emph{get_weather} retrieves weatherdata for a chosen location via www.openweathermap.org
#'
#' @param location String that describes a geographical location.
#'
#' @param api_key String that represents your personal api_key. To receive an api_key, please visit www.openweathermap.org and sign up for free.
#'
#' @return A complex list that includes a variety of weather data, such as current weather, daily weather, ...
#'
#' @example
#' weather_amsterdam <- get_weather("Amsterdam, Netherlands", my_api_key)
#'
#' @export
get_weather <- function(location, api_key) {

  # first, we need to use the function geocode(location) to get the longitude and the latitude of the desired location.

  latitude <- geocode(location)$latitude
  longitude <- geocode(location)$longitude

  # latitude <- tidygeocoder::geo_osm(location)$lat[1] # old version
  # longitude <- tidygeocoder::geo_osm(location)$long[1] # old version

  if (is.na(latitude) | is.na(longitude)) {

    stop("Please type in a valid location")

  }

  # now, we access www.openweatherapp.org and retrieve the weather data.

  my_url <- paste("https://api.openweathermap.org/data/2.5/onecall?lat=", latitude, "&lon=", longitude,
                  "&exclude=FALSE&appid=", api_key, sep ="")

  # We retrieve the data using the url
  my_raw_results <- httr::GET(my_url)

  # We check whether we successfully retrieved data from the API.

  if (status_code(my_raw_results)[[1]] != 200) {

    stop("Something went wrong. You might have put in a wrong location or api_key. Please check for spelling mistakes and try again.")

  }

  # And we transform the infromation we retrieved from JSON format into a usable format in R .

  my_content <- httr::content(my_raw_results, as = "text")

  my_content_from_json <- jsonlite::fromJSON(my_content)

  # check if data retrieval was successful
  if(length(my_content_from_json) == 0)  {
    stop("Something went wrong. Please check your apiKey and input location")
  }

  return(my_content_from_json)

}



#' get_forecast gets the current/hourly/daily weather forecast for a location.
#'
#' The function \emph{get_forecast} retrieves weather data from openweathermap.org.
#'
#' @param cur_hour_day String, either "current","hourly" or "daily".
#' @param location String that describes a geographic location.
#' @param api_key String that represents your personal api Key from www.openweathermap.org
#'
#' @return A complex list with hourly/daily/current weather data.
#'
#' @examples
#' my_forecast <- get_forecast("hourly", "Amsterdam, Niederlande", my_api_key)
#'
#' @export
get_forecast <- function(cur_hour_day = "current", location, api_key) {

  full_weather <- get_weather(location, api_key)

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



# This function takes a location (as a string) as input and returns and saves a map of this location using leaflet::leaflet().

#' get_map gets and saves a map using leaflet()
#'
#' @param location String that describes a geographic location.
#'
#' @return A png of a map.
#'
#' @examples
#' my_map <- get_map("Amsterdam, Niederlande")
#'
#' @export
get_map <- function(location) {

  # first, we need to use the function geocode(location) to get the longitude and the latitude of the desired location.

  latitude <- geocode(location)$latitude
  longitude <- geocode(location)$longitude

  # latitude <- tidygeocoder::geo_osm(location)$lat[1] # old version
  # longitude <- tidygeocoder::geo_osm(location)$long[1] # old version

  if (is.na(latitude) | is.na(longitude)) {

    stop("Please type in a valid location")

  }

  # Retrieve an open map and save it in the object "map" and on the computer.

  map <- leaflet::leaflet() %>%
    leaflet::setView(lng = longitude, lat = latitude, zoom = 11) %>%
    leaflet::addProviderTiles(providers$Stamen.TonerLite, options = providerTileOptions(noWrap = TRUE))
  mapview::mapshot(map, file = "www/map_plot.png")

  # Now open the png of the map again.

  map <- magick::image_read("www/map_plot.png")

  return(map)

}

#' get_icon gets weather icons.
#'
#' The function \emph{get_icon} saves the icon that reflects the current weather.
#'
#' @param location String that describes a geographic location.
#' @param api_key String that represents your personal api Key from www.openweathermap.org
#'
#' @return An image of the weather icons.
#'
#' @example
#'get_icon("Amsterdam, Niederlande", my_api_key)
#'
#' @export
get_icon <- function(location, api_key) {

  latitude <- geocode(location)$latitude
  longitude <- geocode(location)$longitude

  my_weather <- get_weather(location, api_key)

  image_name <- paste0('http://openweathermap.org/img/wn/',my_weather$current$weather$icon, '@2x.png')
  icon <- magick::image_scale(image_read(image_name), "x100")

  magick::image_write(icon, path = "www/weather_icon.png", format = "png")

}


#' get_icon_map creates a map with weather icons.
#'
#' The function \emph{get_icon_map} creates a map of a location with weather icons incorporated in it. The icons reflect the current weather.
#'
#' @param location String that describes a geographic location.
#' @param api_key String that represents your personal api Key from www.openweathermap.org
#'
#' @return An image that consists of a map with weather icons.
#'
#' @example
#'get_icon_map("Amsterdam, Niederlande", my_api_key)
#'
#' @export
get_icon_map <- function(location, api_key) {

  # first, we need to use the function geocode(location) to get the longitude and the latitude of the desired location.

  latitude <- geocode(location)$latitude
  longitude <- geocode(location)$longitude

  # latitude <- tidygeocoder::geo_osm(location)$lat[1] # old version
  # longitude <- tidygeocoder::geo_osm(location)$long[1] # old version

  if (is.na(latitude) | is.na(longitude)) {

    stop("Please type in a valid location")

  }

  # Then, we use the leafllet() function to retrieve an open map with a specific latitude and longitude and zoom level.
  # And we save it in a file called "map_plot.png".

  map <- leaflet::leaflet() %>%
    leaflet::setView(lng = longitude, lat = latitude, zoom = 12) %>%
    leaflet::addProviderTiles(providers$Stamen.TonerLite, options = providerTileOptions(noWrap = TRUE))
  mapview::mapshot(map, file = "www/map_plot.png")

  # We retrieve the weather data from the location we are interested in

  my_weather <- get_weather(location, api_key)

  # We open the map again, that we previously saved.
  # And we open the image of an icon that reflects the current weather we are interested in.

  my_map <- magick::image_scale(image_read(path = "www/map_plot.png"), "x400")
  image_name <- paste0('http://openweathermap.org/img/wn/',my_weather$current$weather$icon, '@2x.png')
  icon <- magick::image_scale(image_read(image_name), "x100")

  # Then we merge the map and the icon and save it in the file my_map_image

  img <- c(my_map, icon)
  my_map_image <- magick::image_mosaic(img)

  # And we create another image that uses two instead of one icon on the map.

  image1 <- magick::image_composite(my_map, icon, offset = "+20+20")
  image2 <- magick::image_composite(image1, icon, offset = "+280+180")

  # And we save both images on the computer.

  magick::image_write(my_map_image, path = "www/my_weather.png", format = "png")
  magick::image_write(image2, path = "www/my_weather2.png", format = "png")

  return(my_map_image)

}



#' get_weather_image returns an image that reflects the current weather
#'
#' @param location String that describes a geographic location.
#' @param api_key String that represents your personal api Key from www.openweathermap.org
#'
#' @return An image that reflects the current weahter forecast of a location (Either clear sky, rainy, cloudy, storm, misty, snowy)
#'
#' @example
#' my_weather_image <- get_weather_image("Amsterdam, Niederlande", my_api_key)
#'
#' @export
get_weather_image <- function(location, api_key) {

  # Again, we retrieve the  long/lat of the location and the current weather.

  latitude <- geocode(location)$latitude
  longitude <- geocode(location)$longitude

  # latitude <- tidygeocoder::geo_osm(location)$lat[1] # old version
  # longitude <- tidygeocoder::geo_osm(location)$long[1] # old version

  if (is.na(latitude) | is.na(longitude)) {

    stop("Please type in a valid location")

  }

  my_weather <- get_weather(location, api_key)

  # Now, depending on the current weather at the location, we save a specific image in the object weather_image.
  # E.g. If the weather is sunny, store an image of a clear sky in weather_image.

  if (my_weather$current$weather$icon == "01d") {

    weather_image <- magick::image_read("https://user-images.githubusercontent.com/64595164/82326387-09d50900-99dd-11ea-8ca1-fdbc291ab991.jpg")
    magick::image_info(weather_image)
    weather_image <- magick::image_crop(weather_image, "1920x1280")

    # If the weather is cloudly in any way, store an image of a cloudy sky in weather_image.

  } else if (my_weather$current$weather$icon == "02d" | my_weather$current$weather$icon == "03d" | my_weather$current$weather$icon == "04d") {

    weather_image <- magick::image_read("https://user-images.githubusercontent.com/64595164/82326873-cdee7380-99dd-11ea-9899-cd9379a824f9.jpg")
    weather_image <- magick::image_crop(weather_image, "1920x1280")

    # If the weather is rainy, store an image of rain in weather_image.

  } else if (my_weather$current$weather$icon == "09d" | my_weather$current$weather$icon == "10d") {

    weather_image <- magick::image_read("https://user-images.githubusercontent.com/64595164/82326953-e9f21500-99dd-11ea-80f3-5ddc2199632b.jpg")

    # If the weather is a thunderstorm, store an image of a thundestorm in weather_image.

  } else if (my_weather$current$weather$icon == "11d") {

    weather_image <- magick::image_read("https://user-images.githubusercontent.com/64595164/82326999-ffffd580-99dd-11ea-8317-cb0a01de15c7.jpg")

    # If the weather is snowy, store an image of a snowy landschape in weather_image.

  } else if (my_weather$current$weather$icon == "13d") {

    weather_image <- magick::image_read("https://user-images.githubusercontent.com/64595164/82327016-0b530100-99de-11ea-8131-b5e82581945d.jpg")

    # If the weather is misty, store an image of a misty landschape in weather_image.

  } else if (my_weather$current$weather$icon == "50d") {

    weather_image <- magick::image_read("https://user-images.githubusercontent.com/64595164/82327064-232a8500-99de-11ea-814c-e0fe6292dc5f.jpg")

  }

  weather_image <- image_crop(weather_image, "1920x500")

  magick::image_write(weather_image, path = "www/weather_image.png", format = "png")

  return(weather_image)

}



#' Creates a weather GIF for the current weather at a specific location.
#'
#' @param location String that describes a geographic location.
#' @param api_key String that represents your personal api Key from www.openweathermap.org
#'
#' @return A gif that reflects the weather at a chosen location.
#'
#' @example
#' my_gif <- my_weather_gif("Amsterdam, Niederlande", my_api_key)
#'
#' @export
get_weather_gif <- function(location, api_key) {

  my_weather <- get_weather(location, api_key)

  ## create a map and overlay it with the weather icon for the current weather

  # get the map and scale the png file
  map <- get_map(location)
  map <- magick::image_scale(map, "x500")

  # get the icon and scale it
  # icon <- image_read(paste0("App-1/www/", my_weather$current$weather$icon,".png"))
  icon <- magick::image_read(paste0('http://openweathermap.org/img/wn/',my_weather$current$weather$icon, '@2x.png'))
  icon <- magick::image_scale(icon, "x200")

  # create different png files that will make up the GIF
  image1 <- magick::image_composite(map, icon, offset = "+40+20")
  image11 <- magick::image_composite(image1, icon, offset = "+20+250")
  image2 <- magick::image_composite(map, icon, offset = "+120+20")
  image22 <- magick::image_composite(image2, icon, offset = "+100+250")
  image3 <- magick::image_composite(map, icon, offset = "+200+20")
  image33 <- magick::image_composite(image3, icon, offset = "+180+250")
  image4 <- magick::image_composite(map, icon, offset = "+280+20")
  image44 <- magick::image_composite(image4, icon, offset = "+260+250")
  image5 <- magick::image_composite(map, icon, offset = "+360+20")
  image55 <- magick::image_composite(image5, icon, offset = "+340+250")

  # put the different images together to create and interactive GIF
  img <- c(image11, image22, image33, image44, image55)
  animation <- magick::image_animate(image_scale(img, "800x800"), fps = 1, dispose = "previous")

  # save the GIF
  magick::image_write(animation, "www/my_weather.gif")

  return(animation)

}




