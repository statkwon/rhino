library(shinydashboard)
library(shiny)
library(leaflet)
library(leaflet.extras)
library(raster)

korea = shapefile('TL_SCCO_SIG.shp')
korea = spTransform(x = korea, CRSobj = CRS('+proj=longlat +datum=WGS84'))
korea = korea[1:25,]
data = read.csv('data.csv')
korea@data = sp::merge(korea@data, data)

convertMenuItem <- function(mi,tabName){
  mi$children[[1]]$attribs['data-toggle']="tab"
  mi$children[[1]]$attribs['data-value']= tabName
  mi
}

header = dashboardHeader(title = '수소차 충전소 입지 선정')
sidebar = dashboardSidebar(
  sidebarMenu(
    menuItem('구별 특성 테이블', tabName = 'feature_table'),
    menuItem('구별 특성 그래프', tabName = 'feautre_plot'),
    convertMenuItem(menuItem('구별 특성 지도', tabName = 'feature_map',
                             selectInput('features', 'Features', choices=colnames(data)[3:16], multiple=F,
                         selected='주유소수')), tabName = 'feautre_map'),
    convertMenuItem(menuItem('수소차수 테이블', tabName = 'car_table',
                             selectInput('features2', 'Features', choices=c("",data[,1]), multiple=F,
                                         selected="")), tabName = 'car_table'),
    menuItem('수소차 충전소 입지 지도', tabName = 'station_map')
    )
)
body = dashboardBody(tags$style(type = "text/css", "#map {height: calc(100vh - 80px) !important;}"),
  tabItems(
    tabItem(tabName = 'feature_table', DT::dataTableOutput('table')),
    tabItem('NOT completed'),
    tabItem(tabName = 'feature_map', leafletOutput('map')),
    tabItem(tabName = 'car_table', tableOutput('table2')),
    tabItem('NOT completed')
  )
)

ui = dashboardPage(header, sidebar, body)

server = function(input, output) {
  output$table = DT::renderDataTable(data)
  output$map = renderLeaflet({
    x = reactive({
      data[,input$features]
    })
    pal1 = colorBin(palette = 'YlGn', domain = x())
    korea %>%
      leaflet() %>%
      addTiles(group = 'OSM') %>%
      addProviderTiles('CartoDB', group = 'Carto') %>%
      addProviderTiles('Esri', group = 'Esri') %>%
      setView(127.001699, 37.564214, zoom = 12) %>%
      addSearchOSM() %>%
      addResetMapButton() %>%
      addPolygons(weight = 3,
                  fillOpacity = 0.8,
                  fillColor = ~pal1(x()),
                  color = 'black',
                  label = ~구,
                  highlight = highlightOptions(weight = 3,
                                               color = 'red',
                                               bringToFront = TRUE),
                  group = input$features) %>%
      addLegend(title = input$features, pal = pal1, values = ~x(), opacity = 1,
                position = 'bottomright', group = input$features) %>%
      addLayersControl(baseGroups = c('OSM', 'Carto', 'Esri'))
  })
  output$table2 = renderTable({
    fun = function(x, y){
      for(i in 1:25){
        if(x[i,1] == input$features){
          x[i,2] = x[i,2] * 3 + 2
        }
      }
      x
      assign(y, x, envir=.GlobalEnv)
    }
    fun(sim, 'sim')
    sim
  })
}

shinyApp(ui, server)