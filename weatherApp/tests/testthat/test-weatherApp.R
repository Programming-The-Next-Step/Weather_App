library("weatherApp")

context("Core weatherApp functionality")

test_that("geocode returns data frame with location, latitude, lognitude", {

  my_location <- geocode("Amsterdam, Netherlands")

  expect_equal(length(my_location), 4)

})

test_that("get_weather retrieves weather data and saves it as a list.", {

  my_weather <- get_weather("Amsterdam, Netherlands", Sys.getenv("MY_API"))

  expect_equal(my_weather$timezone, "Europe/Amsterdam")

})

test_that("get_forecast retrives weather data and saves it in a reduced form, which contains 14 inputs", {

  my_forecast <- get_forecast("current", "Amsterdam, Netherlands", Sys.getenv("MY_API"))

  expect_equal(length(my_forecast), 14)

})

test_that("get_map retrieves a map and saves it. ", {

  my_map <- get_map("Amsterdam, Netherlands")

  expect_equal(image_info(my_map)$format, "PNG")

})

test_that("get_icon_map retrieves a map and saves icons on it.", {

  my_icon_map <- get_icon_map("Amsterdam, Netherlands", Sys.getenv("MY_API"))

  expect_equal(image_info(my_icon_map)$format, "PNG")

})

test_that("get_weather_image saves an image that reflects the current weather.", {

  my_weather_image <- get_weather_image("Amsterdam, Netherlands", Sys.getenv("MY_API"))

  expect_equal(image_info(my_weather_image)$format, "JPEG")

})

test_that("get_icon saves an icon that corresponds to the current weather.", {

  my_weather_icon <- get_icon("Amsterdam, Netherlands", Sys.getenv("MY_API"))

  expect_equal(image_info(my_weather_icon)$format, "PNG" )

})

