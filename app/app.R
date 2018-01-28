library(shiny)
library(shinyjs)
library(shinydashboard)
library(ggplot2)
library(highcharter)
library(plotly)
#source("pre_processa.R")
#source("app/util_imports.R")

#source("pre_processa.R")
#source("util_imports.R")


ui <- dashboardPage(
  
  dashboardHeader(title = "Header da página"),
  
  dashboardSidebar(
    useShinyjs(),
    sidebarMenu(id = "menu",
                menuItem("Universidades", tabName = "tab1", icon = icon("bookmark")),
                menuItem("Times", tabName = "tab2", icon = icon("bookmark"))
    )
  ),
  dashboardBody(
    
    tabItems(
      tabItem(tabName = "tab1",
              fluidRow(
                column(width = 4,
                       box(width = NULL, 
                           selectInput("tab1_select_univ", label = h3("Universidades"),
                                       choices = unique(universidades$nome), multiple=T,
                                       selected = c("UFCG")
                           )
                       )
                ),                
                column(width = 8,
                       box(width = NULL)
                )
              )
              
      ),
      
      tabItem(tabName = "tab2",
              fluidRow(
                column(width = 4,
                       box(width = NULL)
                ),
                column(width = 8,
                       box(width = NULL)
                )
              )
              
      )
    )
  )
)


server <- function(input, output) {
  
  output$selected_var <- renderText({ 
    paste("You have selected", input$slider)
  })
  
  output$histPlot <- renderPlot({
    x    <- faithful$waiting
    bins <- seq(min(x), max(x), length.out = input$slider + 1)
    
    hist(x, breaks = bins, col = "#75AADB", border = "white",
         xlab = "xlab",
         ylab = "ylab",
         main = "Histogram example")
    
  })
}

shinyApp(ui = ui, server = server)

