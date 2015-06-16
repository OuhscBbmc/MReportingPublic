# knitr::stitch_rmd(script="./manipulation/groom_cars.R", output="./manipulation/stitched_output/groom_cars.md")

#These first few lines run only when the file is run in RStudio, !!NOT when an Rmd/Rnw file calls it!!
rm(list=ls(all=TRUE))  #Clear the variables from previous runs.

############################
## @knitr load_sources

############################
## @knitr load_packages
library(magrittr)
requireNamespace("plyr", quietly=TRUE)
requireNamespace("dplyr", quietly=TRUE)
requireNamespace("scales", quietly=TRUE)
requireNamespace("lubridate", quietly=TRUE)
# requireNamespace("readr", quietly=TRUE)
# library(ggplot2)

############################
## @knitr declare_globals
set.seed(184)
pathInputVisit <- "./DataPhiFreeCache/Raw/C1/c1-visit.csv"
pathInputCountyCharacteristics <- "./DataPhiFree/Raw/CountyCharacteristics.csv"
pathOutputLookup <- "./DataPhiFree/Derived/C1/CountyLookup.csv"
pathOutputCachedCountyTagged <- "./DataPhiFreeCache/Derived/C1/CountyTag.csv"
pathOutputCachedRegionTagged <- "./DataPhiFreeCache/Derived/C1/RegionTag.csv"

regions <- 1L:20L

#urn=c(0:9, letters)
DrawTag <- function( tagLength=3L, urn=letters ) {
  paste(sample(urn, size=tagLength, replace=T), collapse="")
}

############################
## @knitr load_data
dsVisit <- read.csv(pathInputVisit, stringsAsFactors=FALSE)
dsCountyCharacteristics <- read.csv(pathInputCountyCharacteristics, stringsAsFactors=FALSE)

############################
## @knitr tweak_data
dsVisit <- dplyr::rename_(dsVisit,
  "CountyID"      = "Program.Unique.Identifier"
  , "ProgramName" = "Program.Name"
)

## Drop non-C1 visits.
isC1 <- grep("^C1-.+$", dsVisit$ProgramName)
message("There are ", scales::comma(length(isC1)), " C1 Visits (out of ", scales::comma(nrow(dsVisit)), " MIECHV Visits).  Non-C1 visits will be dropped.")
dsVisit <- dsVisit[isC1, ]

dsVisit$CountyName <- gsub(" County", "", dsVisit$ProgramName)
# table(dsVisit$CountyName)

dsVisit$CountyName <- gsub("( CHD| CCHD)?", "", dsVisit$CountyName)
# table(dsVisit$CountyName)
dsVisit$CountyName <- gsub("^C1-([A-Za-z ]+)", "\\1", dsVisit$CountyName)
# table(dsVisit$CountyName)

dsVisit$CountyName <- ifelse(dsVisit$CountyName=="Mcclain", "McClain", dsVisit$CountyName)
dsVisit$CountyName <- ifelse(dsVisit$CountyName=="Leflore", "Le Flore", dsVisit$CountyName)
# table(dsVisit$CountyName)
rm(isC1)
############################
## @knitr collapse_county_month
dsCounty <- dsVisit %>%
  dplyr::group_by(
    CountyID,
    CountyName,
    ProgramName
  ) %>%
  dplyr::summarise(
    CountyTag = NA_character_
  )

############################
## @knitr assign_tag_county
dsCountyTagged <- dsCounty
dsCountyTagged$CountyTag <- sapply(rep(3L, nrow(dsCountyTagged)), DrawTag)
# head(dsCountyTagged$CountyTag)

# dput(dsCountyTagged$CountyTag) #To hard-code into Shiny dropdown box.
############################
## @knitr assign_tag_region
dsRegionTagged <- data.frame(
  RegionID = regions,
  RegionTag = sapply(rep(2L, length(regions)), DrawTag),
  stringsAsFactors = FALSE
)

# dput(dsRegionTagged$RegionTag) #To hard-code into Shiny dropdown box.
############################
## @knitr save_to_disk
# message("The C1 county-month summary contains ", length(unique(dsCounty_month$CountyID)), " different counties and ", length(unique(dsCounty_month$VisitMonth)), " different months.")
write.csv(dsCounty, file=pathOutputLookup, row.names=F)
write.csv(dsCountyTagged, file=pathOutputCachedCountyTagged, row.names=F)
write.csv(dsRegionTagged, file=pathOutputCachedRegionTagged, row.names=F)
