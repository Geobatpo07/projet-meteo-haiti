# Charger les clés d'API à partir des variables d'environnement
api_key <- Sys.getenv("OPENCAGE_API_KEY")

# Vérifier et installer les packages nécessaires
packages <- c("DBI", "RSQLite", "httr", "jsonlite", "here")
install_if_missing <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) install.packages(pkg)
}
lapply(packages, install_if_missing)

# Charger les packages
library(httr)
library(jsonlite)
library(RSQLite)
library(here)

# Définir le chemin de la base de données avec 'here'
db_path <- here("data", "meteo_haiti.sqlite")

# Fonction pour récupérer la ville et son département
fetch_ville_and_departement <- function(ville) {
  conn <- dbConnect(RSQLite::SQLite(), db_path)

  # Récupérer le département de la ville
  query <- sprintf("SELECT d.nom AS departement
                    FROM villes v
                    JOIN departements d ON v.id_departement = d.id
                    WHERE v.nom = '%s'", ville)

  departement <- dbGetQuery(conn, query)
  dbDisconnect(conn)

  if (nrow(departement) > 0) {
    return(departement$departement)
  } else {
    return(NA)
  }
}

# Fonction pour récupérer les coordonnées géographiques via OpenCage Geocoder
get_coordinates <- function(place_name, api_key) {
  base_url <- "https://api.opencagedata.com/geocode/v1/json"
  url <- paste0(base_url, "?q=", URLencode(place_name), "&key=", api_key)
  response <- GET(url)
  data <- fromJSON(content(response, "text"))

  if (length(data$results) > 0) {
    lat <- data$results[[1]]$geometry$lat
    lon <- data$results[[1]]$geometry$lng
    return(c(lat, lon))
  } else {
    return(c(NA, NA))
  }
}

# Fonction pour récupérer les données météo depuis l'API Open Meteo
fetch_meteo_data <- function(ville, lat, lon) {
  url <- paste0("https://api.open-meteo.com/v1/forecast?latitude=", lat,
                "&longitude=", lon,
                "&daily=temperature_2m_max,temperature_2m_min,precipitation_sum,humidity_2m_mean,windspeed_10m_max&timezone=America%2FPort-au-Prince")

  # Requête API
  response <- fromJSON(content(GET(url), "text"))

  # Vérifier si la réponse contient les données attendues
  if (!"daily" %in% names(response)) {
    stop("Les données météo n'ont pas pu être récupérées.")
  }

  # Créer un dataframe avec les données récupérées
  data <- data.frame(
    ville = ville,
    departement = fetch_ville_and_departement(ville),
    date = as.Date(response$daily$time),
    temp_max = response$daily$temperature_2m_max,
    temp_min = response$daily$temperature_2m_min,
    humidite = response$daily$humidity_2m_mean,
    vent = response$daily$windspeed_10m_max,
    precipitations = response$daily$precipitation_sum
  )

  return(data)
}

# Fonction pour obtenir les coordonnées géographiques de chaque ville
fetch_villes_coordinates <- function(villes, api_key) {
  coords <- lapply(villes, function(ville) {
    get_coordinates(ville, api_key)
  })
  coords_df <- data.frame(ville = villes, t(do.call(rbind, coords)))
  colnames(coords_df) <- c("ville", "latitude", "longitude")
  return(coords_df)
}

# Exemple d'appel à la fonction fetch_meteo_data
# Assurez-vous de définir la ville, la latitude et la longitude
ville <- "Port-au-Prince"
lat <- 18.5944  # Latitude de Port-au-Prince
lon <- -72.3074 # Longitude de Port-au-Prince

meteo_data <- fetch_meteo_data(ville, lat, lon)
print(meteo_data)
