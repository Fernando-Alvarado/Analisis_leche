library(astsa)        # Version 2.3
library(ggplot2)      # Version 3.5.2
library(ggthemes)     # Version 5.1.0
library(dplyr)        # Version 1.1.4
library(tseries)      # Version 0.10-58
library(forecast)     # Version 8.24.0  
library(TSA)          # Version 1.3.1
library(here)         # Version 1.0.1
library(forecast)


source(here("Modulos" ,"plot_ts.R"), local = TRUE)

# Cargando los datos con los que vamos a trabajar 


data <- read.csv(here("data", "Milk_and_Pigs_Slaughtered.csv"), header = TRUE)


# ====================================================================
# ====================================================================
#                   MODELO HOLT-WINTERS
# ====================================================================
# ====================================================================

milk = data$milk


#Funcion para ajustar el modelo Holt-Winters
# Parametros:
# milk: serie de tiempo a modelar, datos que se le meter
# ventana_pred: numero de periodos a predecir en meses
# Salida: (Lista)
# residualesGrap: Funcion que grafica los residuales y hace el test de Ljung-Box
# residualesDF: Data frame con los residuales del modelo
# modeloHolt: Modelo ajustado de Holt-Winters
# pronosticoHolt: Grafica del pronostico (forecast)
# grahpResiduos: Grafica los residuales de nuestro modelo para ver si son
# pafResiduos: Grafica el PACF de los residuales

holtWinter = function(milk, ventana_pred){
     milk_ts <- ts(milk, frequency = 12)

    # Modelo SARIMA(1,1,1)(1,1,1)[12]
    hw_model <- Arima(
        milk_ts,
        order    = c(1, 1, 1),
        seasonal = list(order = c(1, 1, 1), period = 12)
    )
    #Haciendo la prediccion del modelolo 
    hw_forecast <- forecast(hw_model, h = ventana_pred) #Esta se va a modificar con el tiempo 
    #Hacienod la grafica de nuestro modelo 
    forcastHolt <- plot(hw_forecast, 
                        main = "Predicción de la Producción de Leche con Modelo SARIMA(1,1,1)(1,1,1)[12]",
                        ylab = "Milk Production",
                        xlab = "Time")

    # Sacando los residuales de nuestro modelo para poder compararlos
    hw_residuals = residuals(hw_model)
    n_hw = length(hw_residuals)
    df_res_hw = data.frame(x = c(1:n_hw), y = as.numeric(hw_residuals))

    # Poniendo solo los resiudales del modelo
    solo_residuales_hw = ggplot(data = df_res_hw, aes(x = x, y = y)) +
                            geom_line() +
                            theme_minimal() +
                            labs(title = "Residuales del Modelo SARIMA(1,1,1)(1,1,1)[12]",
                                x = '', 
                                y = '')

    # Poniendo el ACF de los resiudles 
    acf_res_hw = acf(df_res_hw$y, lag.max = 30, plot = F)
    lag = acf_res_hw$lag[,1,]
    val = acf_res_hw$acf[,1,]
    u = rep(1.96/sqrt(n_hw), 30)
    l = -u
    acf_df_hw = data.frame(lag, val, u, l)
    grap1 <- plot_acf(acf_df_hw)

    #Poniendo el PACF de los residuales
    pacf_res_hw = pacf(df_res_hw$y, lag.max = 30, plot = F)
    lag = pacf_res_hw$lag
    val = pacf_res_hw$acf
    u = rep(1.96/sqrt(n_hw), 30)
    l = -u
    pacf_df_hw = data.frame(lag, val, u, l)  
    grap2 <- plot_pacf(pacf_df_hw)

     return(list(
        residualesGrap =  function(p = FALSE){ return(checkresiduals(hw_model,  plot = p)) } ,
        residualesDF = df_res_hw, #Para tener solo los resiudles del df
        modeloHolt = hw_model, #En caso de que solo queramos extrar el modelo
        pronosticoHolt = forcastHolt, #Grafica del pronostico (forecast)
        grahpResiduos = solo_residuales_hw, #Grafica los residuales de nuestro modelo para ver si son Ruido blando
        acfResiduos = grap1, #Grafica el ACF de los residuales
        pafResiduos = grap2 #Grafica el PACF de los residuales

    )) 

}
# Probando la funcion

prueba =  holtWinter(milk, ventana_pred = 12)

print(prueba$grahpResiduos)
