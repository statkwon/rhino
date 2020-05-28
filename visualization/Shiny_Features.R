library(shiny)
library(shinydashboard)

convertMenuItem <- function(mi,tabName){
  mi$children[[1]]$attribs['data-toggle']="tab"
  mi$children[[1]]$attribs['data-value']= tabName
  mi
}

header <- dashboardHeader('Charging stations of hydrogen cars')

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
              infoBoxOutput("info1"),
              infoBoxOutput("info2"),
              infoBoxOutput("info3")
              box(plotOutput("plot"),
              )
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
  output$plot <- renderPlot({
    gas_tbl %>%
      ggplot(aes(fill=gu)) + geom_bar(aes(x=gu,y=get(input$xselect)),stat='identity') + 
      coord_flip() + theme(legend.position = 'none')
  })
  output$table <- DT::renderDataTable(gas_tbl)
}

shinyApp(ui,server)
