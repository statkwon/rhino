library(shinydashboard)
library(shiny)
library(shinycssloaders)
library(leaflet)
library(leaflet.extras)
library(raster)
library(plotly)
library(ggplot2)

korea = shapefile('TL_SCCO_SIG.shp')
korea = spTransform(x = korea, CRSobj = CRS('+proj=longlat +datum=WGS84'))
korea = korea[1:25,]
data = read.csv('data.csv')
simul = read.csv('simul.csv')
loc_data = read.csv('loc_data.csv')
row.names(loc_data) = paste(loc_data$gu, loc_data$dong, sep = '.')
korea@data = sp::merge(korea@data, data)
korea@data = sp::merge(korea@data, simul)

convertMenuItem = function(mi,tabName){
  mi$children[[1]]$attribs['data-toggle']="tab"
  mi$children[[1]]$attribs['data-value']= tabName
  mi
}

header = dashboardHeader(title = '수소차 충전소 입지 선정')
sidebar = dashboardSidebar(
  sidebarMenu(
    convertMenuItem(menuItem('구별 특성 그래프', tabName = "feature_graph",
                             selectInput('features1', 'Features', choices=colnames(data)[3:16], multiple=F,
                                         selected='주유소수')), tabName = 'feautre_graph'),
    menuItem('구별 특성 테이블', tabName = 'feature_table'),
    convertMenuItem(menuItem('구별 특성 지도', tabName = 'feature_map',
                             selectInput('features', 'Features', choices=colnames(data)[3:16], multiple=F,
                                         selected='주유소수')), tabName = 'feautre_map'),
    convertMenuItem(menuItem("수소차 충전소 지도", tabName = "station_map",
                             uiOutput('xselect'), uiOutput('xselect2')), tabName="station_map")
  )
)

