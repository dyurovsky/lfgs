########## HELPER ############
getNewIngred  <- function(this_person, pref_data){
  
  current_data <- pref_data %>%
    filter(person == this_person)
  
  sampled <- ingredients %>%
     anti_join(current_data %>% rename(id = ingredient), by = "id") %>%
     sample_n(1, weight = sampling_weights)
  
  pull(sampled, id)
}

getRadioButton <- function(name, family, image){
          paste0("<label class='radio'><input type='radio' name='person_id' value='", name, "'/><span><img src='", image , "' width='50'/></span> </label>")
}

########## SERVER ############
shinyServer(function(input, output, session) {
  output$loaded <- reactive(0)
  outputOptions(output, "loaded", suspendWhenHidden = FALSE)
  
  output$current_person <- renderUI({
    h4(paste0('You are: ', input$person_id), style = "color:grey")
    })

  output$person_buttons <- renderUI({
      button_string <- pmap(people_data, getRadioButton)
      all_buttons <- paste0(button_string %>% unlist(), collapse = "")
      prefix <- '<div id="person_id" class="form-group shiny-input-radiogroup shiny-input-container shiny-input-container-inline"><label class="control-label" for="person_id">Select yourself:</label>
        <div class="shiny-options-group">'
      suffix <- ' </div> </div> '
      all_buttons_clean <- paste0(prefix, all_buttons, suffix)
      fluidRow(column(width = 12, align = 'center', tags$div(HTML(all_buttons_clean))))
  })

rv <- reactiveValues()

  observeEvent(input$person_id, {
      name <- tolower(input$person_id)

      rv$current_ingredient <- getNewIngred(name, starting_data)

      output$current_food <- renderUI({
        h2(rv$current_ingredient, align = "center", style = "color:red")
      })
    },  ignoreInit = TRUE)


  observeEvent(input$tastiness_rating, {
      name <- tolower(input$person_id)
      rating <- input$tastiness_rating

      # write to google form
      gs_add_row(rating_data, ws = "Sheet1",
                 input = c(rv$current_ingredient, name, rating))
      
      # save internal state
      starting_data <<- add_row(starting_data,
              ingredient = rv$current_ingredient,
              person = name,
              rating = rating)

      #updateSliderInput(session,"tastiness_rating",value = 5)
      rv$current_ingredient <- getNewIngred(name, starting_data)


    },  ignoreInit = TRUE)
   
  ########## PREFERENCE PLOTS ########## 
  
  output$pref_selector <- renderUI({
    req(input$plot_type)
    
    gs_vals <- starting_data
    
    if(input$plot_type == "ingredient") {

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
      left_join(select(ingredients, id, group), by = c("ingredient" = "id"))
    
    if(input$plot_type=="ingredient") {
      req(input$ingredient_pref)
      
      gs_vals %>%
        filter(ingredient == input$ingredient_pref) %>%
        left_join(families) %>%
        ggplot(aes(x = person, y = rating, fill = family)) + 
        geom_bar(stat = "identity") +
        ylim(0,10) + 
        xlab("") +
        ggtitle(paste0("Preferences for ", input$ingredient_pref)) +
        theme(axis.text.x=element_text(angle = 90, vjust=0.5, hjust=1)) + 
        scale_fill_brewer(palette = "Set2")
      
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
  
  ########## CORRELATION PLOTS ##########
  output$corr_plot <- renderPlot({
    
    corrs <- starting_data %>%
      spread(person, rating) %>%
      remove_rownames() %>%
      as.data.frame() %>%
      column_to_rownames(var = "ingredient") %>%
      correlate() %>%
      shave()
    
    rplot(corrs) + 
      theme_classic(base_size = 16) + 
      theme(legend.position = "none")
  })
  
  output$loaded <- reactive(1)
}) 
