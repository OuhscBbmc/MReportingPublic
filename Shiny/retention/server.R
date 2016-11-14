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
report_theme <- theme_light(base_size = 18) +
  theme(axis.text         = element_text(colour="gray40")) +
  theme(axis.title        = element_text(colour="gray40")) +
  theme(panel.border      = element_rect(colour="gray80"))  +
  theme(axis.ticks        = element_blank())


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
  output$rr_longitudinal <- renderPlot({
    d <- filter_visit(start_date=input$date_range[1], stop_date=input$date_range[2])

    if( dplyr::n_distinct(d$program_index) == 1L) {
      subtitle_text <- sprintf("For %s clients across 1 program"  , scales::comma(dplyr::n_distinct(d$client_index)))
    } else {
      subtitle_text <- sprintf("For %s clients across %i programs", scales::comma(dplyr::n_distinct(d$client_index)), dplyr::n_distinct(d$program_index))
    }
    x_max <- dplyr::coalesce(max(ds_visit$days_since_referral), 5L) #Use a common x-axis for all graphs
    
    ggplot() +
      geom_rect(data=ds_risk_palette, mapping=aes(ymin=ymin, ymax=ymax, fill=fill, xmin=-Inf, xmax=Inf, color=NULL, group=NULL), alpha=.15) + #, x=NULL, y=NULL, label=NULL
      geom_vline(xintercept=0, color="gray70", size=1, alpha=.2) +
      geom_line(data=d, aes(x=days_since_referral, y=hat_v3, group=client_index), color="gray50", alpha=.5, na.rm=T) +
      geom_text(data=d[!d$final_visit, ], aes(x=days_since_referral, y=hat_v3, label=client_index), color="gray50" , alpha=.3, na.rm=T) +
      geom_text(data=d[ d$final_visit, ], aes(x=days_since_referral, y=hat_v3, label=client_index), color="#CC2222", alpha=.8, na.rm=T) +
      geom_hline(yintercept=1, linetype="A1", color="gray70", size=1.5, alpha=.5) +
      geom_hline(yintercept=c(.5, 2), linetype="A2", color="gray40", size=1, alpha=.2) +
      geom_text(data=ds_risk_palette, aes(x=Inf, y=y_midpoint, label=category, color=palette_risk_dark, group=NULL), size=5, hjust=1) +
      scale_y_continuous(breaks=seq(0, 4, .5)) +
      scale_color_identity() +
      scale_fill_identity() +
      coord_cartesian(xlim=c(0, x_max), ylim=c(.45, 4.05), expand=T) +
      report_theme +
      labs(title="Relative Risk of Dropping Out after each Visit (V3 model)", subtitle=subtitle_text, x="Days Since Referral", y="Relative Risk of Dropping Out")
  })
  output$rr_phase <- renderPlot({
    d <- filter_visit(start_date=input$date_range[1], stop_date=input$date_range[2]) %>% 
      dplyr::arrange(rev(final_visit))

    if( dplyr::n_distinct(d$program_index) == 1L) {
      subtitle_text <- sprintf("For %s clients across 1 program"  , scales::comma(dplyr::n_distinct(d$client_index)))
    } else {
      subtitle_text <- sprintf("For %s clients across %i programs", scales::comma(dplyr::n_distinct(d$client_index)), dplyr::n_distinct(d$program_index))
    }
    x_max <- dplyr::coalesce(max(ds_visit$days_since_referral), 5L) #Use a common x-axis for all graphs
    
    set.seed(8) #To keep the jittering from creating new graphs
    ggplot(d, aes(x=time_frame, y=hat_v3, label=client_index, color=content_covered_most)) +
      geom_rect(data=ds_risk_palette, aes(ymin=ymin, ymax=ymax, fill=fill, xmin=-Inf, xmax=Inf, x=NULL, y=NULL, label=NULL, color=NULL), alpha=.2) +
      geom_text(data=d[!d$final_visit, ],position=position_jitter(), color="#2a3284", na.rm=T) +
      geom_text(data=d[ d$final_visit, ],position=position_jitter(), color="#CC2222", na.rm=T) +
      geom_hline(yintercept=1, linetype="A1", color="gray70", size=1.5, alpha=.5) +
      geom_hline(yintercept=c(.5, 2), linetype="A2", color="gray40", size=1, alpha=.2) +
      geom_text(data=ds_risk_palette, aes(x=1, y=y_midpoint, label=category, color=palette_risk_dark), size=5, hjust=0) +
      scale_x_discrete(limits=levels(d$time_frame)) +
      scale_y_continuous(breaks=seq(0, 4, .5)) +
      scale_color_identity() +
      scale_fill_identity() +
      coord_cartesian(ylim=c(.45, 4.05), expand=T) +
      report_theme +
      theme(panel.grid.major.x=element_blank()) +
      labs(title="Relative Risk of Dropping Out after each Visit (V3 model)", subtitle=subtitle_text, x="Days Since Referral", y="Relative Risk of Dropping Out")
  })

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
