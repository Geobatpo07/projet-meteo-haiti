# Charger le fichier db_utils.R
source("R/db_utils.R")

# Connexion à la base de données
conn <- connect_db()

# Création des tables (si elles n'existent pas)
create_tables(conn)

# Insertion des départements (si non déjà insérés)
insert_departements(conn)

# Insertion des villes (si non déjà insérées)
insert_villes(conn)

# Fermeture de la connexion
dbDisconnect(conn)

message("Initialisation de la base de données terminée.")
