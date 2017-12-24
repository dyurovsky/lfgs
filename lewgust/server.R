function(input, output, session) {

  
  output$current_food <- renderText({ 
      "Parsley"
    })
    
  current_values <- reactive({
      name <- input$persons_name
      rating <- input$tastiness_rating
  })
  
  name <- "molly"
  rating <- 2
  gs_add_row(output_data, ws = "Sheet1",
             input = c(name, "fish", rating))
  
  
  # get_new_word()


  
} 