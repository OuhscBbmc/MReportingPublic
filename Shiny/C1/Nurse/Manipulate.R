# knitr::stitch_rmd(script="./manipulation/groom_cars.R", output="./manipulation/stitched_output/groom_cars.md")

#These first few lines run only when the file is run in RStudio, !!NOT when an Rmd/Rnw file calls it!!
rm(list=ls(all=TRUE))  #Clear the variables from previous runs.

############################
## @knitr load_sources

############################
## @knitr load_packages
requireNamespace("plyr", quietly=TRUE)
requireNamespace("dplyr", quietly=TRUE)
requireNamespace("scales", quietly=TRUE)
# requireNamespace("readr", quietly=TRUE)
# library(ggplot2)

############################
## @knitr declare_globals
pathInputVisit <- "./DataPhiFreeCache/Raw/C1/c1-visit.csv"
pathOutput <- "./DataPhiFree/Derived/C1/C1NurseMonth.rds"

FillInMonthsForGroups <- function( dsToFillIn, groupVariable, monthVariable, dvNamesToFillWIthZeroes, startMonth, stopMonth ){
  possibleMonths <- seq.Date(from=startMonth, to=stopMonth, by="month")
  # browser()
  groupLevels <- sort(unique(dsToFillIn[, groupVariable]))
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

############################
## @knitr tweak_data

ds <- dplyr::rename_(ds,
                     "ProgramUniqueID"   = "Program.Unique.Identifier"
                     , "EntitySiteID"    = "Entity.Site.Identifier"
                     , "CaseNumber"      = "Case.Number"
                     , "PhocisID"        = "PHOCIS.ID"
                     , "StaffSiteID"     = "Staff.Site.Identifier"
                     , "CaseWorkerName"    = "Case.Worker"
                     , "DismissalReason" = "Reason.For.Dismissal"
                     , "ProgramName"     = "Program.Name"
                     , "VisitDate"        = "Date.Taken_208"
                     , "OriginalDate"    = "Originally.scheduled.for_9397"
                     , "MileageTotal"    = "Total.Miles_9404"
                     , "OSIIS.ID"        = "OSIIS.ID"
)
sapply(ds, class)
sapply(ds, function(x) sum(is.na(x)))
sapply(ds, function(x) sum(nchar(x)==0))

# Add a unique identifier
# ds$CarID <- seq_len(nrow(ds))

ds$VisitDate <- as.Date(ds$VisitDate, format="%Y/%m/%d")
ds$OriginalDate <- as.Date(ds$OriginalDate, format="%Y/%m/%d")


## Drop non-C1 visits.
isC1 <- grep("^C1-.+$", ds$ProgramName)
message("There are ", scales::comma(length(isC1)), " C1 Visits (out of ", scales::comma(nrow(ds)), " MIECHV Visits).  Non-C1 visits will be dropped.")
ds <- ds[isC1, ]

length(unique(ds$EntitySiteID))
############################
## @knitr erase_artifacts

############################
## @knitr save_to_disk
saveRDS(ds, file=pathOutput, compress="xz")
