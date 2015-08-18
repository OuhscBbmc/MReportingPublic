library(shiny)
library(shinydashboard)
library(ggplot2)

#  .table a {color:#000000;}
tags_style <- "
  .panelHeader {color:#605CA8; font-size:200%}
  .table .smallish {font-size:80%; padding:2px;}
  .table a.interviewEvent {background:#B452CD;}
  .table a.reminderEvent {color:#bb2288; background:#54FF9F;}
  .table a.interviewRow {font-size:97%; font-weight:bold;}
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
    checkboxGroupInput(
      inputId = "status",
      label = "Display Status",
      selected = c("Due Date", "Confirmed", "Cancelled", "No Show", "Scheduled"),
      choices = list("Due Date"="Due Date", "Confirmed"="Confirmed", "Cancelled"="Cancelled", "No Show"="No Show", "Scheduled"="Scheduled")
    ),
    HTML('<i class="fa fa-camera panelHeader"> Views</i>'),
    sidebarMenu(
      menuItem("Upcoming Events", tabName="upcoming_events"),
      menuItem("Past Events", tabName="past_events"),
      menuItem("Graph -County", tabName="graph_county"),
      menuItem("Graph -DC", tabName="graph_dc"),
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
        tabName = "upcoming_events", 
        DT::dataTableOutput(outputId = "ScheduleTableUpcoming"),
        HTML(
          "<br/>",
          "<font color='#605CA8'>This table (will) include prototypical indicators of all four best practices outcomes.",
          "    The current columns are: ",
          "  <table>",
          "    <tr><td><code>Participant</code></td><td>ID of participant; links to <em>participant</em> REDCap record.</td></tr>",
          "    <tr><td><code>Event Date</code></td><td>When the call or interview is scheduled; links to <em>event</em> REDCap record.</td></tr>",
          "    <tr><td><code>Status</code></td><td>Status of the event; links to specific <em> scheduled event</em>.</td></tr>",
          "    <tr><td><code>Arm: Event</code></td><td>The participant's arm &amp event; links to participant's <em>overall schedule</em>.</td></tr>",
          "    <tr><td><code>DC</code></td><td>(if checked/displayed) The data collector currently responsible for the participant; links to assignment field.</td></tr>",
          "    <tr><td><code>County</code></td><td>(if checked/displayed) The county of the participant.</td></tr>",
          "  </table>",
          "</font>"
        )
      ), #End the (first) tab with the 'upcoming' table
      tabItem(
        tabName = "past_events",
        DT::dataTableOutput(outputId = "ScheduleTablePast"),
        HTML(
          "<br/>",
          "<font color='#605CA8'>This table (will) include prototypical indicators of all four best practices outcomes.",
          "    The current columns are: ",
          "  <table>",
          "    <tr><td><code>Participant</code></td><td>ID of participant; links to <em>participant</em> REDCap record.</td></tr>",
          "    <tr><td><code>Event Date</code></td><td>When the call or interview is scheduled; links to <em>event</em> REDCap record.</td></tr>",
          "    <tr><td><code>Status</code></td><td>Status of the event; links to specific <em> scheduled event</em>.</td></tr>",
          "    <tr><td><code>Arm: Event</code></td><td>The participant's arm &amp event; links to participant's <em>overall schedule</em>.</td></tr>",
          "    <tr><td><code>DC</code></td><td>(if checked/displayed) The data collector currently responsible for the participant; links to assignment field.</td></tr>",
          "    <tr><td><code>County</code></td><td>(if checked/displayed) The county of the participant.</td></tr>",
          "  </table>",
          "</font>"
        )
      ), #End the (second) tab with the 'past' table
      tabItem(
        tabName = "graph_county", 
        shiny::plotOutput(outputId = "GraphEventCounty", width='95%', height='800px')
      ), #End the (third) tab with the county graph
      tabItem(
        tabName = "graph_dc", 
        shiny::plotOutput(outputId = "GraphDC", width='95%', height='800px')
      ), #End the (fourth) tab with the dc graph
      tabItem(
        tabName = "general_links", 
        # HTML("<font color='green'>{<em>La'Chanda, Is there some explanatory text you'd like here?</em>}</font><br/>"),
        htmlOutput(outputId='redcap_outlooks'),
        htmlOutput(outputId='table_file_info')
        # plotOutput(outputId='trauma_symptoms', width='95%', height='400px')
      )#, #End the (fifth) tab with the links & details
    ) #End the tabsetPanel
  ) #End the dashboardBody
) #End the dashboardPage
