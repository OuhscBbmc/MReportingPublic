library(shiny)
library(ggplot2)
library(grid)
library(magrittr)

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

move_to_last <- function(data, move) { #http://stackoverflow.com/questions/18339370
  data[c(setdiff(names(data), move), move)]
}

status_levels <- c("0" = "Due Date", "1" = "Scheduled", "2" = "Confirmed", "3" = "Cancelled", "4" = "No Show")
icons_status <- c("Due Date"="bicycle", "Scheduled"="book", "Confirmed"="bug", "Cancelled"="bolt", "No Show"="ban")
order_status  <- as.integer(names(status_levels)); names(order_status) <- status_levels
#order_status <- c("Due Date"=1, "Scheduled"=2, "Confirmed"=3, "Cancelled"=4, "No Show"=5)

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
dsUpcomingSchedule$event_status <- plyr::revalue(as.character(dsUpcomingSchedule$event_status), warn_missing=F, replace=status_levels)

dsUpcomingSchedule$group_name <- ifelse(is.na(dsUpcomingSchedule$group_name), "Missing", dsUpcomingSchedule$group_name)
dsUpcomingSchedule$group_name <- gsub("^(.+?)( County)$", "\\1", dsUpcomingSchedule$group_name)

dsUpcomingSchedule$event_description <- gsub("^Year (\\d)", "Y\\1", dsUpcomingSchedule$event_description) #Shorten 'Year' to 'Y'
dsUpcomingSchedule$event_description <- gsub("Month (\\d{1})\\b", "Month 0\\1", dsUpcomingSchedule$event_description) #Pad one-digit month numbers
dsUpcomingSchedule$event_description <- gsub("Month (\\d{2})", "M\\1", dsUpcomingSchedule$event_description) #Shorten 'Month' to 'M'
dsUpcomingSchedule$event_description <- gsub("^(Y\\d) Interview Reminder Call$", "\\1 Reminder Call", dsUpcomingSchedule$event_description) #Shorten 'Interview Reminder Call' to 'Reminder Call'
dsUpcomingSchedule$event_description <- gsub("^(M\\d{2} Contact)$", "Y1 \\1", dsUpcomingSchedule$event_description) #Prepend "Y1" to the 1st year contacts

dsUpcomingSchedule$record_pretty <- sprintf('<a href="https://bbmc.ouhsc.edu/redcap/redcap_v%s/DataEntry/grid.php?pid=%s&arm=%s&id=%s&page=participant_demographics" target="_blank">%s</a>',
                                            redcap_version, project_id, dsUpcomingSchedule$arm_num, dsUpcomingSchedule$record, dsUpcomingSchedule$record)
dsUpcomingSchedule$event_date_pretty <- sprintf('<!--%s for sorting--><a href="https://bbmc.ouhsc.edu/redcap/redcap_v%s/DataEntry/index.php?pid=%s&id=%s&event_id=%s&page=participant_demographics" target="_blank">%s</a>',
                                                dsUpcomingSchedule$event_date, redcap_version, project_id, dsUpcomingSchedule$record, dsUpcomingSchedule$event_id, dsUpcomingSchedule$event_date)
dsUpcomingSchedule$event_status_pretty <- dsUpcomingSchedule$event_status
dsUpcomingSchedule$event_description_pretty <- paste0("A", dsUpcomingSchedule$arm_num, ": ", dsUpcomingSchedule$event_description)
dsUpcomingSchedule$dc_currently_responsible_pretty <- sprintf('<!--%s for sorting--><a href="https://bbmc.ouhsc.edu/redcap/redcap_v%s/DataEntry/index.php?pid=%s&id=%s&page=internal_book_keeping" target="_blank">%s</a>',
                                                              dsUpcomingSchedule$dc_currently_responsible, redcap_version, project_id, dsUpcomingSchedule$record, dsUpcomingSchedule$dc_currently_responsible)

