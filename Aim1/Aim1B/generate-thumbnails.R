# knitr::stitch_rmd(script="./manipulation/car-ellis.R", output="./stitched-output/manipulation/car-ellis.md")
#These first few lines run only when the file is run in RStudio, !!NOT when an Rmd/Rnw file calls it!!
rm(list=ls(all=TRUE))  #Clear the variables from previous runs.

# ---- load-sources ------------------------------------------------------------
# Call `base::source()` on any repo file that defines functions needed below.  Ideally, no real operations are performed.

# ---- load-packages -----------------------------------------------------------
# Attach these packages so their functions don't need to be qualified: http://r-pkgs.had.co.nz/namespace.html#search-path
library(magrittr             , quietly=TRUE) #Pipes

# Verify these packages are available on the machine, but their functions need to be qualified: http://r-pkgs.had.co.nz/namespace.html#search-path
requireNamespace("readr"     , quietly=TRUE)
requireNamespace("tidyr"     , quietly=TRUE)
requireNamespace("dplyr"     , quietly=TRUE) #Avoid attaching dplyr, b/c its function names conflict with a lot of packages (esp base, stats, and plyr).
requireNamespace("testit"    , quietly=TRUE) #For asserting conditions meet expected patterns.

# ---- declare-globals ---------------------------------------------------------
path_input     <- "./DataPhiFree/Raw/miechv-progress-timeline.csv"
path_output    <- "./DataPhiFree/Derived/miechv-progress-timeline.csv"
directory      <- "./DataPhiFree/Derived/timeline-thumbnails"

col_types <- readr::cols(
  `Year`               = readr::col_integer(),
  `Month`              = readr::col_integer(),
  `Day`                = readr::col_integer(),
  `Time`               = readr::col_character(),
  `End Year`           = readr::col_integer(),
  `End Month`          = readr::col_integer(),
  `End Day`            = readr::col_integer(),
  `End Time`           = readr::col_character(),
  `Display Date`       = readr::col_character(),
  `Headline`           = readr::col_character(),
  `Text`               = readr::col_character(),
  `Media`              = readr::col_character(),
  `Media Credit`       = readr::col_character(),
  `Media Caption`      = readr::col_character(),
  `Media Thumbnail`    = readr::col_character(),
  `Type`               = readr::col_character(),
  `Group`              = readr::col_character(),
  `Background`         = readr::col_character()
)

# ---- load-data ---------------------------------------------------------------
ds <- readr::read_csv(path_input, col_types=col_types)

# ---- tweak-data --------------------------------------------------------------
colnames(ds)

# Dataset description can be found at: http://stat.ethz.ch/R-manual/R-devel/library/datasets/html/mtcars.html
# Populate the rename entries with OuhscMunge::column_rename_headstart(ds) # devtools::install_github("OuhscBbmc/OuhscMunge")
ds <- ds %>% 
  # dplyr::select_(
  #   "year"                         = "`Year`"
  #   , "month"                      = "`Month`"
  #   , "day"                        = "`Day`"
  #   , "time"                       = "`Time`"
  #   , "end_year"                   = "`End Year`"
  #   , "end_month"                  = "`End Month`"
  #   , "end_day"                    = "`End Day`"
  #   , "end_time"                   = "`End Time`"
  #   , "display_date"               = "`Display Date`"
  #   , "headline"                   = "`Headline`"
  #   , "text"                       = "`Text`"
  #   , "media"                      = "`Media`"
  #   , "media_credit"               = "`Media Credit`"
  #   , "media_caption"              = "`Media Caption`"
  #   , "media_thumbnail"            = "`Media Thumbnail`"
  #   , "type"                       = "`Type`"
  #   , "group"                      = "`Group`"
  #   , "background"                 = "`Background`"
  # ) %>% 
  dplyr::mutate(
    filename               = sprintf("%03i.png", seq_len(n())),
    file_path              = file.path(directory, filename)
  )
  

# ---- verify-values -----------------------------------------------------------
# testit::assert("`model_name` should be a unique value", sum(duplicated(ds$model_name))==0L)
# testit::assert("`miles_per_gallon` should be a positive value.", all(ds$miles_per_gallon>0))
# testit::assert("`weight_gear_z` should be a positive or missing value.", all(is.na(ds$miles_per_gallon) | (ds$miles_per_gallon>0)))

# ---- save-thumbnails ------------------------------------------------------------

# basename(ds$media)
for( i in seq_len(nrow(ds)) ) {
  cat(i, "\n")
  # i <- 1
  ds$`Media Thumbnail` <- ""
  
  if( !is.na(ds$Media[i]) ) {
    try({
      webshot::webshot(
        url   = ds$Media[i],
        file  = ds$file_path[i]
      )
      ds$`Media Thumbnail`[i] <- ds$file_path[i]
    }, silent = TRUE
    )
  }
}


# ---- save-to-disk ------------------------------------------------------------
readr::write_csv(ds, path_output, na="")

