#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
### change something here 

library(shiny)
library(shinyWidgets)
library(png) 

# This creates the user interface 
ui <- fluidPage(
    
    # set background color to light sky blue. 
    setBackgroundColor("LightSkyBlue"),
    
    # create Heading
    titlePanel(h1("Get your personal weather forecast", align = "center")),
    br(), 
    br(), 
    
    
    sidebarLayout(
        
        sidebarPanel(
            
            style = "background-color: EggWhite;",
        
            # insert search field
            fluidRow(column(width = 12, 
                            align = "center",
                            textInput(inputId = "location", h3("Please enter a location"),
                                      value = "Amsterdam"))
                     ),
            
            # insert select box 
            fluidRow(column(width = 12,
                            align = "center",
                            selectInput("cur_hour_day", "Please indicate the type of forecast you are looking for",
                                        c("current weather", "hourly forecast", "daily forecast")))
                     ),
            
            # insert search button 
            # has to be used with "eventReactive()"
            fluidRow(column(width = 12, actionButton(inputId = "search", "Search"),
                            align = "center")
                     )
        ),
        
        mainPanel(
            
            # display chosen location: 
            fluidRow(
                column(width = 6,
                       offset = 3,
                       verbatimTextOutput("my_output_location"),
                       align = "center")
            ), 
            
            # display weather image: 
            fluidRow(
                column(width = 12, 
                       imageOutput("weather_image"), 
                       align = "center")
            ),
            
            # display current general weather forecast
            fluidRow(
                column(width = 6, 
                       offset = 3,
                       verbatimTextOutput("current_weather"),
                       align = "center")
            ),
            
            # display current temperature weather forecast
            fluidRow(
                column(width = 6, 
                       offset = 3,
                       verbatimTextOutput("current_temp"),
                       align = "center")
            ),
            
            # display sunrise and sunset 
            fluidRow(
                column(width = 6,
                       verbatimTextOutput("sunrise"), 
                       align = "center"),
                column(width = 6, 
                       verbatimTextOutput("sunset"), 
                       align = "center")
            ),
            
            # display feels like and wind 
            fluidRow(
                column(width = 6,
                       verbatimTextOutput("feels_like"), 
                       align = "center"),
                column(width = 6, 
                       verbatimTextOutput("wind_speed"), 
                       align = "center")
            )
            
        )
        
    )
    
) 

# This creates what the server is running 
server <- function(input, output, session) {
    
    #my_api_key <- Sys.getenv("MY_API")
    
    # Only update the input for location if button is pressed. 
    my_location <- eventReactive(input$search, {
        input$location
    })
    
    output$my_output_location <- renderText({
        
        my_location()
        
    })
    
    output$current_weather <- renderText({
        
        weatherApp::get_weather(my_location(), my_api_key)$current$weather$description
        
    })
    
    output$current_temp <- renderText({
        
        temperature <- weatherApp::get_weather(my_location(), my_api_key)$current$temp - 273.15
        paste(temperature, "degrees Celsius")
        
    })
    
    output$sunrise <- renderText({
        
        sunrise <- weatherApp::get_weather(my_location(), my_api_key)$current$sunrise 
        paste("Sunrise:", as.POSIXct(sunrise, origin="1970-01-01", TZ= "Europe/Berlin"))
        
    })
    
    output$sunset <- renderText({
        
        sunset <- weatherApp::get_weather(my_location(), my_api_key)$current$sunset 
        paste("Sunset:", as.POSIXct(sunset, origin="1970-01-01", TZ= "Europe/Berlin"))
        
    })
    
    output$feels_like <- renderText({
        
        paste("Feels like:", (weatherApp::get_weather(my_location(), my_api_key)$current$feels_like - 273.15))
        
    })
    
    output$wind_speed <- renderText({
        
        paste("Wind speed:", weatherApp::get_weather(my_location(), my_api_key)$current$wind_speed)
        
    })
    
    output$weather_image <- renderImage({
        
        weatherApp::get_weather_image(my_location(), my_api_key)
        list( src = "www/weather_image.png",
              alt = paste("weather_image"),
              width = 500,
              height = 100)
    })
    
}

# Run the application 
shinyApp(ui = ui, server = server)

