library(shiny)

ui <- fluidPage(
  titlePanel("Dashboard Météo - Haïti"),
  
  sidebarLayout(
    sidebarPanel(
      selectInput("ville", "Choisir une ville :", 
                  choices = c("Port-au-Prince", "Cap-Haïtien", "Gonaïves", "Les Cayes", "Jacmel")),
      actionButton("update", "Mettre à jour les données")
    ),
    
    mainPanel(
      plotOutput("weatherPlot")
    )
  )
)
