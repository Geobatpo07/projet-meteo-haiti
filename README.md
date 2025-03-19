# Projet Météo Haïti

## Description
Ce projet vise à collecter, stocker et analyser les données météorologiques des villes d'Haïti en utilisant des API publiques. Les données sont stockées dans une base SQLite et peuvent être exploitées pour des analyses et des visualisations futures.

## Fonctionnalités
- Récupération automatique des villes et départements d'Haïti via une API géographique.
- Extraction des données météorologiques grâce à l'API **Open-Meteo**.
- Stockage des données dans une base **SQLite**.
- Scripts en **R** pour l'insertion et la récupération des données.
- Gestion des clés API via un fichier `.Renviron` pour plus de sécurité.

## Structure du projet
```
projet-meteo-haiti/
|-- .gitignore
|-- app/
|   |-- server.R
|   |-- ui.R
|
|-- data/
|   |-- create_db.R   # Création de la base de données
|   |-- meteo_haiti.sqlite  # Base de données SQLite
|
|-- R/
|   |-- db_connect.R     # Connexion à la base de données
|   |-- fetch_data.R        # Extraction des villes et des données météo
|   |-- insert_data.R       # Insertion des données dans la base
|   |-- plots.R           # Visualisation des données
|
|-- www/
|   |-- style.css
|
|-- app.R                # Application Shiny
|-- projet-meteo-haiti.Rproj # Projet RStudio
|-- LICENSE 
|-- README.md               # Documentation du projet
```

## Installation et Configuration
### Prérequis
- **R** installé sur votre machine
- Les packages suivants : `DBI`, `RSQLite`, `httr`, `jsonlite`, `here`
- Une clé API pour l'API géographique (ex. GeoNames) et Open-Meteo

### Installation des packages nécessaires
```r
packages <- c("DBI", "RSQLite", "httr", "jsonlite", "here")
install_if_missing <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) install.packages(pkg)
}
lapply(packages, install_if_missing)
```

### Configuration des clés API
Ajoutez vos clés API dans un fichier `.Renviron` :
```ini
GEONAMES_API_KEY=VOTRE_CLE_API
```

## Utilisation
1. **Exécuter `fetch_data.R`** pour récupérer les villes et leurs coordonnées géographiques.
2. **Exécuter `insert_data.R`** pour insérer les données météorologiques dans la base SQLite.
3. **Interroger la base de données** pour récupérer les informations souhaitées.

## Exemple de récupération des données météo pour une ville
```r
source("scripts/fetch_data.R")
meteo_data <- fetch_meteo_data("Port-au-Prince", 18.5944, -72.3074)
print(meteo_data)
```

## Améliorations futures
- Ajouter une interface pour visualiser les données.
- Automatiser l'extraction et l'insertion avec un cron job.
- Explorer d'autres sources de données météorologiques.

## Auteurs
- **Geovany Batista Polo LAGUERRE** - Data Science & Analytics Engineer

## Licence
Ce projet est sous licence MIT.

