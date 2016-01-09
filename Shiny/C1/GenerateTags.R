# knitr::stitch_rmd(script="./manipulation/groom_cars.R", output="./manipulation/stitched_output/groom_cars.md")

#These first few lines run only when the file is run in RStudio, !!NOT when an Rmd/Rnw file calls it!!
rm(list=ls(all=TRUE))  #Clear the variables from previous runs.

############################
## @knitr load_sources

############################
## @knitr load_packages
library(magrittr)
requireNamespace("dplyr")
requireNamespace("scales")
requireNamespace("lubridate")
requireNamespace("readr")

############################
## @knitr declare_globals
set.seed(184)
pathInputVisit <- "./DataPhiFreeCache/Raw/C1/c1-visit.csv"
pathInputCountyCharacteristics <- "./DataPhiFree/Raw/CountyCharacteristics.csv"
pathOutputCachedCountyTagged <- "./DataPhiFreeCache/Derived/C1/CountyTag.csv"
pathOutputCachedRegionTagged <- "./DataPhiFreeCache/Derived/C1/RegionTag.csv"

DrawTag <- function( tagLength=3L, urn=letters ) { #urn=c(0:9, letters)
  paste(sample(urn, size=tagLength, replace=T), collapse="")
}

############################
## @knitr load_data
dsVisit <- read.csv(pathInputVisit, stringsAsFactors=FALSE)
dsCountyCharacteristics <- readr::read_csv(pathInputCountyCharacteristics)

############################
## @knitr tweak_data
dsVisit <- dplyr::rename_(dsVisit,
  "CountyEtoID"   = "Program.Unique.Identifier"
  , "ProgramName" = "Program.Name"
)

## Drop non-C1 visits.
isC1 <- grep("^C1-.+$", dsVisit$ProgramName)
message("There are ", scales::comma(length(isC1)), " C1 Visits (out of ", scales::comma(nrow(dsVisit)), " MIECHV Visits).  Non-C1 visits will be dropped.")
dsVisit <- dsVisit[isC1, ]

dsVisit$CountyName <- gsub(" County", "", dsVisit$ProgramName) # table(dsVisit$CountyName)

dsVisit$CountyName <- gsub("( CHD| CCHD)?", "", dsVisit$CountyName) # table(dsVisit$CountyName)
dsVisit$CountyName <- gsub("^C1-([A-Za-z ]+)", "\\1", dsVisit$CountyName) # table(dsVisit$CountyName)

dsVisit$CountyName <- ifelse(dsVisit$CountyName=="Mcclain", "McClain", dsVisit$CountyName)
dsVisit$CountyName <- ifelse(dsVisit$CountyName=="Leflore", "Le Flore", dsVisit$CountyName) # table(dsVisit$CountyName)
rm(isC1)

#Thin-out some variables.
dsCountyCharacteristics <- dsCountyCharacteristics %>%
  dplyr::select(
    CountyID,
    CountyName,
    RegionID = C1LeadNurseRegion,
    WicNeedPopInfant
  )

############################
## @knitr assign_tag_county
dsCounty <- dsVisit %>%
  dplyr::group_by(
    CountyEtoID,
    CountyName,
    ProgramName
  ) %>%
  dplyr::summarise(
    CountyTag = NA_character_
  )
dsCounty$CountyTag <- sapply(rep(3L, nrow(dsCounty)), DrawTag)
dsCounty <- dsCounty %>%
  dplyr::left_join(dsCountyCharacteristics, by="CountyName")

if( any(is.na(dsCounty$WicNeedPopInfant)) )
  stop("At least one county was not correctly joined to its WIC Need.")

# dput(dsCounty$CountyTag) #To hard-code into Shiny dropdown box. Numeric Order of ID.
# dput(sort(dsCounty$CountyTag)) #To hard-code into Shiny dropdown box. Alphabetical Order.
############################
## @knitr assign_tag_region
dsRegion <- dsCounty %>%
  dplyr::group_by(
    RegionID
  ) %>%
  dplyr::summarise(
    CountyNames = paste(CountyName, collapse=","),
    CountyIDs = paste(CountyID, collapse=","),
    CountyEtoIDs = paste(CountyEtoID, collapse=","),
    RegionTag = NA_character_,
    WicNeedPopInfant = sum(WicNeedPopInfant)
  )
dsRegion$RegionTag <- sapply(rep(2L, nrow(dsRegion)), DrawTag)

# dput(dsRegion$RegionTag) #To hard-code into Shiny dropdown box. Numeric Order of ID.
# dput(sort(dsRegion$RegionTag)) #To hard-code into Shiny dropdown box. Alphabetical Order.
############################
## @knitr backfill_region_id
dsCounty <- dsCounty %>%
  dplyr::left_join(
    dsRegion %>% 
      dplyr::select_("RegionID", "RegionTag"),
    by="RegionID") 

############################
## @knitr save_to_disk
# message("The C1 county-month summary contains ", length(unique(dsCounty_month$CountyID)), " different counties and ", length(unique(dsCounty_month$VisitMonth)), " different months.")
write.csv(dsCounty, file=pathOutputCachedCountyTagged, row.names=F)
write.csv(dsRegion, file=pathOutputCachedRegionTagged, row.names=F)
