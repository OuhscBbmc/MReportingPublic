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
      inputId = "countyTag",
      label = "County",
      choices = list("All", 
        "ibq", "qtl", "mxt", "ddw", "duz", "ftj", "wvh", "ltr", "mjf", 
        "ssp", "bqf", "guc", "pim", "bwa", "wfa", "eag", "tnn", "xub", 
        "jjc", "zqy", "qid", "ela", "ito", "mpy", "nck", "kmz", "edc", 
        "lwt", "wnp", "fpz", "zpw", "sjv", "ywu", "dwt", "egc", "jsz", 
        "dee", "ibo", "psc", "ibb", "ukx", "hbu", "jpb", "yxc", "ilc", 
        "vqo", "agy", "okg", "rmw", "mtb", "lmu", "fjy", "pxs", "uxq", 
        "lbf", "tee", "tax", "dec", "amp", "wlp", "kmi", "wwo", "kdj", 
        "jrg", "fwu"),
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
        tabName = "table",
        shiny::dataTableOutput(outputId = "ScheduleTablePast"),
        HTML("<font color='green'>{<em>Is there some explanatory text you'd like here?</em>}</font><br/>")
      ), #End the (second) tab with the 'table' table
      tabItem(
        tabName = "graph", 
        shiny::plotOutput(outputId = "GraphActivity", width='95%', height='800px')
      ), #End the (third) tab with the graph
      tabItem(
        tabName = "general_links", 
        HTML("<font color='green'>{<em>David, Is there some explanatory text you'd like here?</em>}</font><br/>"),
        htmlOutput(outputId='table_file_info')
      )#, #End the (fourth) tab with the links & details
    ) #End the tabsetPanel
  ) #End the dashboardBody
) #End the dashboardPage

