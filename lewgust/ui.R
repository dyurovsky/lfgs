

shinyUI(fluidPage(
  theme = shinytheme("spacelab"),
  tags$style(
    type = 'text/css',
    ".selectize-input { font-size: 12px; line-height: 12px;} .selectize-dropdown { font-size: 12px; line-height: 12px; }"
  ),
  
  navbarPage(
    "LewGust",
    tabPanel(
      "Rate Food",
      
      verticalLayout(
        # plotOutput("distPlot"),
        
        textInput(
          "persons_name",
          label = h3("Your name"),
          value = ""
        ),
        HTML("<br>"),
        h1("How much do you like this food?", align = "center"),
        HTML("<br><br><br>"),
        h1(textOutput("current_food"), align = "center"),
        
        
        #hr(),
        #HTML("<br><br><br>"),
        
        #verbatimTextOutput("value"),
        HTML("<br><br><br>"),
        
        wellPanel(
          sliderInput(
            "tastiness_rating",
            0,
            10,
            width = "800px",
            value = 5,
            step = .1,
            label = div(
              style = 'width:800px;',
              div(style = 'float:left;', 'gross!'),
              div(style = 'float:right;', 'yum!')
            )
          )
        ),
        actionButton("go", "Go")
        
      )
    ),
    tabPanel("Who likes what",
             sidebarLayout(
               sidebarPanel(
                 width = 3,
                 selectInput("plot_type", "Plot by",
                             choices = c("Ingredient" = "ingredient", 
                                         "Person" = "person"),
                             selected = "ingredient"),
                  uiOutput("pref_selector")),
               mainPanel(
                 width = 9,
                 plotOutput("preference_plot")
                 )
               )
             ),
    tabPanel("Ingredient Graph",
             sidebarLayout(
               sidebarPanel(
                 width = 3,
                 conditionalPanel(condition = "output.loaded != 1",
                                  h5("Loading...")),
                 
                 conditionalPanel(
                   condition = "output.loaded == 1",
                   uiOutput("cuisine"),
                   uiOutput("person"),
                   sliderInput(
                     "min_prob",
                     "Minimum Overlap",
                     min = .1,
                     max = 1,
                     value = .5,
                     step = .1
                   ),
                   width = 3
                 )
               ),
               
               mainPanel(
                 width = 9,
                 tags$style(
                   type = "text/css",
                   ".shiny-output-error { visibility: hidden; }",
                   ".shiny-output-error:before { visibility: hidden; }"
                 ),
                 conditionalPanel(condition = "output.loaded == 1",
                                  visNetworkOutput("network", height = "600px"))
               )
             )),
    navbarMenu(
      "Lewis Family Preferences",
      tabPanel("Table",
               DT::dataTableOutput("table")),
      tabPanel("About",
               fluidRow(# column(6,
                 #  includeMarkdown("about.md")
                 #),
                 column(
                   3,
                   img(
                     class = "img-polaroid",
                     src = paste0(
                       "http://upload.wikimedia.org/",
                       "wikipedia/commons/9/92/",
                       "1919_Ford_Model_T_Highboy_Coupe.jpg"
                     )
                   ),
                   tags$small(
                     "Source: Photographed at the Bay State Antique ",
                     "Automobile Club's July 10, 2005 show at the ",
                     "Endicott Estate in Dedham, MA by ",
                     a(href = "http://commons.wikimedia.org/wiki/User:Sfoskett",
                       "User:Sfoskett")
                   )
                 )))
    )
  )
))