rm(list=ls(all=TRUE)) #Clear the memory of variables from previous run. This is not called by knitr, because it's above the first chunk.
#####################################
## @knitr LoadPackages
library(DBI)
library(knitr)

#####################################
## @knitr DeclareGlobals
options(show.signif.stars=F) #Turn off the annotations on p-values
path <- "./reports/report_index.sqlite3"

#####################################
## @knitr LoadData
cnn <- dbConnect(RSQLite::SQLite(), path)

dsAim <- dbReadTable(cnn, "tblAim")
dsGoal <- dbReadTable(cnn, "tblGoal")
dsReport <- dbReadTable(cnn, "tblReport")

dbListTables(cnn)
dbDisconnect(cnn)

#####################################
## @knitr TweakData

#####################################
## @knitr Report
projectID <- 1L
dsAimProject <- dsAim[dsAim$ProjectID==projectID, ]

for( aimID in dsAimProject$AimID ) {
  dsGoalAim <- dsGoal[dsGoal$AimID==aimID, ] 
  for( goalID in dsGoalAim$GoalID) {
    #TODO: link to junction table
#     dsReportGoal <- dsReport[dsReport$G]
    
  }
}
