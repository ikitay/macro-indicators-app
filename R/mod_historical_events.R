# =============================================================================
# MODULE: HISTORICAL EVENTS (Tab 5)
# Purpose: Connect macroeconomic data with historical context by overlaying
#   event markers on time-series charts.
# =============================================================================

historical_events_ui <- function(id) {
  ns <- NS(id)
  layout_sidebar(
    fillable = TRUE,
    sidebar = sidebar(
      width = 300, open = "open",
      tags$div(class="sidebar-intro",
        tags$p(style="font-size:0.83rem; color:#555; line-height:1.5; margin-bottom:12px;",
          "Select one or more historical events to see vertical markers on the chart. ",
          "Compare how different countries were affected by the same global shock."
        )
      ),
      checkboxGroupInput(ns("events"), "📅 Historical events",
        choices  = EVENT_CHOICES,
        selected = "gfc"
      ),
      hr(),
      selectizeInput(ns("countries"), "🌍 Countries to compare",
        choices  = NULL,
        selected = c("US","DE","AR","KR"),
        multiple = TRUE,
        options  = list(maxItems=6, placeholder="Type to search…", maxOptions=300)
      ),
      selectInput(ns("variable"), "📊 Indicator",
        choices=core_var_choices(), selected="gdp_growth"
      ),
      sliderInput(ns("year_range"), "📅 Year range",
        min=YEAR_MIN, max=YEAR_MAX, value=c(1995, YEAR_MAX), step=1, sep=""
      ),
      hr(),
      checkboxInput(ns("shade_periods"), "Shade affected periods", value=TRUE),
      checkboxInput(ns("show_annotations"), "Show event labels",   value=TRUE)
    ),

    tags$div(
      # Event description cards (top)
      uiOutput(ns("event_cards")),

      # Main chart
      card(
        class = "mt-2",
        full_screen = TRUE,
        card_header(uiOutput(ns("chart_title"))),
        card_body(padding="0", plotlyOutput(ns("event_plot"), height="430px"))
      ),

      # Key lesson box
      uiOutput(ns("lesson_box"))
    )
  )
}