body = dashboardBody(tags$style(type = "text/css",
                                "#map1 {height: calc(100vh - 80px) !important;}",
                                "#map2 {height: calc(90vh - 40px) !important;}",
                               ".shiny-output-error {visibility: hidden;}",
                                ".shiny-output-error:before {visibility: hidden;}"),
                     tags$head(tags$script('
                                var dimension = [0, 0];
                                $(document).on("shiny:connected", function(e) {
                                    dimension[0] = window.innerWidth;
                                    dimension[1] = window.innerHeight;
                                    Shiny.onInputChange("dimension", dimension);
                                });
                                $(window).resize(function(e) {
                                    dimension[0] = window.innerWidth;
                                    dimension[1] = window.innerHeight;
                                    Shiny.onInputChange("dimension", dimension);
                                });
                            ')),
                     
                     tabItems(
                       tabItem(tabName = 'feature_graph', h2('구별 특성 비교'), 
                               fluidRow(
                                 infoBoxOutput('max'),
                                 infoBoxOutput('median'),
                                 infoBoxOutput('min')),
                               fluidRow(box(title='plot',solidHeader=TRUE,
                                            collapsible=TRUE,withSpinner(plotlyOutput('graph',width='100%'),type=6),width='100%'))),
                       tabItem(tabName = 'feature_table', DT::dataTableOutput('table1')),
                       tabItem(tabName = 'feature_map', leafletOutput('map1')),
                       tabItem(tabName = 'station_map',
                               fluidRow(
                                 box(title='수소차수 지도',
                                     collapsible=TRUE, withSpinner(leafletOutput('map2'), type = 6), width = 8, height = '100%'),
                                 box(title='수소차수 테이블',
                                     collapsible=TRUE, withSpinner(tableOutput('table2'), type = 6), width = 3, height = '100%')))
                     )
)

ui = dashboardPage(skin = 'black', header, sidebar, body)

server = function(input, output) {
  # 구별 특성 플랏
  output$max = renderInfoBox({
    infoBox(
      'Max', data['구'][[1]][which(data[input$features1] == max(data[input$features1]))][1], 
      max(data[input$features1]), icon = icon('credit-card')
    )
  })
  output$median = renderInfoBox({
    infoBox(
      'Median', data['구'][[1]][which(data[input$features1] == median(unlist(data[input$features1])))][1],
      median(unlist(data[input$features1])), icon = icon('credit-card')
    )
  })
  output$min = renderInfoBox({
    infoBox(
      'Min', data['구'][[1]][which(data[input$features1] == min(data[input$features1]))][1],
      min(data[input$features1]), icon = icon('credit-card')
    )
  })
  output$graph = renderPlotly({
    gph <- ggplot(data,aes(fill = 구))+ geom_bar(aes(x = 구,y = get(input$features1)), stat='identity') + 
      coord_flip() + theme(legend.position = 'none') + ylab(input$features1)
    ggplotly(gph,width=input$dimension[1]*(0.84),height=input$dimension[2]*(0.71))
  })
  # 구별 특성 테이블
  output$table1 = DT::renderDataTable(data)
  
  # 구별 특성 지도
  output$map1 = renderLeaflet({
    x = reactive({
      data[,input$features]
    })
    pal1 = colorBin(palette = 'YlGn', domain = x())
    korea %>%
      leaflet() %>%
      addProviderTiles('Esri', group = 'Esri') %>%
      addTiles(group = 'OSM') %>%
      addProviderTiles('CartoDB', group = 'Carto') %>%
      setView(127.001699, 37.564214, zoom = 11.5) %>%
      addSearchOSM() %>%
      addResetMapButton() %>%
      addPolygons(weight = 3,
                  fillOpacity = 0.8,
                  fillColor = ~pal1(x()),
                  color = 'black',
                  label = ~paste0(구, ' : ', x()),
                  highlight = highlightOptions(weight = 3,
                                               color = 'red',
                                               bringToFront = TRUE),
                  group = data$구) %>%
      addLegend(title = input$features, pal = pal1, values = ~x(), opacity = 1,
                position = 'bottomright', group = input$features) %>%
      addLayersControl(baseGroups = c('Esri', 'OSM', 'Carto'))
  })
  
  # 수소차수 테이블 및 지도
  loc1 = reactive({paste(input$xselect, input$xselect2, sep = '.')})
  output$table2 = renderTable(cbind(구 = simul[,1], 증가량 = simul[,loc1()]),
                              options = list(
                                autoWidth = TRUE,
                                columnDefs = list(list(width = '200px', targets = "_all"))
                              ))
  output$map2 = renderLeaflet({
    y = reactive({simul[,loc1()]})
    pal2 = colorBin(palette = 'YlGn', domain = y())
    korea %>%
      leaflet(height = 100, width = 100) %>%
      addProviderTiles('Esri', group = 'Esri') %>%
      addTiles(group = 'OSM') %>%
      addProviderTiles('CartoDB', group = 'Carto') %>%
      setView(127.001699, 37.564214, zoom = 11) %>%
      addSearchOSM() %>%
      addResetMapButton() %>%
      addPolygons(weight = 3,
                  fillOpacity = 0.8,
                  fillColor = ~pal2(y()),
                  color = 'black',
                  label = ~paste0(구, ' : ', simul[,loc1()], '/', sum(simul[,loc1()])),
                  highlight = highlightOptions(weight = 3,
                                               color = 'red',
                                               bringToFront = TRUE),
                  group = data$구) %>%
      addLegend(title = '수소차 대수', pal = pal2, values = ~y(), opacity = 1,
                position = 'bottomright', group = loc1()) %>%
      addMarkers(lat = loc_data[loc1(),]$lat , lng = loc_data[loc1(),]$lng) %>%
      addLayersControl(baseGroups = c('Esri', 'OSM', 'Carto'))
  })
  
  # 구/동 드롭다운 메뉴
  output$xselect = renderUI({
    selectInput("xselect", "Options", unique(loc_data[,1]), selected = isolate(unique(loc_data[,1])[1]), selectize = TRUE)
  })
  output$xselect2 = renderUI({
    selectInput("xselect2", "Options", subset(loc_data,gu==input$xselect)[,2],
                selected=isolate(subset(loc_data,gu==input$xselect)[,2][1]) , selectize = TRUE)
  })
}

shinyApp(ui, server)
