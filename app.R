# =============================================================================
# EXPLORING MACROECONOMICS THROUGH DATA
# An Interactive Educational R Shiny Application
# =============================================================================

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
source("R/data_utils.R")
source("R/glossary.R")
source("R/events_data.R")
source("R/challenges_data.R")
source("R/mod_explore_country.R")
source("R/mod_compare_countries.R")
source("R/mod_global_explorer.R")
source("R/mod_country_profile.R")
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
              "Exploring Macroeconomics Through Data"),
      tags$p(style = "color:#555; font-size:1rem;",
             "An inquiry-based learning environment for economics students")
    ),
    tags$hr(),
    tags$div(
      style = "background:#eaf4fb; border-left:4px solid #2e86c1; padding:12px 16px;
               border-radius:0 6px 6px 0; margin-bottom:16px;",
      tags$p(style = "margin:0; font-style:italic; color:#1a3a5c; font-size:0.97rem;",
        "\"Macroeconomic objectives often involve trade-offs. Relationships between ",
        "variables are not fixed — they vary across countries, periods, and historical contexts.\""
      )
    ),
    tags$h5("🎯 Two kinds of objectives", style = "color:#1e3a5f;"),
    tags$div(
      style = "display:grid; grid-template-columns:1fr 1fr; gap:8px; margin-bottom:14px;",
      tab_card("Central objectives — what is happening?",
               "Economic growth, full employment and price stability"),
      tab_card("Sustainability — can it last?",
               "Fiscal sustainability and external sustainability")
    ),
    tags$h5("🧭 Questions to explore:", style = "color:#1e3a5f;"),
    tags$ul(
      style = "color:#333; line-height:1.9;",
      tags$li("Can a country grow without creating employment?"),
      tags$li("Can inflation fall while unemployment rises?"),
      tags$li("Are there countries that perform well on all macroeconomic objectives?"),
      tags$li("How do global crises affect different countries differently?")
    ),
    tags$hr(),
    tags$h5("📂 Application tabs:", style = "color:#1e3a5f;"),
    tags$div(
      style = "display:grid; grid-template-columns:1fr 1fr; gap:8px; margin-bottom:12px;",
      tab_card("🔍 Explore Country",     "Track one country's indicators over time"),
      tab_card("⚖️ Compare Countries",   "Compare national economic trajectories"),
      tab_card("🌍 Global Explorer",     "Animated Gapminder-style scatter plot"),
      tab_card("🕸️ Country Profile",     "Radar chart of overall performance"),
      tab_card("📅 Historical Events",   "Connect economic data to world history"),
      tab_card("🎯 Discovery Challenges","Guided inquiry learning tasks"),
      tab_card("📊 Correlation Explorer","Test statistical relationships")
    ),
    footer = tags$div(
      style = "text-align:center;",
      actionButton("dismiss_welcome", "🚀 Start Exploring",
                   class = "btn btn-primary btn-lg", style = "min-width:180px;")
    ),
    size = "l", easyClose = FALSE
  )
}

