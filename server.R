#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#
require(leaflet)
require(dplyr)
library(tidyr)

#crime <- read.csv("Merged5-Sabin.csv")
crime <-read.csv('parsed.csv')

# getLatLong <- function(l) {
#   vals <- as.numeric(unique(unlist(regmatches(l, gregexpr("[\\.0-9\\-]+", l)))))
#   return(paste(vals, collapse=";"))
# }
# 
# text <- unlist(lapply(crime$the_geom, function(l) {getLatLong(l)}))
# df <- as.data.frame(text) %>% separate(text, into = c("longitude1", "latitude1", "longitude2", "latitude2"), sep=";")
# df <- sapply(df, function(x) {as.numeric(x)})
# crime <- cbind(crime, df)

#library("ggmap")
#crime$zip <- apply(crime[,c("longitude1", "latitude1")], 1, function(x) {revgeocode(c(x[1], x[2]), output="more")$postal_code})
#res$postal_code
#res$neighborhood

color_map <- list(High = "red",
                  Medium = "orange",
                  Low = "green",
                  All = "blue")


# THRESHOLD = 0.9
# LOW_THRESHOLD = 0.25
# crime$theft_class <- "Low"
# crime$theft_class[crime$Theft_predicted > THRESHOLD] = "High"
# crime$theft_class[crime$Theft_predicted < THRESHOLD & crime$Theft_predicted > LOW_THRESHOLD] = "Medium"

small_crime <- crime[sample(nrow(crime), 100), ]
splits <- split(crime, crime$theft_class)

library(shiny)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
   
  output$map <- renderLeaflet({

      #leaflet(data = small_crime) %>% addTiles() %>%
      #  addMarkers(~latitude, ~longitude, popup = ~as.character(Theft_predicted), label = ~as.character(Theft_predicted))

      if (input$variable1 == "All") {
        data <- small_crime
      } else {
        data <- splits[[input$variable1]]
      }
     
     # leaflet() %>% addTiles() %>%
     #    addRectangles(
     #      lng1=data$longitude1, lat1=data$latitude1,
     #      lng2=data$longitude2, lat2=data$latitude2,
     #      fillColor = "yellow"
     # )
    
    out <- leaflet(data) %>% addTiles()
    
    for(i in 1:nrow(data)) {
      out <- addPolylines(out, lat = as.numeric(data[i, c("latitude1", "latitude2")]), 
                          lng = as.numeric(data[i, c("longitude1", "longitude2")]),
                          color = color_map[[input$variable1]],
                          opacity = 0.8,
                          popup = paste("Theft probability: ", data[i, c("Theft_predicted")], 
                                        "<br/> Subway: ", data[i, c("Subway")],
                                        "<br/> Restaurants: ", data[i, c("Rest")],
                                        "<br/> Graffiti: ", data[i, c("Graf")])
              )
    }
    
    out
  })

  #output$random <- renderPrint({input$variable})
  
  output$slider_map <- renderLeaflet({
    slider_data = crime[crime$Theft_predicted >= input$value, ]
    leaflet(slider_data) %>% addTiles() %>%
      addMarkers(~longitude1, ~latitude1, popup = paste("Theft probability: ", slider_data$Theft_predicted,
                                                                      "<br/> Subway: ", slider_data$Subway,
                                                                      "<br/> Restaurants: ", slider_data$Rest,
                                                                      "<br/> Graffiti: ", slider_data$Graf))
  })
  
  output$theft_prediction <- renderUI({
    h2(
      class = "text-muted",
      0.05+1.159*input$subway + 1.125*input$graffiti + 0.055*input$restaurant
    )
  })
  
})
