rm(list=ls(all=TRUE)) #Clear the memory of variables from previous run. This is not called by knitr, because it's above the first chunk.

# ---- load-sources ------------------------------------------------------------


# ---- load-packages -----------------------------------------------------------
library("magrittr")
requireNamespace("dplyr")
requireNamespace("readr")
requireNamespace("testit")






# ---- declare-globals ---------------------------------------------------------

determine_path <- function( ) {
  # path_input_server_outside <- "//bbmc-shiny-public/Anonymous/MReportingPublic/eto-visit-hat.csv"
  # path_input_server_inside  <- "/var/shinydata/MReportingPublic/eto-visit-hat.csv"
  path_input_repo             <- "../.././DataPhiFreeCache/Raw/C1/eto-visit-hat.rds"
  
  # if( file.exists(pathUpcomingScheduleServerOutside) ) {
  #   pathUpcomingSchedule <- pathUpcomingScheduleServerOutside
  # } else if( file.exists(pathUpcomingScheduleServerInside) ) {
  #   pathUpcomingSchedule <- pathUpcomingScheduleServerInside
  # } else {
  path_input <- path_input_repo
  # }
  
  return( path_input )
}

# ---- load-data ---------------------------------------------------------------

ds_visit <- readr::read_rds(determine_path())

# ---- tweak-data --------------------------------------------------------------

ds_visit <- ds_visit %>%
  dplyr::mutate(
    time_frame                   = dplyr::recode(time_frame, "Pregnancy"="Pregnant", "Infant"="Infancy", "Toddler"="Toddlerhood"),
    visit_month                  = OuhscMunge::clump_month_date(visit_date)
  ) %>% 
  dplyr::select(
    -response_id, -model, -model_id, -completed,
    -visit_date,
    -people_present_count, -visit_location_home,
    -visit_distance, -visit_duration_in_minutes,
    -visit_month_first, -window_start,
    -program_code_f, -time_frame_pregnant,
    -completed_count, -content_covered_most,
    -client_involvement_f, -client_material_conflict_f, -client_material_understanding_f,
    -client_count_in_program
  ) 


# ---- verify-values -----------------------------------------------------------
# testit::assert("All IDs should be nonmissing and positive.", all(!is.na(ds$CountyID) & (ds$CountyID>0)))

