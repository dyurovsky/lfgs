library(tidyverse)
library(feather)
library(visNetwork)

nodes <- read_feather("processed_data/american_ingredients.feather") %>%
  rename(id = ingredient,
         value = n,
         group = category) %>%
  mutate(label = id)

edges <- read_feather("processed_data/american_pairs.feather") %>%
  filter(item1 %in% nodes$id,
         item2 %in% nodes$id) %>%
  filter(prop > .5) %>%
  rename(from = item1, to = item2)

# 
# visNetwork(nodes, edges) %>%
#   visEdges(color = "lightgrey") %>%
#   visNodes(font = list(size = 30)) %>%
#   visIgraphLayout(layout = "layout_nicely", randomSeed = 123, physics = F) %>%
#   visOptions(highlightNearest = list(enabled = T, degree = 1, hover = T)) %>%
#   visLegend(position = "right", ncol =2)

network_pca <- 