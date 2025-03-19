library(shiny)

server <- function(input, output) {
  observeEvent(input$update, {
    conn <- connect_db()
    query <- paste0("SELECT * FROM meteo WHERE ville = '", input$ville, "'")
    weather_data <- dbGetQuery(conn, query)
    dbDisconnect(conn)
    
    output$weatherPlot <- renderPlot({
      plot_meteo(weather_data)
    })
  })
}
