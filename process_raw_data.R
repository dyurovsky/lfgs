library(tidyverse)
library(data.table)
library(feather)
library(widyr)

# 
# pairs <- read_csv("raw_data/srep00196-s2.csv", skip = 4, col_names = F) %>%
#   rename(ingredient1 = X1, ingredient2 = X2, count = X3) %>%
#   gather(number, ingredient, ingredient1, ingredient2) %>%
#   group_by(ingredient) %>%
#   summarise(count = sum(count)) %>%
#   arrange(desc(count), ingredient)
  

one_line <- function(line) {
  split_line <- str_split(line, ",")[[1]]
  data_frame(type = split_line[1],
             ingredient = split_line[2:length(split_line)])
}

raw_data <- read_lines("raw_data/srep00196-s3.csv", skip = 4) %>%
  str_split(pattern = ",")

types <- map(raw_data,first) %>%
  unlist() %>%
  data_frame(type = ., recipe = 1:length(.))

rest <- map(raw_data, function(x) data.table(ingredient = x[-1])) %>%
  bind_rows(.id = "recipe") %>%
  mutate(recipe = as.numeric(recipe))

all_data <- left_join(types, rest)

american_ingredients <- all_data %>%
  filter(type == "NorthAmerican") %>%
  group_by(ingredient) %>%
  summarise(n = n()) %>%
  arrange(desc(n), ingredient)

all_ingredients <- all_data %>%
  group_by(type, ingredient) %>%
  summarise(n = n()) %>%
  arrange(type, desc(n), ingredient)

pair_data <- all_data %>%
  split(.$type) %>%
  map(pairwise_count, ingredient, recipe, sort = TRUE) %>%
  bind_rows(.id = "type") %>%
  rename(co_n = n) %>%
  left_join(all_ingredients, by = c("item1" = "ingredient", "type")) %>%
  mutate(prop = co_n/n) %>%
  select(-n)


american_pairs <- all_data %>%
  filter(type == "NorthAmerican") %>%
  pairwise_count(ingredient, recipe, sort = TRUE) %>%
  rename(co_n = n) %>%
  left_join(american_ingredients, by = c("item1" = "ingredient")) %>%
  mutate(prop = co_n/n) %>%
  select(-n)

write_feather(american_ingredients, "processed_data/american_ingredients.feather")
write_feather(american_pairs, "processed_data/american_pairs.feather")
write_feather(pair_data, "processed_data/all_pairs.feather")
