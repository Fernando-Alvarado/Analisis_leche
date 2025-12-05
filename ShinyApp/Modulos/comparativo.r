#Aqui pondre todas las graficas de los modelos que estamos comparando 
library(dplyr)
library(here)
library(ggplot2)
library(forecast)
library(tseries)
library(TSA)
library(astsa)      # Version 2.3
library(ggthemes)   # Version 5.1.0
library(gridExtra)
library(skimr)


data <- read.csv(here("data", "milk_and_Pigs_Slaughtered.csv"), header = TRUE)
head(data)


# Separando los datos desde un principio para no tener data leakage

milk <- data$milk   
n <- length(milk)     # 120
train_size <- floor(0.8 * n)   # 96

train <- milk[1:train_size]    # posiciones 1 a 96
test  <- milk[(train_size+1):n] # posiciones 97 a 120


ggtsdisplay(train) # Grafica de como venian los datos solos


resultado <- diff(train, lag =12)#Haciendo la serie estacionaria
ggtsdisplay(resultado)





##===================================================================
##=== Empezando a hacer los forecasts ===============================
##===================================================================

# Funcion con la que hacemos los pronosticos en produccion, dividimos la muestra en 80%-20%
# Parametros:
# vector1: primer vector del sarima que vamos a usar
# Vector2: segundo vector del sarima que vamos a usar
# Salida: Grafica con el pronostico y las metricas de error RMSE

forecastProduccion <- function(vector1, vector2){
    
        # Datos como ts sólo para el entrenamiento
        train_ts <- ts(train, frequency = 12)
        # Ajustas el modelo SOLO con train_ts
        fit <- Arima(train_ts, order = vector1, seasonal = vector2)
        # Horizonte = tamaño del test
        h <- length(test)
        # Pronóstico
        fc <- forecast(fit, h = h)
        # Métricas sin broncas de tiempo
        accuracy(fc, test)

        # Gráfica: test alineado al final
        test_ts <- ts(
        test,
        frequency = 12,
        start = end(train_ts) + c(0, 1)  # empieza justo después del train
        )

        # Sacando las metricas que nos interesan 
        # ============================================================================
        acc <- accuracy(fc, test)
        rmseTest <- acc["Test set", "RMSE"]
        rmseTrain <- acc["Training set", "RMSE"]
        #===========================================================================

        graficaForecast <- autoplot(fc) +
        autolayer(test_ts, series = "Test") +        # aquí quité PI = FALSE
        xlab("Tiempo") +
        ylab("Milk") +
        ggtitle("Pronóstico vs datos de prueba") +
        labs(subtitle = paste(
            "RMSE Train:", round(rmseTest, 2),
            "   RMSE Test:", round(rmseTrain, 2), 
            "   AIC:", round(fit$aic, 2)
        ))


    return(graficaForecast)
}
# Funcion encargada de hacer las graficas de los residuales del modelo

residualesModelos <- function( vector1, vector2){
    fit <- Arima(train, order=vector1,seasonal=vector2)
    return(checkresiduals(fit))
}



        #Primer modelo
        #forecast1 = forecastProduccion(c(1,1,1), c(1,1,1)),
        #residuales1 = residualesModelos(c(1,1,1), c(1,1,1)),
        #Segundo modelo
        #forecast2 = forecastProduccion(c(1,1,0), c(1,1,1)),
        #residuales2 = residualesModelos(c(1,1,0), c(1,1,1)),
        #Tercer modelo
        #forecast3 = forecastProduccion(c(1,1,2), c(1,1,1)),
        #residuales3 = residualesModelos(c(1,1,2), c(1,1,1))
        #Cuarto modelo
        #forecast4 = forecastProduccion(c(2,1,1), c(1,1,1)),
        #residuales4 = residualesModelos(c(2,1,1), c(1,1,1)),
       

#forecastProduccion(c(2,1,1), c(1,1,1))
