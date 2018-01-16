library(shiny)

# Define UI for app that draws a histogram ----
ui <- fluidPage(
  
  # App title ----
  titlePanel("Análise Maratona SBC"),

  # Sidebar layout with input and output definitions ----
  sidebarLayout(
     
    sidebarPanel(
       helpText("Análise dos dados da Maratona SBC do Brasil nos últimos anos."),
       sliderInput("slider", h4("Slider"), min = 0, max = 100, value = 50)),
     
     
     mainPanel(
       plotOutput(outputId = "histPlot"),
       textOutput("selected_var"))
  )
)

# Define server logic required to draw a histogram ----
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

