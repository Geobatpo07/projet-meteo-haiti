# forecast_model.R
# ----------------------
# Modèles de prévision ARIMA et Prophet

if (!requireNamespace("forecast", quietly = TRUE)) install.packages("forecast")
if (!requireNamespace("prophet", quietly = TRUE)) install.packages("prophet")
if (!requireNamespace("dplyr", quietly = TRUE)) install.packages("dplyr")
if (!requireNamespace("lubridate", quietly = TRUE)) install.packages("lubridate")

library(forecast)
library(prophet)
library(dplyr)
library(lubridate)

# Fonction : Prévisions ARIMA
forecast_arima <- function(df, n.ahead = 12) {
  # Vérification et tri des données
  df <- df %>%
    mutate(date = as.Date(date)) %>%
    mutate(month = format(date, "%Y-%m")) %>%
    group_by(month) %>%
    summarise(temp_moy = mean(temp_moy, na.rm = TRUE)) %>%
    arrange(month)
  
  # Conversion en série temporelle mensuelle
  df$month <- as.Date(paste0(df$month, "-01"))
  start_year <- year(min(df$month))
  start_month <- month(min(df$month))
  ts_data <- ts(df$temp_moy, frequency = 12, start = c(start_year, start_month))
  
  # Ajustement du modèle ARIMA
  fit <- auto.arima(ts_data)
  forecast_fit <- forecast(fit, h = n.ahead)
  
  return(forecast_fit)
}

# Fonction : Prévisions Prophet
forecast_prophet <- function(df, n.ahead = 12) {
  # Préparation des données pour Prophet
  df_prophet <- df %>%
    mutate(ds = as.Date(date)) %>%
    group_by(ds = floor_date(ds, "month")) %>%
    summarise(y = mean(temp_moy, na.rm = TRUE)) %>%
    arrange(ds)
  
  # Création et ajustement du modèle Prophet
  model <- prophet(df_prophet)
  future <- make_future_dataframe(model, periods = n.ahead, freq = "month")
  forecast_fit <- predict(model, future)
  
  return(forecast_fit)
}
