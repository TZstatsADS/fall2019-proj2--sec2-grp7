library(shiny)
library(leaflet)
library(wordcloud2)
library(plotly)
library(DT)


dog2018 <- read.csv("DogLicensing_clean.csv")
BreedList <- unique(dog2018$BreedName)

# Define UI for application that draws a histogram
shinyUI(navbarPage(
  # Title
  strong("Dog Park",style="font-family: Chalkduster"), 
  #Theme
  theme = "bootstrap.css", 
  # navbarMenu("Text", icon = icon("edit"), tabPanel("Text", icon = icon("save"))), 
  
  tabPanel(p("Introduction",style="font-family: Chalkduster") ,icon  = icon("file-alt"),
           mainPanel(width= 7,
                     # h1("Project: Open Data NYC - an RShiny app development project"),
                     h2("Project Summary"),
                     h5("The DogPark ShinyApp helps you visualize dog and dog park data for all of New York City! In particular, we wanted to give users information about dogs nearby and dog-loving NYC renters a user-friendly way to find an apartment location that best combines their neighborhood interests with easy access to fun parks for their canine pals. The different information tabs (accessible above) are explained below. Enjoy!"),
                     h3("   - ",strong("1. Introduction")),
                     h5("o You are here"),
                     h5("o This tab describes the goal of the app and details its individual tabs"),
                     h3("   - ",strong("2. Fun Finding")),
                     h5("o The", strong("1. Popular Dog Names"), "tab displays wordclouds of male and female dog names in NYC"),
                     h5("o The", strong("2. Popular Dog Breeds"), "tab has a bar chart of the number of dogs of each breed in NYC"),
                     h5("o The", strong("3. Age & Gender Distribution"), "tab shows stats on dog age and gender – hover for details!"),
                     h5("o The", strong("4. Distribution of Dogs and Parks"), "details how dog parks are spread throughout the city"),
                     h3("   - ",strong("3. Map")),
                     h5("o This is an interactive map of NYC with dog parks clearly marked across the city"),
                     h5("o Click for anywhere on the map for additional location info"),
                     h3("   - ",strong("4. Find a 'DogMate'")),
                     h5("o By entering your dog's basic information, we can pick the best neighbrhood for your dog to live"),
                     h3("   - ",strong("5. More")),
                     h5("o The", strong("Data"), "page provides more info on the datasets used for this app"),
                     h5("o The", strong("Contact Us"), "page provides more info on us, the app creators, and how to get in touch"),
                     p(em("Release 10/09/2019.","VERSION 1.0")),
                     p(em(a("Github link", href="https://github.com/TZstatsADS/fall2019-proj2--sec2-grp7")))
           )),
  
  # tab2: Overview
  tabPanel(p("Overview",style="font-family: Chalkduster"), icon  = icon("chart-bar"),
           h3("Some Fun Facts About Dogs in New York"),
           wellPanel(
             wellPanel(style = "background-color: #ffffff;", 
             tabsetPanel(
               # 1. Popular Dog Names
               tabPanel(
                 title = "Popular Dog Names",
                 br(),
                 fluidRow(column(6, wordcloud2Output(outputId = "Mwc")),
                          column(6, wordcloud2Output(outputId = "Fwc"))),
                 fluidRow(column(
                   6,
                   sliderInput(
                     inputId = "Mnames",
                     label = "Number of famous names for Male Dog:",
                     min = 5,
                     max = 50,
                     value = 20
                   )
                 ),
                 column(
                   6,
                   sliderInput(
                     inputId = "Fnames",
                     label = "Number of famous names for Female Dog:",
                     min = 5,
                     max = 50,
                     value = 20
                   )
                 ))
               ),
               
               
               # 2. Popular Dog Breeds
               tabPanel(title = "Popular Dog Breeds",
                        br(),
                        plotOutput(outputId = "Breed")),
               
               
               
               # 3. Age & Gender Distribution
               tabPanel(title = "Dog Age and Gender ",
                        br(),
                        fluidRow(
                          column(6, plotlyOutput(outputId = "Age")),
                          column(6, plotlyOutput(outputId = "gender"))
                        )),
               
               
              
               # 4. Distribution of Dogs and Parks
               tabPanel(title = "Dog and Dog Park Density Map",
                        br(),
                        fluidRow(column(6, leafletOutput(outputId = "park_density")),
                                 column(6, leafletOutput(outputId = "dog_density"))))
             )
           ))),
  
  # tab3: Map
  tabPanel(p("Map",style="font-family: Chalkduster"), icon  = icon("map-marked"), 
    # lealfet map
    leafletOutput("map", height = "95vh"),

    
    # output panel (By zipcode)
    absolutePanel(
      id = "control",
      class = "panel panel-default",
      fixed = TRUE,
      draggable = TRUE,
      top = 120,
      left = "auto",
      right = 20,
      bottom = "auto",
      width = 400,
      height = "auto",
      h2("Tips for You"),
      tags$style("#click_coord{font-size: 16px;display:inline}"), 
      h4('Current Location:',style="display:inline"),  p(textOutput("click_coord")), 
      h4("Nearest Park to Walk Your Dog: "),  p(textOutput("nearest_park")) ,
      tags$style("#distance_to_park{font-size: 16px;display:inline}"), 
      h4("Distance to the Nearest Park: ",style="display:inline"), textOutput("distance_to_park"), br(),  
      tags$style("#walk_min{16px;display:inline}"),
      
      h4("Time Taken to the Nearest Park: ",style="display:inline"), textOutput("walk_min") , br(), 
      tags$style("#dog_num{16px;display:inline}"),br(), 
      
      h4("Total Number of Dogs Near You: ",style="display:inline"), textOutput("dog_num") , br(), 
      tags$style("#dog_age{16px;display:inline}"),br(), 
      
      h4("Average Age: ",style="display:inline"), textOutput("dog_age") , br(), br(), 
      
      h4("Top Three Most Popular Breed: ",style="display:inline"), htmlOutput("dog_breeds") , 
      h4("Male to Female Ratio"),
      plotlyOutput("male_female_pie", height = "400")
    )
  ),
  
  # tab 4  Find the “DogMate” 
  tabPanel(p("Find a 'DogMate'",style="font-family: Chalkduster"), icon = icon("search"), 
           fluidPage(
             sidebarLayout(
               wellPanel(style = "background-color: #ffffff;",
                 selectInput(
                   'Dgender',
                   "Please Select Your Dog's Gender",
                   choices = c("Male", "Female"),
                   selected = NULL
                 ),
                 selectInput(
                   'Dbreed',
                   "Please Select Your Dog's Breed",
                   choices = BreedList,
                   selected = NULL
                 ),
                 selectInput("Dage", "Please Put Your Dog's Age",
                             choices = c(0:18))
               ),
               
               
               mainPanel(
                tags$style('#Bnbhd{font-size: 20px;display:inline}'),br(), 
                 h3("The Best Neighborhood for Your Dog: ",  style="display:inline"), strong(textOutput("Bnbhd")),
                 h3("Information About This Neighborhood"), 
                tags$style("#Nparks{font-size: 16px}"), 
                h4("* Parks Within the Neighborhood: "), htmlOutput("Nparks"), 
                tags$style("#Ndogs{font-size: 16px; display:inline}"), br(), 
                h4("* Number of Dogs of the Same Breed: ", style="display:inline"), strong(textOutput("Ndogs")) , br(),
                tags$style("#Noppo{font-size: 16px; display:inline}"), br(),
                h4("* Number of Dogs of the Opposite Gender:", style="display:inline"), strong( textOutput("Noppo")) , br(), 
                tags$style("#Nsame{font-size: 16px; display:inline}"), br(),
                h4("* Number of Dogs of the Similar Gender:", style="display:inline"), strong( textOutput("Nsame") ) 
               )
             )
           )) , 

  # tab5: More
  tabPanel(p("Data",style="font-family: Chalkduster"), icon = icon("database"), 
                      wellPanel(
                        tabsetPanel(
                          tabPanel(title = "1. NYC Dog Licensing Dataset",
                                   DT::dataTableOutput("table1")),
                          tabPanel(title = "2. NYC Dog Parks Dataset",
                                   DT::dataTableOutput("table2"))))),
             
             
             tabPanel(p("Contact Us",style="font-family: Chalkduster"),icon = icon("address-book"), 
                      mainPanel(h2("Contact Us"),
                                br(),
                                p("If you liked our app or found it useful, feel free to reach out! You can contact us using the information below."),
                                br(),
                                h4("Qiqi Wu"),
                                p("o Columbia University Graduate School of Arts and Sciences, Statistics"),
                                p("o Email:", a("qw2273@columbia.edu", href="qw2273@columbia.edu")),
                                h4("Yakun Wang"),
                                p("o Columbia University Graduate School of Arts and Sciences, Statistics"),
                                p("o Email:", a("yw3211@columbia.edu", href="yw3211@columbia.edu")),
                                h4("Sen Dai"),
                                p("o Columbia University Graduate School of Arts and Sciences, Statistics"),
                                p("o Email:", a("sd3227@columbia.edu", href="sd3227@columbia.edu")),
                                h4("Yuhan Gong"),
                                p("o Columbia University School of Professional Studies, Actuarial Science"),
                                p("o Email:", a("yg2622@columbia.edu", href="yg2622@columbia.edu")),
                                h4("Sam Unger"),
                                p("o Columbia University School of Engineering and Applied Sciences, Applied Mathematics"),
                                p("o Email:", a("sku2105@columbia.edu", href="sku2105@columbia.edu"))
                                
                      )))
)
