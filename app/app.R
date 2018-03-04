library(shiny)
library(shinyjs)
library(shinydashboard)
library(ggplot2)
library(highcharter)
library(plotly)
library(dplyr)
library(leaflet)
library(DT)
library(viridis)
library(viridisLite)

source("../app/util_imports.R")
source("../app/ui_scripts.R")

universities = import_universities()
competitors = import_competitors()
coaches = import_coaches()

ui = dashboardPage(
  dashboardHeader(title = "Header da página"),
  dashboardSidebar(
    useShinyjs(),
    menu_itens()
  ),
  dashboardBody(
    tab_itens(competitors)
  )
)

server = function(input, output) {
  
  output$problemas_geral = renderHighchart({

    problems = import_problems(input$problems_years)
    problems$NotAccepted = problems$Total - problems$Accepted

    highchart() %>%
      hc_chart(animation = FALSE) %>%
      hc_title(text = "Submissões em problemas") %>%
      hc_xAxis(title = list(text = "Questão"), 
               categories = problems$Problems) %>%
      hc_yAxis(title = list(text = "Número de submissões")) %>%
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
      mutate(Size = QntTimes) %>%
      arrange(-QntTimes)
    
    colors <- c("#FFEB3B", "#9AD2E1")
    m_competitors$Color <- colorize(m_competitors$QntTimes, colors)
    x <- c("Universidade:", "Num times classificados: ")
    y <- sprintf("{point.%s}", c("universidade", "QntTimes"))
    tltip <- tooltip_table(x, y)

    hchart(m_competitors, "bar", hcaes(x = universidade, y = QntTimes, size = Size, color = Color)) %>%
      hc_title(text = "Participação por universidade no campeonato mundial", style = list(fontSize = "15px")) %>%
      hc_tooltip(useHTML = TRUE, headerFormat = "", pointFormat = tltip) %>%
      hc_yAxis(title = list(text = "Quantida de times classificados"),
               type = "category"
      ) %>%
      hc_xAxis(title = list(text = "Universidade"))
    
    # library("viridisLite")
    # cols <- viridis(3)
    # cols <- substr(cols, 0, 7)
    # highcharts_demo() %>%
    #   hc_colors(cols)
    
  })
  
  output$mapa <- renderLeaflet({
    data_mapa <- readRDS(file = "../app/mapa/mapa_competidores.rds")
    
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