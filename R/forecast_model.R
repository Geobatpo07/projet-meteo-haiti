# forecast_model.R
# ----------------------
# Modèles de prévision ARIMA et Prophet

# Fonction : Prévisions ARIMA
forecast_arima <- function(df, n.ahead = 12) {
  library(forecast)

  # Conversion des données en série temporelle
  ts_data <- ts(df$temp_moy, frequency = 12)

  # Application du modèle ARIMA
  fit <- auto.arima(ts_data)

  # Prédictions futures
  forecast_fit <- forecast(fit, h = n.ahead)

  return(forecast_fit)
}

# Fonction : Prévisions Prophet
forecast_prophet <- function(df, n.ahead = 12) {
  library(prophet)

  # Préparer les données pour Prophet
  df_prophet <- df %>%
    rename(ds = annee, y = temp_moy)

  # Création et ajustement du modèle Prophet
  model <- prophet(df_prophet)

  # Créer les données futures et prédire
  future <- make_future_dataframe(model, periods = n.ahead, freq = "year")
  forecast_fit <- predict(model, future)

  return(forecast_fit)
}
