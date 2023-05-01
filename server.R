library(shiny)
library(tidyverse)
library(DT)
library(shinymeta)

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
        summarize(Grade = ..(switch(input$grading_policy,
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
}
)
