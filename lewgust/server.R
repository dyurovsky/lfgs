shinyServer(function(input, output, session) {
  output$loaded <- reactive(0)
  outputOptions(output, "loaded", suspendWhenHidden = FALSE)

  output$current_food <- renderText({ 
      "Parsley"
    })
    
  current_values <- reactive({
      name <- input$persons_name
      rating <- input$tastiness_rating
  })
  
  # name <- "molly"
  # rating <- 2
  # gs_add_row(output_data, ws = "Sheet1",
  #            input = c(name, "fish", rating))
  # 
  
  # get_new_word()
  
  ########## NETWORKS ########## 
  
  output$cuisine <- renderUI({
    selectInput("cuisine", "Cuisine",
                choices = cuisines,
                selected = "NorthAmerican")
  })
  
  output$person <- renderUI({
    selectInput("person", "Person",
                choices = people,
                selected = "Everyone")
  })
  
  nodes <- reactive({
    req(input$person)
    
    nodes <- ingredients

    if(input$person != "Everyone")
      filter(nodes, person == input$person)
    
    nodes

  })
  
  edges <- reactive({
    req(input$cuisine)
    req(input$min_prob)
    
    pairs %>%
      filter(type == input$cuisine) %>%
      filter(from %in% nodes()$id,
             to %in% nodes()$id) %>%
      filter(prop >= input$min_prob)
    
  })
  
  output$network <- renderVisNetwork({
    visNetwork(nodes(), edges(), width = "100%", height = "100%") %>%
      visEdges(color = "lightgrey") %>%
      visNodes(font = list(size = 30)) %>%
      visIgraphLayout(layout = "layout_nicely", randomSeed = 123, physics = F) %>%
      visOptions(highlightNearest = list(enabled = T, degree = 1, hover = T)) %>%
      visLegend(position = "right", ncol =2)
  })
  
  output$loaded <- reactive(1)
}) 