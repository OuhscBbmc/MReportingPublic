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
dsReport <- dbReadTable(cnn, "vewReport")

# dbListTables(cnn)
isClosed <- dbDisconnect(cnn, quietly=T)

#####################################
## @knitr TweakData

#####################################
## @knitr Report
projectID <- 1L
dsAimProject <- dsAim[dsAim$ProjectID==projectID, ]

for( aimID in dsAimProject$AimID ) {
  dsAimSlice <- dsAimProject[dsAimProject$AimID==aimID, ]
  cat("##", dsAimSlice$NamePretty, "\n")
  cat(dsAimSlice$Description, "\n\n")
  
  dsGoalAim <- dsGoal[dsGoal$AimID==aimID, ] 
  for( goalID in dsGoalAim$GoalID) {
    dsGoalSlice <- dsGoalAim[dsGoalAim$GoalID==goalID, ]
    cat("**", dsGoalSlice$SubaimNameShort, ": ", dsGoalSlice$Description, "**\n\n", sep="")
    
    
    dsReportGoal <- dsReport[dsReport$GoalID==goalID, ]
    
  }
}
