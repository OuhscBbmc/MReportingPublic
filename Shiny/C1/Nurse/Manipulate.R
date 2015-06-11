# knitr::stitch_rmd(script="./manipulation/groom_cars.R", output="./manipulation/stitched_output/groom_cars.md")

#These first few lines run only when the file is run in RStudio, !!NOT when an Rmd/Rnw file calls it!!
rm(list=ls(all=TRUE))  #Clear the variables from previous runs.

############################
## @knitr load_sources

############################
## @knitr load_packages
requireNamespace("plyr", quietly=TRUE)
requireNamespace("dplyr", quietly=TRUE)
# requireNamespace("readr", quietly=TRUE)
# library(ggplot2)

############################
## @knitr declare_globals
pathInputVisit <- "./DataPhiFreeCache/Raw/C1/c1-visit.csv"
pathOutput <- "./DataPhiFree/Derived/C1/C1NurseMonth.rds"

############################
## @knitr load_data
ds <- read.csv(pathInputVisit, stringsAsFactors=FALSE)

ds <- dplyr::rename_(ds,
                    "ProgramUniqueID"   = "Program.Unique.Identifier"
                    , "EntitySiteID"    = "Entity.Site.Identifier"
                    , "CaseNumber"      = "Case.Number"
                    , "PhocisID"        = "PHOCIS.ID"
                    , "StaffSiteID"     = "Staff.Site.Identifier"
                    , "CaseWorkerID"    = "Case.Worker"
                    , "DismissalReason" = "Reason.For.Dismissal"
                    , "ProgramName"     = "Program.Name"
                    , "OSIIS.ID"        = "OSIIS.ID"
                    )

############################
## @knitr tweak_data
# Add a unique identifier
# ds$CarID <- seq_len(nrow(ds))


############################
## @knitr erase_artifacts

############################
## @knitr save_to_disk
saveRDS(ds, file=pathOutput, compress="xz")
