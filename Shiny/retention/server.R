# ---- load-packages  -----------------------------------
library(shiny)
library(htmlwidgets)
library(magrittr)
library(scales)
library(ggplot2)
requireNamespace("grid")
requireNamespace("DT")
requireNamespace("readr")
requireNamespace("dplyr")

# ---- declare-globals  -----------------------------------
# path_input_server_outside <- "//bbmc-shiny-public/Anonymous/MReportingPublic/UpcomingSchedule.csv"
# path_input_server_inside  <- "/var/shinydata/MReportingPublic/UpcomingSchedule.csv"
path_input_repo             <- "../.././DataPhiFreeCache/Raw/C1/eto-visit.rds"

#Define some common cosmetics for the report.
report_theme <- theme_light() +
  theme(axis.text         = element_text(colour="gray40")) +
  theme(axis.title        = element_text(colour="gray40")) +
  theme(panel.border      = element_rect(colour="gray80")) +
  theme(axis.ticks        = element_line(colour="gray80")) +
  theme(axis.ticks.length = grid::unit(0, "cm"))


# status_levels <- c("0" = "Due Date", "1" = "Scheduled", "2" = "Confirmed", "3" = "Cancelled", "4" = "No Show")
# icons_status <- c("Due Date"="bicycle", "Scheduled"="book", "Confirmed"="bug", "Cancelled"="bolt", "No Show"="ban")
# order_status  <- as.integer(names(status_levels)); names(order_status) <- status_levels


# ---- load-data -----------------------------------
# if( file.exists(pathUpcomingScheduleServerOutside) ) {
#   pathUpcomingSchedule <- pathUpcomingScheduleServerOutside  
# } else if( file.exists(pathUpcomingScheduleServerInside) ) {
#   pathUpcomingSchedule <- pathUpcomingScheduleServerInside  
# } else {
path_input <- path_input_repo
# }

ds_visit <- readr::read_rds(path_input) 

# ---- tweak-data -----------------------------------

# Define a server for the Shiny app  -----------------------------------
function(input, output) {
  
  filter_visit <- function( start_date=as.Date("2000-01-01"), stop_date=as.Date("2100-12-12")) {# Filter schedule based on selections
    d <- ds_visit
    
    # if( nrow(d)>0 & input$regionTag != "All" )
    #   d <- d[d$RegionTag==input$regionTag, ]
    # 
    # d <- d[(start_date<=d$ActivityMonth) & (d$ActivityMonth<=stop_date), ]
    return( d )
  }  


  output$visit_table <- DT::renderDataTable({
    d <- filter_visit(start_date=input$date_range[1], stop_date=input$date_range[2])
    
    # d <- d %>%
    #   dplyr::mutate(
    #     # ActivityMonth = strftime(ActivityMonth, "%Y-%m"),
    #     # VisitsPerInfantNeed = round(VisitsPerInfantNeed, 3)
    #   ) %>%
    #   dplyr::select(
    #     # -WicNeedPopInfant
    #   ) %>%
    #   dplyr::rename_(
    #     # "Region Tag" = "RegionTag",
    #     # "Month" = "ActivityMonth",
    #     # "Visit Count" = "VisitCount",
    #     # "Visits per Need" = "VisitsPerInfantNeed"
    #   )
    
    DT::datatable(
      d, 
      rownames = FALSE,
      style    = 'bootstrap', 
      options  = list(
        searching  = FALSE,
        sort       = FALSE,
        language   = list(emptyTable="--No data to populate this table.  Consider using less restrictive filters.--")#,
        # rowCallback = JS( 
        #   'function(row, data) {
        #     if (data[3].indexOf("Interview") > -1 ) {
        #       $("td", row).addClass("interviewRow"); 
        #       $("td:eq(3)", row).addClass("interviewEvent"); 
        #     } else if (data[3].indexOf("Reminder") > -1 ) {
        #       $("td:eq(3)", row).addClass("reminderEvent"); 
        #     }
        #   }'
        # )
      ),
      class        = 'table-striped table-condensed table-hover', #Applies Bootstrap styles, see http://getbootstrap.com/css/#tables
      escape       = FALSE
    ) #%>%
    # formatStyle(
    #   columns = 'Status', 
    #   color = styleEqual(names(palette_status), palette_status)
    # )
  })  
  # output$GraphVisitCount <- renderPlot({
  #   d <- FilterMonth(start_date=input$dateRange[1], stop_date=input$dateRange[2])
  #   highlightedRegions <- input$regionTag
  #   ActivityEachMonth(d, responseVariable="VisitCount", highlightedRegions=highlightedRegions, mainTitle="Visits Each Month (per region)") + 
  #     scale_y_continuous(labels=comma_format())  
  # })
 
  output$table_file_info <- renderText({
    return( paste0(
      '<h3>Details</h3>',
      "<table border='0' cellspacing='1' cellpadding='2' >",
      "<tr><td>Data Path:<td/><td>&nbsp;", path_input, "<td/><tr/>",
      "<tr><td>Data Last Modified:<td/><td>&nbsp;", file.info(path_input)$mtime, "<td/><tr/>",
      "<tr><td>App Restart Time:<td/><td>&nbsp;", file.info("restart.txt")$mtime, "<td/><tr/>",
      "<table/>"
    ) )
  })
}
