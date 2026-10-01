# =============================================================================
# MODULE: EXPLORE COUNTRY (Tab 1)
# Purpose: Track one country's macroeconomic indicators over time.
# Key feature: Five synchronized time-series panels with shared x-axis.
# =============================================================================

# ── UI ────────────────────────────────────────────────────────────────────────
explore_country_ui <- function(id) {
  ns <- NS(id)
  layout_sidebar(
    fillable = TRUE,
    sidebar = sidebar(
      width = 270,
      open  = "open",

      # ── Tab explanation ──────────────────────────────────────────────────
      tags$div(
        class = "sidebar-intro",
        tags$p(
          style = "font-size:0.83rem; color:#555; line-height:1.5; margin-bottom:12px;",
          "Select a country and time window to explore how its five macroeconomic ",
          "indicators evolved over time. Look for patterns, crises, and recovery periods."
        )
      ),

      # ── Country selector ─────────────────────────────────────────────────
      selectizeInput(
        ns("country"),
        label   = tags$span("🌍 Country", info_icon("GDP Growth")),
        choices = NULL,       # Populated server-side
        selected = "US",
        options = list(
          placeholder = "Type to search…",
          maxOptions  = 300
        )
      ),

      # ── Year range ───────────────────────────────────────────────────────
      sliderInput(
        ns("year_range"),
        label = "📅 Year range",
        min   = YEAR_MIN,
        max   = YEAR_MAX,
        value = c(1995, YEAR_MAX),
        step  = 1,
        sep   = ""
      ),

      hr(),

      # ── Indicator toggles ────────────────────────────────────────────────
      checkboxGroupInput(
        ns("show_vars"),
        label   = "📊 Show indicators",
        choices = setNames(CORE_VARS, sapply(CORE_VARS, var_label)),
        selected = CORE_VARS
      ),

      hr(),

      # ── Display options ──────────────────────────────────────────────────
      checkboxInput(ns("show_trend"),     "Show trend line",         value = FALSE),
      checkboxInput(ns("show_recession"), "Shade negative GDP years", value = TRUE),

      hr(),

      # ── Quick stat summary ───────────────────────────────────────────────
      tags$p(tags$b("Period summary"), style = "font-size:0.85rem; margin-bottom:4px;"),
      uiOutput(ns("summary_cards"))
    ),

    # ── Main plot area ────────────────────────────────────────────────────────
    card(
      full_screen = TRUE,
      card_header(
        class = "d-flex justify-content-between align-items-center",
        uiOutput(ns("chart_title")),
        tags$div(
          style = "font-size:0.78rem; color:#64748b;",
          "Source: World Bank WDI | Hover for values | Drag to zoom | Double-click to reset"
        )
      ),
      card_body(
        padding = "0",
        plotlyOutput(ns("main_plot"), height = "580px")
      )
    )
  )
}

