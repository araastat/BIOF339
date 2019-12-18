# img(src = "gdT.png", height = 72, width = 72)



library(shiny)

# Define UI ----
ui <- fluidPage(
  titlePanel("RNAseq analysis"),
  sidebarLayout(
    sidebarPanel("Heatmap of sorted T cells"),
    mainPanel(
      h2("gdT"),
      img(src = "./gdT.png", height = 500, width = 600),
      h2("Gingiva Th17"),
      img(src = "RNAseq G Th17.png", height = 500, width = 600),
      h2("Lymph nodes Th17"),
      img(src = "RNAseq L Th17.png", height = 500, width = 600),
      h2("other T cells"),
      img(src = "RNAseq_IL17neg.png", height = 500, width = 600),
      h2("all T cells"),
      img(src = "RNAseq_all_samples.png", height = 500, width = 600)
    )
  )
)

# Define server logic ----
server <- function(input, output) {
  
}

# Run the app ----
shinyApp(ui = ui, server = server)
