# =============================================================================
# MODULE: COMPARE COUNTRIES (Tab 2)
# Purpose: Compare economic trajectories of multiple countries on one chart.
# Supports raw values and change since a base year: a real GDP index
# (base year = 100) for GDP growth, percentage-point change for the rest.
# =============================================================================

# ── UI ────────────────────────────────────────────────────────────────────────
compare_countries_ui <- function(id) {
  ns <- NS(id)
  layout_sidebar(
    fillable = TRUE,
    sidebar = sidebar(
      width = 280,
      open  = "open",

      tags$div(
        class = "sidebar-intro",
        tags$p(
          style = "font-size:0.83rem; color:#555; line-height:1.5; margin-bottom:12px;",
          "Select up to 6 countries and one indicator. Switch between raw values ",
          "and the change since a base year to compare trajectories."
        )
      ),

      # ── Country selection ─────────────────────────────────────────────────
      selectizeInput(
        ns("countries"),
        label   = "🌍 Countries (up to 6)",
        choices = NULL,
        selected = c("US", "DE", "CN", "AR", "KR", "ZA"),
        multiple = TRUE,
        options  = list(
          maxItems    = 6,
          placeholder = "Type to search…",
          maxOptions  = 300
        )
      ),

      # ── Variable ─────────────────────────────────────────────────────────
      selectInput(
        ns("variable"),
        label    = "📊 Indicator",
        choices  = core_var_choices(),
        selected = "gdp_growth"
      ),

      # ── Year range ───────────────────────────────────────────────────────
      sliderInput(
        ns("year_range"),
        label = "📅 Year range",
        min   = YEAR_MIN,
        max   = YEAR_MAX,
        value = c(2000, YEAR_MAX),
        step  = 1,
        sep   = ""
      ),

      hr(),

      # ── Display mode ──────────────────────────────────────────────────────
      radioButtons(
        ns("display_mode"),
        label    = "Display mode",
        choices  = c(
          "Raw values"           = "raw",
          "Change since base year" = "indexed"
        ),
        selected = "raw"
      ),

      conditionalPanel(
        condition = paste0("input['", ns("display_mode"), "'] == 'indexed'"),
        sliderInput(
          ns("base_year"),
          label = "📌 Base year",
          min   = YEAR_MIN,
          max   = YEAR_MAX,
          value = 2000,
          step  = 1,
          sep   = ""
        ),
        tags$small(
          style = "color:#64748b; font-size:0.78rem;",
          "GDP growth becomes a real GDP index (base year = 100). The other indicators ",
          "are already rates or ratios, so they show the change in percentage points."
        )
      ),

      hr(),

      # ── Options ────────────────────────────────────────────────────────────
      checkboxInput(ns("show_crisis"),  "Mark crisis years (2009, 2020)", value = TRUE),
      checkboxInput(ns("smooth_lines"), "Smooth lines", value = FALSE),

      hr(),

      # ── Data table toggle ─────────────────────────────────────────────────
      checkboxInput(ns("show_table"), "Show data table", value = FALSE)
    ),

    # ── Main content ──────────────────────────────────────────────────────────
    tags$div(
      card(
        full_screen = TRUE,
        card_header(
          class = "d-flex justify-content-between align-items-center",
          uiOutput(ns("chart_title")),
          tags$div(
            style = "font-size:0.78rem; color:#64748b;",
            "Hover for details | Click legend to show/hide countries"
          )
        ),
        card_body(
          padding = "0",
          plotlyOutput(ns("compare_plot"), height = "490px")
        )
      ),
      # Pedagogical note on indexed values
      conditionalPanel(
        condition = paste0("input['", ns("display_mode"), "'] == 'indexed'"),
        uiOutput(ns("change_note"))
      ),
      # Data table (optional)
      conditionalPanel(
        condition = paste0("input['", ns("show_table"), "']"),
        card(
          class     = "mt-2",
          card_header("📋 Data Table"),
          card_body(
            tableOutput(ns("data_table"))
          )
        )
      )
    )
  )
}

