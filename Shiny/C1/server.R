# LoadPackages  -----------------------------------
library(shiny)
library(magrittr)
library(scales)
library(ggplot2)
requireNamespace("grid")

# DeclareGlobals  -----------------------------------
# pathUpcomingScheduleServerOutside <- "//bbmc-shiny-public/Anonymous/MReportingPublic/UpcomingSchedule.csv"
# pathUpcomingScheduleServerInside <- "/var/shinydata/MReportingPublic/UpcomingSchedule.csv"
pathC1CountyMonthRepo <- "../.././DataPhiFree/Derived/C1/C1CountyMonth.rds"

reportTheme <- theme_bw() +
  theme(axis.text         = element_text(colour="gray40")) +
  theme(axis.title        = element_text(colour="gray40")) +
  theme(panel.border      = element_rect(colour="gray80")) +
  theme(axis.ticks        = element_line(colour="gray80")) +
  theme(axis.ticks.length = grid::unit(0, "cm"))

# move_to_last <- function(data, move) { #http://stackoverflow.com/questions/18339370
#   data[c(setdiff(names(data), move), move)]
# }
# 
# status_levels <- c("0" = "Due Date", "1" = "Scheduled", "2" = "Confirmed", "3" = "Cancelled", "4" = "No Show")
# icons_status <- c("Due Date"="bicycle", "Scheduled"="book", "Confirmed"="bug", "Cancelled"="bolt", "No Show"="ban")
# order_status  <- as.integer(names(status_levels)); names(order_status) <- status_levels


ActivityEachMonth <- function( dsPlot, responseVariable, colorVariable=NULL, monthVariable="ActivityMonth", groupVariable="CountyTag", 
  mainTitle=NULL, xTitle=NULL, yTitle=NULL, baseSize=8, palette=NULL ) {
  # library(mgcv, quietly=TRUE) #For the Generalized Additive Model that smooths the longitudinal graphs.
 
  g <- ggplot(dsPlot, aes_string(x=monthVariable, y=responseVariable, colour=colorVariable, group=groupVariable))
  g <- g + aes(ymin=0)
  # g <- g + geom_boxplot(aes_string(group=monthVariable), outlier.colour=NA, na.rm=TRUE)
  #g <- g + geom_line(stat="identity", alpha=.5, na.rm=TRUE) 
  g <- g + geom_line(stat="identity", alpha=1)
  g <- g + geom_point(stat="identity", shape=21, alpha=.5)
  g <- g + geom_hline(yintercept=c(median(dsPlot[, responseVariable]), mean(dsPlot[, responseVariable])), color="gray50")
  # g <- g + geom_smooth(aes(group=1), method="gam", formula=y ~ s(x, bs = "cs"), color="gray30", na.rm=TRUE)
  # g <- g + geom_smooth(aes(group=1), method="gam", color="gray30", na.rm=TRUE)
  g <- g + scale_x_date(breaks="1 month", labels=date_format("%Y\n%b"))
  g <- g + scale_y_continuous(labels=comma_format())  
  if( !is.null(palette) ) 
    g <- g + scale_color_manual(values=palette)	
  g <- g + guides(colour="none")
  g <- g + labs(title=mainTitle, x=xTitle, y=yTitle)
  g <- g + reportTheme
  return( g )
}
# ActivityEachMonth(readRDS("./DataPhiFree/Derived/C1/C1CountyMonth.rds"), "VisitCount")


# LoadData -----------------------------------
# if( file.exists(pathUpcomingScheduleServerOutside) ) {
#   pathUpcomingSchedule <- pathUpcomingScheduleServerOutside  
# } else if( file.exists(pathUpcomingScheduleServerInside) ) {
#   pathUpcomingSchedule <- pathUpcomingScheduleServerInside  
# } else {
pathC1CountyMonth <- pathC1CountyMonthRepo
# }

dsC1CountyMonth <- readRDS(pathC1CountyMonth) 

# TweakData -----------------------------------

# Define a server for the Shiny app  -----------------------------------
function(input, output) {
  
  FilterCountyMonth <- function( start_date=as.Date("2000-01-01"), stop_date=as.Date("2100-12-12")) {# Filter schedule based on selections
    d <- dsC1CountyMonth
    
    if( nrow(d)>0 & input$countyTag != "All" )
      d <- d[d$CountyTag==input$countyTag, ]
   
    d <- d[(start_date<=d$ActivityMonth) & (d$ActivityMonth<=stop_date), ]
    return( d )
  }

  output$ScheduleTablePast <- renderDataTable({
    d <- FilterCountyMonth(start_date=input$dateRange[1], stop_date=input$dateRange[2])
    return( d )
  }, options = list(
    # lengthMenu = list(c(length(unique(dsItemProgress$item)), -1), c(length(unique(dsItemProgress$item)), 'All')),
    language = list(emptyTable="--<em>Please loosen the filter to populate this table.</em>--"),
    aoColumnDefs = list( #http://legacy.datatables.net/usage/columns
      # list(sClass="semihide", aTargets=-1),
      # list(sClass="session", aTargets=1:length(unique(dsItemProgress$item))),
      list(sClass="smallish", aTargets="_all")
    ),
    # columnDefs = list(list(targets = c(3, 4) - 1, searchable = FALSE)),
    searching = FALSE,
    paging    = TRUE,
    sort      = FALSE),
    escape    = TRUE #Change to 'FALSE' if you embed something like HTML links
  )   
  output$GraphActivity <- renderPlot({
    d <- FilterCountyMonth(start_date=input$dateRange[1], stop_date=input$dateRange[2])
    
    # d$group_name <- ifelse(is.na(d$group_name), "Missing", d$group_name)
    # d$group_name <- gsub("^(.+?)( County)$", "\\1", d$group_name)
    # 
    # if( input$county != "All" )
    #   d <- d[d$group_name==input$county, ]
    
    ActivityEachMonth(d, responseVariable="VisitCount", mainTitle="Visit Each Month (per county)")
  })
  output$table_file_info <- renderText({
    return( paste0(
      '<h3>Details</h3>',
      "<table border='0' cellspacing='1' cellpadding='2' >",
      "<tr><td>Data Path:<td/><td>&nbsp;", pathC1CountyMonth, "<td/><tr/>",
      "<tr><td>Data Last Modified:<td/><td>&nbsp;", file.info(pathC1CountyMonth)$mtime, "<td/><tr/>",
      "<tr><td>App Restart Time:<td/><td>&nbsp;", file.info("restart.txt")$mtime, "<td/><tr/>",
      "<table/>"
    ) )
  })
}
