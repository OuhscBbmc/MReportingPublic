rm(list=ls(all=TRUE))  #Clear the variables from previous runs.  
library(DBI)

cnn <- DBI::dbConnect(drv=RSQLite::SQLite(), dbname="./reports/report_index.sqlite3")

dbListTables(cnn)
dbDisconnect(cnn)
