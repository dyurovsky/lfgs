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


visNetwork(nodes, edges) %>%
  visEdges(color = "lightgrey") %>%
  visNodes(font = list(size = 30)) %>%
  visIgraphLayout(layout = "layout_nicely", randomSeed = 123, physics = F) %>%
  visOptions(highlightNearest = list(enabled = T, degree = 1, hover = T)) %>%
  visLegend(position = "right", ncol =2)

visNetwork(assoc_nodes(),
           rename(assoc_edges(), from = in_node, to = out_node),
           width = "100%", height = "100%") %>%
  visIgraphLayout(layout = "layout_nicely", randomSeed = 123,
                  physics = F) %>%
  visEdges(color = "darkgrey") %>%
  visNodes(font = list(size = 30), size = 20) %>%
  visOptions(highlightNearest = list(enabled = T, degree = 2, hover = F),
             selectedBy = "group") %>% 
  visLegend(width = 0.2, position = "right", 
            addNodes = lnodes(), useGroups = F, ncol = 1,
            stepY = 50)
})