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
          "Elegí hasta 6 países y un indicador. Podés ver los valores originales ",
          "o el cambio desde un año base para comparar trayectorias."
        )
      ),

      # ── Country selection ─────────────────────────────────────────────────
      selectizeInput(
        ns("countries"),
        label   = "🌍 Países (hasta 6)",
        choices = NULL,
        selected = c("US", "DE", "CN", "AR", "KR", "ZA"),
        multiple = TRUE,
        options  = list(
          maxItems    = 6,
          placeholder = "Escribí para buscar…",
          maxOptions  = 300
        )
      ),

      # ── Variable ─────────────────────────────────────────────────────────
      selectInput(
        ns("variable"),
        label    = "📊 Indicador",
        choices  = core_var_choices(),
        selected = "gdp_growth"
      ),

      # ── Year range ───────────────────────────────────────────────────────
      sliderInput(
        ns("year_range"),
        label = "📅 Período",
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
        label    = "Modo de visualización",
        choices  = c(
          "Valores originales"     = "raw",
          "Cambio desde el año base" = "indexed"
        ),
        selected = "raw"
      ),

      conditionalPanel(
        condition = paste0("input['", ns("display_mode"), "'] == 'indexed'"),
        sliderInput(
          ns("base_year"),
          label = "📌 Año base",
          min   = YEAR_MIN,
          max   = YEAR_MAX,
          value = 2000,
          step  = 1,
          sep   = ""
        ),
        tags$small(
          style = "color:#64748b; font-size:0.78rem;",
          "El crecimiento del PBI se convierte en un índice del PBI real (año base = 100). ",
          "Los demás indicadores ya son tasas o proporciones, así que se muestra su cambio ",
          "en puntos porcentuales."
        )
      ),

      hr(),

      # ── Options ────────────────────────────────────────────────────────────
      checkboxInput(ns("show_crisis"),  "Marcar años de crisis (2009, 2020)", value = TRUE),
      checkboxInput(ns("smooth_lines"), "Suavizar las líneas", value = FALSE),

      hr(),

      # ── Data table toggle ─────────────────────────────────────────────────
      checkboxInput(ns("show_table"), "Mostrar tabla de datos", value = FALSE)
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
            "Pasá el mouse para ver detalles | Clic en la leyenda para mostrar u ocultar países"
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
          card_header("📋 Tabla de datos"),
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
        need(length(input$countries) >= 1, "Elegí al menos un país."),
        need(input$variable %in% CORE_VARS, "Elegí un indicador válido.")
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
            tags$b("Índice del PBI real: "),
            "las tasas de crecimiento se encadenan para obtener el nivel del PBI real, igual a ",
            "100 en el año base. Un valor de 110 significa que la economía produce un 10% más ",
            "que en el año base. El crecimiento es la variación del PBI real: si un país pasa ",
            "de crecer un 2% a crecer un 4%, duplica su tasa de crecimiento, pero después de ",
            "esos dos años su PBI real es apenas un 6% mayor."
          )
        } else {
          tagList(
            tags$b("Cambio en puntos porcentuales: "),
            var_short(input$variable), " ya es una tasa o una proporción, así que dividirlo por ",
            "su valor del año base no tendría sentido (una tasa que pasa del 2% al 4% no es ",
            "\"el doble de economía\"). El gráfico muestra cuántos puntos porcentuales se movió ",
            "desde el año base: +2 significa 2 puntos más que en el año base."
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
          " (índice)"
        } else {
          " p.p."
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
            "Año: ", df_c$year, "<br>",
            num_es(df_c$val, 2), unit_lbl,
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
        crisis_labels <- c("Crisis financiera", "COVID-19")
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
            title    = "Año",
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
          displaylogo = FALSE, locale = "es",
          responsive     = TRUE,
          modeBarButtons = list(list("toImage", "zoom2d", "pan2d", "resetScale2d")),
          toImageButtonOptions = list(format = "png", filename = "comparacion_paises",
                                     width = 1200, height = 600)
        )
    })

    # Optional data table
    output$data_table <- renderTable({
      req(plot_data())
      plot_data() %>%
        select(Año = year, country, val) %>%
        pivot_wider(names_from = country, values_from = val) %>%
        arrange(Año) %>%
        mutate(Año = as.character(Año), across(-Año, ~ num_es(.x, 2)))
    }, striped = TRUE, hover = TRUE, bordered = TRUE, align = "r")
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
    paste0("Índice del PBI real (", base_year, " = 100)")
  } else {
    paste0(var_short(v), ": cambio desde ", base_year, " (puntos porcentuales)")
  }
}
