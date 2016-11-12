# The ui.R file formats the screen seen by the user in the browser.

# ---- load-packages  -----------------------------------
library(shiny)
library(shinydashboard)
# library(DT)
library(ggplot2)

# ---- declare-globals  -----------------------------------
#Header
tags_style <- "
  h3 {color:red; font-size:150%}
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
  skin   = "green",
  header = header,
  dashboardSidebar(
    HTML('<i class="fa fa-filter panelHeader"> Filters</i>'),
    # selectInput(
    #   inputId = "regionTag",
    #   label   = "Region",
    #   choices = list(
    #     "All", 
    #     "ao", "aq", "fm", "ii", "it", "jr", "kc", "pd", "qc", "qs", 
    #     "rv", "sx", "tq", "ua", "uq", "wn", "wr", "yn", "zi", "zj"
    #   ),
    #   selected = "All"
    # ),    
    dateRangeInput(
      inputId    = 'dateRange', 
      separator  = "-",
      label      = 'Date Format: yyyy-mm-dd',
      start      = as.Date("2015-01-01"), 
      end        = lubridate::floor_date(Sys.Date(), "month")
    ),
    HTML('<i class="fa fa-camera panelHeader"> Views</i>'),
    sidebarMenu(
      menuItem("Table", tabName="table"),
      # menuItem("Visits", tabName="visits"),
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
        DT::dataTableOutput(outputId = "visit_table"),
        HTML("<br/><font color='#605CA8'>This table (will) include prototypical indicators of all four best practices outcomes.",
             "The current columns are: ",
             "<table>",
             "  <tr><td><code>Region Tag</code></td><td> a randomly-generated two-letter code for each region.</td></tr>", # <td> is standard cells that contain the data
             "  <tr><td><code>Month</code></td><td> Month for the specific record (YYYY-MM).</td></tr>",
             "  <tr><td><code>Referral Count</code></td><td> total number of monthly referrals. (<em>Coming soon</em>)</td></tr>",
             "  <tr><td><code>Referrals per Need</code></td><td> rate of monthly referrals per 'infant in need'. (<em>Coming soon</em>)</td></tr>",
             "  <tr><td><code>Enrollment Count</code></td><td> total number of monthly enrollments. (<em>Coming soon</em>)</td></tr>",
             "  <tr><td><code>Enrollments per Referral</code></td><td> rate of monthly enrollments per referral. (<em>Coming soon</em>)</td></tr>",
             "  <tr><td><code>Visit Count</code></td><td> total number of visits for the month.</td></tr>",
             "  <tr><td><code>Visits per Enrollment</code></td><td> rate of monthly visits per enrollment. (<em>Coming soon</em>)</td></tr>",
             "  <tr><td><code>Visits per Need</code></td><td> rate of monthly visits per 'infant in need'.</td></tr>",
             "</table>",
             "</font>")
      ), #End the (first) tab with the 'table' table
      # tabItem(
      #   tabName = "visits", 
      #   shiny::plotOutput(outputId = "GraphVisitCount", width='95%', height='400px'),
      #   HTML("<br/>"),
      #   shiny::plotOutput(outputId = "GraphVisitPerNeed", width='95%', height='400px')
      # ), #End the (fourth) tab with the graph
      tabItem(
        tabName = "generalLinks", 
        HTML("<font color='green'>{<em>What explanatory text would be helpful here?</em>}</font><br/>"),
        htmlOutput(outputId='table_file_info')
      )#, #End the (six) tab with the links & details
    ) #End the tabsetPanel
  ) #End the dashboardBody
) #End the dashboardPage
