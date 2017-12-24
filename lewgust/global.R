library(tidyverse)
library(shiny)
library(markdown)
library(DT)
library(googlesheets)
library(data.table)
library(feather)
library(widyr)
library(visNetwork)
library(shinythemes)
library(shinyBS)

GAP_KEY <- "12deHY0Q_H7W6NrK2K4TlIWZvlXTCcRqpiAGDB1gVvjI"

output_data <- GAP_KEY %>%
  gs_key()

ingredients <- read_feather("../processed_data/american_ingredients.feather") %>%
  rename(id = ingredient,
         value = n,
         group = category) %>%
  mutate(label = id)

pairs <- read_feather("../processed_data/all_pairs.feather") %>%
  filter(item1 %in% ingredients$id,
         item2 %in% ingredients$id) %>%
  rename(from = item1, to = item2)

cuisines <- pairs %>% distinct(type) %>% pull()

people <- c("Everyone", "Molly", "Dan", "Marshall", "Bonnie", "Heather", "Logan")