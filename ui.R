library(shinymeta)
# Define UI for the app
shinyUI(
  
  fluidPage(
  # App title
  titlePanel("Calculate Grade"),
  
  sidebarLayout(
    sidebarPanel(
      fileInput("file", "Upload CSV file"), #upload file
      #choose which grading policy
      radioButtons("grading_policy", strong("Aggregation Method"),
                   choices = c("Equally Weighted", "Weighted by Points")),
    ),
    # Main panel with table output
    mainPanel(
      
      #shows table with assignment scores calculated
      h4("Assignment Scores"),
      DT::dataTableOutput("assignment_scores_tab", width = "70%"),
      
      #shows table with students' overall grade + download button for this table
      h4("Student Grades"),
      DT::dataTableOutput("student_grades_tab", width = "40%"),
      
      #shows meta code + download button
      verbatimTextOutput("code"),
      downloadButton("downloadr", "download script")
    )
  )
)
)