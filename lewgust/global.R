library(shiny)
library(markdown)
library(DT)
library(googlesheets)

GAP_KEY <- "12deHY0Q_H7W6NrK2K4TlIWZvlXTCcRqpiAGDB1gVvjI"

output_data <- GAP_KEY %>%
  gs_key()