# ── SERVER ────────────────────────────────────────────────────────────────────
explore_country_server <- function(id, data) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # ── Populate country selector once data is loaded ──────────────────────
    observe({
      req(data())
      choices <- get_country_choices(data())
      updateSelectizeInput(session, "country",
        choices  = choices,
        selected = "US",
        server   = FALSE
      )
    })

    # ── Filtered data for selected country ────────────────────────────────
    country_data <- reactive({
      req(data(), input$country, input$year_range)
      data() %>%
        filter(
          iso2c == input$country,
          year  >= input$year_range[1],
          year  <= input$year_range[2]
        ) %>%
        arrange(year)
    })

    # ── Chart title ────────────────────────────────────────────────────────
    output$chart_title <- renderUI({
      req(data(), input$country)
      country_name <- data() %>%
        filter(iso2c == input$country) %>%
        pull(country) %>% unique()
      tags$span(
        style = "font-weight:700; color:#1e3a5f; font-size:1.05rem;",
        paste("Macroeconomic Overview:", country_name[1])
      )
    })

    # ── Summary statistics cards ────────────────────────────────────────────
    output$summary_cards <- renderUI({
      req(country_data())
      df <- country_data()
      vars_shown <- intersect(input$show_vars, CORE_VARS)

      tags$div(
        lapply(vars_shown, function(v) {
          vals    <- df[[v]]
          avg_val <- mean(vals, na.rm = TRUE)
          last_val <- tail(vals[!is.na(vals)], 1)
          if (length(last_val) == 0) last_val <- NA

          tags$div(
            style = paste0(
              "background:#f8fafc; border-left:3px solid ", var_color(v), "; ",
              "padding:5px 8px; margin-bottom:5px; border-radius:0 4px 4px 0;"
            ),
            tags$div(
              style = "font-size:0.75rem; color:#64748b; font-weight:600;",
              var_short(v)
            ),
            tags$div(
              style = "display:flex; justify-content:space-between; font-size:0.82rem;",
              tags$span(
                style = "color:#334155;",
                paste0("Avg: ", format_stat(avg_val, v))
              ),
              tags$span(
                style = "color:#334155;",
                paste0("Latest: ", format_stat(last_val, v))
              )
            )
          )
        })
      )
    })

    # ── Main synchronized subplot ──────────────────────────────────────────
    output$main_plot <- renderPlotly({
      req(country_data(), input$show_vars)
      df        <- country_data()
      vars_show <- intersect(input$show_vars, CORE_VARS)
      if (length(vars_show) == 0) return(plotly_empty())

      # Build one subplot per variable
      plot_list <- lapply(seq_along(vars_show), function(i) {
        v    <- vars_show[i]
        col  <- var_color(v)
        vals <- df[[v]]
        is_last <- (i == length(vars_show))

        p <- plot_ly(df, x = ~year, source = "explore") %>%
          add_trace(
            y          = vals,
            type       = "scatter",
            mode       = "lines+markers",
            name       = var_short(v),
            line       = list(color = col, width = 2.2),
            marker     = list(color = col, size = 5, opacity = 0.8),
            text       = paste0(
              "<b>", var_label(v), "</b><br>",
              "Year: ", df$year, "<br>",
              "Value: ", round(vals, 2), " ", var_unit(v)
            ),
            hoverinfo  = "text",
            showlegend = FALSE
          )

        # Trend line
        if (isTRUE(input$show_trend)) {
          valid_idx <- !is.na(vals)
          if (sum(valid_idx) > 3) {
            yr_v <- df$year[valid_idx]
            tryCatch({
              fit <- lm(vals[valid_idx] ~ yr_v)
              p   <- p %>% add_trace(
                x = yr_v, y = predict(fit),
                type = "scatter", mode = "lines",
                line = list(color = plotly::toRGB(col, alpha = 0.6), dash = "dash", width = 1.5),
                showlegend = FALSE, hoverinfo = "none"
              )
            }, error = function(e) NULL)
          }
        }

        # Zero reference line for variables that cross zero
        if (!is.null(VARS[[v]]$zero_line) && VARS[[v]]$zero_line) {
          p <- p %>% layout(shapes = list(
            list(type="line", x0=min(df$year), x1=max(df$year),
                 y0=0, y1=0, line=list(color="#94a3b8", dash="dot", width=1))
          ))
        }

        # Y-axis label with coloured title
        p %>% layout(
          yaxis = list(
            title = list(
              text = var_short(v),
              font = list(size = 11, color = col)
            ),
            tickfont = list(size = 10),
            gridcolor = "#f1f5f9",
            zerolinecolor = "#94a3b8"
          ),
          xaxis = list(
            showticklabels = is_last,
            tickfont = list(size = 10),
            gridcolor = "#f1f5f9"
          ),
          margin = list(l = 60, r = 20, t = 10, b = if (is_last) 40 else 10),
          plot_bgcolor  = "#ffffff",
          paper_bgcolor = "#ffffff"
        )
      })

      # Combine into synchronized subplot
      n <- length(plot_list)
      h_per <- 1 / n

      do.call(
        subplot,
        c(plot_list, list(
          nrows        = n,
          shareX       = TRUE,
          titleY       = TRUE,
          heights      = rep(h_per, n)
        ))
      ) %>%
        layout(
          hovermode = "x unified",
          margin    = list(l = 70, r = 30, t = 20, b = 50),
          paper_bgcolor = "#ffffff",
          plot_bgcolor  = "#ffffff"
        ) %>%
        config(
          displaylogo    = FALSE,
          modeBarButtons = list(list("toImage", "zoom2d", "pan2d", "resetScale2d")),
          toImageButtonOptions = list(
            format   = "png",
            filename = paste0("macro_", input$country),
            width    = 1200,
            height   = 800
          ),
          responsive = TRUE
        )
    })
  })
}

# Helper: format a statistic value for display
format_stat <- function(x, var_name = NULL) {
  if (is.na(x)) return("N/A")
  if (!is.null(var_name) && var_name == "population") {
    if (x >= 1e9) return(paste0(round(x / 1e9, 1), "B"))
    if (x >= 1e6) return(paste0(round(x / 1e6, 1), "M"))
    return(format(round(x), big.mark = ","))
  }
  paste0(round(x, 1), "%")
}
