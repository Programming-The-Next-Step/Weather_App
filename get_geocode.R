### get longitude latitude ###

library(stringr)
library(jsonlite)
library(httr)

# The function geocode() takes a location as input and returns the longitude and latitude of this location.

geocode <- function(location){
  
  # split the location string, that the function got as input, into the different words. 
  my_location <- stringr::str_split(location, boundary("word"))
  my_location_string <- my_location[[1]][1]
  
  for(i in 2:length(my_location[[1]])){
    my_location_string <- paste(my_location_string, "+", my_location[[1]][i], sep = "")
  }
  
  # Write down the url that retrieves the long/lat information from openstreetmap.org
  
  my_url <- paste("https://nominatim.openstreetmap.org/search?q=", my_location_string, 
                  "&format=json&limit=1", sep="")
  
  # call the Url, retrieve the data and check if it was successful. 
  my_raw_results <- httr::GET(my_url)  
  status_code(my_raw_results)
  
  if (status_code != 200) {
    stop("Please enter a valid location!")
  }
  
  # Transform the JSON data into useable format. 
  my_content <- httr::content(my_raw_results, as = "text")
  
  my_content_from_json <- jsonlite::fromJSON(my_content)
  
  # Save the longitude latitude data in an object and return it. 
  gecode_data <- data.frame(3)
  geocode_data$location <- location
  geocode_data$latitude <- my_content_from_json$lat
  geocode_data$longitude <- my_content_from_json$lon
  
  return(geocode_data)
  
}

##############
#### Test ####
##############


location <- "Dennenrodepad 777, Amsterdam, Niederlande"

my_location <- str_split(location, boundary("word"))
my_location_string <- my_location[[1]][1]

for(i in 2:length(my_location[[1]])){
  my_location_string <- paste(my_location_string, "+", my_location[[1]][i], sep = "")
}

my_url <- paste("https://nominatim.openstreetmap.org/search?q=", my_location_string, 
                "&format=json&limit=1", sep="")

my_raw_results <- httr::GET(my_url)  
status_code(my_raw_results)
my_content <- httr::content(my_raw_results, as = "text")

my_content_from_json <- jsonlite::fromJSON(my_content)
my_content_from_json

geocode_data <- data.frame(3)
geocode_data$location <- location
geocode_data$latitude <- my_content_from_json$lat
geocode_data$longitude <- my_content_from_json$lon

geocode_data

