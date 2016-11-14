#setwd("/Users/Victor/Documents/open-fisheries-alaska/")





  library(shiny)
  library(rgdal)
  library(geojsonio)
  library(leaflet)
  library(dplyr)
  shinyServer(function(input,output,session){
    tw = readOGR("goa_den.geojson", "OGRGeoJSON")
    #Overall map:
    #tw = readOGR("fish.geojson", "OGRGeoJSON")
    
    quota = read.csv("quota.csv", header=TRUE)
    quota$reg_area <- as.factor(quota$reg_area)
    quota$variable <- as.factor(quota$variable)
    quota$value <- as.numeric(quota$value)

    #percent <- data.frame(reg_area = unique(quota$reg_area),percent = c(0.03,0.2,0.11,0.37,0.15,0.05,0.04,0.06))
  
    
    #Build Basic Linear Model    
    fish <- read.csv("test.csv",header=TRUE)
    #Set temp type
    fish$Temperature <- as.numeric(as.character(fish$Temperature))
    #Set quota numeric type
    fish$Quota <- as.numeric(as.character(fish$Quota))
    fish$Year <- as.factor(fish$Year)
    
    mod = lm(fish$Quota[1:24]~ fish$Temperature[1:24])

    observe({
      val <- input$variable

      # Control the value, min, max, and step.
      # Step size is 2 when input value is even; 1 when value is odd.
      updateSliderInput(session, "range", value = fish[fish$Year == val,]$Temperature,step=0.01)
    })
  
    selectedTemp <- reactive({
      year <- input$variable
      temp <- input$range
      quota[quota$variable==year & quota$reg_area=="2A",]$value <- round((as.numeric(mod$coefficients[2]) * temp + as.numeric(mod$coefficients[1])) * 0.03,0)
      quota[quota$variable==year & quota$reg_area=="2B",]$value <- round((as.numeric(mod$coefficients[2]) * temp + as.numeric(mod$coefficients[1])) * 0.2,0)
      quota[quota$variable==year & quota$reg_area=="2C",]$value <- round((as.numeric(mod$coefficients[2]) * temp + as.numeric(mod$coefficients[1])) * 0.11,0)
      quota[quota$variable==year & quota$reg_area=="3A",]$value <- round((as.numeric(mod$coefficients[2]) * temp + as.numeric(mod$coefficients[1])) * 0.37,0)
      quota[quota$variable==year & quota$reg_area=="3B",]$value <- round((as.numeric(mod$coefficients[2]) * temp + as.numeric(mod$coefficients[1])) * 0.15,0)
      quota[quota$variable==year & quota$reg_area=="4A",]$value <- round((as.numeric(mod$coefficients[2]) * temp + as.numeric(mod$coefficients[1])) * 0.05,0)
      quota[quota$variable==year & quota$reg_area=="4B",]$value <- round((as.numeric(mod$coefficients[2]) * temp + as.numeric(mod$coefficients[1])) * 0.04,0)
      subset(quota,
             variable==input$variable)
    })
      
    
    #Maybe add in second curly bracket for dynamic change of area
    selected <- reactive({
      subset(quota,
             variable==input$variable)
    })
    
    
    output$map <- renderLeaflet({
      leaflet() %>% 
        addTiles("CartoDB.Positron") %>% 
        addPolygons(data=tw,weight=2) %>%
        setView(lng = -142.6, lat = 54.50,  zoom = 4)
      
    })
    
    observe({
      tw@data <- left_join(tw@data, selectedTemp())
      
      tw@data <- left_join(tw@data, selected())
      qpal <- colorNumeric(
        palette = "YlGn",
        domain = tw$value
      )
      #For % range:
      #colorQuantile("YlGn", tw$money, n = 3, na.color = "#bdbdbd") 
      
      popup <- paste0("<strong>AREA: </strong>",
                      tw$reg_area,
                      "<br><strong>Year: </strong>",
                      tw$variable,
                      "<br><strong>Catch Limit (K,Pounds): </strong>",
                      tw$value)
      
      
      leafletProxy("map", data = tw) %>%
        addProviderTiles("CartoDB.Positron") %>% 
        clearShapes() %>% 
        clearControls() %>% 
        addPolygons(data=tw,fillColor = ~qpal(value), fillOpacity = 0.7, 
                    color = "white", weight=2,popup=popup)  %>%
        addLegend(pal = qpal, values = ~value, opacity = 0.7,
                  position = 'bottomright', 
                  #                labFormat = labelFormat(prefix = "$"),
                  title = paste0(input$variable," (K,Pounds)")) #%>%
      #      setView(lng = lng, lat = lat, zoom = zoom)
    })
    
    #May not need
    observe({
      leafletProxy("map")
    })
    
  }) 
  


# Working Map
# library(rgdal)
# "GeoJSON" %in% ogrDrivers()$name
# 
# tw = readOGR("/Users/Victor/Documents/open-welfare/twCounty2010.geo.json", "OGRGeoJSON")
# plot(tw)
# 
# tw <- as.data.frame(tw)
#   leaflet() %>% 
#     addTiles() %>% 
#     addPolygons(data=tw,weight=2)





## Working Shiny Leaflet Map:
#setwd("/Users/Victor/Documents/open-welfare/")
# library(shiny)
# library(rgdal)
# library(geojsonio)
# library(leaflet)
# shinyServer(function(input,output){
#   tw = readOGR("/Users/Victor/Documents/open-welfare2/twCounty2010.geo.json", "OGRGeoJSON")
#   
#   output$map <- renderLeaflet({
#     leaflet() %>% 
#       addTiles() %>% 
#       addPolygons(data=tw,weight=2)
#     
#   })
#   
# })  


  
  
# #Combining geojson files:
#   library(rjson)
#   json1 <- fromJSON(file = "bs_den.geojson")
#   json2 <- fromJSON(file = "goa_den.geojson")
#   jsonl <- list(json1, json2)
#   jsonc <- toJSON(jsonl)
#   jsonc
#   write(jsonc, file = "jsonc.geojson")
#   