# ── SERVER ────────────────────────────────────────────────────────────────────
compare_countries_server <- function(id, data) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # Populate country choices
    observe({
      req(data())
      choices <- get_country_choices(data())
      updateSelectizeInput(session, "countries",
        choices  = choices,
        selected = DEFAULT_COUNTRIES,
        server   = FALSE
      )
    })

    # Filtered and processed data
    plot_data <- reactive({
      req(data(), input$countries, input$variable, input$year_range)
      validate(
        need(length(input$countries) >= 1, "Please select at least one country."),
        need(input$variable %in% CORE_VARS, "Please select a valid indicator.")
      )

      df <- data() %>%
        filter(iso2c %in% input$countries) %>%
        select(country, iso2c, year, val = all_of(input$variable),
               src = any_of(paste0(input$variable, "_source"))) %>%
        arrange(country, year)

      # Change since base year, computed on all years so the base year may lie
      # outside the plotted range
      if (input$display_mode == "indexed") {
        req(input$base_year)
        df <- df %>%
          group_by(iso2c) %>%
          mutate(val = change_since_base(val, year, input$base_year,
                                         input$variable == "gdp_growth")) %>%
          ungroup() %>%
          as.data.frame()
      }

      df %>% filter(year >= input$year_range[1], year <= input$year_range[2])
    })

    output$change_note <- renderUI({
      req(input$variable)
      tags$div(
        class = "info-box mt-2",
        tags$span("📌 "),
        if (input$variable == "gdp_growth") {
          tagList(
            tags$b("Real GDP index: "),
            "the growth rates are chained into the level of real GDP, set to 100 in the base ",
            "year. A value of 110 means the economy produces 10% more than in the base year. ",
            "Growth is the change in real GDP: a country whose growth rises from 2% to 4% ",
            "doubles its growth rate, but its real GDP is only about 6% higher after those ",
            "two years."
          )
        } else {
          tagList(
            tags$b("Change in percentage points: "),
            var_short(input$variable), " is already a rate or a ratio, so dividing it by its ",
            "base-year value would be meaningless (a rate that goes from 2% to 4% is not ",
            "\"twice as much economy\"). The chart shows how many percentage points it moved ",
            "since the base year: +2 means 2 points higher than in the base year."
          )
        }
      )
    })

    output$chart_title <- renderUI({
      req(input$variable, input$display_mode)
      mode_txt <- if (input$display_mode == "raw") {
        var_label(input$variable)
      } else {
        change_label(input$variable, input$base_year)
      }
      tags$span(style = "font-weight:700; color:#1e3a5f;", mode_txt)
    })

    output$compare_plot <- renderPlotly({
      req(plot_data())
      df      <- plot_data()
      var_sel <- input$variable

      # Distinct countries and a colour palette
      countries_in <- unique(df$iso2c)
      palette <- c("#2563eb","#dc2626","#16a34a","#d97706",
                   "#7c3aed","#0891b2","#db2777","#475569")
      col_map <- setNames(palette[seq_along(countries_in)], countries_in)

      p <- plot_ly()

      # One trace per country
      for (ctry in countries_in) {
        df_c <- df %>% filter(iso2c == ctry)
        cname <- unique(df_c$country)
        col_c <- col_map[ctry]

        # Optional smoothing
        y_vals <- if (isTRUE(input$smooth_lines) && sum(!is.na(df_c$val)) > 4) {
          tryCatch(
            predict(loess(val ~ year, data = df_c, span = 0.4)),
            error = function(e) df_c$val
          )
        } else {
          df_c$val
        }

        unit_lbl <- if (input$display_mode == "raw") {
          paste0(" ", var_unit(var_sel))
        } else if (var_sel == "gdp_growth") {
          " (index)"
        } else {
          " pp"
        }

        p <- p %>% add_trace(
          data       = df_c,
          x          = ~year,
          y          = y_vals,
          type       = "scatter",
          mode       = "lines+markers",
          name       = cname,
          line       = list(color = col_c, width = 2.5),
          marker     = list(color = col_c, size = 5),
          text       = paste0(
            "<b>", cname, "</b><br>",
            "Year: ", df_c$year, "<br>",
            round(df_c$val, 2), unit_lbl,
            source_hover(df_c$src)
          ),
          hoverinfo  = "text"
        )
      }

      # Crisis year annotations
      shapes <- list()
      annotations <- list()
      if (isTRUE(input$show_crisis)) {
        crisis_years <- c(2009, 2020)
        crisis_labels <- c("GFC", "COVID-19")
        for (k in seq_along(crisis_years)) {
          yr <- crisis_years[k]
          if (yr >= input$year_range[1] && yr <= input$year_range[2]) {
            shapes <- c(shapes, list(list(
              type    = "line",
              x0 = yr, x1 = yr, y0 = 0, y1 = 1,
              xref = "x", yref = "paper",
              line = list(color = "#94a3b8", dash = "dash", width = 1.5)
            )))
            annotations <- c(annotations, list(list(
              x      = yr,
              y      = 0.98,
              xref   = "x",
              yref   = "paper",
              text   = crisis_labels[k],
              showarrow = FALSE,
              font   = list(size = 10, color = "#64748b"),
              xanchor = "left"
            )))
          }
        }
      }

      # Zero line
      zero_line_shapes <- if (input$display_mode == "raw" && VARS[[var_sel]]$zero_line ||
                              input$display_mode == "indexed" && var_sel != "gdp_growth") {
        list(list(
          type = "line",
          x0 = min(df$year), x1 = max(df$year),
          y0 = 0, y1 = 0, xref = "x", yref = "y",
          line = list(color = "#94a3b8", dash = "dot", width = 1)
        ))
      } else list()

      p %>%
        layout(
          xaxis = list(
            title    = "Year",
            tickfont = list(size = 11),
            gridcolor = "#f1f5f9"
          ),
          yaxis = list(
            title    = if (input$display_mode == "raw") var_label(var_sel)
                       else change_label(var_sel, input$base_year),
            tickfont = list(size = 11),
            gridcolor = "#f1f5f9",
            zerolinecolor = "#94a3b8"
          ),
          legend = list(
            orientation = "h",
            x = 0, y = -0.15,
            font = list(size = 11)
          ),
          hovermode    = "x unified",
          shapes       = c(shapes, zero_line_shapes),
          annotations  = annotations,
          margin       = list(l = 70, r = 30, t = 20, b = 80),
          paper_bgcolor = "#ffffff",
          plot_bgcolor  = "#ffffff"
        ) %>%
        config(
          displaylogo    = FALSE,
          responsive     = TRUE,
          modeBarButtons = list(list("toImage", "zoom2d", "pan2d", "resetScale2d")),
          toImageButtonOptions = list(format = "png", filename = "country_comparison",
                                     width = 1200, height = 600)
        )
    })

    # Optional data table
    output$data_table <- renderTable({
      req(plot_data())
      plot_data() %>%
        select(-any_of("src")) %>%
        pivot_wider(names_from = iso2c, values_from = val) %>%
        rename(Year = year) %>%
        select(-country) %>%
        mutate(across(-Year, ~ round(.x, 2)))
    }, striped = TRUE, hover = TRUE, bordered = TRUE, digits = 2)
  })
}

