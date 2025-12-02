# Reporte

## Limpieza de datos.

Los datos no presentan outliers ni requieren de limpieza, se usaron los datos crudos.

## Visualización de la serie de tiempo

[TODO: insertar grafica]

Notamos que hay tendencia creciente y estacionalidad.
Suponemos que es una empresa cuya producción va aumentando, y los ciclos serán anuales como casi en todas las industrias. Claramente no es estacionaria. Al hacer la transformación

$y_t = (1-B)(1-B^12)x_t, $

obtenemos una serie que ahora sí parece estacionaria.

## Exploración de modelos.

De acuerdo a la transformación anterior, el espacio de modelos será el $SARIMA(p, d=1, q)x(1, 1, 1)_{12}$
También exploraremos el modelo Holt-Winters como una alternativa plausible.

### Ajuste de modelos.

Ajustamos varios modelos SARIMA, variando las $p,q$ en un rango razonable, y para todos los casos obtenemos residuales que no están autocorrelacionados, Ljung-Box no rechaza H0 y sus predicciones se ven razonables. A-priori no tenemos razón para preferir uno sobre otro.

[TODO: insertar grafica]

### Selección del modelo.

Para decidir qué modelo es el que usaremos, utilizamos el criterio de minimización de la raíz del error cuadrático medio (RMSE) sobre un conjunto de prueba del 20% final de la serie de tiempo, entrenando cada modelo en el primer 80%.

[TODO: insertar valores]
p=1, q=1, RMSE=, AIC
p=2, q=1
p=1, q=2
p=2, q=2

Este criterio es un poco más pragmático que el AICc porque puede usarse para comparar contra otros modelos de otra naturaleza y da una indicación de lo bueno que sería para predecir el futuro.

EL modelo de Holt-Winter da menor RMSE,

[TODO: insertar graficas]

Nos quedamos con el modelo XXXX ya que minimiza el RMSE.

### Validación del modelo.

Una vez elegido el modelo XXXX
hay que re-entrenarlo en el 100% de los datos para poder hacer la predicción.

[TODO: insertar graficas]

Los residuales se ven bien, todos dentro de las bandas de confianza.
La prueba Ljung-Box no rechaza H0; los residuales no están autcorrelacionados.
Por lo tanto el modelo es válido.

### Predicción a 1 año.

[TODO: insertar graficas de predicción]

A la empresa le diríamos que su producción a los 12 meses va a ser de X galones de leche.

### Riesgo de la predicción.

Como consultora es importante dar una medida del riesgo de la predicción a los clientes, ya que solamente el valor esperado no es suficiente.

Para nuestro caso, las bandas de confianza son pequeña, para 12 meses tenemos un intervalo de +- Y galones alrededor de la media. Hay un 95% de probabilidad de que no se cumpla la predicción que se está dando, 2.5% que esté arriba y 2.5% que esté abajo (caso desfavorable.)

### Conclusiones

El dataset es relativamente simple, no hay outliers ni volatilidad, por lo cual resultó sencillo encontrar un modelo que ajustara bien, se pudiera justificar y cuya predicción fuera razonable.

La empresa tiene una tendencia al crecimiento, y fue posible estimar las ventas de manera adecuada, así como dar una medida de riesgo al cliente.
