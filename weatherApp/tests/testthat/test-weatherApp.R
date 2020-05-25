library("weatherApp")

context("Core weatherApp functionality")

test_that("geocode returns data frame with location, latitude, lognitude", {

  myloc <- geocode("Amsterdam, Netherlands")

  expect_equal(length(myloc), 3)

})
