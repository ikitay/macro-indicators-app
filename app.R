# =============================================================================
# LA MACROECONOMÍA A TRAVÉS DE LOS DATOS (Exploring Macroeconomics Through Data)
# An Interactive Educational R Shiny Application
# =============================================================================

# The code and data are UTF-8 (accents, emoji). Some servers start R in the
# "C" locale (e.g. Posit Connect Cloud, whose es_419.UTF-8 is not installed),
# where they cannot be read; switch to a UTF-8 locale first.
if (!isTRUE(l10n_info()[["UTF-8"]])) {
  for (loc in c("C.UTF-8", "en_US.UTF-8", "English_United States.utf8")) {
    if (nzchar(suppressWarnings(Sys.setlocale("LC_CTYPE", loc)))) break
  }
}

suppressPackageStartupMessages({
  library(shiny)
  library(bslib)
  library(plotly)
  library(dplyr)
  library(tidyr)
  library(cachem)
})

# Load WDI — use package if available, shim otherwise
source("R/wdi_shim.R")
if (requireNamespace("WDI", quietly = TRUE)) library(WDI)

# Load shinyWidgets — use package if available, shim otherwise
source("R/widgets_shim.R")
if (requireNamespace("shinyWidgets", quietly = TRUE)) library(shinyWidgets)

# Source all utilities and modules
source("R/constants.R")
source("R/country_names_es.R")
source("R/data_utils.R")
source("R/glossary.R")
source("R/events_data.R")
source("R/challenges_data.R")
source("R/mod_explore_country.R")
source("R/mod_compare_countries.R")
source("R/mod_global_explorer.R")
source("R/mod_country_profile.R")
source("R/mod_diagnosis.R")
source("R/mod_historical_events.R")
source("R/mod_challenges.R")
source("R/mod_correlation.R")

# =============================================================================
# THEME
# =============================================================================
app_theme <- bs_theme(
  version   = 5,
  bootswatch = "flatly",
  primary   = "#1e3a5f",
  secondary = "#17a589",
  info      = "#2e86c1",
  "font-size-base"    = "0.93rem",
  "border-radius"     = "0.45rem",
  "card-border-width" = "0px"
)

# =============================================================================
# MODAL HELPERS
# =============================================================================
tab_card <- function(title, desc) {
  tags$div(
    style = "background:#f8f9fa; border-radius:6px; padding:8px 12px;",
    tags$div(style = "font-weight:600; color:#1e3a5f; font-size:0.85rem;", title),
    tags$div(style = "color:#666; font-size:0.78rem;", desc)
  )
}

welcome_modal <- function() {
  modalDialog(
    title = NULL,
    tags$div(
      style = "text-align:center; padding:10px 0 6px;",
      tags$div(style = "font-size:2.8rem;", "📊"),
      tags$h3(style = "color:#1e3a5f; font-weight:700; margin:8px 0 4px;",
              "La macroeconomía a través de los datos"),
      tags$p(style = "color:#555; font-size:1rem;",
             "Un entorno para aprender macroeconomía explorando datos reales")
    ),
    tags$hr(),
    tags$div(
      style = "background:#eaf4fb; border-left:4px solid #2e86c1; padding:12px 16px;
               border-radius:0 6px 6px 0; margin-bottom:16px;",
      tags$p(style = "margin:0; font-style:italic; color:#1a3a5c; font-size:0.97rem;",
        "\"Una lectura macroeconómica no consiste en mirar un único número. Consiste en ",
        "seleccionar indicadores, relacionarlos con objetivos y analizar si los resultados ",
        "pueden sostenerse en el tiempo.\""
      )
    ),
    tags$h5("🎯 Dos grupos de objetivos", style = "color:#1e3a5f;"),
    tags$div(
      style = "display:grid; grid-template-columns:1fr 1fr; gap:8px; margin-bottom:14px;",
      tab_card(OBJECTIVE_GROUPS[["central"]],
               "Crecimiento económico, pleno empleo y estabilidad de precios"),
      tab_card(OBJECTIVE_GROUPS[["sustainability"]],
               "Sostenibilidad fiscal y sostenibilidad externa")
    ),
    tags$h5("🧭 Preguntas para explorar:", style = "color:#1e3a5f;"),
    tags$ul(
      style = "color:#333; line-height:1.9;",
      tags$li("¿Puede un país crecer sin crear empleo?"),
      tags$li("¿Puede bajar la inflación mientras sube el desempleo?"),
      tags$li("¿Alcanza con que una economía muestre buenos resultados hoy para afirmar que su situación es buena?"),
      tags$li("¿Pueden mejorar todos los objetivos macroeconómicos al mismo tiempo?"),
      tags$li("¿Cómo afecta una misma crisis global a distintos países?")
    ),
    tags$hr(),
    tags$h5("📂 Pestañas de la aplicación:", style = "color:#1e3a5f;"),
    tags$div(
      style = "display:grid; grid-template-columns:1fr 1fr; gap:8px; margin-bottom:12px;",
      tab_card("🔍 Explorar un país",          "Seguí los indicadores de un país a lo largo del tiempo"),
      tab_card("⚖️ Comparar países",           "Compará las trayectorias de varios países"),
      tab_card("🌍 Explorador global",         "Gráfico de burbujas animado con todos los países"),
      tab_card("🕸️ Perfil del país",           "Objetivos centrales y sostenibilidad en un año"),
      tab_card("🩺 Diagnóstico",               "¿Cómo está esta economía? Evaluá un país en un año"),
      tab_card("📅 Acontecimientos históricos","Relacioná los datos con la historia económica"),
      tab_card("🎯 Desafíos",                  "Consignas para investigar con los datos"),
      tab_card("📊 Correlaciones",             "Analizá si dos indicadores se mueven juntos")
    ),
    footer = tags$div(
      style = "text-align:center;",
      actionButton("dismiss_welcome", "🚀 Empezar a explorar",
                   class = "btn btn-primary btn-lg", style = "min-width:180px;")
    ),
    size = "l", easyClose = FALSE
  )
}

