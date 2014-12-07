library(shiny)
library(ggplot2)
library(grid)


#####################################
#' DeclareGlobals
pathUpcomingSchedule <- "../.././DataPhiFreeCache/UpcomingSchedule.csv"

#####################################
#' LoadData
dsUpcomingSchedule <- read.csv(pathUpcomingSchedule, stringsAsFactors=FALSE) 


# Define a server for the Shiny app
shinyServer( function(input, output) {
  
  #######################################
  ### Set any sesion-wide options
  # options(shiny.trace=TRUE)
  
  #######################################
  ### Call source files that contain semi-encapsulated functions.
  
  
  #######################################
  ### Prepare schedule data to be called for two different tables
  
  retrieve_schedule <- function( start_date=as.Date("2000-01-01"), stop_date=as.Date("2100-12-12")) {
    # Filter Client Progress data based on selections
    
    d <- dsUpcomingSchedule
    
    # if (input$item_progress_therapist_tag != "All")
    #   d <- d[d$therapist_tag == input$item_progress_therapist_tag, ]
    # if (input$item_progress_client_number != "All")
    #   d <- d[d$client_sequence == input$item_progress_client_number, ]
    
    d$cal_id <- NULL
    d$project_id <- NULL
    
    # d <- plyr::rename(d, replace=c(
    #   # "description_short" = "Variable",
    #   "description_html" = "TF-CBT PRACTICE Component",
    #   # "therapist_email" = "Therapist Email",
    #   # "therapist_id_rc" = "TID",
    #   # "client_sequence" = "Client Number",
    #   "branch_item" = "B"
    # ))
    d <- d[(start_date<=d$event_date) & (d$event_date<=stop_date), ]
    return( as.data.frame(d) )
  }
  
  #######################################
  ### Create the DataTables objects (a jQuery library): http://www.datatables.net/
  
  output$UpcomingScheduleTable <- renderDataTable({
    return( retrieve_schedule() )
  },
  options = list(
    # lengthMenu = list(c(length(unique(dsItemProgress$item)), -1), c(length(unique(dsItemProgress$item)), 'All')),
    # pageLength = length(unique(dsItemProgress$item)), #34,
    language = list(emptyTable="--<em>Please select a therapist above to populate this table.</em>--"),
    aoColumnDefs = list( #http://legacy.datatables.net/usage/columns
      # list(sClass="semihide", aTargets=-1),
      # list(sClass="alignRight", aTargets=0),
      # list(sClass="session", aTargets=1:length(unique(dsItemProgress$item))),
      list(sClass="smallish", aTargets="_all")
    ),
    # columnDefs = list(list(targets = c(3, 4) - 1, searchable = FALSE)),
    searching = TRUE,
    paging = FALSE,
    sort = TRUE#,
    # $("td:eq(0)", nRow).css("font-weight", "bold");
    # $("td:eq(0)", nRow).css("font-size", "large");
    # rowCallback = I('
    #   function(nRow, aData) {
    #   // Emphasize rows where the `branch_item` column equals to 1
    #     if (aData[aData.length-1] == "1") {
    #       $("td", nRow).css("background-color", "#aaaaaa");
    #     }
    #   }')
    )
  )
  
  
})
