# =============================================================================
# MODULE: COUNTRY PROFILE (Tab 4)
# Purpose: Radar chart of the three central objectives for up to 4 countries,
#   with the fiscal and external balances shown alongside, unscored, as
#   sustainability information.
# =============================================================================

PROFILE_PALETTE <- c("#2563eb", "#dc2626", "#16a34a", "#d97706")

PROFILE_AXES <- c(
  gdp_growth = "Economic growth\n(GDP growth)",
  employment = "Employment\n(employment rate)",
  inflation  = "Price stability\n(inflation near 2%)"
)

PROFILE_SCORE_LABELS <- c(
  gdp_growth = "Economic growth",
  employment = "Employment",
  inflation  = "Price stability"
)

country_profile_ui <- function(id) {
  ns <- NS(id)
  layout_sidebar(
    fillable = TRUE,
    sidebar = sidebar(
      width = 280, open = "open",
      tags$div(class = "sidebar-intro",
        tags$p(style = "font-size:0.83rem; color:#555; line-height:1.5; margin-bottom:12px;",
          "Compare how countries did on the three central objectives in one year, ",
          "then check whether their fiscal and external situation could sustain it."
        )
      ),
      selectizeInput(ns("countries"), "🌍 Countries (up to 4)",
        choices  = NULL,
        selected = c("US", "DE", "KR", "AR"),
        multiple = TRUE,
        options  = list(maxItems=4, placeholder="Type to search…", maxOptions=300)
      ),
      sliderInput(ns("year"), "📅 Reference year",
        min=YEAR_MIN, max=YEAR_MAX, value=2019, step=1, sep=""
      ),
      hr(),
      checkboxInput(ns("fill_area"), "Fill radar area", value = TRUE),
      hr(),
      tags$div(
        style = "background:#fff8e1; border:1px solid #fde68a; border-radius:6px; padding:10px;",
        tags$p(style="font-size:0.8rem; color:#78350f; margin:0;",
          tags$b("📏 How scores work: "),
          "Each score (0–100) compares this country-year with ",
          tags$b("all countries from 1990–2023."),
          " A score of 70 means better than 70% of all those observations. ",
          tags$b("Price stability"), " rewards inflation close to 2%: both high inflation ",
          "and deflation score lower. Missing data is left blank, not scored as zero."
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
          tags$span("🕸️ "), tags$b("How to read this chart: "),
          "A larger area means better results on the three central objectives in that year. ",
          "It does not tell you whether those results can last: an economy can grow, create ",
          "jobs and keep inflation low while building up fiscal or external imbalances. ",
          "That is why the fiscal and trade balances are shown separately, and not scored."
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
        choices=get_country_choices(data()), selected=c("US","DE","KR","AR"), server=FALSE)
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
        paste("Central objectives and sustainability —", input$year))
    })

    output$radar_plot <- renderPlotly({
      req(profile_data())
      df <- profile_data()
      validate(need(nrow(df) > 0, "No data available for selected countries and year."))

      axis_labels <- unname(PROFILE_AXES[CENTRAL_VARS])
      score_cols  <- paste0(CENTRAL_VARS, "_score")

      p <- plot_ly()

      for (i in seq_len(nrow(df))) {
        vals <- as.numeric(df[i, score_cols])
        col <- PROFILE_PALETTE[i]
        closed_r     <- c(vals, vals[1])
        closed_theta <- c(axis_labels, axis_labels[1])
        hover <- paste0(gsub("\n", " ", closed_theta), ": ",
                        ifelse(is.na(closed_r), "no data", paste0(round(closed_r), "/100")))

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
            angularaxis = list(tickfont=list(size=11.5))
          ),
          legend = list(
            orientation="h", x=0.5, y=-0.12, xanchor="center",
            font=list(size=11)
          ),
          margin = list(l=110,r=110,t=50,b=80),
          paper_bgcolor="#ffffff"
        ) %>%
        config(displaylogo=FALSE, responsive=TRUE,
               modeBarButtons=list(list("toImage")),
               toImageButtonOptions=list(format="png",filename="country_profile",width=900,height=700))
    })

    output$score_table <- renderUI({
      req(profile_data())
      df <- profile_data()
      validate(need(nrow(df) > 0, ""))

      score_cell <- function(x) {
        if (is.na(x)) return(tags$td(style = "text-align:right; color:#94a3b8;", "no data"))
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
               "Central objectives — scores (0–100)"),
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

      fmt <- function(x) if (is.na(x)) "no data" else sprintf("%+.1f%%", x)
      cell <- function(now, past) {
        tags$td(style = "text-align:right;",
          tags$span(style = "font-weight:600; color:#334155;", fmt(now)),
          tags$br(),
          tags$span(style = "font-size:0.7rem; color:#64748b;",
                    paste0(input$year - 5, ": ", fmt(past)))
        )
      }
      col_of <- function(x) if (x %in% names(df)) df[[x]] else rep(NA_real_, nrow(df))

      tags$div(
        style = "padding:4px 10px 10px;",
        tags$p(style="font-size:0.8rem; font-weight:700; color:#1e3a5f; margin-bottom:4px;",
               "Sustainability information — % of GDP, not scored"),
        tags$table(
          class = "table table-sm",
          style = "font-size:0.78rem; margin-bottom:6px;",
          tags$thead(tags$tr(
            tags$th(""), tags$th(style = "text-align:right;", "Fiscal balance"),
            tags$th(style = "text-align:right;", "Trade balance")
          )),
          tags$tbody(lapply(seq_len(nrow(df)), function(i) {
            col <- PROFILE_PALETTE[match(df$iso2c[i], profile_data()$iso2c)]
            tags$tr(
              tags$td(style = paste0("font-weight:700; color:", col, ";"), df$country[i]),
              cell(col_of("fiscal_balance")[i], col_of("fiscal_balance_past")[i]),
              cell(col_of("trade_balance")[i],  col_of("trade_balance_past")[i])
            )
          }))
        ),
        tags$p(style = "font-size:0.74rem; color:#64748b; margin:0; line-height:1.4;",
          "A deficit (negative value) is not automatically a problem. Fiscal sustainability ",
          "depends on the path of public debt; external sustainability depends on how a ",
          "deficit is financed (the balance of payments). Compare with five years earlier: ",
          "is the imbalance growing or shrinking?"
        )
      )
    })
  })
}
