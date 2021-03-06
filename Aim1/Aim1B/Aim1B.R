rm(list=ls(all=TRUE)) #Clear the memory of variables from previous run. This is not called by knitr, because it's above the first chunk.

# ---- load_packages --------------------------------------------------------------
library(knitr, quietly=TRUE)
library(ggplot2, quietly=TRUE) #For graphing
requireNamespace("lubridate")

# ---- declare_globals --------------------------------------------------------------
path_input <- "./DataPhiFree/Raw/MiechvProgressTimeline.csv"
# path_output <- "./DataPhiFree/Derived/MiechvProgressTimeline.json"
date_axis_padding <- lubridate::days(15)
gray_light <- "gray70"
gray_dark <- "gray40"

# ---- load_data --------------------------------------------------------------
ds <- read.csv(path_input, stringsAsFactors=FALSE)

# ---- tweak_data --------------------------------------------------------------
ds$date_start <- as.Date(ds$date_start, format="%m/%d/%Y")
ds$date_start_pretty <- strftime(ds$date_start, format="%Y<br/>%b %d")

ds <- ds[order(ds$date_start), ] #Make sure it's sorted
date_range <- range(ds$date_start)
yAxisRange <- date_range + c(-1, 1) * date_axis_padding

# ds$YmPretty <- strptime(ds$date_start, format="%y")
ds$headline_pretty <- paste(ds$date_start, ds$headline)
ds$rank_position <- seq.Date(from=date_range[1], to=date_range[2], length.out=nrow(ds))

ds <- ds[!(ds$type %in% c("title", "era")), ]

ds$media_url <- ifelse(is.na(ds$media_url), "", ds$media_url)
ds$media_caption <- ifelse(is.na(ds$media_caption), "", ds$media_caption)

ds$link_label <- ifelse(nchar(ds$media_caption)==0L, "Link", ds$media_caption)

ds$description <- paste0("<b>", ds$headline, "</b><br/>", ds$text)
ds$description <- ifelse(
  nchar(ds$media_url) == 0,
  ds$description,
  paste0(ds$description, " <a href='", ds$media_url, "'  target='_blank'>[", ds$link_label, "]</a>")
)

# ---- convert_to_json --------------------------------------------------------------
library(jsonlite)
ds_json <- ds
ds_json$date_start <- strftime(ds_json$date_start, "%Y,%m,%d") 
json <- jsonlite::toJSON(ds_json, pretty = T)
# jsonlite::stream_out(ds_json, file(tmp <- path_output), pretty = F)

# ---- timeline_ggplot --------------------------------------------------------------
x_point <- 0
x_date <- .3
x_label <- .6
ggplot(ds, aes(x=x_point, y=date_start, label=headline_pretty)) + 
  geom_segment(aes(xend=x_date, yend=rank_position), color=gray_light) +
  geom_point(shape=21, size=4, color=gray_dark, fill=gray_light, alpha=.5) +
  
  # geom_text(aes(x=x_label, y=rank_position), hjust=0) +
  geom_text(aes(x=x_date, y=rank_position, label=date_start), hjust=0, color=gray_dark) +
  geom_text(aes(x=x_label, y=rank_position, label=headline), hjust=0) +
  
  scale_x_continuous(breaks=NULL) +
  coord_cartesian(xlim=c(x_point-.05, 3), ylim=yAxisRange) +
  theme_bw() +
  theme(axis.text = element_text(colour="gray40")) +
  theme(axis.title = element_text(colour="gray40")) +
  theme(panel.border = element_blank()) +
  theme(panel.grid.major = element_line(colour="gray95", size = 2)) + 
  theme(axis.ticks.length = grid::unit(0, "cm")) +
  labs(x=NULL, y=NULL)

# ---- table --------------------------------------------------------------
knitr::kable(
  x         = ds[, c("date_start_pretty", "description")], 
  row.names = FALSE, 
  col.names = c("Date", "Description")
)
