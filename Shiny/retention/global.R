rm(list=ls(all=TRUE)) #Clear the memory of variables from previous run. This is not called by knitr, because it's above the first chunk.

# ---- load-sources ------------------------------------------------------------


# ---- load-packages -----------------------------------------------------------
library("magrittr")
requireNamespace("dplyr")
requireNamespace("readr")
requireNamespace("testit")






# ---- declare-globals ---------------------------------------------------------

palette_risk_light <- c("Low Risk"="#5dd3b0", "Baseline Risk"="#b9f3ec", "Elevated Risk"="#fee090", "High Risk"="#f06e3d") #http://colrd.com/image-dna/25396/
palette_risk_dark  <- c("Low Risk"="#017351", "Baseline Risk"="#03c383", "Elevated Risk"="#fbbf45", "High Risk"="#ef6a32") #http://colrd.com/image-dna/25396/
threshold_risk <- c(7/8, 8/7, 1.5)
ds_risk_palette <- tibble::tibble(
  # x          = factor("(Risk Level)", levels=levels(ds_hat$time_frame)),
  y_midpoint = c(5.5/8, 1,(8/7 + 1.5)/2, 2.25),
  category   = names(palette_risk_light),
  color      = palette_risk_dark,
  fill       = palette_risk_light,
  ymin       = c(-Inf, threshold_risk),
  ymax       = c(threshold_risk, Inf),
  class_light= c("risk_light_low", "risk_light_baseline", "risk_light_elevated", "risk_light_high")
)


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

ds_program <- ds_visit %>% 
  dplyr::distinct(program_code, .keep_all=FALSE) %>% 
  dplyr::mutate(
    program_index   = sample(seq_len(n()), replace = FALSE)
  )

ds_visit <- ds_visit %>%
  dplyr::mutate(
    time_frame                   = dplyr::recode(time_frame, "Pregnancy"="Pregnant", "Infant"="Infancy", "Toddler"="Toddlerhood"),
    visit_month                  = OuhscMunge::clump_month_date(visit_date)
  ) %>% 
  dplyr::left_join(ds_program, by="program_code") %>% 
  dplyr::select(
    -program_code,
    -response_id, -model, -model_id, -completed,
    -visit_date,
    -people_present_count, -visit_location_home,
    -visit_distance, -visit_duration_in_minutes,
    -visit_month_first, 
    #-window_start,
    -program_code_f, -time_frame_pregnant,
    -completed_count, 
    # -content_covered_most,
    -client_involvement_f, -client_material_conflict_f, -client_material_understanding_f,
    -client_count_in_program
  ) 




# ---- verify-values -----------------------------------------------------------
# testit::assert("All IDs should be nonmissing and positive.", all(!is.na(ds$CountyID) & (ds$CountyID>0)))

