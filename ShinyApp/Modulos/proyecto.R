library(astsa)        # Version 2.3
library(ggplot2)      # Version 3.5.2
library(ggthemes)     # Version 5.1.0
library(dplyr)        # Version 1.1.4
library(tseries)      # Version 0.10-58
library(forecast)     # Version 8.24.0  
library(TSA)          # Version 1.3.1
library(here)         # Version 1.0.1




source(here("ShinyApp", "Modulos" ,"plot_ts.R"))

## Leemos los datos
milk = read.csv(here("Data", "Milk_and_Pigs_Slaughtered.csv"), header = TRUE)
milk = milk$milk
milk = ts(milk)
plot_TS(milk)
milk_diff = diff(milk)
plot_TS(milk)
n = length(milk)

## ACF Milk
acf_res = acf(milk_diff,lag.max=30,plot=F)
lag = acf_res$lag[,1,]
val = acf_res$acf[,1,]
u = rep(1.96/sqrt(n),30)
l = -u
acf_df = data.frame(lag,val,u,l)  
plot_acf(acf_df)

# Periodogram Milk
period_temp=periodogram(milk_diff,plot=F)
df_period=data.frame(freq=period_temp$freq,spec=period_temp$spec)
plot_periodogram(df_period)

# Dominating cycles Milk
head(order(period_temp$spec,decreasing=T))
1/period_temp$freq[10]
1/period_temp$freq[2]
1/period_temp$freq[13]
1/period_temp$freq[4]

# diferenciamos con lag 12 Milk
diff_lag_milk = diff(milk_diff, lag = 12)
n = length(diff_lag_milk)

# ACF diferenciado lag 12
acf_resdiff = acf(diff_lag_milk,lag.max=30,plot=F)
lag = acf_resdiff$lag[,1,]
val = acf_resdiff$acf[,1,]
u = rep(1.96/sqrt(n),30)
l = -u
acf_df = data.frame(lag,val,u,l)  
plot_acf(acf_df)

# PACF Milk
pacf_resdiff = pacf(diff_lag_milk,lag.max = 30,plot=F)
lag = pacf_resdiff$lag
val = pacf_resdiff$acf
u = rep(1.96/sqrt(n_diff),30)
l = -u
pacf_diff = data.frame(lag,val,u,l)  
plot_pacf(pacf_diff)

# Model for Xt Milk
mod = Arima(milk, order = c(1,1,1), 
            seasonal = list(order=c(1,1,1),period=12));mod

# Residuals of Xt Milk
n=length(mod$residuals)

df_res=data.frame(x=c(1:n),y=mod$residuals)
ggplot(data=df_res,aes(x=x,y=y))+
  geom_line()+
  theme_minimal()+
  labs(x='',y='')

# ACF of Residuals
acf_res = acf(df_res$y,lag.max=30,plot=F)
lag = acf_res$lag[,1,]
val = acf_res$acf[,1,]
u = rep(1.96/sqrt(n),30)
l = -u
acf_df = data.frame(lag,val,u,l)  
plot_acf(acf_df)

# PACF
pacf_res = pacf(df_res$y,lag.max = 30,plot=F)
lag = pacf_res$lag[,1,]
val = pacf_res$acf[,1,]
u = rep(1.96/sqrt(n),30)
l = -u
pacf_df = data.frame(lag,val,u,l)  
plot_pacf(pacf_df)

# Ljung-Box test
Box.test(df_res$y,lag=12,type='Ljung-Box')

checkresiduals(mod)

# ====================================================================
# ====================================================================
#                   MODELO HOLT-WINTERS
# ====================================================================
# ====================================================================


# Ajustamos el modelo
# Usamos un ajueste aditivo ya que parece haber ciclos y la amplitud de 
# nuestro ciclo no se modifica con el paso del tiempo
milk = read.csv(here("Data", "Milk_and_Pigs_Slaughtered.csv"), header = TRUE)
milk = milk$milk
milk = ts(milk, frequency = 12)
hw_model = HoltWinters(milk, 
                       seasonal = "additive",
                       start.periods = 12)




print(hw_model)
summary(hw_model)

## Observemos los residuales, la gr�fica no parece tan convincente, pero 
# pero no es evidencia para concluir.
checkresiduals(hw_model)

# ============================================================================
# Predicci�n con Holt-Winters
# ============================================================================

# Predecimos 24 meses
hw_forecast = forecast(hw_model, h = 24)

# Graficamos
plot(hw_forecast, 
     main = "Holt-Winters Predicci�n",
     ylab = "Milk Production",
     xlab = "Time")

# ============================================================================
# An�lisis de residuales
# ============================================================================

# Hacemos un dataframe con los residuales del modelo
hw_residuals = residuals(hw_model)
n_hw = length(hw_residuals)
df_res_hw = data.frame(x = c(1:n_hw), y = as.numeric(hw_residuals))

