#setwd("/Users/Victor/Documents/open-fisheries-alaska/")

library(leaflet)
quota = read.csv("quota.csv", header=TRUE)
fish <- read.csv("test.csv",header=TRUE)

shinyUI(fluidPage(
  titlePanel("HalibutCatch: Estimate IPHC quota in Pacific Ocean zones through 2020"),
    sidebarLayout(position = "right", 
                  sidebarPanel(
                    selectInput("variable", 
                                label = "Select Year:",
                                choices = levels(quota$variable),
                                selected="X2016"
                    )# Specification of range within an interval
                    ,
                    sliderInput("range", "Sea Surface Temperature (Celsius):",
                                min = 7.00, max = 10.00, val=9.0,step= 0.01)
                    ,
                    mainPanel(
                      br(),br(),
                      strong("Notes:")
                      ,p("1. Click on region in map for more details.")
                      ,p("2. Default temperature based on average sea surface temperature in that year near AREA 3A")
                      ,p("3. For 2017 and beyond, default sea surface temperature is an estimate. Feel free to change it with better estimates.")
                      ,p("4. For 2017 and beyond, quota estimates in each area based on simple model using sea surface temperature estimates and the ten-year average quota percentage share of each area out of total quota.")
                      ,br()
                      ,strong("Sources:"),br()
                      ,p(a("IPHC Halibut Quota", href="http://www.iphc.int"))
                      ,p(a("Sea Surface Temperatures", href="http://data.planetos.com/datasets/noaa_oisst_daily_1_4"))
                      ,p("Updated Nov 2016")
                    )
                  ),
                  

                mainPanel(leafletOutput('map',height="600px"))
  )))



# library(leaflet)
# shinyUI(fluidPage(
#   titlePanel("台灣縣市福利政策"),
#   
#   sidebarLayout(position = "right", 
#                 sidebarPanel(
#                   selectInput("time", 
#                               label = "Choose a time period",
#                               choices = list("1", "2", "3")
#                   )
#                 ),
#                 
#                 mainPanel(leafletOutput('map'))
#   )))