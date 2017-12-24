
########## HELPER ############
getNewIngred  <- function(this_person, starting_data){
  current_data <- starting_data %>%
    filter(person == this_person)
  
  sampled <- ingredients %>%
     anti_join(current_data, by = "ingredient") %>%
     sample_n(1, weight = sampling_weights)
  
  sampled$ingredient
}

getRadioButton <- function(name, group, image){
          paste0("<label class='radio-inline'><input type='radio' name='person' value='", name, "'/><span><img src='", image , "'/></span> </label>")
}

########## SERVER ############
function(input, output) {
  
  output$current_person <- renderUI({
      h4(paste0('You are: ', input$person), style = "color:grey")
    })
    
  output$person_buttons <- renderUI({   
      button_string <- pmap(people_data, getRadioButton)
      all_buttons <- paste0(button_string %>% unlist(), collapse = "") 
      prefix <- '<div id="person" class="form-group shiny-input-radiogroup shiny-input-container shiny-input-container-inline"><label class="control-label" for="person">Select yourself:</label>
        <div class="shiny-options-group">'
      suffix <- ' </div> </div> '
      all_buttons_clean <- paste0(prefix, all_buttons, suffix)
      fluidRow(column(width = 12, align = 'center', tags$div(HTML(all_buttons_clean))))
  })
  
  rv <- reactiveValues()
  
  observeEvent(input$person, {
      name <- tolower(input$person)
      rv$current_ingredient <- getNewIngred(name, starting_data)
  
      output$current_food <- renderUI({
        h2(rv$current_ingredient, align = "center", style = "color:red")
      })
    },  ignoreInit = TRUE)
 
  
  observeEvent(input$tastiness_rating, {
      name <- tolower(input$person)
      rating <- input$tastiness_rating
      
      # write to google form
      gs_add_row(output_data, ws = "Sheet1",
                 input = c(rv$current_ingredient, name, rating))
      # save internal state
      starting_data <- add_row(starting_data, 
              ingredient = rv$current_ingredient,
              person = name, 
              rating = rating)
     
      rv$current_ingredient <- getNewIngred(name, starting_data)
      
    },  ignoreInit = TRUE)
} 