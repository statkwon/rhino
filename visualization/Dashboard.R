# Data import
library(ggplot2)
library(tidyverse)
library(shiny)
library(readr) # Data importing

feature <- read_csv("https://raw.githubusercontent.com/statkwon/rhino/master/data/cleansing/total_data.csv")


# Making a dashboard
ui <- fluidPage(
 h1("Hydrogen car charging station"),
 sliderInput(inputId = "lvalue", label = "Land value",
             min = 112, max = 122,
             value = c(113,114)),
 sliderInput(inputId = "rarea", label = "Road area",
             min = 2000000, max = 7000000,
             value = c(3000000,4000000)),
 plotOutput("plot"),
 DT::dataTableOutput("table")
)

server <- function(input, output) {
 filtered_data <- reactive({
   data <- feature
   data <- subset(
       data,
       (공시지가 >= input$lvalue[1] & 공시지가 <= input$lvalue[2]) |
       (도로면적 >= input$rarea[1] & 도로면적 <= input$rarea[2])
   )
   data
 })
 
 output$table <- DT::renderDataTable({
   data <- filtered_data()
   data
 })
       
 output$plot <- renderPlot({
   data <- filtered_data()
   ggplot(data, aes(공시지가, 주유소수)) +
     geom_point() +
     scale_x_log10()
 })
}
     
 shinyApp(ui, server)
   