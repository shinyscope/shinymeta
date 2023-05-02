library(shinymeta)
library(shinyWidgets)
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
      tabsetPanel(
        tabPanel(h5("ShinyMeta"),
                 #shows table with assignment scores calculated
                 h4("Assignment Scores"),
                 DT::dataTableOutput("assignment_scores_tab", width = "70%"),
                 
                 #shows table with students' overall grade + download button for this table
                 h4("Student Grades"),
                 DT::dataTableOutput("student_grades_tab", width = "40%"),
                 
                 #shows meta code + download button
                 verbatimTextOutput("code"),
                 downloadButton("downloadr", "download script")
                 ),
        tabPanel(h5("New UI for Class"),
                 textInput("course_name", "Enter Course Name", value = "", width = "100%"),
                 fluidRow(
                   column(6,
                          selectInput("sem", "Pick a Semester", choices = c("Fall", "Spring", "Summer"), width = "100%"),
                          textInput("professor", "Enter Professor",value = "", width = "100%", placeholder = "if multiple, separate by commas" )
                          ),
                   column(6,
                          selectInput("year", "Pick a Year", choices = seq(from = 2020, to = 2030, by = 1), width = "100%"),
                          textInput("lecture", "Enter Lecture Number",value = "", width = "100%")
                          )
                 ),
                 textAreaInput("description", "Course Description + Notes", value = "", width = "100%")
                 ),
        tabPanel(h5("New UI for Categories"),
                 numericInput("cat_num", "", value = 1, step = 1),
                 textInput("cat_name", "Enter Category Name", value = "", width = "100%"),
                 shinyWidgets::autonumericInput("weight", "What is this category weighted?", value = "", currencySymbol = "%",
                                                currencySymbolPlacement = "s"),
                 fluidRow(
                   column(4,
                          radioButtons("grading_policy", strong("Aggregation Method"),
                                       choices = c("Equally Weighted", "Weighted by Points")),
                          numericInput("num_drops", "How Many Drops:", 0, step = 1),
                          radioButtons("clobber_boolean", strong("Is there a clobber policy?"),
                                       choices = c("Yes", "No"),
                                       selected = "No"),
                          conditionalPanel(
                            condition = "input.clobber_boolean == 'Yes'",
                            selectInput("clobber_with", "Clobber with the Following Assignment",
                                        choices = ''))
                          ),
                   column(6,
                          radioButtons("late_boolean", strong("Is there a lateness policy?"),
                                       choices = c("Yes", "No"),
                                       selected = "No"),
                          conditionalPanel(
                            condition = "input.late_boolean == 'Yes'",
                            fluidRow(
                              column(6,
                                     textInput("late_allowed","Allowed lateness?", placeholder = "enter as HH:MM:SS")
                                     ),
                              column(6,
                                     shinyWidgets::autonumericInput("late_penalty", "What percent is deducted?", value = "", currencySymbol = "%",
                                                                    currencySymbolPlacement = "s")
                                     )
                            ),
                            radioButtons("late_boolean2", strong("Is there another lateness policy?"),
                                         choices = c("Yes", "No"),
                                         selected = "No"),
                            conditionalPanel(
                              condition = "input.late_boolean2 == 'Yes'",
                              fluidRow(
                                column(6,
                                       textInput("late_allowed2","Allowed lateness?", placeholder = "enter as HH:MM:SS")
                                ),
                                column(6,
                                       shinyWidgets::autonumericInput("late_penalty2", "What percent is deducted?", value = "", currencySymbol = "%",
                                                                      currencySymbolPlacement = "s")
                                )
                              )
                            )
                          )
                          )
                 ),
                 selectizeInput("assign", "Select Assignments:",
                                choices = '',
                                multiple = TRUE,
                                width = "100%"),
                 actionGroupButtons(inputIds = c("delete", "save", "new"), 
                                   labels = c("Delete", "Save", "New Category"))
                 ),
        tabPanel(h5("Cat_table"),
                 tableOutput("cat")
        )
      )
      
    )
  )
)
)