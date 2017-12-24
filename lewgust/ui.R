

shinyUI(fluidPage(
  #theme = shinytheme("spacelab"),
  tags$style(
    type = 'text/css',
    ".selectize-input { font-size: 12px; line-height: 12px;} .selectize-dropdown { font-size: 12px; line-height: 12px; }"
  ),
  
  navbarPage(
    "Lewis Family Food Map",
    
    tabPanel(
      "What is this",
      fluidRow(column( 12,
                       h2(em("Merry Christmas, Lewises!"),  style = "color:red") 
      )),
      br(),
      fluidRow(
        column(12, align = "center",
               img(src = "bigpic.png", width = 800)
        )),
      br(),
      
      fluidRow(column(12,
        h4("As our gift to you this 2017 Xmas, Dan and I made an app for mapping out familiy taste preferences. Using this app, you can see who likes what and who is most similiar to who in their taste preferences. To use the app, 
           each of us needs to first rate our preferences on a series of food ingredients commonly found in recipes.
           You can also see how your preferences are related to ingredients that commonly go together in recipes in North America, but also different cuisine worldwide.
           The recipe data comes from", a(href="https://www.nature.com/articles/srep00196.pdf", target="_blank", "this paper"),", if you want to check it out. Happy mapping!") 
      ))
     
        
        
      ),
      
    
    
    
    
    tabPanel(
      "Rate Food",
      conditionalPanel(condition = "typeof input.person_id == 'undefined'",
                       br(),
                       uiOutput("person_buttons")),
      conditionalPanel(
        condition = "typeof input.person_id !== 'undefined'",
        uiOutput("current_person"),

        verticalLayout(
          HTML("<br>"),
          h2("How much do you like this food?", align = "center"),
          HTML("<br><br><br>"),
          uiOutput("current_food"),
          HTML("<br><br><br>"),
          sliderInput(
              "tastiness_rating",
              0,
              10,
              width = "650px",
              value = 5.5,
              step = .1,
              label = div(
                style = 'width:650px;',
                div(style =
                      'float:left;', 'gross!'),
                div(style =
                      'float:right;', 'yum!')
              )
          ))
        )
      ),
    tabPanel(
      "Lewis Family Preferences",
      verticalLayout(
        plotOutput("corr_plot"),
        HTML("<br>"),
        h4("These circles show how similar everyones preferences are. 
           Blue means similar, red means dissimilar. 
           The larger and darker the circle, the stronger the relationship")
        )
        
    ),
    tabPanel("Who likes what",
             sidebarLayout(
               sidebarPanel(
                 width = 3,
                 selectInput(
                   "plot_type",
                   "Plot by",
                   choices = c("Ingredient" = "ingredient",
                               "Person" = "person"),
                   selected = "ingredient"
                 ),
                 uiOutput("pref_selector")
               ),
               mainPanel(width = 9,
                         plotOutput("preference_plot"))
             )),
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
             )
    )
  )
  )
)