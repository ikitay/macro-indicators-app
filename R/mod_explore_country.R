# =============================================================================
# MODULE: EXPLORE COUNTRY (Tab 1)
# Purpose: Track one country's macroeconomic indicators over time.
# Key feature: Five synchronized time-series panels with shared x-axis.
# =============================================================================

# ── UI ────────────────────────────────────────────────────────────────────────
explore_country_ui <- function(id) {
  ns <- NS(id)
  layout_sidebar(
    fillable = FALSE,
    sidebar = sidebar(
      width = 270,
      open  = "open",

      # ── Tab explanation ──────────────────────────────────────────────────
      tags$div(
        class = "sidebar-intro",
        tags$p(
          style = "font-size:0.83rem; color:#555; line-height:1.5; margin-bottom:12px;",
          "Elegí un país y un período para ver cómo evolucionaron sus indicadores ",
          "macroeconómicos. Buscá patrones, crisis y períodos de recuperación."
        )
      ),

      # ── Country selector ─────────────────────────────────────────────────
      selectizeInput(
        ns("country"),
        label   = tags$span("🌍 País", info_icon("Crecimiento del PBI")),
        choices = NULL,       # Populated server-side
        selected = DEFAULT_COUNTRY,
        options = list(
          placeholder = "Escribí para buscar…",
          maxOptions  = 300
        )
      ),

      # ── Year range ───────────────────────────────────────────────────────
      sliderInput(
        ns("year_range"),
        label = "📅 Período",
        min   = YEAR_MIN,
        max   = YEAR_MAX,
        value = c(1995, YEAR_MAX),
        step  = 1,
        sep   = ""
      ),

      hr(),

      # ── Indicator toggles ────────────────────────────────────────────────
      checkboxGroupInput(
        ns("show_central"),
        label    = OBJECTIVE_GROUPS[["central"]],
        choices  = setNames(group_vars("central"), sapply(group_vars("central"), var_objective_label)),
        selected = group_vars("central")
      ),
      checkboxGroupInput(
        ns("show_sustainability"),
        label    = OBJECTIVE_GROUPS[["sustainability"]],
        choices  = setNames(group_vars("sustainability"),
                            sapply(group_vars("sustainability"), var_objective_label)),
        selected = c("fiscal_balance", "public_debt", "trade_balance", "current_account")
      ),
      checkboxGroupInput(
        ns("show_other"),
        label    = OBJECTIVE_GROUPS[["other"]],
        choices  = setNames(group_vars("other"), sapply(group_vars("other"), var_objective_label)),
        selected = character(0)
      ),

      hr(),

      # ── Display options ──────────────────────────────────────────────────
      checkboxInput(ns("show_trend"),     "Mostrar línea de tendencia",        value = FALSE),
      checkboxInput(ns("show_recession"), "Sombrear los años con caída del PBI", value = TRUE),

      hr(),

      # ── Quick stat summary ───────────────────────────────────────────────
      tags$p(tags$b("Resumen del período"), style = "font-size:0.85rem; margin-bottom:4px;"),
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
          "Fuentes: Banco Mundial y FMI | Pasá el mouse para ver valores | Arrastrá para hacer zoom | Doble clic para volver"
        )
      ),
      card_body(
        padding = "0",
        uiOutput(ns("plot_container"))
      )
    ),

    # ── Levels vs rates ───────────────────────────────────────────────────────
    card(
      full_screen = TRUE,
      card_header(tags$span(style = "font-weight:700; color:#1e3a5f;",
                            "Niveles y tasas: IPC e inflación, PBI nominal y PBI real")),
      card_body(
        layout_columns(
          col_widths = c(6, 6),
          tags$div(
            plotlyOutput(ns("price_level_plot"), height = "320px"),
            tags$div(class = "info-box", style = "font-size:0.82rem;",
              tags$b("IPC ≠ inflación. "),
              "La línea es un índice de precios (el primer año del período = 100). La ",
              "inflación de cada año es la variación porcentual de ese índice: si pasa de 100 ",
              "a 110, la inflación fue del 10%. Pasá el mouse para ver la inflación de cada año.")
          ),
          tags$div(
            plotlyOutput(ns("gdp_level_plot"), height = "320px"),
            tags$div(class = "info-box", style = "font-size:0.82rem;",
              tags$b("PBI nominal ≠ PBI real. "),
              "El PBI nominal usa los precios de cada año, así que crece también cuando suben ",
              "los precios. El PBI real descuenta ese efecto: solo crece si se produce más. ",
              "La distancia entre las dos líneas es el efecto de los precios.")
          )
        ),
        uiOutput(ns("levels_note"))
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
        selected = DEFAULT_COUNTRY,
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
        paste("Panorama macroeconómico:", country_name[1])
      )
    })

    # Indicators ticked in either group, in CORE_VARS order
    shown_vars <- reactive({
      intersect(CORE_VARS, c(input$show_central, input$show_sustainability, input$show_other))
    })

    # One panel per indicator, so the chart grows with the number shown
    output$plot_container <- renderUI({
      plotlyOutput(ns("main_plot"), height = paste0(max(300, 115 * length(shown_vars()) + 60), "px"))
    })

    # ── Summary statistics cards ────────────────────────────────────────────
    output$summary_cards <- renderUI({
      req(country_data())
      df <- country_data()
      vars_shown <- shown_vars()

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
              paste0(var_objective(v), " · ", var_short(v))
            ),
            tags$div(
              style = "display:flex; justify-content:space-between; font-size:0.82rem;",
              tags$span(
                style = "color:#334155;",
                paste0("Promedio: ", format_stat(avg_val, v))
              ),
              tags$span(
                style = "color:#334155;",
                paste0("Último: ", format_stat(last_val, v))
              )
            )
          )
        })
      )
    })

    # ── Main synchronized subplot ──────────────────────────────────────────
    output$main_plot <- renderPlotly({
      req(country_data())
      df        <- country_data()
      vars_show <- shown_vars()
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
              "Año: ", df$year, "<br>",
              "Valor: ", num_es(vals, 2), " ", var_unit(v),
              source_hover(var_source(df, v))
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

      fig <- do.call(
        subplot,
        c(plot_list, list(
          nrows        = n,
          shareX       = TRUE,
          titleY       = TRUE,
          heights      = rep(h_per, n)
        ))
      )
      # Add to the panels' zero lines rather than replacing them
      if (isTRUE(input$show_recession)) {
        fig$x$layout$shapes <- c(fig$x$layout$shapes, negative_growth_shapes(df))
      }

      fig %>%
        layout(
          hovermode = "x unified",
          xaxis     = list(title = "Año"),
          margin    = list(l = 70, r = 30, t = 20, b = 50),
          paper_bgcolor = "#ffffff",
          plot_bgcolor  = "#ffffff"
        ) %>%
        config(
          displaylogo = FALSE, locale = "es",
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

    # ── Levels vs rates ──────────────────────────────────────────────────────
    levels_data <- reactive({
      req(country_data())
      df <- country_data()
      base <- df$year[1]
      data.frame(
        year         = df$year,
        inflation    = df$inflation,
        price_index  = change_since_base(df$inflation, df$year, base, chain_growth = TRUE),
        gdp_nominal  = level_index(df$gdp_nominal_lcu, df$year, base),
        gdp_real     = level_index(df$gdp_real_lcu, df$year, base)
      )
    })

    level_layout <- function(p, y_title, values) {
      log_axis <- use_log_axis(values)
      p %>%
        layout(
          xaxis = list(title = "Año", gridcolor = "#f1f5f9"),
          yaxis = list(title = paste0(y_title, if (log_axis) "<br>escala logarítmica"),
                       type = if (log_axis) "log" else "linear", gridcolor = "#f1f5f9"),
          legend = list(orientation = "h", x = 0, y = -0.25),
          hovermode = "x unified",
          margin = list(l = 60, r = 20, t = 10, b = 40),
          paper_bgcolor = "#ffffff", plot_bgcolor = "#ffffff"
        ) %>%
        config(displaylogo = FALSE, locale = "es", modeBarButtons = list(list("toImage")))
    }

    output$price_level_plot <- renderPlotly({
      d <- levels_data()
      validate(need(any(!is.na(d$price_index)), "No hay datos de inflación para este período."))
      plot_ly(d, x = ~year) %>%
        add_trace(y = ~price_index, type = "scatter", mode = "lines+markers",
                  name = "Índice de precios", line = list(color = var_color("inflation"), width = 2.5),
                  marker = list(color = var_color("inflation"), size = 5),
                  text = paste0("Índice: ", num_es(d$price_index), "<br>Inflación del año: ",
                                ifelse(is.na(d$inflation), "s/d", paste0(num_es(d$inflation), "%"))),
                  hoverinfo = "text") %>%
        level_layout(paste0("Índice de precios (", d$year[1], " = 100)"), d$price_index)
    })

    output$gdp_level_plot <- renderPlotly({
      d <- levels_data()
      validate(need(any(!is.na(d$gdp_nominal)) || any(!is.na(d$gdp_real)),
                    "No hay datos del PBI en moneda local para este período."))
      plot_ly(d, x = ~year) %>%
        add_trace(y = ~gdp_nominal, type = "scatter", mode = "lines+markers", name = "PBI nominal",
                  line = list(color = "#d97706", width = 2.5), marker = list(color = "#d97706", size = 5),
                  text = paste0("PBI nominal: ", num_es(d$gdp_nominal)), hoverinfo = "text") %>%
        add_trace(y = ~gdp_real, type = "scatter", mode = "lines+markers", name = "PBI real",
                  line = list(color = var_color("gdp_growth"), width = 2.5),
                  marker = list(color = var_color("gdp_growth"), size = 5),
                  text = paste0("PBI real: ", num_es(d$gdp_real)), hoverinfo = "text") %>%
        level_layout(paste0("Índice (", d$year[1], " = 100)"), c(d$gdp_nominal, d$gdp_real))
    })

    # The period's totals, in words
    output$levels_note <- renderUI({
      d <- levels_data()
      last <- function(x) { x <- x[!is.na(x)]; if (length(x)) x[length(x)] else NA }
      n <- last(d$gdp_nominal); r <- last(d$gdp_real); p <- last(d$price_index)
      if (anyNA(c(n, r, p))) return(NULL)
      # One string, so no whitespace appears around the bold numbers
      tags$p(style = "font-size:0.85rem; color:#334155; margin:8px 0 0;", HTML(paste0(
        "Entre ", d$year[1], " y ", d$year[nrow(d)], " el PBI nominal se multiplicó por <b>",
        num_es(n / 100, 2), "</b> y el PBI real por <b>", num_es(r / 100, 2),
        "</b>, mientras el índice de precios se multiplicó por <b>", num_es(p / 100, 2), "</b>.")))
    })
  })
}

