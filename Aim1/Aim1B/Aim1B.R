rm(list=ls(all=TRUE)) #Clear the memory of variables from previous run. This is not called by knitr, because it's above the first chunk.
#####################################
## @knitr LoadPackages
library(knitr, quietly=TRUE)
library(plyr, quietly=TRUE)
library(scales, quietly=TRUE) #For formating values in graphs
library(RColorBrewer, quietly=TRUE)
library(ggplot2, quietly=TRUE) #For graphing
library(lubridate, quietly=TRUE)

#####################################
## @knitr DeclareGlobals
path_input <- "./DataPhiFree/Raw/MiechvProgressTimeline.csv"
date_axis_padding <- lubridate::days(15)
gray_light <- "gray70"
gray_dark <- "gray40"

#####################################
## @knitr LoadData
ds <- read.csv(path_input, stringsAsFactors=FALSE)

#####################################
## @knitr TweakData

ds$date <- as.Date(ds$date, format="%m/%d/%Y")
ds <- ds[order(ds$date), ] #Make sure it's sorted
date_range <- range(ds$date)
yAxisRange <- date_range + c(-1, 1) * date_axis_padding

# ds$YmPretty <- strptime(ds$date, format="%y")
ds$event_pretty <- paste(ds$date, ds$event)
ds$rank_position <- seq.Date(from=date_range[1], to=date_range[2], length.out=nrow(ds))
#ds$Rank <- order(ds$date)

#####################################
## @knitr Timeline
x_point <- 0
x_date <- .3
x_label <- .6
ggplot(ds, aes(x=x_point, y=date, label=event_pretty)) + 
  geom_segment(aes(xend=x_date, yend=rank_position), color=gray_light) +
  geom_point(shape=21, size=4, color=gray_dark, fill=gray_light, alpha=.5) +
  
  # geom_text(aes(x=x_label, y=rank_position), hjust=0) +
  geom_text(aes(x=x_date, y=rank_position, label=date), hjust=0, color=gray_dark) +
  geom_text(aes(x=x_label, y=rank_position, label=event), hjust=0) +
  
  scale_x_continuous(breaks=NULL) +
  coord_cartesian(xlim=c(x_point-.05, 3), ylim=yAxisRange) +
  theme_bw() +
  theme(axis.text = element_text(colour="gray40")) +
  theme(axis.title = element_text(colour="gray40")) +
  theme(panel.border = element_blank()) +
  theme(panel.grid.major = element_line(colour="gray95", size = 2)) + 
  theme(axis.ticks.length = grid::unit(0, "cm")) +
  labs(x=NULL, y=NULL)

#####################################
## @knitr Table
kable(ds[, c("date", "event")])

#####################################
## @knitr ConvertToJson
library(jsonlite)
ds_json <- ds
ds_json$date <- strftime(ds_json$date, "%Y,%d,%m") 
jsonlite::toJSON(ds_json, pretty = TRUE)

