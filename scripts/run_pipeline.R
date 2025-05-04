# Installer et charger les packages nécessaires
required_packages <- c("DBI", "RSQLite", "httr", "jsonlite", "here", "progress")

install_if_missing <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) install.packages(pkg)
}
invisible(lapply(required_packages, install_if_missing))

# Charger les packages
library(DBI)
library(RSQLite)
library(httr)
library(jsonlite)
library(here)
library(progress)

# Charger les fonctions définies précédemment
source(here("R", "db_utils.R"))
source(here("R", "fetch_data.R"))

# Connexion à la base de données
conn <- connect_db()

# Création des tables (si elles n'existent pas)
create_tables(conn)

# Insertion des départements (si non déjà insérés)
insert_departements(conn)

# Insertion des villes (si non déjà insérées)
insert_villes(conn)

# Liste des villes
villes <- dbGetQuery(conn, "SELECT id, nom, latitude, longitude FROM villes")

# Période de collecte des données
start_year <- 2019
end_year <- 2020

# Initialisation de la barre de progression
total_steps <- nrow(villes) * (end_year - start_year + 1)
pb <- progress_bar$new(
  total = total_steps,
  format = "  [:bar] :percent | :current/:total | ETA: :eta",
  clear = FALSE,
  width = 50
)

# Fonction pour récupérer et insérer les données climatiques
insert_meteo_data_with_progress <- function(conn, villes, start_year, end_year, pb) {
  for (i in 1:abs(nrow(villes))) {
    ville <- villes[i, ]
    for (year in start_year:end_year) {
      cat("Traitement :", ville$nom, "-", year, "\n")
      df <- get_meteo_data(ville$id, ville$latitude, ville$longitude, year)

      # Si les données sont valides, on les insère dans la base de données
      if (!is.null(df)) {
        dbWriteTable(conn, "meteo", df, append = TRUE)
      }

      # Mise à jour de la barre de progression
      pb$tick()
      Sys.sleep(1)  # Pause pour éviter le rate limiting
    }
  }
  cat("\n Données climatiques insérées avec succès dans la table `meteo`\n")
}

# Lancement du pipeline avec barre de progression
insert_meteo_data_with_progress(conn, villes, start_year, end_year, pb)

# Fermeture de la connexion à la base de données
dbDisconnect(conn)

message("Pipeline terminé avec succès.")
