library(shiny)
library(ggplot2)
library(grid)

#####################################
#' DeclareGlobals
pathUpcomingScheduleServerOutside <- "//bbmc-shiny-public/Anonymous/MReportingPublic/UpcomingSchedule.csv"
pathUpcomingScheduleServerInside <- "/var/shinydata/MReportingPublic/UpcomingSchedule.csv"
pathUpcomingScheduleRepo <- "../.././DataPhiFreeCache/UpcomingSchedule.csv"

redcap_version <- "6.0.2"
project_id <- 35L

reportTheme <- theme_bw() +
  theme(axis.text = element_text(colour="gray40")) +
  theme(axis.title = element_text(colour="gray40")) +
  theme(panel.border = element_rect(colour="gray80")) +
  theme(axis.ticks = element_line(colour="gray80")) +
  theme(axis.ticks.length = grid::unit(0, "cm"))

#####################################
#' LoadData
if( file.exists(pathUpcomingScheduleServerOutside) ) {
  pathUpcomingSchedule <- pathUpcomingScheduleServerOutside  
} else if( file.exists(pathUpcomingScheduleServerInside) ) {
  pathUpcomingSchedule <- pathUpcomingScheduleServerInside  
} else {
  pathUpcomingSchedule <- pathUpcomingScheduleRepo
}

dsUpcomingSchedule <- read.csv(pathUpcomingSchedule, stringsAsFactors=FALSE) 

#####################################
#' TweakData
dsUpcomingSchedule$event_date <- as.Date(dsUpcomingSchedule$event_date)
dsUpcomingSchedule$event_type <- gsub("^.+?(Reminder Call|Interview|Contact)$", "\\1", dsUpcomingSchedule$event_description)
dsUpcomingSchedule$event_status <- plyr::revalue(as.character(dsUpcomingSchedule$event_status), warn_missing=F, replace=c(
  "0" = "Due Date", 
  "1" = "Scheduled", 
  "2" = "Confirmed", 
  "3" = "Cancelled", 
  "4" = "No Show"
))