about_modal <- function() {
  modalDialog(
    title = tags$span("ℹ️ Acerca de esta aplicación"),
    tags$p("Herramienta didáctica para estudiantes de economía, con datos reales del Banco Mundial y del FMI."),
    tags$h6("Objetivos e indicadores", style="color:#1e3a5f; font-weight:700; margin-top:14px;"),
    tags$p(style="font-size:0.85rem;",
      "Un objetivo es lo que una economía busca alcanzar; un indicador es la variable que ",
      "observamos para seguirlo. El PBI real no es el objetivo: el objetivo es el crecimiento. ",
      "Un termómetro permite saber si una persona tiene fiebre, pero el objetivo no es cambiar ",
      "el número del termómetro, sino que la persona esté sana."),
    tags$table(
      class = "table table-sm table-bordered",
      style = "font-size:0.85rem;",
      tags$thead(class="table-light",
        tags$tr(tags$th("Objetivo"), tags$th("Indicador en esta app"), tags$th("Fuente"))),
      tags$tbody(
        tags$tr(tags$td(colspan = 3, class = "table-light", tags$b(OBJECTIVE_GROUPS[["central"]]))),
        tags$tr(tags$td("Crecimiento económico"), tags$td("Crecimiento del PBI real (%)"),
                tags$td("Banco Mundial ", tags$code("NY.GDP.MKTP.KD.ZG"))),
        tags$tr(tags$td("Pleno empleo"),
                tags$td("Tasa de desempleo (%)", tags$br(),
                        tags$small(style = "color:#64748b;",
                                   "También: tasa de empleo (%), en \"Otros indicadores\"")),
                tags$td("Banco Mundial (estimación de la OIT) ", tags$code("SL.UEM.TOTL.ZS"), "; ",
                        tags$code("SL.EMP.TOTL.SP.ZS"))),
        tags$tr(tags$td("Estabilidad de precios"), tags$td("Inflación (%): variación del IPC"),
                tags$td("Banco Mundial ", tags$code("FP.CPI.TOTL.ZG"),
                        "; años faltantes completados con FMI WEO ", tags$code("PCPIPCH"))),
        tags$tr(tags$td(colspan = 3, class = "table-light", tags$b(OBJECTIVE_GROUPS[["sustainability"]]))),
        tags$tr(tags$td(rowspan = 2, "Sostenibilidad fiscal"), tags$td("Resultado fiscal (% del PBI)"),
                tags$td("FMI WEO ", tags$code("GGXCNL_NGDP"),
                        " (préstamo neto / endeudamiento neto del gobierno general)")),
        tags$tr(tags$td("Deuda pública (% del PBI)"),
                tags$td("FMI WEO ", tags$code("GGXWDG_NGDP"), " (deuda bruta del gobierno general)")),
        tags$tr(tags$td(rowspan = 3, "Sostenibilidad externa"),
                tags$td("Saldo comercial de bienes y servicios (% del PBI)"),
                tags$td("Banco Mundial ", tags$code("NE.RSB.GNFS.ZS"))),
        tags$tr(tags$td("Cuenta corriente (% del PBI)"),
                tags$td("Banco Mundial ", tags$code("BN.CAB.XOKA.GD.ZS"))),
        tags$tr(tags$td("Inversión extranjera directa, ingreso neto (% del PBI)"),
                tags$td("Banco Mundial ", tags$code("BX.KLT.DINV.WD.GD.ZS")))
      )
    ),
    tags$p(style="font-size:0.8rem; color:#64748b;",
      "Para evaluar la sostenibilidad no alcanza con el resultado de un año: también importan ",
      "la trayectoria de la deuda pública y cómo se financian los déficits externos. La app ",
      "muestra la cuenta corriente y la inversión extranjera directa, no la balanza de pagos completa."),
    tags$h6("La inflación de la Argentina", style="color:#1e3a5f; font-weight:700; margin-top:14px;"),
    tags$p(style="font-size:0.85rem;",
      "Hasta 2006 se usa el IPC oficial del INDEC. Entre 2007 y 2016 el índice oficial perdió ",
      "credibilidad y después se suspendió, así que la app usa la mediana de IPC provinciales ",
      "independientes (San Luis, Neuquén, Chaco y, desde 2014, la Ciudad de Buenos Aires), ",
      "publicados en datos.gob.ar. Pasá el mouse sobre un punto para ver de qué fuente viene."),
    tags$small(style="color:#888;", "Datos: Banco Mundial (WDI), FMI (WEO), datos.gob.ar | Cobertura: ~215 países, 1990–2023"),
    footer = modalButton("Cerrar"),
    size = "m", easyClose = TRUE
  )
}

