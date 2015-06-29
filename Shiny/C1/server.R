# LoadPackages  -----------------------------------
library(shiny)
library(htmlwidgets)
library(magrittr)
library(scales)
library(ggplot2)
requireNamespace("grid")
requireNamespace("DT")

# DeclareGlobals  -----------------------------------
# pathUpcomingScheduleServerOutside <- "//bbmc-shiny-public/Anonymous/MReportingPublic/UpcomingSchedule.csv"
# pathUpcomingScheduleServerInside <- "/var/shinydata/MReportingPublic/UpcomingSchedule.csv"
# pathC1CountyMonthRepo <- "../.././DataPhiFree/Derived/C1/C1CountyMonth.rds"
pathC1RegionMonthRepo <- "../.././DataPhiFree/Derived/C1/C1RegionMonth.rds"

#Define some common cosmetics for the report.
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


ActivityEachMonth <- function( dsPlot, responseVariable, 
  monthVariable="ActivityMonth", groupVariable="RegionTag", colorVariable=groupVariable, 
  highlightedRegions = character(0),
  # highlightedRegions="ftj",
  mainTitle=NULL, xTitle=NULL, yTitle=NULL, baseSize=8, palette=NULL ) {
  # library(mgcv, quietly=TRUE) #For the Generalized Additive Model that smooths the longitudinal graphs.
 
  g <- ggplot(dsPlot, aes_string(x=monthVariable, y=responseVariable, colour=colorVariable, group=groupVariable))
  g <- g + aes(ymin=0)
  g <- g + geom_boxplot(aes_string(group=monthVariable), color=NA, fill="gray50", outlier.colour=NA, na.rm=TRUE, width=3, alpha=.3)
  g <- g + geom_line(stat="identity", alpha=.5)
  g <- g + geom_point(stat="identity", shape=21, alpha=.5)
  # g <- g + geom_hline(yintercept=median(dsPlot[, responseVariable]), color="gray50")
  # g <- g + geom_smooth(aes(group=1), method="gam", formula=y ~ s(x, bs = "cs"), color="gray30", na.rm=TRUE)
  g <- g + scale_x_date(breaks="1 month", labels=date_format("%Y\n%b"))

  if( (highlightedRegions != "All") & (length(highlightedRegions)==1) ) {
    dsHighlight <- dsPlot[dsPlot$RegionTag %in% highlightedRegions, ]
    dsLabelLeft <- dsHighlight[dsHighlight[, monthVariable]==min(dsHighlight[, monthVariable], na.rm=T), ]
    dsLabelRight <- dsHighlight[dsHighlight[, monthVariable]==max(dsHighlight[, monthVariable], na.rm=T), ]

    g <- g + geom_text(mapping=aes_string(label=colorVariable), data=dsLabelLeft, size=5, hjust=1.4) #Left endpoint
    g <- g + geom_text(mapping=aes_string(label=colorVariable), data=dsLabelRight, size=5, hjust=-.4) #Right endpoint   
    g <- g + geom_line(data=dsHighlight, stat="identity", alpha=1, size=2, na.rm=TRUE)
  }
  
#   if( !is.null(palette) ) 
#     g <- g + scale_color_manual(values=palette)	
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
pathC1RegionMonth <- pathC1RegionMonthRepo
# }

# dsC1RegionMonth <- readRDS(pathC1CountyMonth) 
dsC1RegionMonth <- readRDS(pathC1RegionMonth) 

# TweakData -----------------------------------

# Define a server for the Shiny app  -----------------------------------
function(input, output) {
  
  FilterRegionMonth <- function( start_date=as.Date("2000-01-01"), stop_date=as.Date("2100-12-12")) {# Filter schedule based on selections
    d <- dsC1RegionMonth
    
    if( nrow(d)>0 & input$regionTag != "All" )
      d <- d[d$RegionTag==input$regionTag, ]
   
    d <- d[(start_date<=d$ActivityMonth) & (d$ActivityMonth<=stop_date), ]
    return( d )
  }  
  FilterMonth <- function( start_date=as.Date("2000-01-01"), stop_date=as.Date("2100-12-12")) {# Filter schedule based on selections
    d <- dsC1RegionMonth
    d <- d[(start_date<=d$ActivityMonth) & (d$ActivityMonth<=stop_date), ]
    return( d )
  }

  output$ScheduleTablePast <- DT::renderDataTable({
    d <- FilterRegionMonth(start_date=input$dateRange[1], stop_date=input$dateRange[2])
    
    d <- d %>%
      dplyr::mutate(
        ActivityMonth = strftime(ActivityMonth, "%Y-%m"),
        VisitsPerInfantNeed = round(VisitsPerInfantNeed, 3)
      ) %>%
      dplyr::select(
        -WicNeedPopInfant
      ) %>%
      dplyr::rename_(
        "Region Tag" = "RegionTag",
        "Month" = "ActivityMonth",
        "Visit Count" = "VisitCount",
        "Visits per Need" = "VisitsPerInfantNeed"
      )
    
    DT::datatable(
      d, 
      rownames = FALSE,
      style = 'bootstrap', 
      options = list(
        searching = FALSE,
        sort = FALSE,
        language = list(emptyTable="--No data to populate this table.  Consider using less restrictive filters.--")#,
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
      class = 'table-striped table-condensed table-hover', #Applies Bootstrap styles, see http://getbootstrap.com/css/#tables
      escape = FALSE
    ) #%>%
    # formatStyle(
    #   columns = 'Status', 
    #   color = styleEqual(names(palette_status), palette_status)
    # )
  })  
  output$GraphVisitCount <- renderPlot({
    d <- FilterMonth(start_date=input$dateRange[1], stop_date=input$dateRange[2])
    highlightedRegions <- input$regionTag
    ActivityEachMonth(d, responseVariable="VisitCount", highlightedRegions=highlightedRegions, mainTitle="Visits Each Month (per region)") + 
      scale_y_continuous(labels=comma_format())  
  })
  output$GraphVisitPerNeed <- renderPlot({
    d <- FilterMonth(start_date=input$dateRange[1], stop_date=input$dateRange[2])
    highlightedRegions <- input$regionTag
    ActivityEachMonth(d, responseVariable="VisitsPerInfantNeed", highlightedRegions=highlightedRegions, mainTitle="Visits Each Month per WIC Need (per region)") + 
      scale_y_continuous(labels=percent_format())  
  })
  output$table_file_info <- renderText({
    return( paste0(
      '<h3>Details</h3>',
      "<table border='0' cellspacing='1' cellpadding='2' >",
      "<tr><td>Data Path:<td/><td>&nbsp;", pathC1RegionMonth, "<td/><tr/>",
      "<tr><td>Data Last Modified:<td/><td>&nbsp;", file.info(pathC1RegionMonth)$mtime, "<td/><tr/>",
      "<tr><td>App Restart Time:<td/><td>&nbsp;", file.info("restart.txt")$mtime, "<td/><tr/>",
      "<table/>"
    ) )
  })
}
