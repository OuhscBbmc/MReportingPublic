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
  skin = "green",
  header = header,
  dashboardSidebar(
    HTML('<i class="fa fa-filter panelHeader"> Filters</i>'),
    selectInput(
      inputId = "regionTag",
      label = "Region",
      choices = list("All", 
                     "fm", "pd", "wn", "ua", "jr", "it", "wr", "uq", "ii", "zj", 
                     "qs", "qc", "yn", "ao", "tq", "aq", "sx", "zi", "kc", "rv"),
      selected = "All"
    ),    
    dateRangeInput(
      inputId = 'dateRange', 
      separator = "-",
      label = 'Dates: yyyy-mm-dd',
      start = as.Date("2015-01-01"), end = lubridate::floor_date(Sys.Date(), "month")
    ),
    HTML('<i class="fa fa-camera panelHeader"> Views</i>'),
    sidebarMenu(
      menuItem("Table", tabName="table"),
      menuItem("Visits", tabName="graphVisit"),
      menuItem("General Links", tabName="generalLinks")
    )
  ),  
  dashboardBody(
    shiny::tags$head(
      includeCSS("./www/styles.css"), # Include our custom CSS
      tags$style(HTML(tags_style))
    ),#End tags$head 
    tabItems( #type = "tabs",
      tabItem(
        tabName = "table",
        shiny::dataTableOutput(outputId = "ScheduleTablePast"),
        HTML("<font color='green'>This table includes prototypical indicators of all four best practices outcomes.  
             The column labeled <code>VisitsPerInfantNeed</code> provides the rate of monthly visits per 'infant in need'.
             {TODO: explain the remaining columns.}</font><br/>")
      ), #End the (second) tab with the 'table' table
      tabItem(
        tabName = "graphVisit", 
        shiny::plotOutput(outputId = "GraphVisitCount", width='95%', height='400px'),
        shiny::plotOutput(outputId = "GraphVisitPerNeed", width='95%', height='400px')
      ), #End the (third) tab with the graph
      tabItem(
        tabName = "generalLinks", 
        HTML("<font color='green'>{<em>David, Is there some explanatory text you'd like here?</em>}</font><br/>"),
        htmlOutput(outputId='table_file_info')
      )#, #End the (fourth) tab with the links & details
    ) #End the tabsetPanel
  ) #End the dashboardBody
) #End the dashboardPage

