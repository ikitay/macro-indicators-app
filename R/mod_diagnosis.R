# =============================================================================
# MODULE: ¿CÓMO ESTÁ ESTA ECONOMÍA? (Tab 5)
# Purpose: The course notes' integrative case ("Caso integrador"), built from
#   real data. Students pick a country and a year, read each objective's
#   indicators, and assess the claim "the economy is fine because…" using
#   growth, employment, prices and fiscal and external sustainability. They
#   answer in writing outside the app: the app has no text boxes, because it
#   does not record anything.
# =============================================================================

DIAGNOSIS_LOOKBACK <- 5  # years back for the sustainability trajectory

`%||%` <- function(a, b) if (is.null(a)) b else a

# The objectives of the notes' table, in order, with the indicators that
# inform each one
DIAGNOSIS_OBJECTIVES <- list(
  growth     = c("gdp_growth"),
  employment = c("unemployment", "employment"),
  prices     = c("inflation"),
  fiscal     = c("fiscal_balance", "public_debt"),
  external   = c("trade_balance", "current_account", "fdi_inflows")
)

# Balances get a sign (+/-); levels and rates do not
BALANCE_VARS <- c("fiscal_balance", "trade_balance", "current_account")

# One row per indicator for a country-year, grouped by objective: the value in
# that year, the year before, and DIAGNOSIS_LOOKBACK years before.
diagnosis_rows <- function(df, iso, year) {
  country_df <- df[df$iso2c == iso, , drop = FALSE]
  value_at <- function(v, y) {
    if (!v %in% names(country_df)) return(NA_real_)
    x <- country_df[[v]][country_df$year == y]
    if (length(x) == 0) NA_real_ else x[1]
  }
  vars <- unlist(DIAGNOSIS_OBJECTIVES, use.names = FALSE)
  data.frame(
    objective_id = rep(names(DIAGNOSIS_OBJECTIVES), lengths(DIAGNOSIS_OBJECTIVES)),
    var       = vars,
    group     = sapply(vars, function(v) VARS[[v]]$group),
    dimension = sapply(vars, function(v) VARS[[v]]$dimension),
    objective = sapply(vars, var_objective),
    indicator = sapply(vars, var_label),
    value     = sapply(vars, value_at, y = year),
    previous  = sapply(vars, value_at, y = year - 1),
    past      = sapply(vars, value_at, y = year - DIAGNOSIS_LOOKBACK),
    row.names = NULL, stringsAsFactors = FALSE
  )
}

# The claim students assess (Activity 4 in the notes), built from the central
# results that look favourable in that year. NULL when none do.
diagnosis_claim <- function(rows, country) {
  get <- function(v, col) rows[[col]][rows$var == v]
  parts <- c(
    if (isTRUE(get("gdp_growth", "value") > 0)) "el PBI creció",
    if (isTRUE(get("unemployment", "value") < get("unemployment", "previous"))) "el desempleo bajó",
    if (isTRUE(get("inflation", "value") < get("inflation", "previous"))) "la inflación bajó"
  )
  if (length(parts) == 0) return(NULL)
  listed <- if (length(parts) == 1) parts else
    paste(paste(parts[-length(parts)], collapse = ", "), "y", parts[length(parts)])
  paste0("La economía de ", country, " está bien porque ", listed, ".")
}

