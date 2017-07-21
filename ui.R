#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#
require(leaflet)
library(shinydashboard)

#crime <- read.csv("Merged5-Sabin.csv")
crime <-read.csv('parsed.csv')

library(shiny)

# Define UI for application that draws a histogram
# shinyUI(fluidPage(
#   
#   # Page title
#   titlePanel("Manhattan Crime Predictor"),
#   
#   # Link to source data
#   helpText("Source data from NYC Open Data 'NYPD Complaint Map' "),
#   
#   # Sidebar with controls
#   sidebarLayout(sidebarPanel(selectInput(inputId = 'variable', 
#                                          label   = "Choose level", 
#                                          choices = c("High", "Medium", "Low", "All"))),
#                 sidebarPanel(selectInput(inputId = 'variable1', 
#                                          label   = "Choose level", 
#                                          choices = c("High", "Medium", "Low", "All"))),
#                               # Leaflet map
#                               #mainPanel(textOutput(outputId = 'random'))
#                               mainPanel(leafletOutput(outputId = 'map'))
#   )
#   
# ))


header <- dashboardHeader(
  title = "Manhattan Parking"
)

body <- dashboardBody(
  

  fluidRow(
    column(2,
           numericInput("subway", "Subway", min=0, max=100, value=0)
    ),
    column(2,
           numericInput("graffiti", "Graffiti", min=0, max=100, value=1)
    ),
    column(2,
                 numericInput("restaurant", "Restaurants", min=0, max=100, value=0)
    ),
    column(1,
           h2(
             class = "text-muted",
             paste("=")
           )
    ),
    column(1,
      uiOutput("theft_prediction")
    ),
    column(1,
           br(),
           actionButton("predict", "Predict theft")
    )
    
  ),

  fluidRow(
    column(width = 9,
           box(width = NULL, solidHeader = TRUE,
               leafletOutput("map", height = 400)
           ),
           box(width = NULL,
               leafletOutput("slider_map", height = 400)
           )
           #box(width = NULL,
           #    uiOutput("numVehiclesTable")
           #)
    ),
    column(width = 3,
           box(width = NULL, status = "warning",
               #uiOutput("routeSelect"),
               p(
                 class = "text-muted",
                 paste("choose whether to group points by zip code or display",
                       "individual streets"
                 )
               ),
               selectInput(inputId = "variable2", 
                           label   = "View type", 
                           choices = c("street", "zip"),
                           selected = "street"
               )
               #actionButton("zoomButton", "Zoom to fit buses")
           ),
           box(width = NULL, status = "warning",
               p(class = "text-muted",
                 br(),
                 "Choose level of parking theft probability"
               ),
               selectInput(inputId = "variable1", 
                           label   = "Choose level", 
                           choices = c("High", "Medium", "Low"),
                           selected = "High"
               )
               #uiOutput("timeSinceLastUpdate"),
               #actionButton("refresh", "Refresh now"),
           ),
           br(),
           br(),
           br(),
           br(),
           br(),
           box(width = NULL, status = "warning",
               p(class = "text-muted",
                 br(),
                 "marks places above threshold value on map"
               ),
               sliderInput("value", "Theft probability threshold:",
                           min = min(crime$Theft_predicted), max = max(crime$Theft_predicted), value = max(crime$Theft_predicted)
               )
           )
           
    )
  )
)

dashboardPage(
  header,
  dashboardSidebar(disable = TRUE),
  body
)



