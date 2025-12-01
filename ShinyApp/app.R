# Importando las librerias necesarias
library(shiny)
library(bslib)
library(here) 
# Importando los modulos
#source("Modulos/graficas.r")

source(here("ShinyApp", "Modulos", "modelo_Holt_Winters.r"))  # si aquí tienes módulos, está bien

ui <- page_fixed(
   # ===== TÍTULO PRINCIPAL =====
  div(
    style = "text-align:center; margin-top:15px; margin-bottom:25px;",
    h2("📈 Forecasting Estratégico para la Industria Lechera")
  ),

  # ---- FILA SUPERIOR: Configuración + Forecast ----
  layout_columns(
    col_widths = c(3, 9),

    # Panel Izquierdo (Recuadro de configuración)
    card(
      card_header("Configuración del modelo"),
      sliderInput(
        inputId = "bins",
        label  = "Meses para predecir:",
        min    = 6,
        max    = 36,
        value  = 12
      )
    ),

    # Panel Derecho (Gráfica principal)
    card(
      card_header("Pronóstico Holt-Winters"),
      plotOutput("forecastHolt", height = "350px")
    )
  ),

  tags$br(),

  # ---- FILA INFERIOR: Diagnóstico de residuales ----
  card(
    card_header("Diagnóstico de residuales"),
    navset_pill_list(
      id = "tabs_hw",

      nav_panel(
        "Resumen de residuales",
        plotOutput("resumenResiduales", height = "260px")
      ),
      nav_panel(
        "Residuos individuales",
        plotOutput("plotresiduos", height = "260px")
      ),
      nav_panel(
        "ACF de los residuales",
        plotOutput("plotACFresiduos", height = "260px")
      ),
      nav_panel(
        "PACF de los residuales",
        plotOutput("plotPACFresiduos", height = "260px")
      )
    )
  )
)




server <- function(input, output, session) {

  # 1) Modelo reactivo que depende de input$bins
  prueba <- reactive({
    holtWinter(milk, ventana_pred = input$bins)
  })

  # 2) Pronóstico principal
  output$forecastHolt <- renderPlot({
    # si pronosticoHolt ya es un ggplot, esto basta
    prueba()[[3]]   # o prueba()$pronosticoHolt
  })

    # 3) Resumen de residuales
    output$resumenResiduales <- renderPlot({
         prueba()$residualesGrap(p = TRUE)   # o prueba()$solo_residuales_hw
        })

    # 4) Residuos individuales
    output$plotresiduos <- renderPlot({
        prueba()[[5]]   # o prueba()$solo_residuales_hw
        })
    # 5) ACF de los residuales
    output$plotACFresiduos <- renderPlot({
        prueba()[[6]]   # o prueba()$acf_df_hw
        })

    # 6) PACF de los residuales
    output$plotPACFresiduos <- renderPlot({
        prueba()[[7]]   # o prueba()$pacf_df_hw
        })

}

shinyApp(ui = ui, server = server)

