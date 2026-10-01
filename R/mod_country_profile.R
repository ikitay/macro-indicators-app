# =============================================================================
# MODULE: COUNTRY PROFILE (Tab 4)
# Purpose: Radar chart comparing overall macroeconomic performance across
#   up to 4 countries. Variables are normalized before plotting.
# =============================================================================

country_profile_ui <- function(id) {
  ns <- NS(id)
  layout_sidebar(
    fillable = TRUE,
    sidebar = sidebar(
      width = 280, open = "open",
      tags$div(class = "sidebar-intro",
        tags$p(style = "font-size:0.83rem; color:#555; line-height:1.5; margin-bottom:12px;",
          "Compare overall macroeconomic performance using a radar chart. ",
          "Each axis represents one indicator, normalized globally so countries can be fairly compared."
        )
      ),
      selectizeInput(ns("countries"), "🌍 Countries (up to 4)",
        choices  = NULL,
        selected = c("US", "DE", "KR", "AR"),
        multiple = TRUE,
        options  = list(maxItems=4, placeholder="Type to search…", maxOptions=300)
      ),
      sliderInput(ns("year"), "📅 Reference year",
        min=YEAR_MIN, max=YEAR_MAX, value=2019, step=1, sep=""
      ),
      hr(),
      checkboxInput(ns("fill_area"), "Fill radar area", value = TRUE),
      hr(),
      tags$div(
        style = "background:#fff8e1; border:1px solid #fde68a; border-radius:6px; padding:10px;",
        tags$p(style="font-size:0.8rem; color:#78350f; margin:0;",
          tags$b("📏 How scores work: "),
          "Each score (0–100) shows how this country-year ranks against ",
          tags$b("all countries from 1990–2023."),
          " A score of 70 means better than 70% of all historical observations. ",
          tags$b("Inflation is reverse-scaled"), " — lower inflation = higher score."
        )
      )
    ),
    card(
      full_screen = TRUE,
      card_header(uiOutput(ns("chart_title"))),
      card_body(
        padding = "0",
        layout_columns(
          col_widths = c(8, 4),
          plotlyOutput(ns("radar_plot"), height = "480px"),
          uiOutput(ns("score_table"))
        )
      ),
      card_footer(
        tags$div(class="info-box",
          tags$span("🕸️ "), tags$b("How to read this chart: "),
          "A larger filled area means better overall macroeconomic performance. ",
          "But shape matters too — a country may score well on growth but poorly on fiscal balance."
        )
      )
    )
  )
}

