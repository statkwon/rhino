# Data import
library(ggplot2)
library(tidyverse)
library(shiny)
library(gifski)
library(png)

setwd('C:/Users/Duck/Dropbox/DSI/')
gas <- read.csv("total_data.csv")

# Preprocessing
colnames(gas) <- c('gu', 'gas_station', 'car', 'station_per_car', 'inflow', 'outflow', 'land_value', 'university',
                   'enterprise', 'distributor', 'parking_area', 'school', 'road_area', 'population', 'day_pop', 'night_pop')
library(tidymodels)

gas_tbl <- gas %>% as_tibble %>% 
   janitor::clean_names()

gas_tbl <- gas_tbl %>%
   mutate(car_per_station = car/gas_station)

gas_tbl_lm <- gas_tbl %>% 
   filter(gu != '강북구') %>% 
   select(-gu)

inflow.lm <- lm(inflow~road_area, data=gas_tbl_lm) #road_area와 교통량(inflow, outflow) 상관관계 높아서 유일변수로 회귀분석 실시
outflow.lm <- lm(outflow~road_area, data=gas_tbl_lm)
gas_tbl$inflow[3] <- predict(inflow.lm, newdata = gas_tbl %>% filter(gu == '강북구') %>% select(-gu))
gas_tbl$outflow[3] <- predict(outflow.lm, newdata = gas_tbl %>% filter(gu == '강북구') %>% select(-gu))


# Making a dashboard 
library(shiny)
library(shinydashboard)

convertMenuItem <- function(mi,tabName){
   mi$children[[1]]$attribs['data-toggle']="tab"
   mi$children[[1]]$attribs['data-value']= tabName
   mi
}

header <- dashboardHeader(title='Charging stations of hydrogen cars')

sidebar <- dashboardSidebar(
   sidebarMenu(
      convertMenuItem(menuItem("features", tabName = "Features", icon = icon("dashboard"),
         selectInput("xselect","Options",colnames(gas_tbl)[-1], selectize=TRUE)),
         tabName="Features"),
      menuItem("map", tabName = "Map", icon = icon("th"))
   )
)

body <- dashboardBody(
   tabItems(
      tabItem(tabName = "Features", h2("Comparison by features"), 
              fluidRow(
                 infoBoxOutput("max"),
                 infoBoxOutput("median"),
                 infoBoxOutput("min"),
                 box(plotOutput("plot",width=1600,height=900))
              )
      ),
      tabItem(tabName = "Map", h2("test2"),
              fluidRow(
                 box(DT::dataTableOutput("table"))
              )
      )
   )
)

ui <- dashboardPage(header, sidebar, body)

server <- function(input,output){
   output$max <- renderInfoBox({
      infoBox(
         "Max",gas_tbl['gu'][[1]][which(gas_tbl[input$xselect]==max(gas_tbl[input$xselect]))][1], 
                max(gas_tbl[input$xselect]), icon=icon("credit-card")
      )
   })
   output$median <- renderInfoBox({
      infoBox(
         "Median", gas_tbl['gu'][[1]][which(gas_tbl[input$xselect]==median(unlist(gas_tbl[input$xselect])))][1],
                      median(unlist(gas_tbl[input$xselect])), icon=icon("credit-card")
      )
   })
   output$min <- renderInfoBox({
      infoBox(
         "Min", gas_tbl['gu'][[1]][which(gas_tbl[input$xselect]==min(gas_tbl[input$xselect]))][1],
                      min(gas_tbl[input$xselect]), icon=icon("credit-card")
      )
   })
   output$plot <- renderPlot({
      gas_tbl %>%
         ggplot(aes(fill=gu)) + geom_bar(aes(x=gu,y=get(input$xselect)),stat='identity') + 
         coord_flip() + theme(legend.position = 'none') + ylab(input$xselect)
   })
   output$table <- DT::renderDataTable(gas_tbl)
}

shinyApp(ui,server)


