library(tidyverse)
library(shiny)
library(markdown)
library(googlesheets)
library(repurrrsive)
library(data.table)
library(feather)
library(widyr)
library(igraph)
library(visNetwork)
library(shinythemes)
library(shinyBS)
library(corrr)

GAP_KEY <- "12deHY0Q_H7W6NrK2K4TlIWZvlXTCcRqpiAGDB1gVvjI"

rating_data <- GAP_KEY %>%
  gs_key()

starting_data <- gs_read_csv(rating_data)

ingredients <- read_feather("data/american_ingredients.feather") %>%
  rename(id = ingredient,
         value = n,
         group = category) %>%
  mutate(sampling_weights = exp(value/1000),
         label = id)

people_data <- yaml::yaml.load_file("data/people.yaml") %>%
  purrr::transpose() %>%
  simplify_all() 

people <- c("Everyone", tolower(people_data$name))

#people <- c("Everyone", starting_data %>% distinct(person) %>% pull())

pairs <- read_feather("data/all_pairs.feather") %>%
  filter(item1 %in% ingredients$id,
         item2 %in% ingredients$id) %>%
  rename(from = item1, to = item2)

cuisines <- pairs %>% distinct(type) %>% pull()

theme_set(theme_classic(base_size = 16))

families <- people_data %>%
  as.data.frame() %>%
  mutate(name = tolower(name), family = tolower(family)) %>%
  rename(person = name) %>%
  select(-image)

ingredient_palette <- data_frame(color = c("#a6cee3", "#1f78b4", "#b2df8a", 
                                           "#33a02c", "#fb9a99", "#e31a1c", 
                                           "#fdbf6f", "#ff7f00", "#cab2d6", 
                                           "#6a3d9a", "#ffff99", "#b15928",
                                           "#f0f0f0", "#bdbdbd"),
                                 group = unique(ingredients$group))

ingredients_colored <- left_join(ingredients, ingredient_palette)

