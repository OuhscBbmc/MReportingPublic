#Starting with http://shiny.rstudio.com/gallery/basic-datatable.html
library(shiny)
library(ggplot2)

# Define the overall UI
shinyUI(fluidPage(
  shiny::tags$head(
    includeCSS("./www/styles.css"), # Include our custom CSS
    #;font-family:courier
    tags$style("
      .table .session {font-size: 80%;padding: 0px; text-align:center}
      .table .smallish {font-size: 80%;padding: 0px; }
      .table .alignRight {text-align: right;font-size: 80%;padding: 0px;}
      .table .semihide {color: #cccccc;font-size: 50%;padding: 0px;}
      .table .interviewEvent {color:#bb2288; background:#D8FFCC;}
      .table .interviewRow {font-size:90%;font-weight:bold}
    ") #Right align the columns of this class (in the DataTables). http://stackoverflow.com/questions/22884224/how-to-right-align-columns-of-datatable-in-r-shiny
  ),#tags$head  
  tabsetPanel( type = "tabs",
               
    tabPanel(
      title = "Upcoming", 
      HTML("<font color='green'>{<em>La'Chanda, Is there some explanatory text you'd like here?</em>}</font>"),
        # titlePanel("Item Progress"),    
        # Create a new Row in the UI for selectInputs
      fluidRow(
        # column(width = 3, 
        #   selectInput(inputId="item_progress_client_number", label="Client within Therapist:", width="100%", 
        #               choices=unique(as.character(dsItemProgress$client_sequence))
        #   )
        # )#,     
      ), #End fluid row with the dropdown boxes
      # Create a new row for the table.
      fluidRow(
        dataTableOutput(outputId = "ScheduleTableUpcoming")
      ) #End fluid row with the Group Call table
    ), #End the (first) tab with the Group Call table

    tabPanel(
      title = "Past", 
      HTML("<font color='green'>{<em>La'Chanda, Is there some explanatory text you'd like here?</em>}</font>"),
      # titlePanel("Item Progress"),    
      # Create a new row for the table.
      fluidRow(
        dataTableOutput(outputId = "ScheduleTablePast")
      ) #End fluid row with the Group Call table
    ), #End the (first) tab with the Group Call table

    tabPanel(
      title = "Graph", 
      shiny::plotOutput(outputId = "GraphEventType", width='95%', height='800px')
    ), #End the (first) tab with the Group Call table

    tabPanel(
      title = "General Links", 
      "La'Chanda, Is there some explanatory text you'd like here?",
      HTML('<br/>'),
      HTML('<br/>'),
      HTML('REDCap Outlooks<br/>'),
      HTML('<ul>'),
      HTML('<li><a href="https://bbmc.ouhsc.edu/redcap/redcap_v6.0.2/Calendar/index.php?pid=35&view=month" target="_blank">Monthly</a></li>'),
      HTML('<li><a href="https://bbmc.ouhsc.edu/redcap/redcap_v6.0.2/Calendar/index.php?pid=35&view=week" target="_blank">Weekly</a></li>'),
      HTML('<li><a href="https://bbmc.ouhsc.edu/redcap/redcap_v6.0.2/Calendar/index.php?pid=35&view=day" target="_blank">Daily</a></li>'),
      HTML('</ul>'),
      HTML('Details<br/>'),
      HTML('<ul>'),
      htmlOutput(outputId='table_file_info'),
      HTML('</ul>')
      # plotOutput(outputId='trauma_symptoms', width='95%', height='400px')
    )#, #End the (third) tab with the symptoms
 
  ) #End the tabsetPanel
)) #End the fluidPage and shinyUI
