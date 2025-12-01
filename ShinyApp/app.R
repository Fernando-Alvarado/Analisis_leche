# Importando las librerias necesarias
library(shiny)
library(bslib)

# Importando los modulos
#source("Modulos/graficas.r")





library(shiny)
library(bslib)

source("Modulos/graficas.r")  # si aquí tienes módulos, está bien

ui <- page_sidebar(
  title = "Forecasting Estratégico para la Industria Lechera",
  sidebar = sidebar(
    sliderInput(
      inputId = "bins",
      label  = "Number of bins:",
      min    = 1,
      max    = 50,
      value  = 30
    )
  ),
  # contenido principal
  mainPanel(
    plotOutput("distPlot")
  )
)

server <- function(input, output, session) {
  # Ejemplo simple para que veas que levanta
  output$distPlot <- renderPlot({
    x <- faithful$waiting
    hist(x, breaks = input$bins)
  })

  # Aquí luego metemos tus módulos de graficas.r
}

shinyApp(ui = ui, server = server)
