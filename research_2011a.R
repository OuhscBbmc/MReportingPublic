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
dsReportJunction <- dbReadTable(cnn, "vewReport")

# dbListTables(cnn)
isClosed <- dbDisconnect(cnn, quietly=T)

#####################################
## @knitr TweakData
# Tweak dsReport
dsReport <- dsReport[order(dsReport$DescriptionShort), ]
dsReport$Path <- ifelse(dsReport$IsLocal,
                        file.path(dsReport$LocalDirectory, dsReport$LocalName),
                        dsReport$RemoteUri)
dsReport$ReportName <- paste0("[", dsReport$DescriptionShort, "](",  dsReport$Path, ")")

# Tweak dsReportJunction
dsReportJunction$Path <- ifelse(dsReportJunction$IsLocal,
                        file.path(dsReportJunction$LocalDirectory, dsReportJunction$LocalName),
                        dsReportJunction$RemoteUri)
dsReportJunction$ReportName <- paste0("[", dsReportJunction$DescriptionShort, "](",  dsReportJunction$Path, ")")
dsReportJunction$Visible <- as.logical(dsReportJunction$Visible)

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
    
    
    dsReportGoal <- dsReportJunction[dsReportJunction$GoalID==goalID, ]
      for( reportID in dsReportGoal$ReportID ) {
        dsReportSlice <- dsReportGoal[dsReportGoal$ReportID==reportID, ]
        cat("   * ", dsReportSlice$ReportName, ": ", dsReportSlice$DescriptionLong, " [", dsReportSlice$FileFormat, "]\n\n", sep="")
      }    
  }
}

#####################################
## @knitr Index

kable(dsReport[, c("ReportName", "FileFormat", "DescriptionLong")],
      col.names = c("Report Name", "Format", "Description"),
      row.names = FALSE)

cat("\n\n")
