# app.R
# ------
# Application Shiny pour visualiser les prévisions avec ARIMA ou Prophet

library(shiny)
library(DBI)
library(ggplot2)
library(dplyr)
library(here)

# Charger les fonctions nécessaires
source(here("R", "db_connect.R"))
source(here("R", "plots.R"))

# Interface utilisateur
ui <- fluidPage(
  titlePanel("Prévisions Météorologiques"),

  sidebarLayout(
    sidebarPanel(
      selectInput("model", "Choisir le modèle de prévision",
                  choices = c("ARIMA", "Prophet")),
      numericInput("n_ahead", "Nombre d'années à prédire", value = 5, min = 1),
      actionButton("forecast_btn", "Générer Prévisions")
    ),

    mainPanel(
      plotOutput("forecast_plot"),
      plotOutput("temp_moy_plot"),
      plotOutput("precipitation_plot")
    )
  )
)

# Serveur
server <- function(input, output) {

  observeEvent(input$forecast_btn, {
    # Connexion à la base de données
    conn <- connect_db()

    # Afficher les prévisions en fonction du modèle choisi
    output$forecast_plot <- renderPlot({
      if (input$model == "ARIMA") {
        plot_forecast_arima(conn, n.ahead = input$n_ahead)
      } else if (input$model == "Prophet") {
        plot_forecast_prophet(conn, n.ahead = input$n_ahead)
      }
    })

    # Afficher les autres graphiques
    output$temp_moy_plot <- renderPlot({
      plot_temp_moyenne(conn)
    })

    output$precipitation_plot <- renderPlot({
      plot_precipitations(conn)
    })

    dbDisconnect(conn)
  })
}

# Lancer l'application
shinyApp(ui = ui, server = server)
