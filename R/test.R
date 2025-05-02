install.packages("httr")
install.packages("jsonlite")

library(httr)
library(jsonlite)

# API Open-Meteo pour Port-au-Prince
url <- "https://api.open-meteo.com/v1/forecast?latitude=18.5411&longitude=-72.3361&daily=temperature_2m_max,temperature_2m_min,precipitation_sum&timezone=America%2FPort-au-Prince"

# Requête API et extraction des données
response <- fromJSON(content(GET(url), "text"))
weather_data <- data.frame(
  Date = as.Date(response$daily$time),
  Temp_Max = response$daily$temperature_2m_max,
  Temp_Min = response$daily$temperature_2m_min,
  Precipitations = response$daily$precipitation_sum
)

print(weather_data)