# Graficamos los residuales, la gr�fica es muy parecida a la de los 
# residuales del SARIMA
ggplot(data = df_res_hw, aes(x = x, y = y)) +
  geom_line() +
  theme_minimal() +
  labs(title = "Holt-Winters Residuals",
       x = '', 
       y = '')

# ============================================================================
# ACF de los residuales
# ============================================================================

acf_res_hw = acf(df_res_hw$y, lag.max = 30, plot = F)
lag = acf_res_hw$lag[,1,]
val = acf_res_hw$acf[,1,]
u = rep(1.96/sqrt(n_hw), 30)
l = -u
acf_df_hw = data.frame(lag, val, u, l)  
plot_acf(acf_df_hw)

# ============================================================================
# PACF de los residuales
# ============================================================================

pacf_res_hw = pacf(df_res_hw$y, lag.max = 30, plot = F)
lag = pacf_res_hw$lag
val = pacf_res_hw$acf
u = rep(1.96/sqrt(n_hw), 30)
l = -u
pacf_df_hw = data.frame(lag, val, u, l)  
plot_pacf(pacf_df_hw)

# ============================================================================
# LJUNG-BOX TEST para ver si los residuales son ruido blanco
# ============================================================================

Box.test(df_res_hw$y, lag = 12, type = 'Ljung-Box')

# ============================================================================
# Comparaci�n de modelos: SARIMA vs Holt-Winters
# ============================================================================

# M�tricas de error
rmse_sarima = sqrt(mean(mod$residuals^2))
mae_sarima = mean(abs(mod$residuals))

rmse_hw = sqrt(mean(hw_residuals^2))
mae_hw = mean(abs(hw_residuals))

# Sacamos a mano el AIC del Holt-Winters
# AIC = 2*k + n*log(SSE/n), donde k = num. parametros,
#n = observaciones, SSE = suma de erorres cuadraticos
n_obs = length(milk)
sse_hw = sum(hw_residuals^2)
# Holt-Winters tiene 3 parametros (level, trend, seasonal) + smoothing parameters
k_hw = 3 + 3  # Parametros exp smoothing: alpha, beta, gamma smoothing parameters
aic_hw = 2*k_hw + n_obs*log(sse_hw/n_obs)

# juntamos los datos en un dataframe
comparison_df = data.frame(
  Model = c("SARIMA", "Holt-Winters"),
  RMSE = c(rmse_sarima, rmse_hw),
  MAE = c(mae_sarima, mae_hw),
  AIC = c(mod$aic, aic_hw)
)

print(comparison_df)

# ============================================================================
# Comparaci�n visual: Valores ajustados
# ============================================================================

# Vamos a juntar los datos observados con las predicciones
n_data = length(milk)

# Hay que completar con 13 NA debido al lag 12
sarima_fitted = c(rep(NA, 13), mod$fitted[1:(n_data-13)])

# Datos ajustados de HW
hw_fitted = c(rep(NA, 13),fitted(hw_model)[1:(n_data-13)])

# Creamos un dataframe y juntamos los datos
comparison_plot_df = data.frame(
  time = c(1:n_data),
  actual = as.numeric(milk),
  sarima = sarima_fitted,
  hw = hw_fitted
)

# Comparaci�n gr�fica
ggplot(data = comparison_plot_df, aes(x = time)) +
  geom_line(aes(y = actual, color = "Actual"), size = 1) +
  geom_line(aes(y = sarima, color = "SARIMA"), size = 0.8, alpha = 0.8) +
  geom_line(aes(y = hw, color = "Holt-Winters"), size = 0.8, alpha = 0.8) +
  theme_minimal() +
  labs(title = "SARIMA vs Holt-Winters: Fitted Values",
       x = "Time",
       y = "Milk Production",
       color = "Model") +
  theme(legend.position = "bottom")

# ============================================================================
# Resumen de la comparaci�n
# ============================================================================

# Create a summary of residual diagnostics
cat("\n====== Resumen de la comparaci�n ======\n")
cat("SARIMA - Box-Ljung p-value: ")
cat(Box.test(mod$residuals, lag = 12, type = 'Ljung-Box')$p.value, "\n")

cat("Holt-Winters - Box-Ljung p-value: ")
cat(Box.test(hw_residuals, lag = 12, type = 'Ljung-Box')$p.value, "\n")
cat("(Valores mayores del p-value indican que los residuales son m�s como ruido blanco)\n")






# ====================================================================
# TRAIN/TEST SPLIT (80/20)
# ====================================================================

# Cargamos los datos
milk = read.csv(here("Milk and Pigs Slaughtered.csv"))
milk = milk$milk
milk = ts(milk)

