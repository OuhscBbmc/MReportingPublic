# LoadPackages  -----------------------------------
library(shiny)
library(ggplot2)
#library(grid)
library(magrittr)

# DeclareGlobals  -----------------------------------
# pathUpcomingScheduleServerOutside <- "//bbmc-shiny-public/Anonymous/MReportingPublic/UpcomingSchedule.csv"
# pathUpcomingScheduleServerInside <- "/var/shinydata/MReportingPublic/UpcomingSchedule.csv"
pathC1CountyMonthRepo <- "../.././DataPhiFree/Derived/C1/C1CountyMonth.rds"


# reportTheme <- theme_bw() +
#   theme(axis.text = element_text(colour="gray40")) +
#   theme(axis.title = element_text(colour="gray40")) +
#   theme(panel.border = element_rect(colour="gray80")) +
#   theme(axis.ticks = element_line(colour="gray80")) +
#   theme(axis.ticks.length = grid::unit(0, "cm"))
# 
# move_to_last <- function(data, move) { #http://stackoverflow.com/questions/18339370
#   data[c(setdiff(names(data), move), move)]
# }
# 
# status_levels <- c("0" = "Due Date", "1" = "Scheduled", "2" = "Confirmed", "3" = "Cancelled", "4" = "No Show")
# icons_status <- c("Due Date"="bicycle", "Scheduled"="book", "Confirmed"="bug", "Cancelled"="bolt", "No Show"="ban")
# order_status  <- as.integer(names(status_levels)); names(order_status) <- status_levels

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
  set.seed(122)
  histdata <- rnorm(500)
  
  output$plot1 <- renderPlot({
    data <- histdata[seq_len(input$slider)]
    hist(data)
  })
}