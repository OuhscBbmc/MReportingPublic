# knitr::stitch_rmd(script="./manipulation/groom_cars.R", output="./manipulation/stitched_output/groom_cars.md")

#These first few lines run only when the file is run in RStudio, !!NOT when an Rmd/Rnw file calls it!!
rm(list=ls(all=TRUE))  #Clear the variables from previous runs.

############################
## @knitr load_sources

############################
## @knitr load_packages
library(magrittr)
requireNamespace("dplyr", quietly=TRUE)
requireNamespace("scales", quietly=TRUE)
requireNamespace("lubridate", quietly=TRUE)
requireNamespace("readr", quietly=TRUE)
# library(ggplot2)

############################
## @knitr declare_globals
pathInputVisit <- "./DataPhiFreeCache/Raw/C1/c1-visit.csv"
pathInputCountyTagged <- "./DataPhiFreeCache/Derived/C1/CountyTag.csv"
pathInputRegionTagged <- "./DataPhiFreeCache/Derived/C1/RegionTag.csv"
# pathInputCountyCharacteristics <- "./DataPhiFree/Raw/CountyCharacteristics.csv"
pathOutputCounty <- "./DataPhiFree/Derived/C1/C1CountyMonth.rds"
pathOutputRegion <- "./DataPhiFree/Derived/C1/C1RegionMonth.rds"

defaultDayOfMonth <- 2L

rangeDate <- c(as.Date("2015-01-01"), Sys.Date())

FillInMonthsForGroups <- function( dsToFillIn, groupVariable, monthVariable, dvNamesToFillWIthZeroes, dateRange ){
  possibleMonths <- seq.Date(from=dateRange[1], to=dateRange[2], by="month")
  groupLevels <- sort(unique(as.data.frame(dsToFillIn)[, groupVariable]))
  lubridate::day(possibleMonths) <- defaultDayOfMonth
  dsEmpty <- expand.grid(Month=possibleMonths, Group=groupLevels, stringsAsFactors=FALSE) 
  
  dsToFillIn <-  merge(x=dsToFillIn, y=dsEmpty, by.x=c(groupVariable, monthVariable), by.y=c("Group", "Month"), all.y=TRUE)
  for( dvName in dvNamesToFillWIthZeroes ) {
    dsToFillIn[is.na(dsToFillIn[, dvName]), dvName] <- 0
  }
  return( dsToFillIn )
}
############################
## @knitr load_data
dsVisit <- read.csv(pathInputVisit, stringsAsFactors=FALSE)
dsCountyTag <- readr::read_csv(pathInputCountyTagged)
dsRegionTag <- readr::read_csv(pathInputRegionTagged)
# dsCountyCharacteristics <- read.csv(pathInputCountyCharacteristics, stringsAsFactors=FALSE)

############################
## @knitr tweak_data

dsVisit <- dplyr::rename_(dsVisit,
  "CountyEtoID"       = "Program.Unique.Identifier"
  , "EntitySiteID"    = "Entity.Site.Identifier"
  , "CaseNumber"      = "Case.Number"
  , "PhocisID"        = "PHOCIS.ID"
  , "StaffSiteID"     = "Staff.Site.Identifier"
  , "CaseWorkerName"  = "Case.Worker"
  , "DismissalReason" = "Reason.For.Dismissal"
  , "ProgramName"     = "Program.Name"
  , "VisitDate"       = "Date.Taken_208"
  , "OriginalDate"    = "Originally.scheduled.for_9397"
  , "MileageTotal"    = "Total.Miles_9404"
  , "OSIIS.ID"        = "OSIIS.ID"
)
sapply(dsVisit, class)
sapply(dsVisit, function(x) sum(is.na(x)))
sapply(dsVisit, function(x) sum(nchar(iconv(x))==0))


# Add a unique identifier
# dsVisit$CarID <- seq_len(nrow(dsVisit))

dsVisit$VisitDate <- as.Date(dsVisit$VisitDate, format="%Y/%m/%d")
dsVisit$OriginalDate <- as.Date(dsVisit$OriginalDate, format="%Y/%m/%d")
dsVisit$ActivityMonth <- dsVisit$VisitDate
lubridate::day(dsVisit$ActivityMonth) <- defaultDayOfMonth

## Drop non-C1 visits.
isC1 <- grep("^C1-.+$", dsVisit$ProgramName)
message("There are ", scales::comma(length(isC1)), " C1 Visits (out of ", scales::comma(nrow(dsVisit)), " MIECHV Visits).  Non-C1 visits will be dropped.")
dsVisit <- dsVisit[isC1, ]

message("There are ", scales::comma(sum(is.na(dsVisit$VisitDate))), " visits missing dates (out of ", scales::comma(nrow(dsVisit)), " MIECHV Visits).  These records will be dropped.")
dsVisit <- dsVisit[!is.na(dsVisit$VisitDate), ]

tooEarly <- (dsVisit$VisitDate < rangeDate[1])
# write.csv(dsVisit[tooEarly, ], "./DataPhiFreeCache/Derived/C1/C1TooEarly.csv", row.names=F)
message("There are ", scales::comma(sum(tooEarly)), " visits before ", rangeDate[1], " that will be dropped.")
dsVisit <- dsVisit[!tooEarly, ]

tooLate <- (rangeDate[2] < dsVisit$VisitDate)
# write.csv(dsVisit[tooLate, ], "./DataPhiFreeCache/Derived/C1/C1TooLate.csv", row.names=F)
message("There are ", scales::comma(sum(tooLate)), " visits after ", rangeDate[2], " that will be dropped.")
dsVisit <- dsVisit[!tooLate, ]

length(unique(dsVisit$EntitySiteID))
# rangeDate <- range(dsVisit$VisitDate)
rm(isC1, tooEarly, tooLate)

############################
## @knitr join_tag
dsVisit <- dsVisit %>%
  dplyr::left_join(
    dsCountyTag %>% 
      dplyr::select_("CountyEtoID", "RegionTag"),
    by="CountyEtoID") 

############################
## @knitr collapse_region_month
dsRegionMonth <- dsVisit %>%
  dplyr::group_by(
    RegionTag, #RegionID,
    ActivityMonth
  ) %>%
  dplyr::summarise(
    VisitCount = length(ActivityMonth)
  )

dsRegionMonth <- FillInMonthsForGroups(dsRegionMonth, "RegionTag", "ActivityMonth", c("VisitCount"), rangeDate)

# Pull in WIC estimate of need.
dsRegionMonth <- dsRegionMonth %>%
  dplyr::left_join(
    dsRegionTag %>% 
      dplyr::select_("RegionTag", "WicNeedPopInfant"),
    by="RegionTag") 

if( any(is.na(dsRegionMonth$WicNeedPopInfant)) )
  stop("At least one Region was not correctly joined to its WIC Need.")

dsRegionMonth$VisitsPerInfantNeed <- dsRegionMonth$VisitCount / dsRegionMonth$WicNeedPopInfant

############################
## @knitr save_to_disk
# message("The C1 county-month summary contains ", length(unique(dsCountyMonth$CountyTag)), " different counties and ", length(unique(dsCountyMonth$ActivityMonth)), " different months.")
# saveRDS(dsCountyMonth, file=pathOutputCounty, compress="xz")

message("The C1 region-month summary contains ", length(unique(dsRegionMonth$RegionTag)), " different regions and ", length(unique(dsRegionMonth$ActivityMonth)), " different months.")
saveRDS(dsRegionMonth, file=pathOutputRegion, compress="xz")
