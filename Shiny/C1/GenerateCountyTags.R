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
pathOutputLookup <- "./DataPhiFree/Derived/C1/CountyLookup.csv"
pathOutputCachedTagged <- "./DataPhiFreeCache/Derived/C1/CountyTag.csv"

#urn=c(0:9, letters)
DrawTag <- function( tagLength=3L, urn=letters ) {
  paste(sample(urn, size=tagLength, replace=T), collapse="")
}

############################
## @knitr load_data
ds <- read.csv(pathInputVisit, stringsAsFactors=FALSE)

############################
## @knitr tweak_data

ds <- dplyr::rename_(ds,
  "CountyID"      = "Program.Unique.Identifier"
  , "ProgramName" = "Program.Name"
)

## Drop non-C1 visits.
isC1 <- grep("^C1-.+$", ds$ProgramName)
message("There are ", scales::comma(length(isC1)), " C1 Visits (out of ", scales::comma(nrow(ds)), " MIECHV Visits).  Non-C1 visits will be dropped.")
ds <- ds[isC1, ]

ds$CountyName <- gsub(" County", "", ds$ProgramName)
# table(ds$CountyName)

ds$CountyName <- gsub("( CHD| CCHD)?", "", ds$CountyName)
# table(ds$CountyName)
ds$CountyName <- gsub("^C1-([A-Za-z ]+)", "\\1", ds$CountyName)
# table(ds$CountyName)

rm(isC1)
############################
## @knitr collapse_county_month
dsCounty <- ds %>%
  dplyr::group_by(
    CountyID,
    CountyName,
    ProgramName
  ) %>%
  dplyr::summarise(
    CountyTag = NA_character_
  )

############################
## @knitr assign_tags
dsCountyTagged <- dsCounty
dsCountyTagged$CountyTag <- sapply(rep(3L, nrow(dsCountyTagged)), DrawTag)
head(dsCountyTagged$CountyTag)
############################
## @knitr save_to_disk
# message("The C1 county-month summary contains ", length(unique(dsCounty_month$CountyID)), " different counties and ", length(unique(dsCounty_month$VisitMonth)), " different months.")
write.csv(dsCounty, file=pathOutputLookup, row.names=F)
write.csv(dsCountyTagged, file=pathOutputCachedTagged, row.names=F)
