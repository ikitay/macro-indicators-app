# =============================================================================
# MODULE: GLOBAL EXPLORER (Tab 3)
# Purpose: Animated scatter plot (Gapminder-style) showing cross-country
#   patterns and how they evolve over time.
# =============================================================================

global_explorer_ui <- function(id) {
  ns <- NS(id)
  layout_sidebar(
    fillable = TRUE,
    sidebar = sidebar(
      width = 280, open = "open",
      tags$div(class = "sidebar-intro",
        tags$p(style = "font-size:0.83rem; color:#555; line-height:1.5; margin-bottom:12px;",
          "Cada burbuja es un país. Mové el selector de año para explorar patrones, ",
          "o tocá el botón de reproducción para verlos cambiar en el tiempo."
        )
      ),
      selectInput(ns("x_var"), "↔ Eje X",    choices = core_var_choices(), selected = "gdp_growth"),
      selectInput(ns("y_var"), "↕ Eje Y",    choices = core_var_choices(), selected = "inflation"),
      selectInput(ns("size_var"), "⬤ Tamaño de las burbujas",
        choices  = c(list("Otros" = c("Todas iguales" = "equal", "Población" = "population")),
                     core_var_choices()),
        selected = "population"
      ),
      hr(),
      checkboxGroupInput(ns("regions"), "🌐 Regiones",
        choices  = names(REGION_COLORS),
        selected = names(REGION_COLORS)
      ),
      hr(),
      sliderInput(ns("static_year"), "📅 Año",
        min = YEAR_MIN, max = YEAR_MAX, value = 2019, step = 1, sep = "",
        animate = animationOptions(interval = 900, loop = FALSE)
      ),
      hr(),
      checkboxInput(ns("log_size"),    "Tamaño en escala logarítmica", value = TRUE),
      checkboxInput(ns("show_labels"), "Rotular los países más grandes", value = TRUE),
      tags$small(style = "color:#64748b; font-size:0.78rem;",
        "No se muestran los países sin datos para alguno de los dos ejes.")
    ),
    card(
      full_screen = TRUE,
      card_header(
        class = "d-flex justify-content-between align-items-center",
        uiOutput(ns("chart_title")),
        tags$div(style = "font-size:0.78rem; color:#64748b;",
          "Pasá el mouse para ver detalles | Usá el selector de año para animar")
      ),
      card_body(padding = "0", plotlyOutput(ns("scatter_plot"), height = "520px")),
      card_footer(
        tags$div(class = "info-box",
          tags$span("🔍 "), tags$b("Preguntas: "),
          "¿Los países con más inflación crecen menos? ¿Un crecimiento alto viene siempre ",
          "con una tasa de empleo alta? ¿Los países con déficit fiscal tienen también déficit ",
          "comercial? Los casos que se apartan del patrón suelen contar la historia más interesante."
        )
      )
    )
  )
}

