# Importando las librerias necesarias
library(shiny)
library(bslib)
library(here) 
# Importando los modulos
#source("Modulos/graficas.r")

source(here("ShinyApp", "Modulos", "modelo_Holt_Winters.r"))  # si aquí tienes módulos, está bien
source(here("ShinyApp", "Modulos", "comparativo.r"))  
source(here("ShinyApp", "Modulos", "Holt.r"))  


ui <- page_fixed(
  title = "Forecasting Estratégico para la Industria Lechera",
  theme = bslib::bs_theme(
    version   = 5,
    bootswatch = "flatly",
    primary   = "#0d6efd",
    secondary = "#4e73df",
    success   = "#1cc88a",
    info      = "#36b9cc",
    light     = "#f8f9fc",
    dark      = "#2e2e3e",
    base_font = bslib::font_google("Montserrat")
  ),

  # ===== ESTILOS PERSONALIZADOS =====
  tags$head(
    tags$style(HTML("
      .app-title-bar {
        background: linear-gradient(90deg, #0d6efd, #4e73df);
        color: #ffffff;
        padding: 16px 28px;
        border-radius: 16px;
        box-shadow: 0 6px 18px rgba(0,0,0,0.15);
        margin-top: 15px;
        margin-bottom: 25px;
      }

      .app-title {
        font-weight: 700;
        letter-spacing: 0.03em;
      }

      .app-subtitle {
        font-size: 0.85rem;
        opacity: 0.9;
      }

      .app-logo {
        height: 42px;
        margin-right: 10px;
      }

      .card-dashboard {
        border-radius: 14px;
        box-shadow: 0 4px 14px rgba(15, 23, 42, 0.08);
        border: none;
      }

      .card-header-main {
        background-color: #f8f9fc;
        border-bottom: 1px solid #e3e6f0;
        font-weight: 600;
        font-size: 0.95rem;
      }

      .slider-label-strong {
        font-weight: 600;
      }

      .nav-pills .nav-link {
        border-radius: 999px;
      }

      .nav-pills .nav-link.active {
        background-color: #4e73df;
        box-shadow: 0 3px 8px rgba(78,115,223,0.4);
      }
    "))
  ),

  # ===== TÍTULO PRINCIPAL CON LOGOS =====
  div(
    class = "app-title-bar d-flex align-items-center justify-content-between",

    # Logos (pon tus archivos en /www; si no existen, no crashea, sólo no se ven)
    div(
      class = "d-flex align-items-center"
    ),

    # Título y subtítulo
    div(
      class = "flex-grow-1 text-center",
      h2(class = "app-title mb-1",
         "📈 Forecasting Estratégico para la Industria Lechera"
      ),
      div(
        class = "app-subtitle",
        "Modelos SARIMA y Holt-Winters para la planeación de la producción mensual"
      )
    ),

    # Espacio a la derecha (por si luego quieres perfil/fecha)
    div()
  ),

  # ---- FILA SUPERIOR: Configuración + Forecast ----
  layout_columns(
    col_widths = c(3, 9),

    # Panel Izquierdo (Recuadro de configuración)
    card(
      class = "card-dashboard",
      card_header(div(class = "card-header-main", "Configuración del modelo")),
      div(
        class = "mb-2 text-muted small",
        icon("sliders"), " Ajusta el horizonte de pronóstico"
      ),
      sliderInput(
        inputId = "bins",
        label  = span("Meses para predecir:", class = "slider-label-strong"),
        min    = 6,
        max    = 36,
        value  = 12,
        step   = 3
      )
    ),

    # Panel Derecho (Gráfica principal)
    card(
      class = "card-dashboard",
      card_header(div(class = "card-header-main", "Pronóstico Holt-Winters")),
      plotOutput("forecastHolt", height = "350px")
    )
  ),

  tags$br(),

  # ---- FILA INFERIOR: Diagnóstico de residuales ----
  card(
    class = "card-dashboard",
    card_header(div(class = "card-header-main", "Diagnóstico de residuales")),
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
  ),

  tags$br(),

  # ---- COMPARATIVA DE MODELOS ----
  card(
    class = "card-dashboard",
    card_header(div(class = "card-header-main", "Comparativa de modelos propuestos y sus residuos")),
    navset_pill_list(
      id = "tabs_hw",      # dejo el mismo id para no romper tu server

      nav_panel(
        "Modelo: (1,1,1)(1,1,1)_12",
        plotOutput("primerFor", height = "260px"),
        h5("Residuales del modelo: (1,1,1)(1,1,1)_12"),
        plotOutput("residuales1", height = "260px")
      ),
      nav_panel(
        "Modelo: (1,1,0)(1,1,1)_12",
        plotOutput("segundoFor", height = "260px"),
        h5("Residuales del modelo: (1,1,0)(1,1,1)_12"),
        plotOutput("residuales2", height = "260px")
      ),
      nav_panel(
        "Modelo: (1,1,2)(1,1,1)_12",
        plotOutput("tercerFor", height = "260px"),
        h5("Residuales del modelo: (1,1,2)(1,1,1)_12"),
        plotOutput("residuales3", height = "260px")
      ),
      nav_panel(
        "Modelo: Holt-Winters (ETS AAA)",
        plotOutput("cuartoFor", height = "260px"),
        h5("Residuales del modelo: Holt-Winters (ETS AAA)"),
        plotOutput("residuales4", height = "260px")
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
    # ================================================================================    
    # Haciendo las graficas de los forecaste de los distitos modelos que comparamos 
    output$primerFor <- renderPlot({
        forecastProduccion(c(1,1,1), c(1,1,1))
    })
    output$segundoFor <- renderPlot({
        forecastProduccion(c(1,1,0), c(1,1,1))
    })
    output$tercerFor <- renderPlot({
       forecastProduccion(c(2,1,1), c(1,1,1))
    })
    output$cuartoFor <- renderPlot({
        graficaForecast_hw
    })
    # =================================================================================
    #  Poniendo las graficas de los residulos de los distitnos modelos
    output$residuales1 <- renderPlot({
        residualesModelos(c(1,1,1), c(1,1,1))
    })
    output$residuales2 <- renderPlot({
        residualesModelos(c(1,1,0), c(1,1,1))
    })
    output$residuales3 <- renderPlot({
        residualesModelos(c(2,1,1), c(1,1,1))
    })
    output$residuales4 <- renderPlot({
        graficaResiduales_hw()
    })

}

shinyApp(ui = ui, server = server)

