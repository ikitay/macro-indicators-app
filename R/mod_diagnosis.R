# =============================================================================
# MODULE: ¿CÓMO ESTÁ ESTA ECONOMÍA? (Tab 5)
# Purpose: The course notes' integrative case ("Caso integrador"), built from
#   real data. Students pick a country and a year, read each objective's
#   indicator, write what it shows, and assess the claim "the economy is fine
#   because…" using growth, employment, prices and fiscal and external
#   sustainability. Their answers can be downloaded as a text file.
# =============================================================================

DIAGNOSIS_LOOKBACK <- 5  # years back for the sustainability trajectory

`%||%` <- function(a, b) if (is.null(a)) b else a

# One row per objective for a country-year: the indicator's value in that year,
# the year before, and DIAGNOSIS_LOOKBACK years before.
diagnosis_rows <- function(df, iso, year) {
  country_df <- df[df$iso2c == iso, , drop = FALSE]
  value_at <- function(v, y) {
    x <- country_df[[v]][country_df$year == y]
    if (length(x) == 0) NA_real_ else x[1]
  }
  data.frame(
    var       = CORE_VARS,
    group     = sapply(CORE_VARS, function(v) VARS[[v]]$group),
    dimension = sapply(CORE_VARS, function(v) VARS[[v]]$dimension),
    objective = sapply(CORE_VARS, var_objective),
    indicator = sapply(CORE_VARS, var_label),
    value     = sapply(CORE_VARS, value_at, y = year),
    previous  = sapply(CORE_VARS, value_at, y = year - 1),
    past      = sapply(CORE_VARS, value_at, y = year - DIAGNOSIS_LOOKBACK),
    row.names = NULL, stringsAsFactors = FALSE
  )
}

# The claim students assess (Activity 4 in the notes), built from the central
# results that look favourable in that year. NULL when none do.
diagnosis_claim <- function(rows, country) {
  get <- function(v, col) rows[[col]][rows$var == v]
  parts <- c(
    if (isTRUE(get("gdp_growth", "value") > 0)) "el PBI creció",
    if (isTRUE(get("employment", "value") > get("employment", "previous"))) "el empleo aumentó",
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
  sapply(seq_len(nrow(rows)), function(i) {
    r <- rows[i, ]
    if (is.na(r$value)) return("No hay datos para este año.")
    change <- if (is.na(r$previous)) "" else if (round(r$value - r$previous, 1) == 0)
      " Igual que el año anterior." else
      paste0(if (r$value > r$previous) " Subió " else " Bajó ", pts(r$value - r$previous),
             " respecto del año anterior.")
    switch(r$var,
      gdp_growth = paste0(
        if (r$value > 0) "La producción aumentó: el PBI real creció un "
        else if (r$value < 0) "La producción cayó: el PBI real se redujo un "
        else "La producción no cambió: el PBI real varió un ",
        pct(abs(r$value)), "."),
      employment = paste0(pct(r$value), " de la población de 15 años o más tenía empleo.", change),
      inflation  = paste0("Los precios al consumidor subieron un ", pct(r$value),
                          " en el año.", change),
      paste0(
        if (r$value < 0) "Déficit del " else if (r$value > 0) "Superávit del " else "Equilibrio: ",
        if (r$value != 0) paste0(pct(abs(r$value)), " del PBI."),
        if (!is.na(r$past)) paste0(" ", DIAGNOSIS_LOOKBACK, " años antes: ",
                                   if (r$past > 0) "+", pct(r$past), " del PBI."))
    )
  })
}

# Plain-text record of the student's work, for download
diagnosis_text <- function(country, year, rows, notes, claim, answers) {
  fmt <- function(x, v) if (is.na(x)) "s/d" else paste0(num_es(x), var_unit(v))
  lines <- c(
    paste0("¿Cómo está esta economía? ", country, ", ", year),
    strrep("=", 60), "",
    "ACTIVIDAD 1. Identificar", ""
  )
  for (i in seq_len(nrow(rows))) {
    r <- rows[i, ]
    lines <- c(lines,
      paste0(r$dimension, " / ", r$objective),
      paste0("  Indicador: ", r$indicator, ": ", fmt(r$value, r$var),
             " (", year - 1, ": ", fmt(r$previous, r$var), "; ",
             year - DIAGNOSIS_LOOKBACK, ": ", fmt(r$past, r$var), ")"),
      paste0("  ¿Qué muestra?: ", if (nzchar(notes[i])) notes[i] else "(sin responder)"),
      "")
  }
  section <- function(title, text) c(title, if (nzchar(text)) text else "(sin responder)", "")
  c(lines,
    section("ACTIVIDAD 2. Interpretar: ¿qué resultados parecen favorables y qué problemas permanecen?",
            answers$interpret),
    section(paste0("ACTIVIDAD 4. Evaluar la afirmación: \"", claim, "\""), answers$evaluate),
    section("ACTIVIDAD 5. ¿Qué otra información necesitarías?", answers$missing))
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
        choices = NULL, selected = "AR",
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
      downloadButton(ns("download"), "Descargar mis respuestas", class = "btn btn-sm btn-success w-100")
    ),
    card(
      card_header(uiOutput(ns("title"))),
      card_body(
        tags$h6(style = "color:#1e3a5f; font-weight:700;", "Actividad 1. Identificar"),
        tags$p(style = "font-size:0.85rem; color:#475569;",
          "Para cada objetivo, mirá su indicador y escribí qué muestra el caso. Para la ",
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
        textAreaInput(ns("interpret"), NULL, width = "100%", rows = 4,
                      placeholder = "Escribí tu interpretación…"),
        tags$h6(style = "color:#1e3a5f; font-weight:700; margin-top:10px;", "Actividad 4. Evaluar"),
        uiOutput(ns("claim_box")),
        textAreaInput(ns("evaluate"), NULL, width = "100%", rows = 6,
                      placeholder = "La afirmación toma en cuenta…, pero no alcanza para evaluar la situación completa porque…"),
        tags$h6(style = "color:#1e3a5f; font-weight:700; margin-top:10px;", "Actividad 5. Integrar"),
        tags$p(style = "font-size:0.85rem; color:#475569; margin-bottom:4px;",
          "¿Qué otra información necesitarías para una evaluación más completa? Organizá tu ",
          "respuesta en producción, empleo, precios, situación fiscal y situación externa. ",
          "Pista: esta app no muestra la tasa de desempleo, la deuda pública ni la balanza de pagos."),
        textAreaInput(ns("missing"), NULL, width = "100%", rows = 4,
                      placeholder = "Para evaluar mejor la situación fiscal necesitaría…")
      )
    )
  )
}