global_explorer_server <- function(id, data) {
  moduleServer(id, function(input, output, session) {

    plot_data <- reactive({
      req(data(), input$x_var, input$y_var, input$static_year, input$regions)
      validate(need(input$x_var != input$y_var, "Elegí variables distintas para los ejes X e Y."))

      df <- data() %>%
        filter(year == input$static_year, region %in% input$regions) %>%
        select(country, iso2c, year, region,
               x_val = all_of(input$x_var),
               y_val = all_of(input$y_var),
               any_of(c("population", CORE_VARS))) %>%
        filter(!is.na(x_val), !is.na(y_val))

      if (nrow(df) == 0) return(df)

      # Compute bubble size
      if (input$size_var == "equal") {
        df$size_val <- 20
      } else if (input$size_var == "population" && "population" %in% names(df)) {
        df$size_val <- df$population
      } else if (input$size_var %in% names(df)) {
        df$size_val <- abs(df[[input$size_var]])
      } else {
        df$size_val <- 20
      }

      if (isTRUE(input$log_size) && input$size_var != "equal")
        df$size_val <- log1p(pmax(0, df$size_val))

      s_min <- min(df$size_val, na.rm = TRUE)
      s_max <- max(df$size_val, na.rm = TRUE)
      df$size_val <- if (s_max > s_min) 6 + 54 * (df$size_val - s_min) / (s_max - s_min) else 20

      df$hover_text <- paste0(
        "<b>", df$country, "</b> (", df$year, ")<br>",
        var_label(input$x_var), ": <b>", num_es(df$x_val, 2), " ", var_unit(input$x_var), "</b><br>",
        var_label(input$y_var), ": <b>", num_es(df$y_val, 2), " ", var_unit(input$y_var), "</b><br>",
        "Región: ", df$region
      )
      df
    })

    output$chart_title <- renderUI({
      req(input$x_var, input$y_var, input$static_year)
      tags$span(style = "font-weight:700; color:#1e3a5f;",
        paste0(var_short(input$y_var), " vs. ", var_short(input$x_var), " (", input$static_year, ")"))
    })

    output$scatter_plot <- renderPlotly({
      req(plot_data())
      df <- plot_data()
      validate(need(nrow(df) > 0, "No hay datos para esta selección."))

      regions_present <- unique(df$region)
      r_cols <- REGION_COLORS[names(REGION_COLORS) %in% regions_present]

      p <- plot_ly(
        data = df, x = ~x_val, y = ~y_val,
        size = ~size_val, color = ~region, colors = r_cols,
        text = ~hover_text, hoverinfo = "text",
        type = "scatter", mode = "markers",
        marker = list(sizemode = "diameter", opacity = 0.72,
                      line = list(width = 1, color = "white"))
      )

      if (isTRUE(input$show_labels)) {
        lbl_df <- df %>% arrange(desc(size_val)) %>% slice_head(n = 14)
        p <- p %>% add_trace(
          data = lbl_df, x = ~x_val, y = ~y_val,
          type = "scatter", mode = "text", text = ~iso2c,
          textfont = list(size = 9, color = "#334155"),
          hoverinfo = "none", showlegend = FALSE
        )
      }

      shapes <- list()
      if (isTRUE(VARS[[input$x_var]]$zero_line))
        shapes <- c(shapes, list(list(type="line", x0=0,x1=0,y0=0,y1=1,
          xref="x",yref="paper", line=list(color="#94a3b8",dash="dot",width=1))))
      if (isTRUE(VARS[[input$y_var]]$zero_line))
        shapes <- c(shapes, list(list(type="line", x0=0,x1=1,y0=0,y1=0,
          xref="paper",yref="y", line=list(color="#94a3b8",dash="dot",width=1))))

      size_note <- switch(input$size_var,
        "equal"      = "Burbujas del mismo tamaño",
        "population" = "Tamaño de la burbuja = población",
        paste0("Tamaño de la burbuja = ", var_short(input$size_var)))

      p %>%
        layout(
          xaxis  = list(title=var_label(input$x_var), tickfont=list(size=11), gridcolor="#f1f5f9"),
          yaxis  = list(title=var_label(input$y_var), tickfont=list(size=11), gridcolor="#f1f5f9"),
          legend = list(orientation="v", x=1.01, y=0.99,
                        font=list(size=10), title=list(text="<b>Región</b>")),
          annotations = list(list(x=0.01,y=0.01,xref="paper",yref="paper",
            text=size_note, showarrow=FALSE, font=list(size=9,color="#94a3b8"), xanchor="left")),
          shapes = shapes,
          margin = list(l=70,r=165,t=20,b=70),
          paper_bgcolor="#ffffff", plot_bgcolor="#ffffff"
        ) %>%
        config(displaylogo = FALSE, locale = "es", responsive=TRUE,
               modeBarButtons=list(list("toImage","zoom2d","pan2d","resetScale2d")),
               toImageButtonOptions=list(format="png",filename="explorador_global",width=1400,height=700))
    })
  })
}
