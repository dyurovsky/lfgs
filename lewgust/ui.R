
navbarPage("LewGust",
           tabPanel("Rate Food",
                    conditionalPanel(condition = "typeof input.person == 'undefined'",
                        br(),
                        uiOutput("person_buttons")
                    ),
                    conditionalPanel(condition = "typeof input.person !== 'undefined'",
                                     uiOutput("current_person"),
                   
                 
                    verticalLayout(  
                      HTML("<br>"),
                      h2("How much do you like this food?", align = "center"),
                      HTML("<br><br><br>"), 
                      uiOutput("current_food"),
                      HTML("<br><br><br>"), 
                      fluidRow(column(width = 3, align = 'center', 
                       # wellPanel(
                          sliderInput("tastiness_rating", 0, 10, width = "400px",
                                      value = 5, step = .1,
                                      label = div(style='width:400px;', 
                                                div(style='float:left;', 'gross!'),
                                                div(style='float:right;', 'yum!'))
                                      ),
                        offset = 4)
                    ) )

           )),
           tabPanel("Your Preferences",
                    verbatimTextOutput("summary")
           ),
           navbarMenu("Lewis Family Preferences",
                      tabPanel("Table",
                               DT::dataTableOutput("table")
                      )
           )
)