country_profile_server <- function(id, data) {
  moduleServer(id, function(input, output, session) {

    observe({
      req(data())
      updateSelectizeInput(session, "countries",
        choices=get_country_choices(data()), selected=c("US","DE","KR","AR"), server=FALSE)
    })

    norm_data <- reactive({
      req(data())
      # Always normalize against the full global dataset (all countries, all years).
      # This gives each score a stable meaning: "better than X% of all country-years
      # from 1990–2023." The scale doesn't shift when the selected year changes.
      normalize_for_radar(data())
    })

    profile_data <- reactive({
      req(norm_data(), input$countries, input$year)
      norm_data() %>%
        filter(iso2c %in% input$countries, year == input$year) %>%
        select(country, iso2c, all_of(paste0(CORE_VARS, "_norm")))
    })

    output$chart_title <- renderUI({
      req(input$year)
      tags$span(style="font-weight:700; color:#1e3a5f;",
        paste("Macroeconomic Performance Profile —", input$year))
    })

    output$radar_plot <- renderPlotly({
      req(profile_data())
      df <- profile_data()
      validate(need(nrow(df) > 0, "No data available for selected countries and year."))

      axis_labels <- c(
        "GDP Growth", "Employment", "Low Inflation\n(reverse)", "Fiscal Balance", "Trade Balance"
      )
      norm_cols <- paste0(CORE_VARS, "_norm")

      palette <- c("#2563eb","#dc2626","#16a34a","#d97706")

      p <- plot_ly()

      for (i in seq_len(nrow(df))) {
        vals <- as.numeric(df[i, norm_cols]) * 100
        vals[is.na(vals)] <- 0
        col <- palette[i]
        closed_r     <- c(vals, vals[1])
        closed_theta <- c(axis_labels, axis_labels[1])

        p <- p %>% add_trace(
          r     = closed_r,
          theta = closed_theta,
          name  = df$country[i],
          type  = "scatterpolar",
          mode  = "lines+markers",
          fill  = if (isTRUE(input$fill_area)) "toself" else "none",
          fillcolor = paste0(col, "22"),
          line  = list(color = col, width = 2.5),
          marker = list(color = col, size = 7),
          text  = paste0(closed_theta, ": ", round(closed_r, 1), "/100"),
          hoverinfo = "text"
        )
      }

      p %>%
        layout(
          polar = list(
            radialaxis = list(
              visible  = TRUE,
              range    = c(0, 100),
              tickvals = unname(c(0, 25, 50, 75, 100)),
              ticktext = unname(c("0", "25", "50", "75", "100")),
              tickfont = list(size=9),
              gridcolor = "#e2e8f0"
            ),
            angularaxis = list(tickfont=list(size=11.5))
          ),
          legend = list(
            orientation="h", x=0.5, y=-0.12, xanchor="center",
            font=list(size=11)
          ),
          margin = list(l=60,r=60,t=30,b=80),
          paper_bgcolor="#ffffff"
        ) %>%
        config(displaylogo=FALSE, responsive=TRUE,
               modeBarButtons=list(list("toImage")),
               toImageButtonOptions=list(format="png",filename="country_profile",width=900,height=700))
    })

    output$score_table <- renderUI({
      req(profile_data())
      df <- profile_data()
      validate(need(nrow(df) > 0, ""))

      palette <- c("#2563eb","#dc2626","#16a34a","#d97706")
      norm_cols <- paste0(CORE_VARS, "_norm")

      score_labels <- c(
        "GDP Growth","Employment","Low Inflation","Fiscal Balance","Trade Balance"
      )

      tags$div(
        style = "padding:10px;",
        tags$p(style="font-size:0.8rem; font-weight:700; color:#1e3a5f; margin-bottom:8px;",
               "Scores (0–100)"),
        lapply(seq_len(nrow(df)), function(i) {
          col  <- palette[i]
          vals <- as.numeric(df[i, norm_cols]) * 100

          tags$div(
            style = paste0("margin-bottom:14px; border-left:3px solid ",col,"; padding-left:8px;"),
            tags$div(style=paste0("font-weight:700; color:",col,"; font-size:0.85rem; margin-bottom:4px;"),
                     df$country[i]),
            lapply(seq_along(CORE_VARS), function(j) {
              v <- if (!is.na(vals[j])) round(vals[j]) else NA
              bar_pct <- if (!is.na(v)) v else 0
              bar_col <- if (!is.na(v) && v >= 60) "#16a34a" else if (!is.na(v) && v >= 35) "#d97706" else "#dc2626"
              tags$div(
                style = "margin-bottom:3px;",
                tags$div(style="font-size:0.73rem; color:#64748b; margin-bottom:1px;",
                         score_labels[j]),
                tags$div(
                  style = "display:flex; align-items:center; gap:5px;",
                  tags$div(
                    style = "flex:1; background:#f1f5f9; border-radius:3px; height:7px;",
                    tags$div(style=paste0(
                      "width:", bar_pct, "%; background:", bar_col,
                      "; height:7px; border-radius:3px; transition:width 0.4s;"))
                  ),
                  tags$span(style="font-size:0.73rem; color:#334155; width:26px; text-align:right;",
                             if (is.na(v)) "N/A" else v)
                )
              )
            })
          )
        })
      )
    })
  })
}
