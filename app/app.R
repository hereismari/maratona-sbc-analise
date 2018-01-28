library(shiny)
library(shinyjs)
library(shinydashboard)
library(ggplot2)
library(highcharter)
library(plotly)
library(leaflet)
#source("app/pre_processa.R")
#source("app/util_imports.R")

#source("pre_processa.R")
source("~/maratona-sbc-analise/app/util_imports.R")


ui <- dashboardPage(
  
  dashboardHeader(title = "Header da página"),
  
  dashboardSidebar(
    useShinyjs(),
    sidebarMenu(id = "menu",
                menuItem("Geral", tabName = "tab1", icon = icon("bookmark")),
                menuItem("Universidades", tabName = "tab2", icon = icon("bookmark"))
    )
  ),
  dashboardBody(
    
    tabItems(
      tabItem(tabName = "tab1",
              fluidRow(
                column(width = 4,
                       box(width = NULL)
                ),
                column(width = 8,
                       textOutput("selected_var"),
                       box(width = NULL, highchartOutput("problemas_geral")),
                       box(width = NULL, uiOutput('selectUI'),
                           sliderInput(inputId = "problems_years", label = "Anos:",
                                       min = 2015, max = 2017, step = 1, 
                                       sep = "", value = c(2017, 2017)))
                ),
                column(width=8,
                       box(width=8, leafletOutput("mapa")),
                       box(width=4, selectInput("teste", "Mostrar:", c("ouro", "medalhas", "prata", "classificados", "bronze"))))
              )
      )
      # tabItem(tabName = "tab2",
      #         fluidRow(
      #           column(width = 4,
      #                  box(width = NULL, 
      #                      selectInput("tab1_select_univ", label = h3("Universidades"),
      #                                  choices = unique(universidades$nome), multiple=T,
      #                                  selected = c("UFCG")
      #                      )
      #                  )
      #           ),                
      #           column(width = 8,
      #                  box(width = NULL)
      #           )
      #         )
      #         
      # )
    )
  )
)


server <- function(input, output) {
  
  # output$selected_var <- renderText({ 
  #   for (ano in input$problems_years) {
  #    paste("oi", ano)
  #   }
  # })
  
  output$problemas_geral = renderHighchart({

    problems = import_problems(input$problems_years)
    problems$NotAccepted = problems$Total - problems$Accepted

    highchart() %>%
      hc_chart(animation = FALSE) %>%
      hc_title(text = "Submissões em problemas") %>%
      hc_xAxis(categories = problems$Problems) %>%
      hc_plotOptions( column = list(stacking = "normal") ) %>%
      hc_add_series(
        data = (problems$NotAccepted),
        name = "Quantidade de submissões não aceitas",
        color = "#B71C1C",
        type = "column"
      ) %>%
      hc_add_series(
        data = (problems$Accepted),
        name = "Quantidade de submissões aceitas",
        color = "#2980b9",
        type = "column"
      )
  })
  
  output$mapa <- renderLeaflet({
    
    data <- readRDS(file = "~/maratona-sbc-analise/app/mapa/mapa_competidores.rds")
    
    bins <- c(0, 5, 10, 15, 20, 25, 30, 40, Inf)
    # Blue
    pal <- colorBin("Blues", domain = data[[input$teste]], bins=bins)
    # Red
    # pal <- colorBin("YlOrRd", domain = data[[input$teste]], bins = bins)
    
    # draw the histogram with the specified number of bins
    state_popup <- paste0("<strong>Estado: </strong>", 
                          data$estado,
                          "<br><strong>Medalhas de ouro: </strong>",
                          data[[input$teste]])
                          
    
    labels <- sprintf(
      "<strong>%s</strong><br/>%g %s",
      data$estado, data[[input$teste]], input$teste
    ) %>% lapply(htmltools::HTML)
    
    
    leaflet(data = brasileiropg) %>%
      # setView(-96, 37.8, 4) %>%
      # addProviderTiles("CartoDB.Positron") %>%
      addProviderTiles("MapBox", options = providerTileOptions(
      id = "mapbox.light",
      accessToken = Sys.getenv('MAPBOX_ACCESS_TOKEN'))) %>%
      addPolygons(
        fillColor = ~pal(data[[input$teste]]),
        weight = 2,
        opacity = 1,
        color = "white",
        dashArray = "3",
        fillOpacity = 0.7,
        highlight = highlightOptions(
          weight = 3,
          color = "pink",
          dashArray = "",
          fillOpacity = 0.7,
          bringToFront = TRUE),
        label = labels,
        labelOptions = labelOptions(
          style = list("font-weight" = "normal", padding = "3px 8px"),
          textsize = "15px",
          direction = "auto")) %>%
      addLegend(pal = pal, values = ~data[[input$teste]],
                title = "Pontos Conquistados",
                opacity = 1)
    
  })
}

shinyApp(ui = ui, server = server)