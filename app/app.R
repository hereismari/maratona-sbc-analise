library(shiny)
library(shinyjs)
library(shinydashboard)
library(ggplot2)
library(highcharter)
library(plotly)
library(dplyr)
library(leaflet)
library(DT)
library("viridisLite")

source("../app/util_imports.R")

universities = import_universities()
competitors = import_competitors()
coaches = import_coaches()


ui <- dashboardPage(
  
  dashboardHeader(title = "Header da página"),
  
  dashboardSidebar(
    useShinyjs(),
    sidebarMenu(id = "menu",
                menuItem("Sobre", tabName = "tab_sobre", icon = icon("bookmark")),
                menuItem("Números da Maratona", tabName = "tab_numeros", icon = icon("bookmark")),
                menuItem("Universidades", tabName = "tab_universidades", icon = icon("bookmark")),
                menuItem("Contests", tabName = "tab_contests", icon = icon("bookmark")),
                menuItem("Medalhistas", tabName = "tab_medalhistas", icon = icon("bookmark")),
                menuItem("Coaches", tabName = "tab_coaches", icon = icon("bookmark")),
                menuItem("Regiões do Brasil", tabName = "tab_regioes", icon = icon("bookmark"))
    )
  ),
  dashboardBody(
    
    tabItems(
      tabItem(tabName = "tab_numeros",
              h3("Submissões totais"),
              fluidRow(
                column(width = 3,
                       box(width = NULL)
                ),
                column(width = 6, 
                       box(width = NULL, highchartOutput("problemas_geral")),
                       box(width = NULL,
                           sliderInput(inputId = "problems_years", label = "Anos:",
                                       min = 2015, max = 2017, step = 1, 
                                       sep = "", value = c(2017, 2017))
                       )
                )
              )
      ),
      tabItem(tabName = "tab_coaches",
              fluidRow(
                column(width = 12,
                       DTOutput('tbl')),
                verbatimTextOutput("selectedCells")),
              fluidRow(
                conditionalPanel(condition =  "typeof input.tbl_rows_selected  !== 'undefined' && input.tbl_rows_selected.length > 0",
                                 box(width = NULL,
                                     highchartOutput("participation_coaches"))
                                 )
                )
      ),
      tabItem(tabName = "tab_medalhistas"),
      tabItem(tabName = "tab_sobre"),
      tabItem(tabName = "tab_universidades",
              fluidRow(
                column(width = 4,
                       box(width = NULL,
                           selectInput(inputId = "univs", label = h3("Universidades"),
                                       choices = unique(competitors$universidade), multiple=T,
                                       selected = c("UFCG", "USP", "UFPE")
                           )
                       )
                ),
                column(width = 8,
                       box(width = NULL, highchartOutput("participation_univs")),
                       box(width = NULL,  
                           sliderInput(inputId = "classifications_years", label = "Anos:",
                                       min = min(competitors$ano), max = max(competitors$ano), step = 1, 
                                       sep = "", value = c(2015, 2017))
                       )
                )
              )
      ),
      tabItem(tabName = "tab_contests",
              h3("Algum título"),
              fluidRow(
                
                column(width = 2,
                       box(width = NULL,
                           selectInput(inputId = "contest_year", label = "Selecione o ano",
                                       choices = list("2015" = 2015, "2016" = 2016, "2017" = 2017), selected = 2017
                           )
                       )
                ),
                
                column(width = 10,
                  
                  column(width = 12,
                    column(width = 3,
                          box(width = NULL, uiOutput("contest_teams_cond"))                        
                    ),
                    column(width = 9,
                           box(width = NULL, highchartOutput("teams_in_contest"))
                    ) 
                  ),
                  
                  column(width = 12,
                         box(width = NULL, highchartOutput("submissions_per_interval"))
                  )
                  
                )
              )
      ),
      tabItem(tabName = "tab_regioes",
              h3("Classificações e medalhas por região"),
              fluidRow(
                column(width = 3,
                       box(width = NULL, 
                           selectInput("tipo_mapa", "Mostrar:", c("ouro", "medalhas", "prata", "classificados", "bronze")))
                ),
                column(width = 6,
                       box(width = NULL, 
                           leafletOutput("mapa"))
                )
              )
      )
    )
  )
)


