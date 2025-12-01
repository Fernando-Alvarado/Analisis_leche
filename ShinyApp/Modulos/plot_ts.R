####################################################################
# Plot functions
# Author: Jose Antonio Perusquia Cortes
# Afil: Facultad de Ciencias - UNAM
# Module: Time series 
####################################################################

####################################################################
# Plots time series or arma objects for which we can extract
# the time
plot_TS = function(mod){
  t=time(mod)
  vals=as.data.frame(mod)               
  vals$t=t
  
  p=ggplot(data=vals,aes(x=t,y=x))+
    geom_line()+
    theme_minimal()+
    labs(x='',y='')
  return(p)
}

# Plots the ACF for a data frame that needs to contain
# h, gamma(h), and the upper and lower value of confidence
# intervals
plot_acf = function(df_acf){
  p = ggplot() +
    geom_point(data = df_acf, aes(x = lag, y = val), size = 1) +
    geom_segment(data = df_acf, aes(x = lag, xend = lag, y = 0, yend = val)) +
    geom_line(data = df_acf, aes(x = lag, y = u), linetype = 2, col = 'blue') +
    geom_line(data = df_acf, aes(x = lag, y = l), linetype = 2, col = 'blue') +
    geom_hline(yintercept = 0) +
    theme_minimal() +
    labs(x = expression(h), y = expression(ACF))
  
  return(p)
}


# Plots the PACF for a data frame that needs to contain
# h, alpha(h), and the upper and lower value of confidence
# intervals
plot_pacf = function(df_pacf){
  p = ggplot() +
    geom_point(data = df_pacf, aes(x = lag, y = val), size = 1) +
    geom_segment(data = df_pacf, aes(x = lag, xend = lag, y = 0, yend = val)) +
    geom_line(data = df_pacf, aes(x = lag, y = u), linetype = 2, col = 'blue') +
    geom_line(data = df_pacf, aes(x = lag, y = l), linetype = 2, col = 'blue') +
    geom_hline(yintercept = 0) +
    theme_minimal() +
    labs(x = expression(h), y = expression(PACF))
  
  return(p)
}

# Plots the periodogram for a data frame that needs to contain
# the spectral and the frequencies
plot_periodogram = function(df_period){
  p=ggplot(data=df_period)+
    geom_point(aes(x=freq,y=spec),size=1)+
    theme_minimal()+
    labs(x=expression(Frequency),y=expression(Periodogram))
  return(p)
}
####################################################################