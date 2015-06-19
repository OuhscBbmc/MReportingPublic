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
                     "ao", "aq", "fm", "ii", "it", "jr", "kc", "pd", "qc", "qs", 
                     "rv", "sx", "tq", "ua", "uq", "wn", "wr", "yn", "zi", "zj"),
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
      menuItem("Referrals (coming)", tabName="referrals"),
      menuItem("Enrollments (coming)", tabName="enrollments"),
      menuItem("Visits", tabName="visits"),
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
        DT::dataTableOutput(outputId = "ScheduleTablePast"),
        HTML("<font color='#605CA8'>This table (will) include prototypical indicators of all four best practices outcomes.",
             "The current columns are: ",
             "<ul>",
             "  <li><code>Region Tag</code>: a randomly-generated two-letter code for each region.</li>",
             "  <li><code>Month</code>: Month for the specific record (YYYY-MM).</li>",
             "  <li><code>Referral Count</code>: total number of monthly referrals. (<em>Coming soon</em>)</li>",
             "  <li><code>Referrals per Need</code>: rate of monthly referrals per 'infant in need'. (<em>Coming soon</em>)</li>",
             "  <li><code>Enrollment Count</code>: total number of monthly enrollments. (<em>Coming soon</em>)</li>",
             "  <li><code>Enrollments per Referral</code>: rate of monthly enrollments per referral. (<em>Coming soon</em>)</li>",
             "  <li><code>Visit Count</code>: total number of visits for the month.</li>",
             "  <li><code>Visits per Enrollment</code>: rate of monthly visits per enrollment. (<em>Coming soon</em>)</li>",
             "  <li><code>Visits per Need</code>: rate of monthly visits per 'infant in need'.</li>",
             "</ul>",
             "</font><br/>")
      ), #End the (first) tab with the 'table' table
      tabItem(
        tabName = "referrals",
        HTML("<font color='#605CA8'>Referral information is coming soon.</font><br/>")
      ), #End the (second) tab with the graph
      tabItem(
        tabName = "enrollments",
        HTML("<font color='#605CA8'>Enrollment information is coming soon.</font><br/>")
      ), #End the (third) tab with the graph
      tabItem(
        tabName = "visits", 
        shiny::plotOutput(outputId = "GraphVisitCount", width='95%', height='400px'),
        HTML("<br/>"),
        shiny::plotOutput(outputId = "GraphVisitPerNeed", width='95%', height='400px')
      ), #End the (fourth) tab with the graph
      tabItem(
        tabName = "generalLinks", 
        HTML("<font color='green'>{<em>What explanatory text would be helpful here?</em>}</font><br/>"),
        htmlOutput(outputId='table_file_info')
      )#, #End the (six) tab with the links & details
    ) #End the tabsetPanel
  ) #End the dashboardBody
) #End the dashboardPage

