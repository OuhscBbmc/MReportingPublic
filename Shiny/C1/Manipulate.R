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
pathInputVisit <- "./DataPhiFreeCache/Raw/C1/c1-visit.csv"
pathInputCountyTagged <- "./DataPhiFreeCache/Derived/C1/CountyTag.csv"
pathOutput <- "./DataPhiFree/Derived/C1/C1CountyMonth.rds"

rangeDate <- c(as.Date("2015-01-01"), Sys.Date())

FillInMonthsForGroups <- function( dsToFillIn, groupVariable, monthVariable, dvNamesToFillWIthZeroes, dateRange ){
  possibleMonths <- seq.Date(from=dateRange[1], to=dateRange[2], by="month")
  groupLevels <- sort(unique(as.data.frame(dsToFillIn)[, groupVariable]))
  lubridate::day(possibleMonths) <- 15L
  dsEmpty <- expand.grid(Month=possibleMonths, Group=groupLevels, stringsAsFactors=FALSE) 
  
  dsToFillIn <-  merge(x=dsToFillIn, y=dsEmpty, by.x=c(groupVariable, monthVariable), by.y=c("Group", "Month"), all.y=TRUE)
  for( dvName in dvNamesToFillWIthZeroes ) {
    dsToFillIn[is.na(dsToFillIn[, dvName]), dvName] <- 0
  }
  return( dsToFillIn )
}
############################
## @knitr load_data
ds <- read.csv(pathInputVisit, stringsAsFactors=FALSE)
dsCountyLookup <- read.csv(pathInputCountyTagged, stringsAsFactors=FALSE)

############################
## @knitr tweak_data

ds <- dplyr::rename_(ds,
                     "CountyID"          = "Program.Unique.Identifier"
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
sapply(ds, class)
sapply(ds, function(x) sum(is.na(x)))
sapply(ds, function(x) sum(nchar(iconv(x))==0))


# Add a unique identifier
# ds$CarID <- seq_len(nrow(ds))

ds$VisitDate <- as.Date(ds$VisitDate, format="%Y/%m/%d")
ds$OriginalDate <- as.Date(ds$OriginalDate, format="%Y/%m/%d")
ds$ActivityMonth <- ds$VisitDate
lubridate::day(ds$ActivityMonth) <- 15L

## Drop non-C1 visits.
isC1 <- grep("^C1-.+$", ds$ProgramName)
message("There are ", scales::comma(length(isC1)), " C1 Visits (out of ", scales::comma(nrow(ds)), " MIECHV Visits).  Non-C1 visits will be dropped.")
ds <- ds[isC1, ]

message("There are ", scales::comma(sum(is.na(ds$VisitDate))), " visits missing dates (out of ", scales::comma(nrow(ds)), " MIECHV Visits).  These records will be dropped.")
ds <- ds[!is.na(ds$VisitDate), ]

tooEarly <- (ds$VisitDate < rangeDate[1])
# write.csv(ds[tooEarly, ], "./DataPhiFreeCache/Derived/C1/C1TooEarly.csv", row.names=F)
message("There are ", scales::comma(sum(tooEarly)), " visits before ", rangeDate[1], " that will be dropped.")
ds <- ds[!tooEarly, ]

tooLate <- (rangeDate[2] < ds$VisitDate)
# write.csv(ds[tooLate, ], "./DataPhiFreeCache/Derived/C1/C1TooLate.csv", row.names=F)
message("There are ", scales::comma(sum(tooLate)), " visits after ", rangeDate[2], " that will be dropped.")
ds <- ds[!tooLate, ]

length(unique(ds$EntitySiteID))
# rangeDate <- range(ds$VisitDate)
rm(isC1, tooEarly, tooLate)
############################
## @knitr collapse_county_month
dsCountyMonth <- ds %>%
  dplyr::group_by(
    CountyID,
    ActivityMonth
  ) %>%
  dplyr::summarise(
    VisitCount = length(ActivityMonth)
  )

dsCountyMonth <- FillInMonthsForGroups(dsCountyMonth, "CountyID", "ActivityMonth", "VisitCount", rangeDate)
# function( dsToFillIn, groupVariable, monthVariable, dvNamesToFillWIthZeroes, dateRange ){
# table(ds$ActivityMonth)
############################
## @knitr join_tag
dsCountyMonth <- dsCountyMonth %>%
  dplyr::left_join(dsCountyLookup) %>%
  dplyr::select_(
    "CountyTag", 
    "ActivityMonth", 
    "VisitCount"
  )


############################
## @knitr save_to_disk
message("The C1 county-month summary contains ", length(unique(dsCountyMonth$CountyID)), " different counties and ", length(unique(dsCountyMonth$ActivityMonth)), " different months.")
saveRDS(dsCountyMonth, file=pathOutput, compress="xz")
