library(shiny)
library(tidyverse)
library(DT)
library(shinymeta)

shinyServer(function(input, output, session) {
  # reads uploaded file
  data <- metaReactive2({
    shiny::req(input$file)
    metaExpr({
      read.csv(..(input$file$datapath))
    })
  })
  #original data
  output$original <- metaRender(renderDataTable, {
    ..(data())
  })
  #calculates scores for each assignment
  means <- metaReactive({
    ..(data()) |>
      rowwise() |>
      mutate(Score = round(Raw_Points/Max_Points*100,2))
    # mutate(mean = mean(c_across(3:ncol(..(data())))))
  })
  grading <- metaReactive({
    (..(input$grading_policy) == "Equally Weighted")
  })
  # Output data table with assignment scores
  output$table <- metaRender(renderDataTable, {
    ..(means())
  })
  #calculates grades based on criteria
  grades_table <- metaReactive({
    test <- ..(means())
    test <- (unique(test[1]))
    colnames(test) <- "Names"
    table <- data.frame(Names = test,
                        Grades = 0) #table with each unique student
    if (..(grading())){
      table <- ..(means()) |>
        group_by(name) |>
        summarize(Grade = mean(Score)) #grades with equal weights of each assignment
    } else {
      table <- ..(means()) |>
        group_by(name) |>
        summarize(Grade = sum(Raw_Points)/sum(Max_Points)) %>%
        mutate(Grade = round(Grade*100, 2)) #grades with weights based on points
    }
    return (table)
  })
  #outputs table with student grades
  output$grades <- metaRender(renderDataTable, {
    ..(grades_table())
  })
  # download grades as CSV
  output$download <- downloadHandler(
    filename = function() {
      paste("grades_", Sys.Date(), ".csv", sep = "")
    },
    content = function(file) {
      write.csv(grades_table(), file, row.names = FALSE)
    }
  )
  #outputs code
  output$code <- renderPrint({
    expandChain(quote(library(tidyverse)), output$table(), output$grades())
  })
  #downloading code
  output$downloadr <- downloadHandler(
    filename = "report.zip",
    content = function(file) {
      report <- output$code()
      buildScriptBundle(report, file)
    }
  )
}
)
