#load libraries
library(shiny)
library(tidyverse)
library(DT)
library(shinymeta)



#load ui and server
source("ui.R")
source("server.R")

shinyApp(ui, server)
