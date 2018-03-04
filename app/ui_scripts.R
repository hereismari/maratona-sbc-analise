library(shinydashboard)
library(shinyjs)

menu_itens = function() {
  sidebarMenu(
    id = "menu",
    menuItem("Sobre", tabName = "tab_sobre", icon = icon("bookmark")),
    menuItem("Números da Maratona", tabName = "tab_numeros", icon = icon("bookmark")),
    menuItem("Universidades", tabName = "tab_universidades", icon = icon("bookmark")),
    menuItem("Contests", tabName = "tab_contests", icon = icon("bookmark")),
    menuItem("Medalhistas", tabName = "tab_medalhistas", icon = icon("bookmark")),
    menuItem("Coaches", tabName = "tab_coaches", icon = icon("bookmark")),
    menuItem("Regiões do Brasil", tabName = "tab_regioes", icon = icon("bookmark")) 
  )
}

tab_itens = function(competitors) {
  tabItems(
    tabItem(tabName = "tab_numeros", tab_numeros()),
    tabItem(tabName = "tab_coaches", tab_coaches()),
    tabItem(tabName = "tab_medalhistas"),
    tabItem(tabName = "tab_sobre"),
    tabItem(tabName = "tab_universidades", tab_universidades(competitors)),
    tabItem(tabName = "tab_contests", tab_contests()),
    tabItem(tabName = "tab_regioes", tab_regioes())
  )
}

tab_numeros = function() {
  basicPage(
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
  )
}

tab_coaches = function() {
  basicPage(
    fluidRow(
      column(width = 12,
             DTOutput('tbl')
      ),
      verbatimTextOutput("selectedCells")
    ),
    fluidRow(
      conditionalPanel(condition =  "typeof input.tbl_rows_selected  !== 'undefined' && input.tbl_rows_selected.length > 0",
                       box(width = NULL,
                           highchartOutput("participation_coaches")
                       )
      )
    )    
  )
}

tab_universidades = function(competitors) {
  basicPage(
    h3("Algum título"),
    fluidRow(
      column(width = 3,
             box(width = NULL,
                 selectInput(inputId = "univs", label = h3("Universidades"),
                             choices = unique(competitors$universidade), multiple=T,
                             selected = c("UFCG", "USP", "UFPE")
                 )
             )
      ),
      column(width = 6,
             box(width = NULL, highchartOutput("participation_univs")),
             box(width = NULL,  
                 sliderInput(inputId = "classifications_years", label = "Anos:",
                             min = min(competitors$ano), max = max(competitors$ano), step = 1, 
                             sep = "", value = c(2015, 2017))
             )
      )
    )
  )
}

tab_contests = function() {
  basicPage(
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
  )
}

tab_regioes = function() {
  basicPage(
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
}