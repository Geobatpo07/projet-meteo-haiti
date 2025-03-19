# Connexion à la base de données SQLite (création si elle n'existe pas)
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

db_path <- here("data", "meteo_haiti.sqlite")
conn <- dbConnect(RSQLite::SQLite(), db_path)

# Création des tables
dbExecute(conn, "CREATE TABLE IF NOT EXISTS departements (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nom TEXT NOT NULL UNIQUE
);")

dbExecute(conn, "CREATE TABLE IF NOT EXISTS villes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nom TEXT NOT NULL,
    id_departement INTEGER,
    FOREIGN KEY (id_departement) REFERENCES departements(id)
);")

dbExecute(conn, "CREATE TABLE IF NOT EXISTS meteo (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    ville TEXT NOT NULL,
    date DATE NOT NULL,
    temp_min REAL,
    temp_max REAL,
    humidite REAL,
    precipitation REAL,
    vent REAL,
    FOREIGN KEY (ville) REFERENCES villes(nom)
);")

# Insérer des données dans la table departements
departements <- data.frame(nom = c("Artibonite", "Centre", "Grand'Anse", "Nippes", "Nord",
                                   "Nord-Est", "Nord-Ouest", "Ouest", "Sud", "Sud-Est"))

dbWriteTable(conn, "departements", departements, append = TRUE, row.names = FALSE)

# Insérer des données dans la table villes
villes <- data.frame(
  nom = c("Gonaïves", "Saint-Marc", "Hinche", "Mirebalais", "Jérémie",
          "Miragoâne", "Cap-Haïtien", "Fort-Liberté", "Port-de-Paix",
          "Port-au-Prince", "Les Cayes", "Jacmel"),
  id_departement = c(1, 1, 2, 2, 3, 4, 5, 6, 7, 8, 9, 10)
)

dbWriteTable(conn, "villes", villes, append = TRUE, row.names = FALSE)

# Vérification des données insérées
print(dbGetQuery(conn, "SELECT * FROM departements;"))
print(dbGetQuery(conn, "SELECT * FROM villes;"))

# Fermeture de la connexion
dbDisconnect(conn)

print("Base de données créée avec succès ! ✅")
