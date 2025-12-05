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

library(forecast)
library(ggplot2)


data <- read.csv(here("data", "milk_and_Pigs_Slaughtered.csv"), header = TRUE)
head(data)




# --------- Datos train / test ----------
milk <- data$milk
n <- length(milk)

train_size <- floor(0.8 * n)
train <- milk[1:train_size]
test  <- milk[(train_size + 1):n]

train_ts <- ts(train, frequency = 12)

h <- 12
test12    <- test[1:h]
test12_ts <- ts(test12,
                start = tsp(train_ts)[2] + 1/12,
                frequency = 12)

# --------- Modelo Holt-Winters vía ETS (AAA) ----------
# ETS(AAA) = Holt-Winters aditivo
ets_hw <- forecast::ets(train_ts, model = "AAA")

fc_hw  <- forecast::forecast(ets_hw, h = h)

# Métricas con accuracy()
acc_hw <- forecast::accuracy(fc_hw, test12_ts)

print(acc_hw)

rmseTrain_hw <- acc_hw["Training set", "RMSE"]
rmseTest_hw  <- acc_hw["Test set",  "RMSE"]

# AIC NUMÉRICO
aic_hw <- ets_hw$aic
is.numeric(aic_hw)  # aquí debe dar TRUE

# --------- Gráfica forecast vs test ----------
graficaForecast_hw <- autoplot(fc_hw) +
  autolayer(test12_ts, series = "Test") +
  xlab("Tiempo") +
  ylab("Producción de leche") +
  ggtitle("Pronóstico Holt-Winters (ETS AAA) vs datos de prueba") +
  labs(subtitle = paste(
    "RMSE Train:", round(rmseTrain_hw, 2),
    "   RMSE Test:", round(rmseTest_hw, 2),
    "   AIC:", round(aic_hw, 2)
  )) +
  theme_minimal()


# --------- Gráfica de residuales (train) ----------
df_res_hw <- data.frame(
  t = time(train_ts),
  r = as.numeric(residuals(ets_hw))
)

graficaResiduales_hw <- function(){return( checkresiduals(ets_hw))}


