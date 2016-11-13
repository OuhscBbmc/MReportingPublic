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
  title = "C1 Retention",
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
        HTML("<br/><font color='#605CA8'>Each row in this table describes a completed home visit.",
             "The columns are: ",
             "<table>",
             "  <tr><td><code>Client</code></td><td> The client's ID (which is obfuscated for this demo).</td></tr>", # <td> is standard cells that contain the data
             "  <tr><td><code>Program</code></td><td> The program's ID (a 'program' is defined as a specific HV model adminstered from a specific site.)</td></tr>",
             "  <tr><td><code>Visit Month</code></td><td> Month of the Visit (YYYY-MM).</td></tr>",
             "  <tr><td><code>Phase</code></td><td>The child's developmental phase (<em>e.g.</em>, pregnant, infant, or toddler).</td></tr>",
             "  <tr><td><code>Content Covered</code></td><td>Percent of the material covered (during the visit; 0%-100%).</td></tr>",
             "  <tr><td><code>Involved</code></td><td>Subjective judgment how involved the client seemed (during the visit; 1-5).</td></tr>",
             "  <tr><td><code>Conflict with Material</code></td><td>Subjective judgment how much conflict the client had with the material (during the visit; 1-5).</td></tr>",
             "  <tr><td><code>Understands Material</code></td><td>Subjective judgment how well the client understood the material (during the visit; 1-5).</td></tr>",
             "  <tr><td><code>Days Since Referral</code></td><td>Number of days between the referral and this visit.</td></tr>",
             "  <tr><td><code>Final Visit?</code></td><td> Does this appear to be the client's final NFP visit?</td></tr>",
             "  <tr><td><code><em>RR</em><sub>v1</sub></code> - <code><em>RR</em><sub>v3</sub></code></td><td>Predicted relative risk of dropping out before the next visit.  Each <em>RR</em> version corresponds to a different model.  The last one is our recommendation.</td></tr>",
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
