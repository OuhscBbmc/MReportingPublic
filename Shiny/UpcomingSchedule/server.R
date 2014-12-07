library(shiny)
library(ggplot2)
library(grid)


#####################################
#' DeclareGlobals
pathUpcomingSchedule <- "../.././DataPhiFreeCache/UpcomingSchedule.csv"
project_id <- 35L

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
    # Filter schedule based on selections
    
    d <- dsUpcomingSchedule
    d <- d[(start_date<=d$event_date) & (d$event_date<=stop_date), ]
    
    # if (input$item_progress_therapist_tag != "All")
    #   d <- d[d$therapist_tag == input$item_progress_therapist_tag, ]
    # if (input$item_progress_client_number != "All")
    #   d <- d[d$client_sequence == input$item_progress_client_number, ]
    
    d$group_name <- gsub("^(.+?)( County)$", "\\1", d$group_name)
    #d$event_description <- gsub("^Year (\\d) Month (\\d{1,2}) Contact$", "Y\\1M\\2", d$event_description)
    d$event_description <- gsub("^Year (\\d)", "Y\\1 ", d$event_description)
    d$event_description <- gsub("Month (\\d{1,2})", "M\\1 ", d$event_description)
    
    d$arm_name <- gsub("^Year (\\d) Cohort$", "Y\\1", d$arm_name)
    
    d$event_status <- plyr::revalue(as.character(d$event_status), warn_missing=F, replace=c(
      "0" = "Due Date", 
      "1" = "Scheduled", 
      "2" = "Confirmed", 
      "3" = "Cancelled", 
      "4" = "No Show"
    ))
    
    d$cal_id <- NULL
    d$group_id <- NULL
    d$project_id <- NULL
    
    d <- plyr::rename(d, replace=c(
      "record" = "record__",
      "group_name" = "county",
      "arm_name" = "arm",
      "event_status" = "status",
      "event_description" = "description"
    ))
    colnames(d) <- gsub("(\\_)", " ", colnames(d), perl=TRUE);
    
    return( as.data.frame(d) )
    
    #TODO: add column for day of week? (eg, `Thursday`)
  }
  
  #######################################
  ### Create the DataTables objects (a jQuery library): http://www.datatables.net/
  
  #This list is pulled out so it can be used by both function
  table_options_schedule <- list(
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
    paging = TRUE,
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
  
  output$ScheduleTableUpcoming <- renderDataTable({
    return( retrieve_schedule(start_date=Sys.Date()) )
  }, options = table_options_schedule
  )
    
  output$ScheduleTablePast <- renderDataTable({
    return( retrieve_schedule(stop_date=Sys.Date()) )
  }, options = table_options_schedule
  )
  
  
})
