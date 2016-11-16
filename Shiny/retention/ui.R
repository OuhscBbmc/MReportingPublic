# The ui.R file formats the screen seen by the user in the browser.

# ---- load-packages  -----------------------------------
library(shiny)
library(shinydashboard)
# library(DT)
library(ggplot2)
library(survival)
requireNamespace("lubridate")
requireNamespace("GGally")

# ---- declare-globals  -----------------------------------
#Header
header <- dashboardHeader(
  title = "C1 Retention",
  dropdownMenuOutput("messageMenuPast"),
  dropdownMenuOutput("messageMenuUpcoming")
)

dashboardPage(
  skin   = "green",
  header = header,
  dashboardSidebar(
    HTML('<i class="fa fa-filter panel_header"> Filters</i>'),
    selectInput(
      inputId  = "client_index",
      label    = "Client",
      choices  = c("All", sort(unique(ds_visit$client_index))),
      selected = "All"
    ),
    selectInput(
      inputId  = "program_index",
      label    = "Program",
      choices  = c("All", sort(unique(ds_visit$program_index))),
      selected = "All"
    ),
    dateRangeInput(
      inputId    = 'date_range', 
      separator  = "-",
      label      = 'Date Format: yyyy-mm-dd',
      start      = as.Date("2015-01-01"), 
      end        = lubridate::floor_date(Sys.Date(), "month")
    ),
    selectInput(
      inputId  = "final_visit",
      label    = "Was Final Visit",
      choices  = c("All", "Yes", "No"),
      selected = "All"
    ),
    HTML('<i class="fa fa-camera panel_header"> Views</i>'),
    sidebarMenu(
      menuItem("Table"               , tabName = "table"                ),
      menuItem("RR Longitudinal"     , tabName = "rr_longitudinal"      ),
      menuItem("RR Phase"            , tabName = "rr_phase"             ),
      menuItem("Survival"            , tabName = "survival"             ),
      menuItem("General Links"       , tabName = "general_links"        )
    )
  ),  
  dashboardBody(
    shiny::tags$head(
      includeCSS("./www/styles.css") # Include our custom CSS
    ),#End tags$head 
    tabItems( #type = "tabs",
      tabItem(
        tabName = "table",
        DT::dataTableOutput(outputId = "visit_table"),
        HTML("
          <br/>
          <div class='table_legend'>
            Each row in this table describes a completed home visit. The columns are: 
            <table>
              <tr><td><code>Client</code></td><td> The client's ID (which is obfuscated for this demo).</td></tr>
              <tr><td><code>Program</code></td><td> The program's ID (which is obfuscated for this demo).  A 'program' is defined as a specific HV model adminstered from a specific site.</td></tr>
              <tr><td><code>Visit Month</code></td><td> Month of the Visit (YYYY-MM).</td></tr>
              <tr><td><code>Phase</code></td><td>The child's developmental phase (<em>e.g.</em>, pregnant, infant, or toddler).</td></tr>
              <tr><td><code>Content Covered</code></td><td>Percent of the material covered (during the visit; 0%-100%).</td></tr>
              <tr><td><code>Involved</code></td><td>Subjective judgment how involved the client seemed (during the visit; 1-5).</td></tr>
              <tr><td><code>Conflict with Material</code></td><td>Subjective judgment how much conflict the client had with the material (during the visit; 1-5).</td></tr>
              <tr><td><code>Understands Material</code></td><td>Subjective judgment how well the client understood the material (during the visit; 1-5).</td></tr>
              <tr><td><code>Days Since Referral</code></td><td>Number of days between the referral and this visit.</td></tr>
              <tr><td><code>Final Visit?</code></td><td> Does this appear to be the client's final NFP visit?</td></tr>
              <tr><td><code><em>RR</em><sub>v1</sub></code> - <code><em>RR</em><sub>v3</sub></code></td><td>Predicted relative risk of dropping out before the next visit.  Each <em>RR</em> version corresponds to a different model.  The last one is our recommendation.</td></tr>
            </table>
          </div>
        ")
      ), #End the (first) tab with the 'table' table
      tabItem(
        tabName = "rr_longitudinal",
        shiny::plotOutput(outputId = "rr_longitudinal", width='95%', height='700px'),
        HTML("
          <br/>
          <div class='table_legend'>
            Explanation of graph:
            <ul>
              <li>Each gray line represents a single client over time (starting at their referral date).</li>
              <li>The <em>x</em>-value is the number of days since the client's referral.</li>  
              <li>The <em>y</em>-value is the risk of dropping out after that visit, relative to baseline risk.  
                <ul>
                  <li>A value of '1' means the client currently has the typical amount of risk of dropping out.</li>
                  <li>A value less than 1 appears relatively stable and less likely to drop out.  For instance, a '2' is twice as likely to drop out.</li>
                  <li>A value greater than 1 isat greater risk (than most clients) of dropping out.  Consider if additional measures can be taken with this client.  For instance, a '.5' is half as likely to drop out.</li>
                </ul>
              <li>The client's ID is shown at each visit.  Red numbers mark the client's likely final NFP visit.</li>
              <li>Filter points using the drop-down boxes in the lefthand panel.</li>
            </ul>
          </div>
        ")
      ), #End the (second) tab with the longitudinal RR graph
      tabItem(
        tabName = "rr_phase",
        shiny::plotOutput(outputId = "rr_phase", width='95%', height='700px'),
        HTML("
          <br/>
          <div class='table_legend'>
            Explanation of graph:
            <ul>
              <li>Each point/number represents a single client visit.</li>
              <li>The <em>x</em>-value is the developmental phase during the visit.</li>  
              <li>The <em>y</em>-value is the risk of dropping out after that visit, relative to baseline risk.  
                <ul>
                  <li>A value of '1' means the client currently has the typical amount of risk of dropping out.</li>
                  <li>A value less than 1 appears relatively stable and less likely to drop out.  For instance, a '2' is twice as likely to drop out.</li>
                  <li>A value greater than 1 isat greater risk (than most clients) of dropping out.  Consider if additional measures can be taken with this client.  For instance, a '.5' is half as likely to drop out.</li>
                </ul>
              <li>The client's ID is shown at each visit.  Red numbers mark the client's likely final NFP visit.</li>
              <li>Filter points using the drop-down boxes in the lefthand panel.</li>
            </ul>
          </div>
        ")
      ), #End the (third) tab with the phase RR graph
      tabItem(
        tabName = "survival",
        shiny::plotOutput(outputId = "survival", width='95%', height='500px'),
        HTML("
          <br/>
          <div class='table_legend'>
            Explanation of graph:
            <ul>
              <li>Each red plus represents an observed visit.</li>
              <li>The <em>x</em>-value is the number of days since the client's referral.</li>  
              <li>The <em>y</em>-value is the proportion of clients retained after <em>x</em> number of days.</li>
              <li>The solid black is is the predicted proportion.</li>
              <li>The dashed black lines mark the survival's 95% CI.</li>
              <li>National benchmarks (from <a href='http://hv-coiin.edc.org/sites/hv-coiin.edc.org/files/HV%20CoIIN%20Family%20Engagement%20Charter%202016.pdf'>HV CoIIN Family Engagement Charter, 2016</a>) are shown at 3, 6, and 12 months.  The survival lines for the four programs fall well below the values of 85%, 73%, and 58%.</li>
              <li>Filter points using the drop-down boxes in the lefthand panel.</li>
            </ul>
          </div>
        ")
      ), #End the (fourth) tab with the cox survival graph
      tabItem(
        tabName = "general_links", 
        HTML("<font color='green'>{<em>What explanatory text would be helpful here?</em>}</font><br/>"),
        htmlOutput(outputId='table_file_info')
      ) #End the (fifth) tab with the links & details
    ) #End the tabsetPanel
  ) #End the dashboardBody
) #End the dashboardPage
