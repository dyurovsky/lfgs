

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
          fluidRow(column(
            width = 3,
            align = 'center',
            # wellPanel(
            sliderInput(
              "tastiness_rating",
              0,
              10,
              width = "400px",
              value = 5,
              step = .1,
              label = div(
                style = 'width:400px;',
                div(style =
                      'float:left;', 'gross!'),
                div(style =
                      'float:right;', 'yum!')
              )
            ),
            offset = 4
          ))
        )

      )
    ),
    tabPanel("Your Preferences",
             verbatimTextOutput("summary")),
    navbarMenu(
      "Lewis Family Preferences",
      tabPanel("Table",
               DT::dataTableOutput("table"))
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