# Descriptive sentences for each row: what the numbers say, never a verdict
diagnosis_reading <- function(rows) {
  pct <- function(x) paste0(num_es(x), "%")
  pts <- function(x) paste0(num_es(abs(x)), if (abs(round(x, 1)) == 1) " punto" else " puntos")
  signed <- function(x) paste0(if (x > 0) "+", pct(x))
  balance_name <- c(fiscal_balance = "fiscal", trade_balance = "comercial",
                    current_account = "de cuenta corriente")
  sapply(seq_len(nrow(rows)), function(i) {
    r <- rows[i, ]
    if (is.na(r$value)) return("No hay datos para este año.")
    change <- if (is.na(r$previous)) "" else if (round(r$value - r$previous, 1) == 0)
      " Igual que el año anterior." else
      paste0(if (r$value > r$previous) " Subió " else " Bajó ", pts(r$value - r$previous),
             " respecto del año anterior.")
    earlier <- if (is.na(r$past)) "" else
      paste0(" ", DIAGNOSIS_LOOKBACK, " años antes: ",
             if (r$var %in% BALANCE_VARS) signed(r$past) else pct(r$past), " del PBI.")
    switch(r$var,
      gdp_growth = paste0(
        if (r$value > 0) "La producción aumentó: el PBI real creció un "
        else if (r$value < 0) "La producción cayó: el PBI real se redujo un "
        else "La producción no cambió: el PBI real varió un ",
        pct(abs(r$value)), "."),
      unemployment = paste0("El ", pct(r$value), " de la población económicamente activa ",
                            "buscaba trabajo y no lo encontraba.", change),
      employment = paste0("El ", pct(r$value), " de la población de 15 años o más tenía empleo.", change),
      inflation  = paste0("Los precios al consumidor subieron un ", pct(r$value),
                          " en el año.", change),
      public_debt = paste0("La deuda pública equivalía al ", pct(r$value), " del PBI.", earlier),
      fdi_inflows = paste0("La inversión extranjera directa que ingresó (neta) equivalía al ",
                           pct(r$value), " del PBI.", earlier),
      paste0(
        if (r$value < 0) paste0("Déficit ", balance_name[[r$var]], " del ")
        else if (r$value > 0) paste0("Superávit ", balance_name[[r$var]], " del ")
        else "Equilibrio",
        if (r$value != 0) paste0(pct(abs(r$value)), " del PBI.") else ".",
        earlier)
    )
  })
}

diagnosis_ui <- function(id) {
  ns <- NS(id)
  layout_sidebar(
    fillable = FALSE,
    sidebar = sidebar(
      width = 280, open = "open",
      tags$div(class = "sidebar-intro",
        tags$p(style = "font-size:0.83rem; color:#555; line-height:1.5; margin-bottom:12px;",
          "Elegí un país y un año, y construí una evaluación integrada de su situación ",
          "macroeconómica: qué está ocurriendo y si puede sostenerse."
        )
      ),
      selectizeInput(ns("country"), "🌍 País",
        choices = NULL, selected = DEFAULT_COUNTRY,
        options = list(placeholder = "Escribí para buscar…", maxOptions = 300)
      ),
      sliderInput(ns("year"), "📅 Año", min = YEAR_MIN + DIAGNOSIS_LOOKBACK, max = YEAR_MAX,
                  value = 2017, step = 1, sep = ""),
      actionButton(ns("random_case"), "🎲 Caso al azar", class = "btn btn-outline-primary btn-sm w-100"),
      hr(),
      checkboxInput(ns("show_reading"), "Mostrar una lectura guiada de los datos", value = FALSE),
      tags$small(style = "color:#64748b; font-size:0.78rem;",
        "La lectura guiada describe los números; la interpretación la hacés vos."),
      hr(),
      tags$small(style = "color:#64748b; font-size:0.78rem; line-height:1.4;",
        "✏️ Respondé las actividades por escrito, fuera de la app: la app no guarda respuestas.")
    ),
    card(
      card_header(uiOutput(ns("title"))),
      card_body(
        tags$h6(style = "color:#1e3a5f; font-weight:700;", "Actividad 1. Identificar"),
        tags$p(style = "font-size:0.85rem; color:#475569;",
          "Para cada objetivo, mirá sus indicadores y anotá qué muestra el caso. Para la ",
          "sostenibilidad no alcanza con un año: compará con cinco años antes."),
        uiOutput(ns("table"))
      )
    ),
    card(
      card_body(
        tags$h6(style = "color:#1e3a5f; font-weight:700;", "Actividad 2. Interpretar"),
        tags$p(style = "font-size:0.85rem; color:#475569; margin-bottom:4px;",
          "¿Qué resultados parecen favorables? ¿Qué problemas permanecen? ¿Qué información ",
          "del caso permite evaluar la sostenibilidad fiscal y la externa?"),
        tags$h6(style = "color:#1e3a5f; font-weight:700; margin-top:10px;", "Actividad 4. Evaluar"),
        uiOutput(ns("claim_box")),
        tags$h6(style = "color:#1e3a5f; font-weight:700; margin-top:10px;", "Actividad 5. Integrar"),
        tags$p(style = "font-size:0.85rem; color:#475569; margin-bottom:4px;",
          "¿Qué otra información necesitarías para una evaluación más completa? Organizá tu ",
          "respuesta en producción, empleo, precios, situación fiscal y situación externa. ",
          "Pista: la app no muestra, por ejemplo, la balanza de pagos completa, las reservas ",
          "internacionales ni las tasas de interés a las que se financia el Estado.")
      )
    )
  )
}

