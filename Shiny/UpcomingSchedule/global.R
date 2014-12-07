# rm(list=ls(all=TRUE)) #Clear the memory of variables from previous run. 

############################
#+ LoadSources
# source("../.././Manipulation/GroomClientSummary.R") #Load the `GroomClientSummary()` function

#####################################
#' LoadPackages
# library(magrittr)

#####################################
#' DeclareGlobals
# pathUpcomingSchedule <- "../.././DataPhiFreeCache/UpcomingSchedule.csv"

#####################################
#' LoadData
# dsSessionSurvey <- read.csv(pathSessionSurvey, stringsAsFactors=FALSE)
# dsClientSummary <- GroomClientSummary(pathSessionSurvey=pathSessionSurvey)
# dsUpcomingSchedule <- read.csv(pathUpcomingSchedule, stringsAsFactors=FALSE) 

#####################################
#' TweakData
# dsSessionSurvey$session_date <- as.Date(dsSessionSurvey$session_date)
# dsSessionSurvey <- plyr::rename(dsSessionSurvey, replace=c(
#   "caregiver_score" = "trauma_score_caregiver",
#   "child_score" = "trauma_score_child"
# ))
# 
# dsSessionSurvey$trauma_score_caregiver <- as.integer(dsSessionSurvey$trauma_score_caregiver)
# dsSessionSurvey$trauma_score_child <- as.integer(dsSessionSurvey$trauma_score_child)
