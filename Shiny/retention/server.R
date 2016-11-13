# ---- load-packages  -----------------------------------
library(shiny)
library(htmlwidgets)
library(magrittr)
library(scales)
library(ggplot2)
requireNamespace("grid")
requireNamespace("DT")
requireNamespace("readr")
requireNamespace("dplyr")

# ---- declare-globals  -----------------------------------
# To create the 'hat' dataset, run `MReporting/OsdhReports/retention/retention.R`.

#Define some common cosmetics for the report.
report_theme <- theme_light() +
  theme(axis.text         = element_text(colour="gray40")) +
  theme(axis.title        = element_text(colour="gray40")) +
  theme(panel.border      = element_rect(colour="gray80")) +
  theme(axis.ticks        = element_line(colour="gray80")) +
  theme(axis.ticks.length = grid::unit(0, "cm"))


# status_levels <- c("0" = "Due Date", "1" = "Scheduled", "2" = "Confirmed", "3" = "Cancelled", "4" = "No Show")
# icons_status <- c("Due Date"="bicycle", "Scheduled"="book", "Confirmed"="bug", "Cancelled"="bolt", "No Show"="ban")
# order_status  <- as.integer(names(status_levels)); names(order_status) <- status_levels


# ---- load-data -----------------------------------
# Dataset is loaded  & tweaked once in 'global.R'.



# ---- tweak-data -----------------------------------

# Define a server for the Shiny app  -----------------------------------
function(input, output) {

  filter_visit <- function( start_date=as.Date("2000-01-01"), stop_date=as.Date("2100-12-12")) {# Filter schedule based on selections
    d <- ds_visit

    if( nrow(d)>0 & input$client_index != "All" )
      d <- d[d$client_index==input$client_index, ]
    if( nrow(d)>0 & input$program_index != "All" )
      d <- d[d$program_index==input$program_index, ]
    if( nrow(d)>0 & input$final_visit != "All" )
      d <- d[d$final_visit==dplyr::recode(input$final_visit, "Yes"=TRUE, "No"=FALSE), ]
    
    d <- d[(start_date<=d$visit_month) & (d$visit_month<=stop_date), ]
    
    return( d )
  }


  output$visit_table <- DT::renderDataTable({
    d <- filter_visit(start_date=input$date_range[1], stop_date=input$date_range[2])

    d <- d %>%
      dplyr::mutate(
        visit_month                  = strftime(visit_month, "%Y-%m"),
        content_covered_percent      = paste0(content_covered_percent, "%"),
        final_visit                  = dplyr::if_else(final_visit, "Yes", "-"),
        hat_v1                       = sprintf("%.2f", hat_v1),
        hat_v2                       = sprintf("%.2f", hat_v2),
        hat_v3                       = sprintf("%.2f", hat_v3)
      ) %>%
      dplyr::select_(
        "Client"                                 = "client_index",
        "Program"                                = "program_index",
        "Visit Month"                            = "visit_month",
        "Phase"                                  = "time_frame",
        "Content Covered"                        = "content_covered_percent",
        "Involved"                               = "client_involvement",
        "Conflict<br/>with Material"             = "client_material_conflict",
        "Understands<br/>Material"               = "client_material_understanding",
        "Days<br/> Since Referral"               = "days_since_referral",
        "Final Visit?"                           = "final_visit",
        "<em>RR</em><sub>v1</sub>"               = "hat_v1",
        "<em>RR</em><sub>v2</sub>"               = "hat_v2",
        "<em>RR</em><sub>v3</sub>"               = "hat_v3"
      )

    # colnames(d)  <- gsub("_", " ", colnames(d))

    DT::datatable(
      d,
      rownames = FALSE,
      style    = 'bootstrap',
      options  = list(
        searching  = FALSE,
        sort       = TRUE,
        language   = list(emptyTable="--No data to populate this table.  Consider using less restrictive filters.--")#,
        # rowCallback = JS(
        #   'function(row, data) {
        #     if (data[3].indexOf("Interview") > -1 ) {
        #       $("td", row).addClass("interviewRow");
        #       $("td:eq(3)", row).addClass("interviewEvent");
        #     } else if (data[3].indexOf("Reminder") > -1 ) {
        #       $("td:eq(3)", row).addClass("reminderEvent");
        #     }
        #   }'
        # )
      ),
      class        = 'table-striped table-condensed table-hover', #Applies Bootstrap styles, see http://getbootstrap.com/css/#tables
      escape       = FALSE
    ) #%>%
    # formatStyle(
    #   columns = 'Status',
    #   color = styleEqual(names(palette_status), palette_status)
    # )
  })
  # output$GraphVisitCount <- renderPlot({
  #   d <- FilterMonth(start_date=input$dateRange[1], stop_date=input$dateRange[2])
  #   highlightedRegions <- input$regionTag
  #   ActivityEachMonth(d, responseVariable="VisitCount", highlightedRegions=highlightedRegions, mainTitle="Visits Each Month (per region)") +
  #     scale_y_continuous(labels=comma_format())
  # })

  output$table_file_info <- renderText({
    return( paste0(
      '<h3>Details</h3>',
      "<table border='0' cellspacing='1' cellpadding='2' >",
      "<tr><td>Data Path:<td/><td>&nbsp;", determine_path(), "<td/><tr/>",
      "<tr><td>Data Last Modified:<td/><td>&nbsp;", file.info(determine_path())$mtime, "<td/><tr/>",
      "<tr><td>App Restart Time:<td/><td>&nbsp;", file.info("restart.txt")$mtime, "<td/><tr/>",
      "<table/>"
    ) )
  })
}