# Dividimos los datos: 80% entrenamiento, 20% prueba
n_total = length(milk)
train_size = floor(0.8 * n_total)
test_size = n_total - train_size

milk_train = window(milk, start = 1, end = train_size)
milk_test = window(milk, start = train_size + 1, end = n_total)

cat("Total observations:", n_total, "\n")
cat("Training set size:", length(milk_train), "\n")
cat("Test set size:", length(milk_test), "\n")

# ====================================================================
# MODELO SARIMA CON TRAIN
# ====================================================================

# Ajustamos el SARIMA solo con el conjunto de entrenamiento
mod_train = Arima(milk_train, order = c(1,1,1), 
                  seasonal = list(order=c(1,1,1), period=12))

print(mod_train)

# Hacemos predicciones en el conjunto de prueba
sarima_predictions = forecast(mod_train, h = length(milk_test))$mean

# Comparamos con valores reales
sarima_rmse_test = sqrt(mean((milk_test - sarima_predictions)^2))
sarima_mae_test = mean(abs(milk_test - sarima_predictions))

cat("\n====== SARIMA Test Set Performance ======\n")
cat("RMSE:", sarima_rmse_test, "\n")
cat("MAE:", sarima_mae_test, "\n")

# ====================================================================
# MODELO HOLT-WINTERS CON TRAIN
# ====================================================================

# Ajustamos Holt-Winters solo con el conjunto de entrenamiento

milk = read.csv(here("Milk and Pigs Slaughtered.csv"))
milk = milk$milk
milk = ts(milk, frequency = 12)

# Dividimos los datos: 80% entrenamiento, 20% prueba
n_total = length(milk)
train_size = floor(0.8 * n_total)
test_size = n_total - train_size
milk_train = ts(milk_train, frequency = 12, start = start(milk))
milk_test = ts(milk_test, frequency = 12, start = c(start(milk)[1], start(milk)[2] + train_size))

hw_model_train = HoltWinters(milk_train, 
                             seasonal = "additive")

print(hw_model_train)

# Hacemos predicciones en el conjunto de prueba
hw_predictions = forecast(hw_model_train, h = length(milk_test))$mean

# Comparamos con valores reales
hw_rmse_test = sqrt(mean((milk_test - hw_predictions)^2))
hw_mae_test = mean(abs(milk_test - hw_predictions))

cat("\n====== Holt-Winters Test Set Performance ======\n")
cat("RMSE:", hw_rmse_test, "\n")
cat("MAE:", hw_mae_test, "\n")

# ====================================================================
# COMPARACI�N EN EL CONJUNTO DE PRUEBA
# ====================================================================

comparison_test_df = data.frame(
  Model = c("SARIMA", "Holt-Winters"),
  RMSE = c(sarima_rmse_test, hw_rmse_test),
  MAE = c(sarima_mae_test, hw_mae_test)
)

print(comparison_test_df)
cat("\nMejor modelo (menor RMSE):", comparison_test_df$Model[which.min(comparison_test_df$RMSE)], "\n")

# ====================================================================
# VISUALIZACI�N: Predicciones vs Valores Reales en Test Set
# ====================================================================

# Creamos un dataframe con los resultados
test_comparison_plot = data.frame(
  time = c((train_size + 1):n_total),
  actual = as.numeric(milk_test),
  sarima_pred = as.numeric(sarima_predictions),
  hw_pred = as.numeric(hw_predictions)
)

# Gr�fica
ggplot(data = test_comparison_plot, aes(x = time)) +
  geom_line(aes(y = actual, color = "Actual"), size = 1) +
  geom_line(aes(y = sarima_pred, color = "SARIMA"), size = 0.8, alpha = 0.8, linetype = "dashed") +
  geom_line(aes(y = hw_pred, color = "Holt-Winters"), size = 0.8, alpha = 0.8, linetype = "dashed") +
  theme_minimal() +
  labs(title = "Test Set: SARIMA vs Holt-Winters Predictions",
       x = "Time",
       y = "Milk Production",
       color = "Model") +
  theme(legend.position = "bottom")

# ====================================================================
# AJUSTAR MODELOS CON DATOS COMPLETOS (OPCIONAL)
# ====================================================================

# Una vez hayas validado que los modelos funcionan bien,
# puedes ajustarlos con TODOS los datos para hacer predicciones futuras

mod_final = Arima(milk, order = c(1,1,1), 
                  seasonal = list(order=c(1,1,1), period=12))

hw_model_final = HoltWinters(ts(milk, frequency = 12), seasonal = "additive", start.periods = 12)

# Predicciones futuras
sarima_future = forecast(mod_final, h = 24)
hw_future = forecast(hw_model_final, h = 24)

# Visualizar predicciones futuras
plot(sarima_future, main = "SARIMA: Predicciones Futuras")
plot(hw_future, main = "Holt-Winters: Predicciones Futuras")
