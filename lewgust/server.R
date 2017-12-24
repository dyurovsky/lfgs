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
  
  ########## PREFERENCE PLOTS ########## 
  
  output$pref_selector <- renderUI({
    req(input$plot_type)
    
    gs_vals <- starting_data
    
    print("here")
    
    if(input$plot_type == "ingredient") {
      print("here again")
      ingredients <- gs_vals %>%
        distinct(ingredient) %>%
        pull()
    
      selectInput("ingredient_pref", "Ingredient",
                  choices = ingredients,
                  selected = ingredients[1])
      
    } else if(input$plot_type == "person") {
      people <- gs_vals %>%
        distinct(person) %>%
        pull()
      
      selectInput("person_pref", "Person",
                  choices = people,
                  selected = people[1])
    }
  })
  
  output$preference_plot <- renderPlot({
    req(input$plot_type)
    
    gs_vals <- starting_data %>%
      left_join(select(ingredients, id, group,), by = c("ingredient" = "id"))
    
    if(input$plot_type=="ingredient") {
      req(input$ingredient_pref)
      
      gs_vals %>%
        filter(ingredient == input$ingredient_pref) %>%
        ggplot(aes(x = person, y = rating)) + 
        geom_bar(stat = "identity", fill = "#e41a1c") +
        ylim(0,10) + 
        xlab("") +
        ggtitle(paste0("Preferences for ", input$ingredient_pref)) +
        theme(axis.text.x=element_text(angle = 90, vjust=0.5, hjust=1))
      
    } else if(input$plot_type == "person") {
      req(input$person_pref)
      
      gs_vals %>%
        filter(person == input$person_pref) %>%
        left_join(ingredient_palette) %>%
        ggplot(aes(x = ingredient, y = rating, fill = group)) + 
        geom_bar(stat = "identity") + 
        ylim(0,10) +
        xlab("") +
        ggtitle(paste0("Preferences for ", input$person_pref)) +
        theme(axis.text.x=element_text(angle = 90, vjust=0.5, hjust=1)) +
        scale_fill_manual(values = structure(ingredient_palette$color,
                                             names = ingredient_palette$group))
    }
  })
  
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

    if(input$person != "Everyone")
      person_ingredients <- starting_data %>%
        filter(person == input$person) %>%
        left_join(ingredients_colored, by = c("ingredient" = "id")) %>%
        select(-value) %>%
        rename(value = rating, id = ingredient)
    else
      ingredients_colored

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
  
  legend <- reactive({
    req(input$person)
    
    if(input$person != "Everyone")
      person_ingredients <- starting_data %>%
        filter(person == input$person) %>%
        left_join(ingredients_colored, by = c("ingredient" = "id")) %>%
        distinct(group, color) %>%
        mutate(shape = "ellipse") %>%
        rename(label = group)
    else
      ingredients_colored %>%
        distinct(group, color) %>%
        mutate(shape = "ellipse") %>%
        rename(label = group)
    
  })
  
  
  output$network <- renderVisNetwork({
    visNetwork(nodes(), edges(), width = "100%", height = "100%") %>%
      visEdges(color = "lightgrey") %>%
      visNodes(font = list(size = 30)) %>%
      visIgraphLayout(layout = "layout_nicely", randomSeed = 123, physics = F) %>%
      visOptions(highlightNearest = list(enabled = T, degree = 1, hover = T)) %>%
      visLegend(position = "right", ncol =2, addNodes = legend(), useGroups = F)
  })
  
  output$loaded <- reactive(1)
}) 