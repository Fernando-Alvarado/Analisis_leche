####################################################################
# Air passengers time series
# Author: Jose Antonio Perusquia Cortes
# Afil: Facultad de Ciencias - UNAM
# Module: Time series 
####################################################################

####################################################################
# Libraries
library(astsa)        # Version 2.3
library(ggplot2)      # Version 3.5.2
library(ggthemes)     # Version 5.1.0
library(dplyr)        # Version 1.1.4
library(tseries)      # Version 0.10-58
library(here)         # Version 1.0.1
library(forecast)     # Version 8.24.0    
library(TSA)          # Version 1.3.1
####################################################################

####################################################################
# Functions
source(here('plot_ts.R'))
####################################################################

####################################################################
# Air passenger data
data("AirPassengers")
n=length(AirPassengers)
plot_TS(AirPassengers)
####################################################################

####################################################################
# Moving average q=1
MovAv = stats::filter(AirPassengers,rep(1/3,3),sides=2)
plot_TS(MovAv)

Res = AirPassengers-MovAv
plot_TS(Res)
####################################################################

####################################################################
# Moving average with q = 6
MovAv2 = stats::filter(AirPassengers,rep(1/13,13),sides=2)
plot_TS(MovAv2)

Res = AirPassengers-MovAv2
plot_TS(Res)
####################################################################

####################################################################
# Exponential smoothing state space model
etsAir = ets(AirPassengers)

# Fitted values and original series
etsAirFit = data.frame(t=time(AirPassengers),X=etsAir$fitted)
plot_TS(AirPassengers)+
  geom_line(data=etsAirFit,aes(x=t,y=X),col='red')

# Residuales
etsAirRes = etsAir$residuals
plot_TS(etsAirRes)

# ACF of Residuals
acf_res = acf(etsAirRes,lag.max = 30,plot=F)
lag = acf_res$lag
val = acf_res$acf
u = rep(1.96/sqrt(n),30)
l = -u
acf_res = data.frame(lag,val,u,l)  
plot_acf(acf_res)

# PACF
pacf_res = pacf(etsAirRes,lag.max = 30,plot=F)
lag = pacf_res$lag
val = pacf_res$acf
u = rep(1.96/sqrt(n),30)
l = -u
pacf_res = data.frame(lag,val,u,l)  
plot_pacf(pacf_res)

# Ljung-Box test (not white noise)
Box.test(etsAirRes,lag=12,type='Ljung-Box')
####################################################################

####################################################################
# SARIMA approach

# Apply logarithm to control the variance
logAirPass = log(AirPassengers)
plot_TS(logAirPass)

# Periodogram
period_air=periodogram(logAirPass,plot=F)
df_period=data.frame(freq=period_air$freq,spec=period_air$spec)
plot_periodogram(df_period)

# Dominating cycles
head(order(period_air$spec,decreasing=T))
1/period_air$freq[1]
1/period_air$freq[2]
1/period_air$freq[12]
1/period_air$freq[3]

# Differentiating at lag 12 and lag 1 to remove trend
airDiff = diff(logAirPass,lag=12)
airDiff = diff(airDiff,lag=1)
n_diff = length(airDiff)
plot_TS(airDiff)

# ACF
acf_diff = acf(airDiff,lag.max = 30,plot=F)
lag = acf_diff$lag
val = acf_diff$acf
u = rep(1.96/sqrt(n_diff),30)
l = -u
acf_diff = data.frame(lag,val,u,l)  
plot_acf(acf_diff)

# PACF
pacf_diff = pacf(airDiff,lag.max = 30,plot=F)
lag = pacf_diff$lag
val = pacf_diff$acf
u = rep(1.96/sqrt(n_diff),30)
l = -u
pacf_diff = data.frame(lag,val,u,l)  
plot_pacf(pacf_diff)

# Model for Xt
mod = Arima(logAirPass, order = c(1,1,1), 
            seasonal = list(order=c(1,1,1),period=12));mod

# Residuals of Xt
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

# Prediction for the logAirPass series
t=time(AirPassengers)
df_Xt=data.frame(t=t,X=logAirPass)

k=24
preds=forecast(mod,h=k)
tnew = c(1961.000,1961.083,1961.167,1961.250,1961.333,1961.417,
         1961.500,1961.583,1961.667,1961.750,1961.833,1961.917,
         1962.000,1962.083,1962.167,1962.250,1962.333,1962.417,
         1962.500,1962.583,1962.667,1962.750,1962.833,1962.917)

df_preds=data.frame(t=tnew,x=preds$mean,
                    l=preds$lower[,2],u=preds$upper[,2])

plot_preds(df_Xt,df_preds)

# Prediction for the original series
df_Xt=data.frame(t=t,X=AirPassengers)
df_preds=data.frame(t=tnew,x=exp(preds$mean),
                    l=exp(preds$lower[,2]),u=exp(preds$upper[,2]))

plot_preds(df_Xt,df_preds)
####################################################################