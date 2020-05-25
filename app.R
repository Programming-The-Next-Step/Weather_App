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
    
    # insert search button 
    # has to be used with "eventReactive()"
    fluidRow(
        column(width = 12, 
               actionButton(inputId = "search", "Search"),
               align = "center"),
               br(), 
               br()
        ),
    
    # test reactivity 
    fluidRow(
        column(width = 12,
               verbatimTextOutput("my_output_location"), 
               align = "center")
        ), 
    
    fluidRow(
        column(width = 12, 
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
}

# Run the application 
shinyApp(ui = ui, server = server)



###################
### Old Version ###
###################


# This creates the user interface 
ui <- fluidPage( 
    
    setBackgroundColor("LightSkyBlue"),
    
    titlePanel(h1("Get your personal weather forecast", align = "center")),
    fluidRow(column(width = 12, h3("Your location", align = "center"))),
    fluidRow(column(width = 12, align = "center", img(src = "rain.png",
                                                      height = 70, width = 70))),
    fluidRow(column(width = 12, "Display of your weather forecast, e.g. rainy", align = "center")), 
    fluidRow(column(width = 12, h3("Display of the degrees in Celsius", align = "center"))),
    br(),
    fluidRow(column(width = 1, offset = 2, "22C"),  
             column(width = 1, "20C"), 
             column(width = 1, "20C"),
             column(width = 1, "20C"),
             column(width = 1, "20C"),
             column(width = 1, "18C")),
    br(),
    fluidRow(column(width = 4, offset = 2, "Sunrise"), 
             column(width = 4, offset = 2, "Sunset"))

) 

# This creates what the server is running 
server <- function(input, output, session) {

}

# Run the application 
shinyApp(ui = ui, server = server)
