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
library(here)

# Cargando los datos con los que vamos a trabajar 


# Aqui ira el modelo seleccionado para hacer el forecast
data <- read.csv(here("Data", "Milk_and_Pigs_Slaughtered.csv"), header = TRUE)
head(data)

