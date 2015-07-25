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
pathInput <- "./PhiFreeDatasets/MiechvProgressTimeline.csv"
dateAxisPadding <- lubridate::days(15)
grayLight <- "gray70"
grayDark <- "gray40"

#####################################
## @knitr LoadData
ds <- read.csv(pathInput, stringsAsFactors=FALSE)

#####################################
## @knitr TweakData

ds$Date <- as.Date(ds$Date, format="%m/%d/%Y")
ds <- ds[order(ds$Date), ] #Make sure it's sorted
dateRange <- range(ds$Date)
yAxisRange <- dateRange + c(-1, 1) * dateAxisPadding

# ds$YmPretty <- strptime(ds$Date, format="%y")
ds$EventPretty <- paste(ds$Date, ds$Event)
ds$RankPosition <- seq.Date(from=dateRange[1], to=dateRange[2], length.out=nrow(ds))
#ds$Rank <- order(ds$Date)

#####################################
## @knitr Timeline
xPoint <- 0
xDate <- .3
xLabel <- .6
ggplot(ds, aes(x=xPoint, y=Date, label=EventPretty)) + 
  geom_segment(aes(xend=xDate, yend=RankPosition), color=grayLight) +
  geom_point(shape=21, size=4, color=grayDark, fill=grayLight, alpha=.5) +
  
  # geom_text(aes(x=xLabel, y=RankPosition), hjust=0) +
  geom_text(aes(x=xDate, y=RankPosition, label=Date), hjust=0, color=grayDark) +
  geom_text(aes(x=xLabel, y=RankPosition, label=Event), hjust=0) +
  
  scale_x_continuous(breaks=NULL) +
  coord_cartesian(xlim=c(xPoint-.05, 3), ylim=yAxisRange) +
  theme_bw() +
  theme(axis.text = element_text(colour="gray40")) +
  theme(axis.title = element_text(colour="gray40")) +
  theme(panel.border = element_blank()) +
  theme(panel.grid.major = element_line(colour="gray95", size = 2)) + 
  theme(axis.ticks.length = grid::unit(0, "cm")) +
  labs(x=NULL, y=NULL)

#####################################
## @knitr Table
kable(ds[, c("Date", "Event")])
