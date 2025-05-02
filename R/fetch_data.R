# Vérifier et installer les packages nécessaires
packages <- c("DBI", "RSQLite", "httr", "jsonlite", "here")
install_if_missing <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) install.packages(pkg)
}
lapply(packages, install_if_missing)

# Charger les packages
library(httr)
library(jsonlite)
library(DBI)
library(RSQLite)
library(here)

# Connexion à la base SQLite
db_path <- here("data", "meteo_haiti.sqlite")
conn <- dbConnect(RSQLite::SQLite(), db_path)

# Lire les villes existantes
villes <- dbGetQuery(conn, "SELECT id, nom AS ville, latitude, longitude FROM villes")

# Période de collecte
start_year <- 2010
end_year <- 2020

# Fonction pour récupérer les données climatiques (avec vent)
get_meteo_data <- function(id_ville, lat, lon, year) {
  url <- paste0(
    "https://archive-api.open-meteo.com/v1/archive?",
    "latitude=", lat,
    "&longitude=", lon,
    "&start_date=", year, "-01-01",
    "&end_date=", year, "-12-31",
    "&daily=temperature_2m_max,temperature_2m_min,precipitation_sum,relative_humidity_2m_mean,windspeed_10m_max",
    "&timezone=auto"
  )

  response <- try(GET(url), silent = TRUE)
  if (inherits(response, "try-error") || response$status_code != 200) {
    warning(paste("Erreur pour la ville ID", id_ville, "année", year))
    return(NULL)
  }

  data <- content(response, as = "parsed", simplifyVector = TRUE)
  if (is.null(data$daily)) return(NULL)

  df <- data.frame(
    id_ville = id_ville,
    date = data$daily$time,
    temp_min = data$daily$temperature_2m_min,
    temp_max = data$daily$temperature_2m_max,
    humidite = data$daily$relative_humidity_2m_mean,
    precipitation = data$daily$precipitation_sum,
    vent = data$daily$windspeed_10m_max,
    stringsAsFactors = FALSE
  )

  return(df)
}

# Fonction d'insertion principale
insert_meteo_data <- function(conn, villes, start_year, end_year) {
  for (i in 1:nrow(villes)) {
    ville <- villes[i, ]
    for (year in start_year:end_year) {
      cat("Traitement :", ville$ville, "-", year, "\n")
      df <- get_meteo_data(ville$id, ville$latitude, ville$longitude, year)
      if (!is.null(df)) {
        dbWriteTable(conn, "meteo", df, append = TRUE, row.names = FALSE)
      }
      Sys.sleep(1)  # Pause pour éviter le rate limiting
    }
  }
  cat("\n Données climatiques insérées avec succès dans la table `meteo`\n")
}

# Appel direct si exécution standalone
if (sys.nframe() == 0) {
  insert_meteo_data(conn, villes, start_year, end_year)
  dbDisconnect(conn)
}