# =============================================================================
# UI
# =============================================================================
ui <- tagList(
  tags$head(
    tags$link(rel="stylesheet", type="text/css", href="styles.css"),
    if (!is.null(IDLE_TIMEOUT_MINUTES))
      tags$meta(name = "idle-timeout-minutes", content = IDLE_TIMEOUT_MINUTES),
    tags$script(src = "idle_timeout.js"),
    tags$meta(name="viewport", content="width=device-width, initial-scale=1")
  ),
  page_navbar(
    title = tags$span(
      style = "font-weight:700; letter-spacing:0.3px; font-size:1.1rem;",
      "📊 La macroeconomía en datos"
    ),
    theme          = app_theme,
    window_title   = "La macroeconomía a través de los datos",
    navbar_options = navbar_options(
      theme = "dark"
    ),
    fillable       = TRUE,

    nav_panel("🔍 Explorar un país",           explore_country_ui("mod_explore")),
    nav_panel("⚖️ Comparar países",            compare_countries_ui("mod_compare")),
    nav_panel("🌍 Explorador global",          global_explorer_ui("mod_global")),
    nav_panel("🕸️ Perfil del país",            country_profile_ui("mod_profile")),
    nav_panel("🩺 Diagnóstico",                diagnosis_ui("mod_diagnosis")),
    nav_panel("📅 Acontecimientos históricos", historical_events_ui("mod_events")),
    nav_panel("🎯 Desafíos",                   challenges_ui("mod_challenges")),
    nav_panel("📊 Correlaciones",              correlation_ui("mod_correlation")),

    nav_spacer(),
    nav_item(tags$div(
      style = "display:flex; gap:6px; align-items:center; padding:2px 4px;",
      actionButton("show_glossary", "📖 Glosario", class="btn btn-sm btn-outline-light"),
      actionButton("show_about",    "ℹ️ Acerca de", class="btn btn-sm btn-outline-light")
    ))
  )
)

# =============================================================================
# SERVER
# =============================================================================
server <- function(input, output, session) {

  demo_notice_shown <- reactiveVal(FALSE)

  # Data loading — shared reactive across all modules
  macro_data <- reactive({
    withProgress(
      message = "Cargando los datos macroeconómicos…",
      detail  = "Se usa el archivo incluido en la app; si falta, la caché o la API.",
      value   = 0.2, {
        incProgress(0.4, detail = "Leyendo los indicadores…")
        df <- get_macro_data()
        incProgress(0.4, detail = "¡Listo!")
        df
      }
    )
  })

  observe({
    df <- macro_data()
    if (identical(attr(df, "data_source"), "demo") && !demo_notice_shown()) {
      demo_notice_shown(TRUE)
      showNotification(
        ui = tagList(
          tags$b("Modo de datos de demostración"),
          tags$br(),
          "No se pudieron descargar los datos del Banco Mundial. Se muestran datos simulados de 25 países."
        ),
        type = "warning",
        duration = 12,
        closeButton = TRUE
      )
    }
  })

  # Module servers
  explore_country_server("mod_explore",   macro_data)
  compare_countries_server("mod_compare", macro_data)
  global_explorer_server("mod_global",    macro_data)
  country_profile_server("mod_profile",   macro_data)
  diagnosis_server("mod_diagnosis",       macro_data)
  historical_events_server("mod_events",  macro_data)
  challenges_server("mod_challenges",     macro_data)
  correlation_server("mod_correlation",   macro_data)

  # A tab idle for IDLE_TIMEOUT_MINUTES (www/idle_timeout.js) is disconnected
  observeEvent(input$idle_timeout, session$close())

  # Modals
  observe({ showModal(welcome_modal()) })
  observeEvent(input$dismiss_welcome, { removeModal() })
  observeEvent(input$show_glossary,   { showModal(glossary_modal()) })
  observeEvent(input$show_about,      { showModal(about_modal()) })

  # Glossary dynamic filter
  glossary_server_outputs(input, output, session)
}

shinyApp(ui = ui, server = server)
