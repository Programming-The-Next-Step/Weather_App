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
    
    setBackgroundColor("LightSkyBlue"),
    
    titlePanel(h1("Find your weather forecast", align = "center")),
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
