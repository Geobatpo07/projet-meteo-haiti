library(shiny)

# Charger les scripts
source("R/fetch_data.R")
source("R/db_connect.R")
source("R/plots.R")

# Lancer l'application
shinyApp(ui = source("app/ui.R")$value, server = source("app/server.R")$value)
