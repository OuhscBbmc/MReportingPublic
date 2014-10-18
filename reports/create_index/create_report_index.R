rm(list=ls(all=TRUE))  #Clear the variables from previous runs.  
library(DBI)

##################
## @knitr declare_globals
path_db <- "./reports/report_index.sqlite3"
path_person <- "./reports/create_index/tblPerson.csv"
path_project <- "./reports/create_index/tblProject.csv"
path_aim <- "./reports/create_index/tblAim.csv"
path_goal <- "./reports/create_index/tblGoal.csv"
path_report <- "./reports/create_index/tblReport.csv"
path_junction_report_by_goal <- "./reports/create_index/tblJunctionReportByGoal.csv"

##################
## @knitr load_data
ds_person <- read.csv(path_person, stringsAsFactors=FALSE)
ds_project <- read.csv(path_project, stringsAsFactors=FALSE)
ds_aim <- read.csv(path_aim, stringsAsFactors=FALSE)
ds_goal <- read.csv(path_goal, stringsAsFactors=FALSE)
ds_report <- read.csv(path_report, stringsAsFactors=FALSE)
ds_report_by_goal <- read.csv(path_junction_report_by_goal, stringsAsFactors=FALSE)

##################
## @knitr remove_old_db
if( file.exists(path_db) ) 
  file.remove(path_db)

##################
## @knitr open_connection
cnn <- DBI::dbConnect(drv=RSQLite::SQLite(), dbname=path_db)
RSQLite::dbSendQuery(cnn, "PRAGMA foreign_keys=ON;") #This needs to be activated each time a connection is made. #http://stackoverflow.com/questions/15301643/sqlite3-forgets-to-use-foreign-keys
dbListTables(cnn)

##################
## @knitr define_tables
sql_create_tbl_person <- "CREATE TABLE `tblPerson` (
  `PersonID`  INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
	`Name`	TEXT NOT NULL UNIQUE
);"

sql_create_tbl_project <- "CREATE TABLE `tblProject` (
  `ProjectID`	INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
	`Name`	TEXT NOT NULL UNIQUE,
	`SubmissionYear`	INTEGER NOT NULL
);"

sql_create_tbl_aim <- "CREATE TABLE `tblAim` (
  `AimID`  INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE,
  `ProjectID`	INTEGER NOT NULL,
  `NameShort`  TEXT NOT NULL,
  `NamePretty`  TEXT NOT NULL,
	`Description`	TEXT NOT NULL,
  FOREIGN KEY(ProjectID) REFERENCES tblProject(ProjectID)
);"

sql_create_tbl_goal <- "CREATE TABLE `tblGoal` (
  `GoalID`  INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE,
	`AimID`	INTEGER NOT NULL,
  `SubaimName`	TEXT NOT NULL,
  `SubaimNameShort`	TEXT NOT NULL,
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

sql_create_tbl_report <- "CREATE TABLE `tblReport` (
  `ReportID`  INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE,
  `DescriptionShort`  TEXT NOT NULL,
  `FileFormat`  TEXT NOT NULL,
  `IsLocal`  INTEGER NOT NULL,
  `LocalDirectory`  TEXT,
  `LocalName`  TEXT,
  `RemoteUri`  TEXT,
  `DescriptionLong`  TEXT NOT NULL
);"

sql_create_tbl_report_by_goal <- "CREATE TABLE `tblJunctionReportByGoal` (
  `ReportByGoalID`  INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE,
  `ReportID`  INTEGER NOT NULL,
  `GoalID`  INTEGER NOT NULL
);"

sql_create_view_report <- "CREATE VIEW vewReport AS
SELECT tblJunctionReportByGoal.ReportByGoalID, 
  tblJunctionReportByGoal.GoalID, tblJunctionReportByGoal.ReportID,
  tblReport.DescriptionShort, tblReport.DescriptionLong, tblReport.IsLocal, tblReport.LocalDirectory, tblReport.LocalName,
  tblReport.RemoteUri, tblReport.FileFormat
FROM tblJunctionReportByGoal
INNER JOIN tblReport
ON tblJunctionReportByGoal.ReportID=tblReport.ReportID
ORDER BY tblReport.DescriptionShort;"

##################
## @knitr create_objects
dbSendQuery(cnn, sql_create_tbl_person)
dbSendQuery(cnn, sql_create_tbl_project)
dbSendQuery(cnn, sql_create_tbl_aim)
dbSendQuery(cnn, sql_create_tbl_goal)
dbSendQuery(cnn, sql_create_tbl_report)
dbSendQuery(cnn, sql_create_tbl_report_by_goal)
dbSendQuery(cnn, sql_create_view_report)
dbListTables(cnn)

##################
## @knitr populate_tables
# d1 <- dbReadTable(cnn, name='tblSubaim')
# str(d1)

dbWriteTable(cnn, name='tblProject', value=ds_project, append=TRUE, row.names=FALSE)
dbWriteTable(cnn, name='tblPerson', value=ds_person, append=TRUE, row.names=FALSE)
dbWriteTable(cnn, name='tblAim', value=ds_aim, append=TRUE, row.names=FALSE)
dbWriteTable(cnn, name='tblGoal', value=ds_goal, append=TRUE, row.names=FALSE)
dbWriteTable(cnn, name='tblReport', value=ds_report, append=TRUE, row.names=FALSE)
dbWriteTable(cnn, name='tblJunctionReportByGoal', value=ds_report_by_goal, append=TRUE, row.names=FALSE)


# d2 <- dbReadTable(cnn, name='tblSubaim')
# str(d2)

##################
## @knitr close_connection
dbDisconnect(cnn)

# file.remove(path_db)
