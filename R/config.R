# config.R
# ------------------------
# Ce fichier contient toutes les variables de configuration globales utilisées dans le projet.

# Chargement du package here (s'assurer qu'il est installé avant de sourcer ce fichier)
if (!requireNamespace("here", quietly = TRUE)) install.packages("here")
library(here)

# Chemin vers la base de données SQLite
db_path <- here("data", "meteo_haiti.sqlite")

# Période d’étude météorologique
start_year <- 2010
end_year <- 2020

# Liste des départements haïtiens (forcés en UTF-8)
departements <- c(
  "Artibonite", "Centre", "Grand'Anse", "Nippes", "Nord",
  "Nord-Est", "Nord-Ouest", "Ouest", "Sud", "Sud-Est"
)
departements <- iconv(departements, from = "", to = "UTF-8")

# Données initiales des villes
villes_initiales <- data.frame(
  id = 1:12,
  nom = c(
    "Gonaïves", "Saint-Marc", "Hinche", "Mirebalais", "Jérémie", "Miragoâne",
    "Cap-Haïtien", "Fort-Liberté", "Port-de-Paix", "Port-au-Prince", "Les Cayes", "Jacmel"
  ),
  id_departement = c(1,1,2,2,3,4,5,6,7,8,9,10),
  departement = c(
    "Artibonite", "Artibonite", "Centre", "Centre", "Grand'Anse", "Nippes",
    "Nord", "Nord-Est", "Nord-Ouest", "Ouest", "Sud", "Sud-Est"
  ),
  latitude = c(
    19.4456, 19.1080, 19.1451, 18.8347, 18.6402, 18.4456,
    19.7594, 19.6667, 19.9333, 18.5944, 18.1933, 18.2341
  ),
  longitude = c(
    -72.6887, -72.6938, -72.0054, -72.1076, -74.1186, -73.0877,
    -72.1982, -71.8333, -72.8333, -72.3074, -73.7460, -72.5340
  ),
  stringsAsFactors = FALSE
)

# Forcer l'encodage des colonnes textuelles en UTF-8
villes_initiales$nom <- iconv(villes_initiales$nom, from = "", to = "UTF-8")
villes_initiales$departement <- iconv(villes_initiales$departement, from = "", to = "UTF-8")
