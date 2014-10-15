rm(list=ls(all=TRUE))  #Clear the variables from previous runs.  
library(DBI)

##################
## @knitr declare_globals
path_db <- "./reports/report_index.sqlite3"

##################
## @knitr open_connection
cnn <- DBI::dbConnect(drv=RSQLite::SQLite(), dbname=path_db)
dbListTables(cnn)

##################
## @knitr define_tables
sql_create_person <- "CREATE TABLE `tblPerson` (
  `ID`	INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
	`Name`	TEXT NOT NULL UNIQUE
);"

sql_create_project <- "CREATE TABLE `tblProject` (
  `ID`	INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
	`Name`	TEXT NOT NULL UNIQUE,
	`SubmissionYear`	INTEGER NOT NULL
);"

sql_create_aim <- "CREATE TABLE `tblAim` (
  `ID`  INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE,
	`ProjectID`	INTEGER NOT NULL,
	`Aim`	TEXT NOT NULL,
  FOREIGN KEY(ProjectID) REFERENCES tblProject(ID)
);"

sql_create_subaim <- "CREATE TABLE `tblSubaim` (
  `ID`  INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE,
	`AimID`	INTEGER NOT NULL,
	`Subaim`	TEXT NOT NULL,
	`Description`	TEXT NOT NULL,
	`AssignedTo`	INTEGER NOT NULL,
	`IsStarted`	INTEGER NOT NULL,
	`StartDate`	TEXT,
	`IsFinished`	INTEGER NOT NULL,
	`FinishDate`	TEXT,
  FOREIGN KEY(AssignedTo) REFERENCES tblPerson(ID),
  FOREIGN KEY(AimID) REFERENCES tblAim(ID)
);"
# 

##################
## @knitr create_tables
dbSendQuery(cnn, sql_create_person)
dbSendQuery(cnn, sql_create_project)
dbSendQuery(cnn, sql_create_aim)
dbSendQuery(cnn, sql_create_subaim)
dbListTables(cnn)

##################
## @knitr populate_datasets
ds_person <- data.frame(
  ID = 1:5,
  Name = letters[1:5],
  stringsAsFactors=FALSE
)
# rownames(ds_person) <- NULL

ds_subaim <- read.csv(text ="
ID,ProjectID,Subaim,Description,AssignedTo,IsStarted,StartDate,IsFinished,FinishDate
1,1,1a,'Reduction in duplication of services for any particular client',1999,0,NA,0,NA
")
str(ds_subaim)

##################
## @knitr populate_tables
d1 <- dbReadTable(cnn, name='tblSubaim')
str(d1)

dbWriteTable(cnn, name='tblPerson', value=ds_person, append=TRUE, row.names=FALSE)
dbWriteTable(cnn, name='tblSubaim', value=ds_subaim, append=TRUE, row.names=FALSE)


d2 <- dbReadTable(cnn, name='tblSubaim')
str(d2)

##################
## @knitr close_connection
dbDisconnect(cnn)

# file.remove(path_db)
