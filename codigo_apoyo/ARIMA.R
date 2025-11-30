####################################################################
# ARIMA (p,d,q) models 
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
library(forecast)     # Version 8.24.0  
library(TSA)          # Version 1.3.1
library(here)         # Version 1.0.1
####################################################################

####################################################################
# Functions
source(here('plot_ts.R'))
####################################################################

####################################################################
# ARIMA(1,1,0)
n=200
h=n/4

set.seed(314159)
Xt = arima.sim(list(order = c(1,1,0), ar = 0.7), n = n-1)
plot_TS(Xt)

# ACF
acf_Xt = acf(Xt,lag.max=h,plot=F)
lag = acf_Xt$lag[,1,]
val = acf_Xt$acf[,1,]
u = rep(1.96/sqrt(n),h)
l = -u
acf_df = data.frame(lag,val,u,l)  
plot_acf(acf_df)

# PACF
pacf_Xt = pacf(Xt,lag.max = h,plot=F)
lag = pacf_Xt$lag[,1,]
val = pacf_Xt$acf[,1,]
u = rep(1.96/sqrt(n),h)
l = -u
pacf_df = data.frame(lag,val,u,l)  
plot_pacf(pacf_df)

# Differentiate the process 
n_Yt=n-1
Yt = diff(Xt,1)
plot_TS(Yt)

# ACF
acf_Yt = acf(Yt,lag.max=h,plot=F)
lag = acf_Yt$lag[,1,]
val = acf_Yt$acf[,1,]
u = rep(1.96/sqrt(n_Yt),h)
l = -u
acf_df = data.frame(lag,val,u,l)  
plot_acf(acf_df)

# PACF
pacf_Yt = pacf(Yt,lag.max = h,plot=F)
lag = pacf_Yt$lag[,1,]
val = pacf_Yt$acf[,1,]
u = rep(1.96/sqrt(n_Yt),h)
l = -u
pacf_df = data.frame(lag,val,u,l)  
plot_pacf(pacf_df)
####################################################################

####################################################################
# ARIMA (2,1,2)
set.seed(29127)
Xt = arima.sim(list(order = c(2,1,2), ar = c(0.5,-.3),
                    ma=c(.6,.4)),n = n-1)
plot_TS(Xt)

# ACF
acf_Xt = acf(Xt,lag.max=h,plot=F)
lag = acf_Xt$lag[,1,]
val = acf_Xt$acf[,1,]
u = rep(1.96/sqrt(n),h)
l = -u
acf_df = data.frame(lag,val,u,l)  
plot_acf(acf_df)

# PACF
pacf_Xt = pacf(Xt,lag.max = h,plot=F)
lag = pacf_Xt$lag[,1,]
val = pacf_Xt$acf[,1,]
u = rep(1.96/sqrt(n),h)
l = -u
pacf_df = data.frame(lag,val,u,l)  
plot_pacf(pacf_df)

# Differentiate the process 
Yt = diff(Xt,1)
n_Yt=n-1
plot_TS(Yt)

# ACF
acf_Yt = acf(Yt,lag.max=h,plot=F)
lag = acf_Yt$lag[,1,]
val = acf_Yt$acf[,1,]
u = rep(1.96/sqrt(n_Yt),h)
l = -u
acf_df = data.frame(lag,val,u,l)  
plot_acf(acf_df)

# PACF
pacf_Yt = pacf(Yt,lag.max = h,plot=F)
lag = pacf_Yt$lag[,1,]
val = pacf_Yt$acf[,1,]
u = rep(1.96/sqrt(n_Yt),h)
l = -u
pacf_df = data.frame(lag,val,u,l)  
plot_pacf(pacf_df)

# ARMA(2,1) and ARMA(2,2) models for Yt
mod1=Arima(Yt,order=c(2,0,2));mod1
mod2=Arima(Yt,order=c(2,0,1));mod2

# Residuals of Yt
df_res=data.frame(x=c(1:n_Yt),y=mod1$residuals)
ggplot(data=df_res,aes(x=x,y=y))+
  geom_line()+
  theme_minimal()+
  labs(x='',y='')

# ACF of residuals
acf_res = acf(df_res$y,lag.max=h,plot=F)
lag = acf_res$lag[,1,]
val = acf_res$acf[,1,]
u = rep(1.96/sqrt(n_Yt),h)
l = -u
acf_df = data.frame(lag,val,u,l)  
plot_acf(acf_df)

# PACF of residuals
pacf_res = pacf(df_res$y,lag.max = h,plot=F)
lag = pacf_res$lag[,1,]
val = pacf_res$acf[,1,]
u = rep(1.96/sqrt(n_Yt),h)
l = -u
pacf_df = data.frame(lag,val,u,l)  
plot_pacf(pacf_df)

# Ljung-Box test
Box.test(df_res$y,type='Ljung-Box')

# Prediction for Yt
df_Yt=data.frame(t=c(1:n_Yt),X=Yt)

k=10
preds=forecast(mod1,h=k)
df_preds=data.frame(t=c((n_Yt+1):(n_Yt+k)),x=preds$mean,
                    l=preds$lower[,2],u=preds$upper[,2])

plot_preds(df_Yt,df_preds)

# Model for Xt
mod = Arima(Xt,order=c(2,1,2));mod

# Residuals of Xt
df_res=data.frame(x=c(1:n),y=mod$residuals)
ggplot(data=df_res,aes(x=x,y=y))+
  geom_line()+
  theme_minimal()+
  labs(x='',y='')

# ACF of residuals
acf_res = acf(df_res$y,lag.max=h,plot=F)
lag = acf_res$lag[,1,]
val = acf_res$acf[,1,]
u = rep(1.96/sqrt(n),h)
l = -u
acf_df = data.frame(lag,val,u,l)  
plot_acf(acf_df)

# PACF
pacf_res = pacf(df_res$y,lag.max = h,plot=F)
lag = pacf_res$lag[,1,]
val = pacf_res$acf[,1,]
u = rep(1.96/sqrt(n),h)
l = -u
pacf_df = data.frame(lag,val,u,l)  
plot_pacf(pacf_df)

# Ljung-Box test
Box.test(df_res$y,type='Ljung-Box')

# Prediction for Xt
df_Xt=data.frame(t=c(1:n),X=Xt)

k=10
preds=forecast(mod,h=k)
df_preds=data.frame(t=c((n+1):(n+k)),x=preds$mean,
                    l=preds$lower[,2],u=preds$upper[,2])

plot_preds(df_Xt,df_preds)
####################################################################