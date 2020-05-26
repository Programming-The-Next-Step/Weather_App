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
    
    # insert search field
    fluidRow(
        column(width = 12, 
               textInput(inputId = "location", h3("Search for a location"),
                         value = "Enter a location..."),
               align = "center")
    ),
    
    # insert select box 
    fluidRow(
        column(width = 12, 
               selectInput("cur_hour_day", "Please indicate the type of forecast you are looking for", 
                           c("current weather", "hourly forecast", "daily forecast")),
               align = "center")
    ),
    
    # insert search button 
    # has to be used with "eventReactive()"
    fluidRow(
        column(width = 12, 
               actionButton(inputId = "search", "Search"),
               align = "center"),
               br(), 
               br()
    ),
    
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
    )
    
) 

# This creates what the server is running 
server <- function(input, output, session) {
    
    my_api_key <- Sys.getenv("MY_API")
    
    # Only update the input for location if button is pressed. 
    my_location <- eventReactive(input$search, {
        input$location
    })
    
    output$my_output_location <- renderText({
        
        my_location()
        
    })
    
    output$current_weather <- renderText({
        
        weatherApp::get_weather(my_location(), my_api_key)$current$weather$main
        
    })
    
    output$weather_image <- renderImage({
        
        weatherApp::get_weather_image(my_location(), my_api_key)
        list( src = "www/weather_image.png",
              alt = paste("weather image"),
              width = 300,
              height = 220)
        
    })
}

# Run the application 
shinyApp(ui = ui, server = server)