# Helper: format a statistic value for display
format_stat <- function(x, var_name = NULL) {
  if (is.na(x)) return("s/d")
  if (!is.null(var_name) && var_name == "population") {
    if (x >= 1e9) return(paste0(num_es(x / 1e9), " mil millones"))
    if (x >= 1e6) return(paste0(num_es(x / 1e6), " millones"))
    return(num_es(x, 0))
  }
  paste0(num_es(x), "%")
}

# Grey bands behind every panel for the years in which real GDP fell
negative_growth_shapes <- function(df) {
  yrs <- df$year[!is.na(df$gdp_growth) & df$gdp_growth < 0]
  lapply(yrs, function(y) list(
    type = "rect", xref = "x", yref = "paper",
    x0 = y - 0.5, x1 = y + 0.5, y0 = 0, y1 = 1,
    fillcolor = "rgba(148,163,184,0.18)", line = list(width = 0), layer = "below"
  ))
}

# A level as an index, base year = 100 (NA when the base year has no value)
level_index <- function(level, year, base_year) {
  base <- level[match(base_year, year)]
  if (length(base) == 0 || is.na(base) || base == 0) return(rep(NA_real_, length(level)))
  100 * level / base
}

# Use a log axis when the series spans a very wide range (e.g. high inflation)
use_log_axis <- function(values) {
  v <- values[!is.na(values) & values > 0]
  length(v) > 1 && max(v) / min(v) > 20
}
