library(shiny)
library(tidyverse)
library(DT)
library(shinymeta)

HSLocation <- "HelperScripts/"
source(paste0(HSLocation, "Functions.R"))

shinyServer(function(input, output, session) {
  # reads uploaded file and calculates scores for each assignment
  assignment_scores <- metaReactive2({
    shiny::req(input$file)
    
    metaExpr({
      read.csv(..(input$file$datapath)) %>%
        mutate(Score = round(Raw_Points/Max_Points*100, 2))
    })
  })

  # output data table with assignment scores
  output$assignment_scores_tab <- metaRender(renderDataTable, {
    ..(assignment_scores())
  })
  
  # agg_fn <- metaReactive2({
  #   switch(input$grading_policy,
  #          "Equally Weighted" = rlang::expr(mean(Score)),
  #          "Weighted by Points" = rlang::expr(sum(Raw_Points)/sum(Max_Points)))
  # })
  
  # calculate student grades
  student_grades <- metaReactive({
      ..(assignment_scores()) %>%
        group_by(name) %>%
        summarize(Grade = !!..(switch(input$grading_policy,
                                    "Equally Weighted" = rlang::expr(mean(Score)),
                                    "Weighted by Points" = rlang::expr(sum(Raw_Points)/sum(Max_Points)))))
  })

  # output table with student grades
  output$student_grades_tab <- metaRender(renderDataTable, {
    ..(student_grades())
  })
  
  # # download grades as CSV
  # output$download <- downloadHandler(
  #   filename = function() {
  #     paste("grades_", Sys.Date(), ".csv", sep = "")
  #   },
  #   content = function(file) {
  #     write.csv(grades_table(), file, row.names = FALSE)
  #   }
  # )
  
  #outputs code
  output$code <- renderPrint({
    expandChain(quote(library(dplyr)), output$student_grades_tab())
  })
  
  #downloading code
  output$downloadr <- downloadHandler(
    filename = "report.zip",
    content = function(file) {
      report <- output$code()
      buildScriptBundle(report, file)
    })
  
  
  
  cat <- reactiveValues(table = cat_table <- data.frame(matrix(ncol = 7, nrow = 1)) %>%
                          rename(Categories = "X1", Weights = "X2", Assignments_Included = "X3", Drops = "X4", Grading_Policy = "X5", Clobber_Policy = "X6", Late_Policy = "X7"))
  
  output$cat <- renderTable(cat$table)
  
  observeEvent(input$save,{
    inputs <- c(input$cat_name, input$weight, input$num_drops,input$grading_policy, input$clobber_boolean, input$late_boolean)
    cat$table <- updateCatTable(cat$table, input$cat_num, inputs)
  })
  
  observeEvent(input$new,{
    cat$table[ nrow(cat$table) + 1 , ] <- NA
    updateNumericInput(session, "cat_num", value = nrow(cat$table))
  })
  
  observeEvent(input$delete,{
    cat$table <- cat$table[-input$cat_num,]
  })
  
  observeEvent(input$cat_num,{
    n <- input$cat_num
    updateTextInput(session, "cat_name", value = cat$table[n, 1])
    shinyWidgets::updateAutonumericInput(session, "weight", value = cat$table[n, 2])
    updateNumericInput(session, "num_drops", value = cat$table[n, 4])
    
  })
  
  observe({
    updateNumericInput(session, "cat_num", max = nrow(cat$table))
  })
}
)
