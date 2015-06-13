library(shiny)
library(shinydashboard)
library(ggplot2)

tags_style <- "
  .panelHeader {color:#605CA8; font-size:200%}
  .table .smallish {font-size:80%; padding:2px; }
  .table .interviewEvent {color:#bb2288; background:#D8FFCC;}
  .table .interviewRow {font-size:90%; font-weight:bold}
  "

header <- dashboardHeader(
  title = "GPAV Schedule",
  dropdownMenuOutput("messageMenuPast"),
  dropdownMenuOutput("messageMenuUpcoming")
)

# Define the overall UI
dashboardPage(
  skin = "purple",
  header = header,
  dashboardSidebar(
    HTML('<i class="fa fa-filter panelHeader"> Filters</i>'),
    selectInput(
      inputId = "county",
      label = "County",
      choices = list("Missing", "Comanche", "Muskogee", "Oklahoma", "Tulsa", "All"),
      selected = "Missing"
    ),
    checkboxInput(inputId="show_county", label="Display County", value=FALSE),
    selectInput(
      inputId = "dc",
      label = "DC",
      choices = list("(please assign)", "Beverly", "Julie", "Felisa", "Crystal", "Denise", "Kalyn", "All"),
      selected = "All"
    ),
    checkboxInput(inputId="show_dc", label="Display DC", value=TRUE),
    dateRangeInput(
      inputId = 'upcoming_date_range', 
      separator = "-",
      label = 'Upcoming Dates: yyyy-mm-dd',
      start = Sys.Date(), end = Sys.Date()+45
    ),
    dateRangeInput(
      inputId = 'past_date_range', 
      separator = "-",
      label = 'Past Dates: yyyy-mm-dd',
      start = Sys.Date()-60, end = Sys.Date()-1
    ),
    HTML('<i class="fa fa-camera panelHeader"> Views</i>'),
    sidebarMenu(
      menuItem("Upcoming", tabName="upcoming"),
      menuItem("Past", tabName="past"),
      menuItem("Graph", tabName="graph"),
      menuItem("General Links", tabName="general_links")
    )
  ),
  dashboardBody(
    shiny::tags$head(
      includeCSS("./www/styles.css"), # Include our custom CSS
      tags$style(HTML(tags_style))
    ),#End tags$head 
    tabItems( #type = "tabs",
      tabItem(
        tabName = "upcoming", 
        DT::dataTableOutput(outputId = "ScheduleTableUpcoming"),
        HTML("<font color='green'>{<em>La'Chanda, Is there some explanatory text you'd like here?</em>}</font><br/>")
      ), #End the (first) tab with the 'upcoming' table
      tabItem(
        tabName = "past",
        DT::dataTableOutput(outputId = "ScheduleTablePast"),
        HTML("<font color='green'>{<em>La'Chanda, Is there some explanatory text you'd like here?</em>}</font><br/>")
      ), #End the (second) tab with the 'past' table
      tabItem(
        tabName = "graph", 
        shiny::plotOutput(outputId = "GraphEventType", width='95%', height='800px')
      ), #End the (third) tab with the graph
      tabItem(
        tabName = "general_links", 
        HTML("<font color='green'>{<em>La'Chanda, Is there some explanatory text you'd like here?</em>}</font><br/>"),
        htmlOutput(outputId='redcap_outlooks'),
        htmlOutput(outputId='table_file_info')
        # plotOutput(outputId='trauma_symptoms', width='95%', height='400px')
      )#, #End the (fourth) tab with the links & details
    ) #End the tabsetPanel
  ) #End the dashboardBody
) #End the dashboardPage