historical_events_server <- function(id, data) {
  moduleServer(id, function(input, output, session) {

    observe({
      req(data())
      updateSelectizeInput(session,"countries",
        choices=get_country_choices(data()), selected=c("US","DE","AR","KR"), server=FALSE)
    })

    selected_events <- reactive({
      req(input$events)
      HISTORICAL_EVENTS[input$events]
    })

    output$event_cards <- renderUI({
      events <- selected_events()
      if (length(events) == 0) return(NULL)
      tags$div(
        style="display:grid; gap:8px; margin-bottom:8px;",
        lapply(events, function(ev) {
          tags$div(
            style=paste0("background:#fff; border:1px solid #e2e8f0; border-left:4px solid ",
                         ev$color,"; border-radius:0 8px 8px 0; padding:10px 14px;"),
            tags$div(style="display:flex; justify-content:space-between; align-items:flex-start;",
              tags$div(
                tags$span(ev$icon, " "),
                tags$span(style=paste0("font-weight:700; color:",ev$color,"; font-size:0.95rem;"),
                          ev$name),
                tags$span(style="color:#64748b; font-size:0.82rem; margin-left:8px;",
                          paste0(ev$year_start, if(ev$year_end != ev$year_start) paste0("–",ev$year_end)))
              ),
              tags$span(
                style="background:#f1f5f9; color:#475569; font-size:0.75rem; padding:2px 8px; border-radius:10px;",
                paste(ev$affected_regions, collapse=", ")
              )
            ),
            tags$p(style="font-size:0.82rem; color:#334155; margin:6px 0 4px;", ev$description),
            tags$div(
              style="background:#f8fafc; border-radius:5px; padding:6px 10px; font-size:0.8rem;",
              tags$span(style="font-weight:600; color:#1e3a5f;", "Economic impact: "),
              tags$span(style="color:#475569;", ev$macro_impact)
            )
          )
        })
      )
    })

    output$chart_title <- renderUI({
      req(input$variable)
      tags$span(style="font-weight:700; color:#1e3a5f;",
        paste(var_label(input$variable), "— With Historical Event Markers"))
    })

    output$event_plot <- renderPlotly({
      req(data(), input$countries, input$variable, input$year_range)
      validate(need(length(input$countries) >= 1, "Select at least one country."))

      df <- data() %>%
        filter(iso2c %in% input$countries,
               year >= input$year_range[1], year <= input$year_range[2]) %>%
        select(country, iso2c, year, val = all_of(input$variable)) %>%
        arrange(country, year)

      palette <- c("#2563eb","#dc2626","#16a34a","#d97706","#7c3aed","#0891b2")
      ctry_list <- unique(df$iso2c)
      col_map   <- setNames(palette[seq_along(ctry_list)], ctry_list)

      p <- plot_ly()
      for (ctry in ctry_list) {
        df_c  <- df %>% filter(iso2c == ctry)
        cname <- unique(df_c$country)
        col_c <- col_map[ctry]
        p <- p %>% add_trace(
          data=df_c, x=~year, y=~val,
          type="scatter", mode="lines+markers", name=cname,
          line=list(color=col_c, width=2.5),
          marker=list(color=col_c, size=5),
          text=paste0("<b>",cname,"</b><br>Year: ",df_c$year,"<br>",
                      round(df_c$val,2)," ",var_unit(input$variable)),
          hoverinfo="text"
        )
      }

      shapes <- list()
      annotations_list <- list()
      events <- selected_events()

      for (ev in events) {
        yr_s <- max(ev$year_start, input$year_range[1])
        yr_e <- min(ev$year_end,   input$year_range[2])
        if (yr_s > input$year_range[2] || yr_e < input$year_range[1]) next

        # Shaded rectangle
        if (isTRUE(input$shade_periods)) {
          shapes <- c(shapes, list(list(
            type="rect", xref="x", yref="paper",
            x0=yr_s - 0.4, x1=yr_e + 0.4, y0=0, y1=1,
            fillcolor=paste0(ev$color,"18"),
            line=list(width=0)
          )))
        }

        # Vertical line at peak
        shapes <- c(shapes, list(list(
          type="line", xref="x", yref="paper",
          x0=ev$peak_year, x1=ev$peak_year, y0=0, y1=1,
          line=list(color=ev$color, dash="dash", width=1.8)
        )))

        # Label annotation
        if (isTRUE(input$show_annotations)) {
          annotations_list <- c(annotations_list, list(list(
            x=ev$peak_year, y=0.97, xref="x", yref="paper",
            text=paste0(ev$icon," ",ev$short_name),
            showarrow=FALSE,
            font=list(size=9.5, color=ev$color),
            bgcolor="#ffffffcc",
            bordercolor=ev$color,
            borderwidth=1,
            borderpad=3,
            xanchor="left"
          )))
        }
      }

      # Zero line
      if (isTRUE(VARS[[input$variable]]$zero_line)) {
        yr_range <- range(df$year, na.rm=TRUE)
        shapes <- c(shapes, list(list(
          type="line", xref="x", yref="y",
          x0=yr_range[1], x1=yr_range[2], y0=0, y1=0,
          line=list(color="#94a3b8", dash="dot", width=1)
        )))
      }

      p %>%
        layout(
          xaxis = list(title="Year", tickfont=list(size=11), gridcolor="#f1f5f9"),
          yaxis = list(title=var_label(input$variable), tickfont=list(size=11),
                       gridcolor="#f1f5f9", zerolinecolor="#94a3b8"),
          legend = list(orientation="h", x=0, y=-0.18, font=list(size=11)),
          hovermode = "x unified",
          shapes = shapes,
          annotations = annotations_list,
          margin = list(l=70,r=30,t=20,b=80),
          paper_bgcolor="#ffffff", plot_bgcolor="#ffffff"
        ) %>%
        config(displaylogo=FALSE, responsive=TRUE,
               modeBarButtons=list(list("toImage","zoom2d","pan2d","resetScale2d")),
               toImageButtonOptions=list(format="png",filename="historical_events",width=1200,height=600))
    })

    output$lesson_box <- renderUI({
      events <- selected_events()
      if (length(events) == 0) return(NULL)
      lessons <- sapply(events, `[[`, "key_lesson")
      tags$div(
        class = "mt-2",
        lapply(seq_along(events), function(i) {
          ev <- events[[i]]
          tags$div(
            style=paste0("background:#f0fdf4; border:1px solid #bbf7d0; border-radius:6px; ",
                         "padding:10px 14px; margin-bottom:6px;"),
            tags$span(style=paste0("font-weight:700; color:",ev$color,";"), ev$icon, " Key lesson: "),
            tags$span(style="font-size:0.85rem; color:#166534;", ev$key_lesson)
          )
        })
      )
    })
  })
}
