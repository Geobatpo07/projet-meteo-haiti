# Vérification et chargement des packages nécessaires
packages <- c("DBI", "RSQLite", "here", "stringi")
install_if_missing <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) install.packages(pkg)
}
invisible(lapply(packages, install_if_missing))

library(DBI)
library(RSQLite)
library(here)
library(stringi)

# Chargement des dépendances internes
source(here("R", "config.R"))
source(here("R", "db_connect.R"))

# Fonction de création des tables
create_tables <- function(conn) {
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
      latitude REAL,
      longitude REAL,
      FOREIGN KEY (id_departement) REFERENCES departements(id)
    );
  ")

  dbExecute(conn, "
    CREATE TABLE IF NOT EXISTS meteo (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      id_ville INTEGER NOT NULL,
      date DATE NOT NULL,
      temp_min REAL,
      temp_max REAL,
      humidite REAL,
      precipitation REAL,
      vent REAL,
      FOREIGN KEY (id_ville) REFERENCES villes(id)
    );
  ")

  message("Tables créées avec succès (si non existantes).")
}

# Insertion des départements
insert_departements <- function(conn) {
  for (dep in departements) {
    # Assurer l'encodage UTF-8
    dep_utf8 <- stri_encode(dep, from = "latin1", to = "UTF-8")
    dbExecute(conn, "INSERT OR IGNORE INTO departements (nom) VALUES (?)", params = list(dep_utf8))
  }
  message("Départements insérés avec succès (si absents).")
}

# Insertion des villes
insert_villes <- function(conn, villes_df = NULL) {
  # Utiliser villes_initiales par défaut si aucun argument n'est passé
  if (is.null(villes_df)) {
    villes_df <- villes_initiales
    message("Utilisation des villes initiales pour l'insertion.")
  } else {
    message("Utilisation des données fournies pour l'insertion dans la table villes.")
  }

  # Vérifier que la colonne id_departement existe
  if (!"id_departement" %in% names(villes_df)) {
    stop("La colonne 'id_departement' est manquante dans le dataframe fourni.")
  }

  for (i in 1:abs(nrow(villes_df))) {
    dep_id <- villes_df$id_departement[i]
    if (is.na(dep_id) || length(dep_id) != 1) {
      warning(sprintf("ID département invalide pour '%s'. Insertion ignorée.", villes_df$nom[i]))
      next
    }

    dbExecute(conn, "
      INSERT OR IGNORE INTO villes (nom, id_departement, latitude, longitude)
      VALUES (?, ?, ?, ?)",
      params = list(
        villes_df$nom[i],
        dep_id,
        villes_df$latitude[i],
        villes_df$longitude[i]
      )
    )
  }

  message("Insertion dans la table villes terminée (si absentes).")
}

reset_tables <- function(conn) {
  dbExecute(conn, "DELETE FROM meteo;")
  dbExecute(conn, "DELETE FROM villes;")
  dbExecute(conn, "DELETE FROM departements;")
  message("Tables vidées avec succès.")
}
