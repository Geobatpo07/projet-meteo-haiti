# Vérifier et installer les packages nécessaires
packages <- c("DBI", "RSQLite", "here")
install_if_missing <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) install.packages(pkg)
}
lapply(packages, install_if_missing)

# Charger les packages
library(DBI)
library(RSQLite)
library(here)

# Définir le chemin de la base de données avec here
db_path <- here("data", "meteo_haiti.sqlite")

# Fonction pour établir la connexion à la base de données
connect_db <- function() {
  conn <- dbConnect(RSQLite::SQLite(), db_path)
  return(conn)
}

# Vérifier si la connexion est bien établie
conn <- connect_db()
if (!is.null(conn)) {
  print("Connexion à la base de données réussie ! ✅")
} else {
  stop("Échec de la connexion à la base de données ❌")
}

# Création des tables si elles n'existent pas
dbExecute(conn, "
CREATE TABLE IF NOT EXISTS departements (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nom TEXT NOT NULL UNIQUE
);
")

dbExecute(conn, "
CREATE TABLE IF NOT EXISTS villes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nom TEXT NOT NULL,
    id_departement INTEGER,
    FOREIGN KEY (id_departement) REFERENCES departements(id)
);
")

dbExecute(conn, "
CREATE TABLE IF NOT EXISTS meteo (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    ville TEXT NOT NULL,
    date DATE NOT NULL,
    temp_min REAL,
    temp_max REAL,
    humidite REAL,
    precipitation REAL,
    vent REAL,
    FOREIGN KEY (ville) REFERENCES villes(nom)
);
")

# Insertion des départements si non existants
departements <- c("Artibonite", "Centre", "Grand'Anse", "Nippes", "Nord", 
                  "Nord-Est", "Nord-Ouest", "Ouest", "Sud", "Sud-Est")

for (dep in departements) {
  dbExecute(conn, sprintf("INSERT OR IGNORE INTO departements (nom) VALUES ('%s')", dep))
}

# Fonction pour stocker les données météo dans la table 'meteo'
insert_meteo_data <- function(data) {
  conn <- connect_db()
  
  # Boucle sur les lignes du dataframe pour insérer les données
  for (i in 1:nrow(data)) {
    query <- sprintf(
      "INSERT OR IGNORE INTO meteo (ville, date, temp_min, temp_max, humidite, precipitation, vent)
       VALUES ('%s', '%s', %f, %f, %f, %f, %f)", 
      data$ville[i], data$date[i], data$temp_min[i], data$temp_max[i], 
      data$humidite[i], data$precipitations[i], data$vent[i]
    )
    
    dbExecute(conn, query)
  }
  
  dbDisconnect(conn)
  print("Données météo insérées avec succès ! ✅")
}

# Exemple d'appel de la fonction 'insert_meteo_data'
# Assume que 'meteo_data' est le dataframe généré dans fetch_data.R
# insert_meteo_data(meteo_data)

# Fonction pour récupérer les données météo pour une ville
fetch_data_from_db <- function(ville) {
  conn <- connect_db()
  query <- sprintf("SELECT * FROM meteo WHERE ville = '%s'", ville)
  data <- dbGetQuery(conn, query)
  dbDisconnect(conn)
  return(data)
}

# Fermer la connexion proprement
dbDisconnect(conn)
print("Connexion à la base de données fermée. 🔌")