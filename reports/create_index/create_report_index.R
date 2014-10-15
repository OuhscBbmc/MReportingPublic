rm(list=ls(all=TRUE))  #Clear the variables from previous runs.  
library(DBI)

##################
## @knitr declare_globals
path_db <- "./reports/report_index.sqlite3"
path_aim <- "./reports/create_index/tblAim.csv"
path_goal <- "./reports/create_index/tblGoal.csv"

##################
## @knitr load_data
ds_aim <- read.csv(path_aim, stringsAsFactors=FALSE)
ds_goal <- read.csv(path_goal, stringsAsFactors=FALSE)

##################
## @knitr open_connection
cnn <- DBI::dbConnect(drv=RSQLite::SQLite(), dbname=path_db)
RSQLite::dbSendQuery(cnn, "PRAGMA foreign_keys=ON;") #This needs to be activated each time a connection is made. #http://stackoverflow.com/questions/15301643/sqlite3-forgets-to-use-foreign-keys
dbListTables(cnn)

##################
## @knitr define_tables
sql_create_person <- "CREATE TABLE `tblPerson` (
  `PersonID`  INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
	`Name`	TEXT NOT NULL UNIQUE
);"

sql_create_project <- "CREATE TABLE `tblProject` (
  `ProjectID`	INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
	`Name`	TEXT NOT NULL UNIQUE,
	`SubmissionYear`	INTEGER NOT NULL
);"

sql_create_aim <- "CREATE TABLE `tblAim` (
  `AimID`  INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE,
  `ProjectID`	INTEGER NOT NULL,
  `Name`	TEXT NOT NULL,
	`Description`	TEXT NOT NULL,
  FOREIGN KEY(ProjectID) REFERENCES tblProject(ProjectID)
);"

sql_create_goal <- "CREATE TABLE `tblGoal` (
  `GoalID`  INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE,
	`AimID`	INTEGER NOT NULL,
	`SubaimName`	TEXT NOT NULL,
	`Description`	TEXT NOT NULL,
	`AssignedTo`	INTEGER NOT NULL,
	`IsStarted`	INTEGER NOT NULL,
	`StartDate`	TEXT,
	`IsFinished`	INTEGER NOT NULL,
  `FinishDate`	TEXT,
  `SubsubaimDescriptions`	TEXT,
  FOREIGN KEY(AssignedTo) REFERENCES tblPerson(PersonID),
  FOREIGN KEY(AimID) REFERENCES tblAim(AimID)
);"
# 

##################
## @knitr create_tables
dbSendQuery(cnn, sql_create_person)
dbSendQuery(cnn, sql_create_project)
dbSendQuery(cnn, sql_create_aim)
dbSendQuery(cnn, sql_create_goal)
dbListTables(cnn)

##################
## @knitr populate_datasets
ds_project<- data.frame(
  ID = 1:2,
  Name = c("2011a", "2014a"),
  SubmissionYear = c(2011, 2014),
  stringsAsFactors=FALSE
)
ds_person <- data.frame(
  PersonID = 1:3,
  Name = c("Will Beasley", "Thomas Wilson", "David Bard"),
  stringsAsFactors=FALSE
)
# rownames(ds_person) <- NULL

# ds_subaim <- read.csv(text ="
# ID,ProjectID,Subaim,Description,AssignedTo,IsStarted,StartDate,IsFinished,FinishDate
# 1,1,1a,'Reduction in duplication of services for any particular client',1,0,NA,0,NA
# ")
# str(ds_subaim)



##################
## @knitr populate_tables
# d1 <- dbReadTable(cnn, name='tblSubaim')
# str(d1)

dbWriteTable(cnn, name='tblProject', value=ds_project, append=TRUE, row.names=FALSE)
dbWriteTable(cnn, name='tblPerson', value=ds_person, append=TRUE, row.names=FALSE)
# dbWriteTable(cnn, name='tblAim', value=ds_aim, append=TRUE, row.names=FALSE)
dbWriteTable(cnn, name='tblGoal', value=ds_goal, append=TRUE, row.names=FALSE)


# d2 <- dbReadTable(cnn, name='tblSubaim')
# str(d2)

##################
## @knitr close_connection
dbDisconnect(cnn)

# file.remove(path_db)