# Change since base year for one country's series (sorted by year).
# Growth rates are chained into a level index (base year = 100); any other
# rate or ratio becomes its difference in percentage points from the base year.
# Returns NA where the base year is missing or a gap breaks the chain.
change_since_base <- function(val, year, base_year, chain_growth) {
  out <- rep(NA_real_, length(val))
  b <- match(base_year, year)
  if (is.na(b) || (!chain_growth && is.na(val[b]))) return(out)
  if (!chain_growth) return(val - val[b])

  out[b] <- 100
  # Forward: the level grows by each year's growth rate
  for (i in seq_len(length(val) - b) + b) {
    if (year[i] != year[i - 1] + 1 || is.na(val[i])) break
    out[i] <- out[i - 1] * (1 + val[i] / 100)
  }
  # Backward: undo the growth of the following year
  for (i in rev(seq_len(b - 1))) {
    if (year[i + 1] != year[i] + 1 || is.na(val[i + 1])) break
    out[i] <- out[i + 1] / (1 + val[i + 1] / 100)
  }
  out
}

change_label <- function(v, base_year) {
  if (v == "gdp_growth") {
    paste0("Real GDP index (", base_year, " = 100)")
  } else {
    paste0(var_short(v), " — change since ", base_year, " (percentage points)")
  }
}