about_modal <- function() {
  modalDialog(
    title = tags$span("ℹ️ About This Application"),
    tags$p("Pedagogical tool for undergraduate economics students using real World Bank and IMF data."),
    tags$h6("Objectives and indicators", style="color:#1e3a5f; font-weight:700; margin-top:14px;"),
    tags$p(style="font-size:0.85rem;",
      "An objective is what an economy seeks to achieve; an indicator is the variable we ",
      "observe to follow it. Real GDP is not the objective: growth is. A thermometer tells ",
      "you whether someone has a fever, but the goal is for the person to be healthy, not ",
      "to change the number on the thermometer."),
    tags$table(
      class = "table table-sm table-bordered",
      style = "font-size:0.85rem;",
      tags$thead(class="table-light",
        tags$tr(tags$th("Objective"), tags$th("Indicator in this app"), tags$th("Source"))),
      tags$tbody(
        tags$tr(tags$td(colspan = 3, class = "table-light", tags$b(OBJECTIVE_GROUPS[["central"]]))),
        tags$tr(tags$td("Economic growth"), tags$td("GDP growth (%), change in real GDP"),
                tags$td("World Bank ", tags$code("NY.GDP.MKTP.KD.ZG"))),
        tags$tr(tags$td("Full employment"),
                tags$td("Employment rate (%)", tags$br(),
                        tags$small(style = "color:#64748b;",
                                   "The course's main indicator is the unemployment rate.")),
                tags$td("World Bank ", tags$code("SL.EMP.TOTL.SP.ZS"))),
        tags$tr(tags$td("Price stability"), tags$td("Inflation (%), change in the CPI"),
                tags$td("World Bank ", tags$code("FP.CPI.TOTL.ZG"),
                        "; gaps filled from IMF WEO ", tags$code("PCPIPCH"))),
        tags$tr(tags$td(colspan = 3, class = "table-light", tags$b(OBJECTIVE_GROUPS[["sustainability"]]))),
        tags$tr(tags$td("Fiscal sustainability"), tags$td("Fiscal balance (% of GDP)"),
                tags$td("IMF WEO ", tags$code("GGXCNL_NGDP"),
                        " (general government net lending/borrowing)")),
        tags$tr(tags$td("External sustainability"), tags$td("Trade balance (% of GDP), goods and services"),
                tags$td("World Bank ", tags$code("NE.RSB.GNFS.ZS")))
      )
    ),
    tags$p(style="font-size:0.8rem; color:#64748b;",
      "Sustainability needs more than one year's balance: the path of public debt and how ",
      "external deficits are financed (the balance of payments)."),
    tags$h6("Argentina's inflation", style="color:#1e3a5f; font-weight:700; margin-top:14px;"),
    tags$p(style="font-size:0.85rem;",
      "INDEC's official CPI is used through 2006. From 2007 to 2016 the official index was ",
      "discredited and later suspended, so the app uses the median of independent provincial CPIs ",
      "(San Luis, Neuquén, Chaco and, from 2014, the City of Buenos Aires), published on datos.gob.ar. ",
      "Hover over a point to see which source it comes from."),
    tags$small(style="color:#888;", "Data: World Bank WDI, IMF WEO, datos.gob.ar | Coverage: ~215 countries, 1990–2023"),
    footer = modalButton("Close"),
    size = "m", easyClose = TRUE
  )
}

# =============================================================================
# UI
# =============================================================================
ui <- tagList(
  tags$head(
    tags$link(rel="stylesheet", type="text/css", href="styles.css"),
    tags$meta(name="viewport", content="width=device-width, initial-scale=1")
  ),
  page_navbar(
    title = tags$span(
      style = "font-weight:700; letter-spacing:0.3px; font-size:1.1rem;",
      "📊 Exploring Macroeconomics"
    ),
    theme          = app_theme,
    window_title   = "Exploring Macroeconomics Through Data",
    navbar_options = navbar_options(
      theme = "dark"
    ),
    fillable       = TRUE,

    nav_panel("🔍 Explore Country",      explore_country_ui("mod_explore")),
    nav_panel("⚖️ Compare Countries",    compare_countries_ui("mod_compare")),
    nav_panel("🌍 Global Explorer",      global_explorer_ui("mod_global")),
    nav_panel("🕸️ Country Profile",      country_profile_ui("mod_profile")),
    nav_panel("📅 Historical Events",    historical_events_ui("mod_events")),
    nav_panel("🎯 Discovery Challenges", challenges_ui("mod_challenges")),
    nav_panel("📊 Correlation Explorer", correlation_ui("mod_correlation")),

    nav_spacer(),
    nav_item(tags$div(
      style = "display:flex; gap:6px; align-items:center; padding:2px 4px;",
      actionButton("show_glossary", "📖 Glossary", class="btn btn-sm btn-outline-light"),
      actionButton("show_about",    "ℹ️ About",    class="btn btn-sm btn-outline-light")
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
      message = "Loading macroeconomic data…",
      detail  = "Uses bundled CSV if available; otherwise cache or API.",
      value   = 0.2, {
        incProgress(0.4, detail = "Fetching indicators…")
        df <- get_macro_data()
        incProgress(0.4, detail = "Ready!")
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
          tags$b("Demo data mode"),
          tags$br(),
          "World Bank data could not be downloaded. Showing synthetic data for 25 countries."
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
  historical_events_server("mod_events",  macro_data)
  challenges_server("mod_challenges",     macro_data)
  correlation_server("mod_correlation",   macro_data)

  # Modals
  observe({ showModal(welcome_modal()) })
  observeEvent(input$dismiss_welcome, { removeModal() })
  observeEvent(input$show_glossary,   { showModal(glossary_modal()) })
  observeEvent(input$show_about,      { showModal(about_modal()) })

  # Glossary dynamic filter
  glossary_server_outputs(input, output, session)
}

shinyApp(ui = ui, server = server)