# d$event_description <- gsub("^Year (\\d) Month (\\d{1,2}) Contact$", "Y\\1M\\2", d$event_description)
# d$event_type <- gsub("^.+?(Reminder Call|Interview|Contact)$", "\\1", d$event_description)
# d$arm_name <- gsub("^Year (\\d) Cohort$", "Y\\1", d$arm_name)

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
      dc = input$dc,
      upcoming_date_range = input$upcoming_date_range,
      past_date_range = input$past_date_range
    ))
  })
  
  #######################################
  ### Prepare schedule data to be called for two different tables
  filter_schedule <- function( start_date=as.Date("2000-01-01"), stop_date=as.Date("2100-12-12")) {
    # Filter schedule based on selections
    
    d <- dsUpcomingSchedule
    
    if( nrow(d)>0 & SideInputs()$county != "All" )
      d <- d[d$group_name==SideInputs()$county, ]
    if( nrow(d)>0 &  SideInputs()$dc != "All" )
      d <- d[!is.na(d$dc_currently_responsible) & (d$dc_currently_responsible==SideInputs()$dc), ]
    
    d <- d[(start_date<=d$event_date) & (d$event_date<=stop_date), ]
    
    return( d )
  }

  prettify_schedule <- function( d, pretty_only=TRUE ){
    d <- plyr::rename(d, replace=c(
      "record_pretty" = "participant",
      "event_date_pretty" = "event date",
      "event_status_pretty" = "status",
      "event_description_pretty" = "arm: event",
      "dc_currently_responsible_pretty"= "dc",
      "group_name" = "county"
    ))
    
    if( input$show_dc ) 
      d <- move_to_last(d, c("dc"))
    else 
      d$dc <- NULL
    
    if( input$show_county ) 
      d <- move_to_last(d, c("county"))
    else 
      d$county <- NULL
    
    if( pretty_only ) {
      d$record <- NULL
      d$event_date <- NULL
      d$event_status <- NULL
      d$event_description <- NULL
      d$dc_currently_responsible <- NULL
      
      d$baseline_date <- NULL
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
    }
    # colnames(d) <- gsub("(\\_)", " ", colnames(d), perl=TRUE);
    
    return( d )
    
    #TODO: add column for day of week? (eg, `Thursday`)
  }
  
  #######################################
  ### Create the DataTables objects (a jQuery library): http://www.datatables.net/
  
  #This list is pulled out so it can be used by both function
  table_options_schedule <- list(
    # lengthMenu = list(c(length(unique(dsItemProgress$item)), -1), c(length(unique(dsItemProgress$item)), 'All')),
    language = list(emptyTable="--<em>Please loosen the filter to populate this table.</em>--"),
    aoColumnDefs = list( #http://legacy.datatables.net/usage/columns
      # list(sClass="semihide", aTargets=-1),
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
        }

        if (data[2].indexOf("Due Date") > -1 ) $("td:eq(2)", row).css("color", "#bb2288");
        else if (data[2].indexOf("Confirmed") > -1 ) $("td:eq(2)", row).css("color", "#387566");
        else if (data[2].indexOf("Cancelled") > -1 ) $("td:eq(2)", row).css("color", "#b8b49b");
        else if (data[2].indexOf("No Show") > -1 ) $("td:eq(2)", row).css("color", "#fba047");
        else if (data[2].indexOf("Scheduled") > -1 ) $("td:eq(2)", row).css("color", "#3875bb");
      }'
    )
  )
  
  output$ScheduleTableUpcoming <- renderDataTable({
    d <- prettify_schedule(filter_schedule(start_date=SideInputs()$upcoming_date_range[1], stop_date=SideInputs()$upcoming_date_range[2]))
    return( d )
  }, options = table_options_schedule,
    escape = FALSE
  )
  
  output$ScheduleTablePast <- renderDataTable({
    d <- prettify_schedule(filter_schedule(start_date=SideInputs()$past_date_range[1], stop_date=SideInputs()$past_date_range[2]))
    return( d )
  }, options = table_options_schedule,
    escape = FALSE
  )    
  
  output$GraphEventType <- renderPlot({
    d <- dsUpcomingSchedule
    d$group_name <- ifelse(is.na(d$group_name), "Missing", d$group_name)
    d$group_name <- gsub("^(.+?)( County)$", "\\1", d$group_name)
    
    if( SideInputs()$county != "All" )
      d <- d[d$group_name==SideInputs()$county, ]
    
    ggplot(d, aes(x=event_date, color=event_status)) +
      geom_line(stat="bin", binwidth=7) +
      geom_vline(xintercept=as.numeric(Sys.Date()), size=3, color="gray50", alpha=.3) +
      scale_color_manual(values=palette_status) +
      # scale_color_brewer(palette="Dark2") + 
      guides(colour = guide_legend(override.aes = list(size = 3))) +
      facet_grid(event_type ~ group_name, scales="free_y") +
      reportTheme +
      theme(legend.position="top") +
      theme(axis.text.x = element_text(angle=90, hjust=1)) +
      labs(x=NULL, y="Events per Week", color="Status", title="Weekly Events for County\n(change county in the side panel)")
  })
  output$redcap_outlooks <- renderText({
    return( paste0(
      "<h3>REDCap Outlooks</h3>",
      "<table border='0' cellspacing='1' cellpadding='2' >",
      '<tr><td><a href="https://bbmc.ouhsc.edu/redcap/redcap_v6.0.2/Calendar/index.php?pid=35&view=month" target="_blank">Monthly</a></td></tr>',
      '<tr><td><a href="https://bbmc.ouhsc.edu/redcap/redcap_v6.0.2/Calendar/index.php?pid=35&view=week" target="_blank">Weekly</a></td></tr>',
      '<tr><td><a href="https://bbmc.ouhsc.edu/redcap/redcap_v6.0.2/Calendar/index.php?pid=35&view=day" target="_blank">Daily</a></td></tr>',
      "<table/>"
    ) )
  })
  output$table_file_info <- renderText({
    return( paste0(
      '<h3>Details</h3>',
      "<table border='0' cellspacing='1' cellpadding='2' >",
      "<tr><td>Data Path:<td/><td>&nbsp;", pathUpcomingSchedule, "<td/><tr/>",
      "<tr><td>Data Last Modified:<td/><td>&nbsp;", file.info(pathUpcomingSchedule)$mtime, "<td/><tr/>",
      "<tr><td>App Restart Time:<td/><td>&nbsp;", file.info("restart.txt")$mtime, "<td/><tr/>",
      "<table/>"
    ) )
  })

  create_schedule_dropdown <- function( upcoming = TRUE ) {
    # https://github.com/rstudio/shinydashboard/issues/1#issuecomment-71713501
    if( any(upcoming) ) {
      d <- filter_schedule(start_date=SideInputs()$upcoming_date_range[1], stop_date=SideInputs()$upcoming_date_range[2])
      label <- "upcoming"
      icon_name <- "calendar"
    } else {
      d <- filter_schedule(start_date=SideInputs()$past_date_range[1], stop_date=SideInputs()$past_date_range[2])
      label <- "past"
      icon_name <- "calendar-o"
    }
    
    d_status <- d %>%
      dplyr::group_by(event_status) %>%
      dplyr::summarize(
        status_count = n()
      )
    d_status$icon <- icons_status[d_status$event_status]
    d_status$status_count_pretty <- format(d_status$status_count, big.mark=",")
    d_status$order <- order_status[d_status$event_status]
    d_status <- d_status[order(d_status$order), ]
    
    if( nrow(d_status) == 0L ) {
      msgs <- character(0)
    } else {
      msgs <- apply(d_status, 1, function(row) {
        messageItem(
          icon = icon(row[["icon"]]),
          from = paste0(row[["event_status"]], " (", label, ")"),
          message = paste(row[["status_count_pretty"]], "in", ifelse(input$county=="All", "All Counties", paste(input$county, "County")), ifelse(input$dc=="All", "", paste(" with", input$dc)))
        )
      })
    }
    dropdownMenu(type="messages", .list=msgs, icon=icon(icon_name))    
  }
  output$messageMenuUpcoming <- renderUI({
    create_schedule_dropdown()
  })
  output$messageMenuPast <- renderUI({
    create_schedule_dropdown(upcoming=FALSE)
  })
})
