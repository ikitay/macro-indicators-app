# =============================================================================
# MODULE: COUNTRY PROFILE (Tab 4)
# Purpose: Radar chart of the three central objectives for up to 4 countries,
#   with the fiscal and external balances shown alongside, unscored, as
#   sustainability information.
# =============================================================================

PROFILE_PALETTE <- c("#2563eb", "#dc2626", "#16a34a", "#d97706")

PROFILE_AXES <- c(
  gdp_growth = "Crecimiento económico\n(crecimiento del PBI)",
  unemployment = "Pleno empleo\n(desempleo bajo)",
  inflation  = "Estabilidad de precios\n(inflación cerca del 2%)"
)

# Column headers of the sustainability table, in SUSTAINABILITY_VARS order
PROFILE_SUSTAINABILITY_LABELS <- c(
  fiscal_balance  = "Resultado",
  public_debt     = "Deuda",
  trade_balance   = "Saldo comercial",
  current_account = "Cuenta corriente"
)

PROFILE_SCORE_LABELS <- c(
  gdp_growth = "Crecimiento",
  unemployment = "Empleo",
  inflation  = "Precios"
)

country_profile_ui <- function(id) {
  ns <- NS(id)
  layout_sidebar(
    fillable = TRUE,
    sidebar = sidebar(
      width = 280, open = "open",
      tags$div(class = "sidebar-intro",
        tags$p(style = "font-size:0.83rem; color:#555; line-height:1.5; margin-bottom:12px;",
          "Compará cómo les fue a los países en los tres objetivos centrales en un año, ",
          "y después fijate si su situación fiscal y externa permitía sostenerlo."
        )
      ),
      selectizeInput(ns("countries"), "🌍 Países (hasta 4)",
        choices  = NULL,
        selected = DEFAULT_PEERS,
        multiple = TRUE,
        options  = list(maxItems=4, placeholder="Escribí para buscar…", maxOptions=300)
      ),
      sliderInput(ns("year"), "📅 Año de referencia",
        min=YEAR_MIN, max=YEAR_MAX, value=2019, step=1, sep=""
      ),
      hr(),
      checkboxInput(ns("fill_area"), "Rellenar el área", value = TRUE),
      hr(),
      tags$div(
        style = "background:#fff8e1; border:1px solid #fde68a; border-radius:6px; padding:10px;",
        tags$p(style="font-size:0.8rem; color:#78350f; margin:0;",
          tags$b("📏 Cómo se calculan los puntajes: "),
          "cada puntaje (0 a 100) compara este país y año con ",
          tags$b("todos los países entre 1990 y 2023."),
          " Un puntaje de 70 significa que le fue mejor que en el 70% de esas observaciones. ",
          tags$b("Estabilidad de precios"), " premia una inflación cercana al 2%: tanto la ",
          "inflación alta como la deflación puntúan más bajo. Si falta un dato, queda en blanco ",
          "en lugar de contar como cero."
        )
      )
    ),
    card(
      full_screen = TRUE,
      card_header(uiOutput(ns("chart_title"))),
      card_body(
        padding = "0",
        layout_columns(
          col_widths = c(7, 5),
          plotlyOutput(ns("radar_plot"), height = "480px"),
          tags$div(
            uiOutput(ns("score_table")),
            uiOutput(ns("sustainability_table"))
          )
        )
      ),
      card_footer(
        tags$div(class="info-box",
          tags$span("🕸️ "), tags$b("Cómo leer este gráfico: "),
          "un área más grande indica mejores resultados en los tres objetivos centrales ese año. ",
          "No dice si esos resultados pueden sostenerse: una economía puede crecer, crear empleo ",
          "y mantener la inflación baja mientras acumula desequilibrios fiscales o externos. ",
          "Por eso la información fiscal y externa se muestra aparte, sin puntaje."
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
        choices=get_country_choices(data()), selected=DEFAULT_PEERS, server=FALSE)
    })

    # Scores always compare against the full global dataset (all countries, all
    # years), so a score keeps the same meaning when the selected year changes.
    scored_data <- reactive({
      req(data())
      score_central_objectives(data())
    })

    profile_data <- reactive({
      req(scored_data(), input$countries, input$year)
      scored_data() %>%
        filter(iso2c %in% input$countries, year == input$year) %>%
        select(country, iso2c, all_of(paste0(CENTRAL_VARS, "_score")))
    })

    # Fiscal and trade balance in the reference year and five years earlier
    sustainability_data <- reactive({
      req(data(), input$countries, input$year)
      df <- data() %>% filter(iso2c %in% input$countries)
      now  <- df %>% filter(year == input$year)
      past <- df %>% filter(year == input$year - 5) %>%
        select(iso2c, any_of(SUSTAINABILITY_VARS))
      names(past)[-1] <- paste0(names(past)[-1], "_past")
      now %>%
        select(country, iso2c, any_of(SUSTAINABILITY_VARS)) %>%
        left_join(past, by = "iso2c")
    })

    output$chart_title <- renderUI({
      req(input$year)
      tags$span(style="font-weight:700; color:#1e3a5f;",
        paste0("Objetivos centrales y sostenibilidad (", input$year, ")"))
    })

    output$radar_plot <- renderPlotly({
      req(profile_data())
      df <- profile_data()
      validate(need(nrow(df) > 0, "No hay datos para los países y el año elegidos."))

      axis_labels <- unname(PROFILE_AXES[CENTRAL_VARS])
      score_cols  <- paste0(CENTRAL_VARS, "_score")

      p <- plot_ly()

      for (i in seq_len(nrow(df))) {
        vals <- as.numeric(df[i, score_cols])
        col <- PROFILE_PALETTE[i]
        closed_r     <- c(vals, vals[1])
        closed_theta <- c(axis_labels, axis_labels[1])
        hover <- paste0(gsub("\n", " ", closed_theta), ": ",
                        ifelse(is.na(closed_r), "sin datos", paste0(round(closed_r), "/100")))

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
          text  = hover,
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
            # Growth at the top, so no long label sits at the left or right edge
            angularaxis = list(tickfont=list(size=11.5), rotation=90, direction="clockwise")
          ),
          legend = list(
            orientation="h", x=0.5, y=-0.12, xanchor="center",
            font=list(size=11)
          ),
          margin = list(l=110,r=110,t=50,b=80),
          paper_bgcolor="#ffffff"
        ) %>%
        config(displaylogo = FALSE, locale = "es", responsive=TRUE,
               modeBarButtons=list(list("toImage")),
               toImageButtonOptions=list(format="png",filename="perfil_pais",width=900,height=700))
    })

    output$score_table <- renderUI({
      req(profile_data())
      df <- profile_data()
      validate(need(nrow(df) > 0, ""))

      score_cell <- function(x) {
        if (is.na(x)) return(tags$td(style = "text-align:right; color:#94a3b8;", "sin datos"))
        v   <- round(x)
        col <- if (v >= 60) "#16a34a" else if (v >= 35) "#d97706" else "#dc2626"
        tags$td(style = "text-align:right;",
          tags$span(style = paste0("display:inline-block; min-width:34px; padding:1px 6px; ",
                                   "border-radius:4px; color:white; font-weight:600; ",
                                   "background:", col, ";"), v))
      }

      tags$div(
        style = "padding:10px 10px 0;",
        tags$p(style="font-size:0.8rem; font-weight:700; color:#1e3a5f; margin-bottom:4px;",
               "Objetivos centrales: puntajes (0 a 100)"),
        tags$table(
          class = "table table-sm",
          style = "font-size:0.78rem; margin-bottom:10px;",
          tags$thead(tags$tr(
            tags$th(""),
            lapply(CENTRAL_VARS, function(v)
              tags$th(style = "text-align:right;", PROFILE_SCORE_LABELS[[v]]))
          )),
          tags$tbody(lapply(seq_len(nrow(df)), function(i) {
            tags$tr(
              tags$td(style = paste0("font-weight:700; color:", PROFILE_PALETTE[i], ";"),
                      df$country[i]),
              lapply(paste0(CENTRAL_VARS, "_score"), function(sc) score_cell(df[[sc]][i]))
            )
          }))
        )
      )
    })

    output$sustainability_table <- renderUI({
      req(sustainability_data(), profile_data())
      df    <- sustainability_data()
      order <- match(profile_data()$iso2c, df$iso2c)
      df    <- df[order[!is.na(order)], , drop = FALSE]
      validate(need(nrow(df) > 0, ""))

      # Balances get a sign; debt is a stock and is always positive
      fmt <- function(x, v) {
        if (is.na(x)) return("s/d")
        paste0(if (v != "public_debt" && x > 0) "+", num_es(x), "%")
      }
      col_of <- function(x) if (x %in% names(df)) df[[x]] else rep(NA_real_, nrow(df))
      cell <- function(v, i) {
        tags$td(style = "text-align:right;",
          tags$span(style = "font-weight:600; color:#334155;", fmt(col_of(v)[i], v)),
          tags$br(),
          tags$span(style = "font-size:0.68rem; color:#64748b;",
                    paste0(input$year - 5, ": ", fmt(col_of(paste0(v, "_past"))[i], v)))
        )
      }
      group_head <- function(label) {
        tags$th(colspan = 2, style = "text-align:center; border-bottom:1px solid #cbd5e1;", label)
      }

      tags$div(
        style = "padding:4px 10px 10px;",
        tags$p(style="font-size:0.8rem; font-weight:700; color:#1e3a5f; margin-bottom:4px;",
               "Información de sostenibilidad: % del PBI, sin puntaje"),
        tags$table(
          class = "table table-sm",
          style = "font-size:0.76rem; margin-bottom:6px;",
          tags$thead(
            tags$tr(tags$th(""), group_head("Fiscal"), group_head("Externa")),
            tags$tr(
              tags$th(""),
              lapply(SUSTAINABILITY_VARS, function(v)
                tags$th(style = "text-align:right; font-weight:600;", PROFILE_SUSTAINABILITY_LABELS[[v]]))
            )
          ),
          tags$tbody(lapply(seq_len(nrow(df)), function(i) {
            col <- PROFILE_PALETTE[match(df$iso2c[i], profile_data()$iso2c)]
            tags$tr(
              tags$td(style = paste0("font-weight:700; color:", col, ";"), df$country[i]),
              lapply(SUSTAINABILITY_VARS, cell, i = i)
            )
          }))
        ),
        tags$p(style = "font-size:0.74rem; color:#64748b; margin:0; line-height:1.4;",
          "Un déficit (valor negativo) no es automáticamente un problema. La sostenibilidad ",
          "fiscal depende de la trayectoria de la deuda pública; la externa, de cómo se ",
          "financia el déficit de cuenta corriente. Compará con cinco años antes: ",
          "¿el desequilibrio crece o se achica?"
        )
      )
    })
  })
}
