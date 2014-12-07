library(shiny)
library(ggplot2)
library(grid)


#####################################
#' DeclareGlobals
pathUpcomingSchedule <- "./DataPhiFreeCache/UpcomingSchedule.csv"
redcap_version <- "5.11.3"
project_id <- 35L

reportTheme <- theme_bw() +
  theme(axis.text = element_text(colour="gray40")) +
  theme(axis.title = element_text(colour="gray40")) +
  theme(panel.border = element_rect(colour="gray80")) +
  theme(axis.ticks = element_line(colour="gray80")) +
  theme(axis.ticks.length = grid::unit(0, "cm"))

#####################################
#' LoadData
ds <- read.csv(pathUpcomingSchedule, stringsAsFactors=FALSE) 

#####################################
#' TweakData
ds$event_date <- as.Date(ds$event_date)
ds$event_status <- factor(ds$event_status)

# ds$event_contact <- 
des <- unique(ds$event_description)
ds$event_type <- gsub("^.+?(Reminder Call|Interview|Contact)$", "\\1", ds$event_description)

#####################################
#' Graph
ggplot(ds, aes(x=event_date, color=event_status)) +
  geom_line(stat="bin", binwidth=1) +
  scale_color_brewer(palette="Dark2") + 
  facet_grid(event_type ~ group_name, scales="free_y") +
  reportTheme +
  theme(legend.position="top") +
  theme(axis.text.x = element_text(angle=90, hjust=1)) +
  labs(x="Date", y="Events per Day")

