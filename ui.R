library(shinymeta)
# Define UI for the app
shinyUI(
  
  fluidPage(
  # App title
  titlePanel("Calculate Grade"),
  # Sidebar with file input
  sidebarLayout(
    sidebarPanel(
      fileInput("file", "Upload CSV file"), #upload file
      #choose which grading policy
      radioButtons("grading_policy", strong("Aggregation Method"),
                   choices = c("Equally Weighted", "Weighted by Points")),
    ),
    # Main panel with table output
    mainPanel(
      tabsetPanel(
        #shows original csv
        tabPanel(h5("Original Data"),
                 DT::dataTableOutput("original")),
        #shows table with assignment scores calculated
        tabPanel(h5("Calculated Scores"),
                 DT::dataTableOutput("table")),
        #shows table with students' overall grade + download button for this table
        tabPanel(h5("Grades"),
                 DT::dataTableOutput("grades"),
                 downloadButton("download", "Download Results"),),
        #shows meta code + download button for this code
        tabPanel(h5("Code"),
                 verbatimTextOutput("code"),
                 downloadButton("downloadr", "download R code"))
      )
    )
  )
)
)