#####################################
#' Define a server for the Shiny app
shinyServer( function(input, output) {
  
  #######################################
  ### Set any sesion-wide options
  # options(shiny.trace=TRUE)
  #palette_status <- c("Due Date"="#bb2288", "Confirmed"="", "Cancelled"="#dd0000", "No Show"="", "Scheduled"="")
  palette_status <- c("Due Date"="#bf4136", "Confirmed"="#387566", "Cancelled"="#b8b49b", "No Show"="#fba047", "Scheduled"="#3875bb") #Mostly from http://colrd.com/image-dna/42290/
  
  #######################################
  ### Call source files that contain semi-encapsulated functions.
  
  
  #######################################
  # Prepare inputs -----------------------------------
  SideInputs <- reactive({
    return(list(
      county = input$county,
      upcoming_date_range = input$upcoming_date_range,
      past_date_range = input$past_date_range
    ))
  })
  
  #######################################
  ### Prepare schedule data to be called for two different tables
  retrieve_schedule <- function( start_date=as.Date("2000-01-01"), stop_date=as.Date("2100-12-12")) {
    # Filter schedule based on selections
    
    d <- dsUpcomingSchedule
    
    d$group_name <- ifelse(is.na(d$group_name), "Missing", d$group_name)
    d$group_name <- gsub("^(.+?)( County)$", "\\1", d$group_name)
    if( SideInputs()$county != "All" )
      d <- d[d$group_name==SideInputs()$county, ]
    
    d <- d[(start_date<=d$event_date) & (d$event_date<=stop_date), ]
    
    #d$event_description <- gsub("^Year (\\d) Month (\\d{1,2}) Contact$", "Y\\1M\\2", d$event_description)
    d$event_description <- gsub("^Year (\\d)", "Y\\1", d$event_description) #Shorten 'Year' to 'Y'
    d$event_description <- gsub("Month (\\d{1})\\b", "Month 0\\1", d$event_description) #Pad one-digit month numbers
    d$event_description <- gsub("Month (\\d{2})", "M\\1", d$event_description) #Shorten 'Month' to 'M'
    d$event_description <- gsub("^(Y\\d) Interview Reminder Call$", "\\1 Reminder Call", d$event_description) #Shorten 'Interview Reminder Call' to 'Reminder Call'
    d$event_description <- gsub("^(M\\d{2} Contact)$", "Y1 \\1", d$event_description) #Prepend "Y1" to the 1st year contacts
    
    d$arm_name <- gsub("^Year (\\d) Cohort$", "Y\\1", d$arm_name)
    d$event_type <- gsub("^.+?(Reminder Call|Interview|Contact)$", "\\1", d$event_description)
    
    d$event_date <- sprintf('<a href="https://bbmc.ouhsc.edu/redcap/redcap_v%s/DataEntry/index.php?pid=%s&id=%s&event_id=%s&page=participant_demographics" target="_blank">%s</a>',
                            redcap_version, project_id, d$record, d$event_id, d$event_date)
    d$dc_currently_responsible <- sprintf('<a href="https://bbmc.ouhsc.edu/redcap/redcap_v%s/DataEntry/index.php?pid=%s&id=%s&page=internal_book_keeping" target="_blank">%s</a>',
                                          redcap_version, project_id, d$record, d$dc_currently_responsible)
    d$record <- sprintf('<a href="https://bbmc.ouhsc.edu/redcap/redcap_v%s/DataEntry/grid.php?pid=%s&arm=%s&id=%s&page=participant_demographics" target="_blank">%s</a>',
                       redcap_version, project_id, d$arm_num, d$record, d$record)
    d$event_description <- paste0("A", d$arm_num, ": ", d$event_description)

    d$baseline_date <- NULL
    d$group_name <- NULL #county
    d$event_time <- NULL
    d$cal_id <- NULL
    d$group_id <- NULL
    d$project_id <- NULL
    d$event_id <- NULL
    d$arm_id <- NULL
    d$arm_num <- NULL
    d$day_offset <- NULL
    d$event_type <- NULL
    d$arm_name <- NULL
    d$redcap_event_name <- NULL
    
    d <- plyr::rename(d, replace=c(
      "record" = "participant",
      #"group_name" = "county",
      #"arm_name" = "arm",
      "event_status" = "status",
      "event_description" = "arm: event",
      "dc_currently_responsible"= "dc"
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
    sort = TRUE,
    
    #http://stackoverflow.com/questions/28359626
    #http://stackoverflow.com/questions/22850562
    rowCallback = I(
      'function(row, data) {
        if (data[3].indexOf("Interview") > -1 ) {
          $("td:eq(0)", row).addClass("interviewEvent");
          $("td:eq(3)", row).addClass("interviewEvent");
          $("td", row).addClass("interviewRow"); 
          //$("td", row).css("font-weight", "bold");
        }
      }'
    )
  )
  
  output$ScheduleTableUpcoming <- renderDataTable({
    return( retrieve_schedule(start_date=SideInputs()$upcoming_date_range[1], stop_date=SideInputs()$upcoming_date_range[2]) )
  }, options = table_options_schedule,
    escape = FALSE
  )
  
  output$ScheduleTablePast <- renderDataTable({
    return( retrieve_schedule(start_date=SideInputs()$past_date_range[1], stop_date=SideInputs()$past_date_range[2]) )
  }, options = table_options_schedule,
    escape = FALSE
  )    
  
  output$GraphEventType <- renderPlot({
#     d <- retrieve_schedule()
    ggplot(dsUpcomingSchedule, aes(x=event_date, color=event_status)) +
      geom_line(stat="bin", binwidth=7) +
      geom_vline(xintercept=as.numeric(Sys.Date()), size=3, color="gray50", alpha=.3) +
      scale_color_manual(values=palette_status) +
      # scale_color_brewer(palette="Dark2") + 
      guides(colour = guide_legend(override.aes = list(size = 3))) +
      facet_grid(event_type ~ group_name, scales="free_y") +
      reportTheme +
      theme(legend.position="top") +
      theme(axis.text.x = element_text(angle=90, hjust=1)) +
      labs(x=NULL, y="Events per Day", color="Status", title="Weekly Events")
  })
  output$table_file_info <- renderText({
    return( paste0(
      "<table border='0' cellspacing='1' cellpadding='2' >",
        "<tr><td>Data Path:<td/><td>&nbsp;", pathUpcomingSchedule, "<td/><tr/>",
        "<tr><td>Data Last Modified:<td/><td>&nbsp;", file.info(pathUpcomingSchedule)$mtime, "<td/><tr/>",
        "<tr><td>App Restart Time:<td/><td>&nbsp;", file.info("restart.txt")$mtime, "<td/><tr/>",
      "<table/>"
    ) )
  })
})