diagnosis_server <- function(id, data) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    observe({
      req(data())
      updateSelectizeInput(session, "country", choices = get_country_choices(data()),
                           selected = "AR", server = FALSE)
    })

    # A random country-year with data for every indicator
    observeEvent(input$random_case, {
      df <- data()
      complete <- df[stats::complete.cases(df[, CORE_VARS]) &
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
        paste0(if (v %in% SUSTAINABILITY_VARS && x > 0) "+", num_es(x), "%")
      }
      group_row <- function(g) tags$tr(class = "table-light",
        tags$td(colspan = 5, tags$b(OBJECTIVE_GROUPS[[g]])))

      body <- list()
      for (g in c("central", "sustainability")) {
        body <- c(body, list(group_row(g)))
        for (i in which(r$group == g)) {
          body <- c(body, list(tags$tr(
            tags$td(style = "width:20%;",
              tags$div(style = "font-weight:600;", r$objective[i]),
              tags$div(style = "font-size:0.75rem; color:#64748b;", r$dimension[i])),
            tags$td(style = "width:20%; font-size:0.85rem;", r$indicator[i]),
            tags$td(style = "width:9%; text-align:right; font-weight:600;", fmt(r$value[i], r$var[i])),
            tags$td(style = "width:13%; text-align:right; font-size:0.78rem; color:#64748b;",
              tags$div(paste0(input$year - 1, ": "), fmt(r$previous[i], r$var[i])),
              if (r$group[i] == "sustainability")
                tags$div(paste0(input$year - DIAGNOSIS_LOOKBACK, ": "), fmt(r$past[i], r$var[i]))),
            tags$td(
              if (isTRUE(input$show_reading))
                tags$div(style = "font-size:0.78rem; color:#0369a1; margin-bottom:4px;", reading[i]),
              # Keep what the student already typed when the case changes
              textAreaInput(ns(paste0("note_", r$var[i])), NULL, width = "100%", rows = 2,
                            value = isolate(input[[paste0("note_", r$var[i])]]) %||% "",
                            placeholder = "¿Qué muestra el caso?"))
          )))
        }
      }
      tags$table(
        class = "table table-sm align-middle",
        style = "font-size:0.88rem;",
        tags$thead(tags$tr(
          tags$th("Objetivo"), tags$th("Indicador"),
          tags$th(style = "text-align:right;", input$year),
          tags$th(style = "text-align:right;", "Antes"),
          tags$th("¿Qué muestra el caso?")
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
          "¿Estás de acuerdo? Construí una respuesta que reconozca qué información de la ",
          "afirmación es positiva, señale qué dimensiones quedan fuera, incorpore la ",
          "inflación, la sostenibilidad fiscal y la situación externa, y formule una ",
          "conclusión general.")
      )
    })

    output$download <- downloadHandler(
      filename = function() {
        paste0("diagnostico_", input$country, "_", input$year, ".txt")
      },
      content = function(file) {
        notes <- sapply(rows()$var, function(v) input[[paste0("note_", v)]] %||% "")
        answers <- list(interpret = input$interpret %||% "",
                        evaluate  = input$evaluate  %||% "",
                        missing   = input$missing   %||% "")
        writeLines(enc2utf8(diagnosis_text(country_name(), input$year, rows(), notes,
                                           claim(), answers)),
                   file, useBytes = TRUE)
      }
    )
  })
}