server <- function(input, output) {
  
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
  
  output$participation_univs = renderHighchart({
    
    m_competitors = import_competitors() %>%
      filter(ano %in% c(input$classifications_years[1]:input$classifications_years[2])) %>%
      filter(universidade %in% input$univs) %>%
      select(-competidor) %>%
      unique() %>%
      filter(classificado == 1) %>%
      group_by(universidade) %>%
      summarise(QntTimes = n()) %>%
      mutate(Size = QntTimes)

    colors <- c("#FB1108", "#9AD2E1")
    m_competitors$Color <- colorize(m_competitors$QntTimes, colors)

    x <- c("Universidade:", "Num times classificados: ")
    y <- sprintf("{point.%s}", c("universidade", "QntTimes"))
    tltip <- tooltip_table(x, y)

    hchart(m_competitors, "scatter", hcaes(x = universidade, y = QntTimes, size = Size, color = Color)) %>%
      hc_title(text = "Participação por universidade na mundial", style = list(fontSize = "15px")) %>%
      hc_tooltip(useHTML = TRUE, headerFormat = "", pointFormat = tltip)
    
  })

  output$mapa <- renderLeaflet({
    data_mapa <- readRDS(file = "~/maratona-sbc-analise/app/mapa/mapa_competidores.rds")
    
    bins <- c(0, 5, 10, 15, 20, 25, 30, 40, Inf)
    # Blue
    pal <- colorBin("Blues", domain = data_mapa[[input$tipo_mapa]], bins=bins)
    # Red
    # pal <- colorBin("YlOrRd", domain = data[[input$tipo_mapa]], bins = bins)
    
    # draw the histogram with the specified number of bins
    state_popup <- paste0("<strong>Estado: </strong>",
                          data_mapa$estado,
                          "<br><strong>Medalhas de ouro: </strong>",
                          data_mapa[[input$tipo_mapa]])
                          
   
    labels <- sprintf(
      "<strong>%s</strong><br/>%g %s",
      data_mapa$estado, data_mapa[[input$tipo_mapa]], input$tipo_mapa
    ) %>% lapply(htmltools::HTML)


    leaflet(data_mapa) %>%
      # setView(-96, 37.8, 4) %>%
      # addProviderTiles("CartoDB.Positron") %>%
      addProviderTiles("MapBox", options = providerTileOptions(
      id = "mapbox.light",
      accessToken = Sys.getenv('MAPBOX_ACCESS_TOKEN'))) %>%
      addPolygons(
        fillColor = ~pal(data_mapa[[input$tipo_mapa]]),
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
      addLegend(pal = pal, values = ~data_mapa[[input$tipo_mapa]],
                title = "Pontos Conquistados",
                opacity = 1)

  })
  
  output$contest_teams_cond = renderUI({
    submissions <- import_submissions(input$contest_year)
    teams = unique(submissions$User)
    
    random_selected = sample(teams, 1)
    
    selectInput(inputId = "contest_teams", label = "Selecione os times",
                choices = teams, multiple=T, selected=random_selected
    )
  })
  
  output$teams_in_contest = renderHighchart({
    submissions = import_submissions(input$contest_year) %>% na.omit() %>%
      filter(User %in% input$contest_teams) %>%
      group_by(User)
    
    cols <- viridis(6)
    cols <- substr(cols, 0, 7)
        
    hchart(submissions, "spline", hcaes(x = Time, y = Penalty, group = User)) %>%
      hc_plotOptions(
        series  = list(
          marker = list(enabled = TRUE, 'x')
        )
      ) %>%
    hc_colors(cols) %>%
    hc_title(text = "Desempenho de times ao longo da competição", style = list(fontSize = "15px")) %>%
    hc_yAxis(title = list(text = "Pontuação"), min = 0) %>%
    hc_xAxis(title = list(text = "Tempo"), min = 0) %>%
    hc_legend(align = "right", verticalAlign = "top", layout = "vertical", x= 0, y = 10) %>% 
    hc_tooltip(sort = TRUE, table = TRUE)
    
  })
  
  output$submissions_per_interval = renderHighchart({
    
    submissions = import_submissions(input$contest_year)
    
    submissions_grouped <- submissions %>%
                           group_by(intervalo=cut(Time, breaks=seq(0, 400, by = 10), right=F)) %>%
                           summarise(total=n(), aceitas=sum(AnswerBin),
                                     aproveitamento=aceitas/total, n_aceitas=total-aceitas)
    highchart() %>%
      hc_chart(animation = FALSE) %>%
      hc_title(text = paste('Submissões ao longo do tempo, Fase 2, Maratona SBC', input$contest_year)) %>%
      hc_xAxis(categories = submissions_grouped$intervalo,
               title = list(text = "Decorrer do campeonato")) %>%
      hc_yAxis(title = list(text = "Número de Submissões")) %>%
      hc_plotOptions( column = list(stacking = "normal") ) %>%
      hc_add_series(
        data = (submissions_grouped$n_aceitas),
        name = "Não aceitas",
        color = "#311B92",
        type = "column"
      ) %>%
      hc_add_series(
        data = (submissions_grouped$aceitas),
        name = "Aceitas",
        color = "#00BFA5",
        type = "column"
      )
  })
  
  output$tbl = renderDT({
    
    coaches_grouped <- import_coaches_grouped()
    
    datatable(coaches_grouped, 
              selection=list(mode="single"))
  })
  
  output$participation_coaches = renderHighchart({
    coaches_grouped = import_coaches_grouped()
    nome <- coaches_grouped[input$tbl_rows_selected[1],] %>% select(coach)
    temp_coaches <- coaches %>% filter(coach %in% nome) %>% arrange(ano) %>% 
      group_by(medalha, ano)
    
    x <- c("Classificados", "Posição: ", "Universidade:", "Time:")
    y <- sprintf("{point.%s}", c("classificado", "posicao", "universidade", "time"))
    tltip <- tooltip_table(x, y)
    
    hchart(temp_coaches, "scatter", hcaes(x = ano, y=posicao, group = medalha)) %>%
      hc_title(text = "Resultado das competições anteriores", style = list(fontSize = "15px")) %>%
      hc_tooltip(useHTML = TRUE, headerFormat = "", pointFormat = tltip)
    
})
  
}

shinyApp(ui = ui, server = server)