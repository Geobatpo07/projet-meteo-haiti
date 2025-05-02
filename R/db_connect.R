# Vérification et installation des packages nécessaires
required_packages <- c("DBI", "RSQLite")

install_if_missing <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) install.packages(pkg)
}
invisible(lapply(required_packages, install_if_missing))

# Chargement des bibliothèques
source(here::here("R", "config.R"))
library(DBI)
library(RSQLite)

connect_db <- function() {
  dbConnect(RSQLite::SQLite(), db_path)
}
