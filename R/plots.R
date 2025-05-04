# plots.R
# ------------------------
# Génération de graphiques météorologiques à partir de la base de données

# Installation conditionnelle des packages
if (!requireNamespace("ggplot2", quietly = TRUE)) install.packages("ggplot2")
if (!requireNamespace("dplyr", quietly = TRUE)) install.packages("dplyr")
if (!requireNamespace("forecast", quietly = TRUE)) install.packages("forecast")
if (!requireNamespace("prophet", quietly = TRUE)) install.packages("prophet")
if (!requireNamespace("lubridate", quietly = TRUE)) install.packages("lubridate")
if (!requireNamespace("DBI", quietly = TRUE)) install.packages("DBI")

library(DBI)
library(ggplot2)
library(dplyr)
library(forecast)
library(prophet)
library(lubridate)

# Charger les fonctions de prévision
source(here::here("R", "forecast_model.R"))

# Fonction : Température moyenne annuelle par ville
plot_temp_moyenne <- function(conn) {
  query <- "
    SELECT v.nom AS ville, strftime('%Y', m.date) AS annee,
           AVG((m.temp_min + m.temp_max)/2) AS temp_moy
    FROM meteo m
    JOIN villes v ON m.id_ville = v.id
    GROUP BY ville, annee
    ORDER BY annee
  "
  
  df <- dbGetQuery(conn, query)
  
  ggplot(df, aes(x = as.numeric(annee), y = temp_moy, color = ville)) +
    geom_line(size = 1) +
    labs(
      title = "Température moyenne annuelle par ville",
      x = "Année",
      y = "Température moyenne (°C)"
    ) +
    theme_minimal()
}

# Fonction : Précipitations totales par année
plot_precipitations <- function(conn) {
  query <- "
    SELECT strftime('%Y', date) AS annee, SUM(precipitation) AS total_precip
    FROM meteo
    GROUP BY annee
    ORDER BY annee
  "
  
  df <- dbGetQuery(conn, query)
  
  ggplot(df, aes(x = as.numeric(annee), y = total_precip)) +
    geom_col(fill = "steelblue") +
    labs(
      title = "Précipitations totales par année",
      x = "Année",
      y = "Précipitations (mm)"
    ) +
    theme_minimal()
}

# Fonction : Prévisions ARIMA
plot_forecast_arima <- function(conn, n.ahead = 12) {
  query <- "
    SELECT date,
           AVG((temp_min + temp_max)/2) AS temp_moy
    FROM meteo
    GROUP BY date
    ORDER BY date
  "
  
  df <- dbGetQuery(conn, query)
  
  forecast_fit <- forecast_arima(df, n.ahead)
  
  autoplot(forecast_fit) +
    labs(
      title = "Prévisions des températures moyennes (ARIMA)",
      x = "Temps",
      y = "Température moyenne (°C)"
    ) +
    theme_minimal()
}

# Fonction : Prévisions Prophet
plot_forecast_prophet <- function(conn, n.ahead = 12) {
  query <- "
    SELECT date,
           AVG((temp_min + temp_max)/2) AS temp_moy
    FROM meteo
    GROUP BY date
    ORDER BY date
  "
  
  df <- dbGetQuery(conn, query)
  
  forecast_fit <- forecast_prophet(df, n.ahead)
  
  ggplot(forecast_fit, aes(x = ds, y = yhat)) +
    geom_line(color = "blue") +
    geom_ribbon(aes(ymin = yhat_lower, ymax = yhat_upper), alpha = 0.2, fill = "lightblue") +
    labs(
      title = "Prévisions des températures moyennes (Prophet)",
      x = "Date",
      y = "Température moyenne (°C)"
    ) +
    theme_minimal()
}
