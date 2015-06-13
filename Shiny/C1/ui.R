library(shiny)
library(shinydashboard)
# library(DT)
library(ggplot2)

tags_style <- "
.panelHeader {color:#605CA8; font-size:200%}
.table .smallish {font-size:80%; padding:2px; }
.table .interviewEvent {color:#bb2288; background:#D8FFCC;}
.table .interviewRow {font-size:90%; font-weight:bold}
"

header <- dashboardHeader(
  title = "C1 Activity",
  dropdownMenuOutput("messageMenuPast"),
  dropdownMenuOutput("messageMenuUpcoming")
)

dashboardPage(
  skin = "red",
  header = header,
  dashboardSidebar(
    HTML('<i class="fa fa-camera panelHeader"> Views</i>'),
    sidebarMenu(
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
    
        # htmlOutput(outputId='table_file_info'),
    tabItems( #type = "tabs",
      tabItem(
        tabName = "past",
        shiny::dataTableOutput(outputId = "ScheduleTablePast"),
        HTML("<font color='green'>{<em>Is there some explanatory text you'd like here?</em>}</font><br/>")
      ), #End the (second) tab with the 'past' table
#       # tabItem(
#       #   tabName = "graph", 
#       #   shiny::plotOutput(outputId = "GraphEventType", width='95%', height='800px')
#       # ), #End the (third) tab with the graph
      tabItem(
        tabName = "general_links", 
#         HTML("<font color='green'>{<em>La'Chanda, Is there some explanatory text you'd like here?</em>}</font><br/>"),
#         htmlOutput(outputId='redcap_outlooks'),
        htmlOutput(outputId='table_file_info')
        # plotOutput(outputId='trauma_symptoms', width='95%', height='400px')
      )#, #End the (fourth) tab with the links & details
    ) #End the tabsetPanel
  ) #End the dashboardBody
) #End the dashboardPage

