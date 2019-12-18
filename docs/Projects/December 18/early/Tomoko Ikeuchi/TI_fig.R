img(src = "gdT.png", height = 72, width = 72)



library(shiny)

# Define UI ----
ui <- fluidPage(
  titlePanel("RNAseq analysis"),
  sidebarLayout(
    sidebarPanel("Tcell"),
    mainPanel(
      img(src = "gdT.png", height = 400, width = 450),
      img(src = "RNAseq G Th17.png", height = 400, width = 450),
      img(src = "RNAseq L Th17.png", height = 400, width = 450),
      img(src = "RNAseq_IL17neg.png", height = 400, width = 450),
      img(src = "RNAseq_all_samples.png", height = 500, width = 600)
    )
  )
)

# Define server logic ----
server <- function(input, output) {
  
}

# Run the app ----
shinyApp(ui = ui, server = server)