diagnosis_server <- function(id, data) {
  moduleServer(id, function(input, output, session) {

    observe({
      req(data())
      updateSelectizeInput(session, "country", choices = get_country_choices(data()),
                           selected = DEFAULT_COUNTRY, server = FALSE)
    })

    # A random country-year with data for every central and sustainability indicator
    observeEvent(input$random_case, {
      df <- data()
      needed <- intersect(c(CENTRAL_VARS, SUSTAINABILITY_VARS), names(df))
      complete <- df[stats::complete.cases(df[, needed]) &
                       df$year >= YEAR_MIN + DIAGNOSIS_LOOKBACK, ]
      if (nrow(complete) == 0) return()
      pick <- complete[sample(nrow(complete), 1), ]
      updateSelectizeInput(session, "country", selected = pick$iso2c)
      updateSliderInput(session, "year", value = pick$year)
    })

    country_name <- reactive({
      req(data(), input$country)
      data()$country[data()$iso2c == input$country][1]
    })

    rows <- reactive({
      req(data(), input$country, input$year)
      diagnosis_rows(data(), input$country, input$year)
    })

    claim <- reactive({
      diagnosis_claim(rows(), country_name()) %||%
        paste0("La economía de ", country_name(), " está bien.")
    })

    output$title <- renderUI({
      tags$span(style = "font-weight:700; color:#1e3a5f;",
                paste0("¿Cómo está esta economía? ", country_name(), ", ", input$year))
    })

    output$table <- renderUI({
      r <- rows()
      reading <- diagnosis_reading(r)
      fmt <- function(x, v) {
        if (is.na(x)) return(tags$span(style = "color:#94a3b8;", "s/d"))
        paste0(if (v %in% BALANCE_VARS && x > 0) "+", num_es(x), "%")
      }
      group_row <- function(g) tags$tr(class = "table-light",
        tags$td(colspan = 4, tags$b(OBJECTIVE_GROUPS[[g]])))

      body <- list()
      for (g in c("central", "sustainability")) {
        body <- c(body, list(group_row(g)))
        for (id in unique(r$objective_id[r$group == g |
                                         r$objective_id %in% r$objective_id[r$group == g]])) {
          rows_i <- which(r$objective_id == id)
          n <- length(rows_i)
          for (k in seq_along(rows_i)) {
            i <- rows_i[k]
            body <- c(body, list(tags$tr(
              # The objective spans all its indicators
              if (k == 1) tags$td(rowspan = n, style = "width:18%;",
                tags$div(style = "font-weight:600;", r$objective[i]),
                tags$div(style = "font-size:0.75rem; color:#64748b;", r$dimension[i])),
              tags$td(style = "width:22%; font-size:0.85rem;",
                r$indicator[i],
                if (isTRUE(input$show_reading))
                  tags$div(style = "font-size:0.76rem; color:#0369a1; margin-top:2px;", reading[i])),
              tags$td(style = "width:9%; text-align:right; font-weight:600;", fmt(r$value[i], r$var[i])),
              tags$td(style = "width:12%; text-align:right; font-size:0.78rem; color:#64748b;",
                tags$div(paste0(input$year - 1, ": "), fmt(r$previous[i], r$var[i])),
                if (r$group[i] == "sustainability")
                  tags$div(paste0(input$year - DIAGNOSIS_LOOKBACK, ": "), fmt(r$past[i], r$var[i])))
            )))
          }
        }
      }
      tags$table(
        class = "table table-sm align-middle",
        style = "font-size:0.88rem;",
        tags$thead(tags$tr(
          tags$th("Objetivo"), tags$th("Indicador"),
          tags$th(style = "text-align:right;", input$year),
          tags$th(style = "text-align:right;", "Antes")
        )),
        tags$tbody(body)
      )
    })

    output$claim_box <- renderUI({
      tagList(
        tags$p(style = "font-size:0.85rem; color:#475569; margin-bottom:4px;",
          "Alguien afirma:"),
        tags$blockquote(
          style = "background:#eaf4fb; border-left:4px solid #2e86c1; padding:10px 14px; font-style:italic; margin-bottom:8px;",
          paste0("“", claim(), "”")),
        tags$p(style = "font-size:0.85rem; color:#475569; margin-bottom:4px;",
          "¿Estás de acuerdo? Construí por escrito una respuesta que reconozca qué información de la ",
          "afirmación es positiva, señale qué dimensiones quedan fuera, incorpore la ",
          "inflación, la sostenibilidad fiscal y la situación externa, y formule una ",
          "conclusión general.")
      )
    })
  })
}
