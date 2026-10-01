# =============================================================================
# MODULE: CORRELATION EXPLORER (Tab 7)
# Purpose: Teach statistical reasoning. Students explore whether two
#   macroeconomic variables are correlated, how strong that relationship is,
#   and whether it varies across countries and time periods.
# =============================================================================

correlation_ui <- function(id) {
  ns <- NS(id)
  layout_sidebar(
    fillable = TRUE,
    sidebar = sidebar(
      width = 290, open = "open",
      tags$div(class="sidebar-intro",
        tags$p(style="font-size:0.83rem; color:#555; line-height:1.5; margin-bottom:12px;",
          "Explore whether two indicators move together for a selected country and period. ",
          "Each dot is one year. The line shows the statistical trend."
        )
      ),

      selectizeInput(ns("country"), "🌍 Country",
        choices=NULL, selected="US",
        options=list(placeholder="Type to search…", maxOptions=300)
      ),
      selectInput(ns("x_var"), "↔ X-axis variable",
        choices=core_var_choices(), selected="gdp_growth"),
      selectInput(ns("y_var"), "↕ Y-axis variable",
        choices=core_var_choices(), selected="employment"),
      sliderInput(ns("year_range"), "📅 Year range",
        min=YEAR_MIN, max=YEAR_MAX, value=c(1995,YEAR_MAX), step=1, sep=""
      ),
      hr(),
      checkboxInput(ns("show_trend"),  "Show trend line",    value=TRUE),
      checkboxInput(ns("show_labels"), "Label year points",  value=TRUE),
      checkboxInput(ns("multi_country"), "Compare across countries", value=FALSE),
      conditionalPanel(
        condition=paste0("input['",ns("multi_country"),"']"),
        selectizeInput(ns("extra_countries"), "Additional countries",
          choices=NULL, selected=c("DE","KR","AR"),
          multiple=TRUE,
          options=list(maxItems=5, placeholder="Type to search…", maxOptions=300)
        ),
        tags$small(style="color:#64748b; font-size:0.78rem;",
          "Each country gets its own colour. Compare whether the relationship holds universally.")
      )
    ),

    tags$div(
      # Correlation warning — always visible
      tags$div(
        style="background:#fff7ed; border:1px solid #fed7aa; border-radius:8px;
               padding:12px 16px; margin-bottom:12px;",
        tags$span(style="font-size:1.1rem;","⚠️ "),
        tags$span(style="font-weight:700; color:#c2410c;","Correlation ≠ Causation: "),
        tags$span(style="color:#7c2d12; font-size:0.87rem;",
          "A statistical correlation tells you two variables tend to move together — ",
          "it does NOT tell you one causes the other. There may be a third variable ",
          "driving both, the relationship may be coincidental, or causation may run ",
          "in the opposite direction from what you expect."
        )
      ),

      # Stats summary row
      uiOutput(ns("stats_summary")),

      # Main scatter plot
      card(
        class="mt-2",
        full_screen=TRUE,
        card_header(uiOutput(ns("chart_title"))),
        card_body(padding="0", plotlyOutput(ns("scatter_plot"), height="440px")),
        card_footer(uiOutput(ns("interpretation_guide")))
      )
    )
  )
}

correlation_server <- function(id, data) {
  moduleServer(id, function(input, output, session) {

    observe({
      req(data())
      ch <- get_country_choices(data())
      updateSelectizeInput(session,"country",choices=ch,selected="US",server=FALSE)
      updateSelectizeInput(session,"extra_countries",choices=ch,selected=c("DE","KR","AR"),server=FALSE)
    })

    all_countries <- reactive({
      req(input$country)
      clist <- input$country
      if (isTRUE(input$multi_country) && length(input$extra_countries) > 0)
        clist <- unique(c(clist, input$extra_countries))
      clist
    })

    plot_data <- reactive({
      req(data(), all_countries(), input$x_var, input$y_var, input$year_range)
      validate(need(input$x_var != input$y_var, "Please choose different variables for X and Y axes."))

      data() %>%
        filter(iso2c %in% all_countries(),
               year >= input$year_range[1],
               year <= input$year_range[2]) %>%
        select(country, iso2c, year,
               x_val=all_of(input$x_var),
               y_val=all_of(input$y_var)) %>%
        filter(!is.na(x_val), !is.na(y_val))
    })

    # Correlation stats per country
    cor_stats <- reactive({
      req(plot_data())
      df <- plot_data()
      ctries <- unique(df$iso2c)

      lapply(ctries, function(ctry) {
        df_c <- df %>% filter(iso2c == ctry)
        n    <- nrow(df_c)
        if (n < 4) return(list(iso2c=ctry, country=unique(df_c$country), r=NA, p=NA, n=n))
        ct <- tryCatch(cor.test(df_c$x_val, df_c$y_val, method="pearson"), error=function(e) NULL)
        if (is.null(ct)) return(list(iso2c=ctry, country=unique(df_c$country), r=NA, p=NA, n=n))
        list(iso2c=ctry, country=unique(df_c$country),
             r=round(ct$estimate,3), p=round(ct$p.value,4), n=n)
      })
    })

    output$chart_title <- renderUI({
      req(input$x_var, input$y_var)
      tags$span(style="font-weight:700; color:#1e3a5f;",
        paste(var_short(input$y_var), "vs", var_short(input$x_var)))
    })

    output$stats_summary <- renderUI({
      req(cor_stats())
      stats <- cor_stats()

      tags$div(
        style="display:flex; gap:10px; flex-wrap:wrap; margin-bottom:4px;",
        lapply(stats, function(s) {
          if (is.na(s$r)) return(NULL)
          r_abs   <- abs(s$r)
          strength <- if (r_abs >= 0.7) "Strong" else if (r_abs >= 0.4) "Moderate" else "Weak"
          direction <- if (s$r > 0) "positive ↗" else "negative ↘"
          sig_text  <- if (!is.na(s$p) && s$p < 0.05) "significant" else "not significant"
          stat_col  <- if (r_abs >= 0.7) "#1e3a5f" else if (r_abs >= 0.4) "#d97706" else "#64748b"

          tags$div(
            style=paste0("background:white; border:1px solid #e2e8f0; border-radius:8px; ",
                         "padding:10px 14px; min-width:200px; flex:1;"),
            tags$div(style=paste0("font-weight:700; color:",stat_col,"; font-size:0.9rem;"),
                     s$country),
            tags$div(style="margin-top:4px; font-size:0.85rem; color:#334155;",
              tags$span(style=paste0("font-weight:700; font-size:1.1rem; color:",stat_col,";"),
                        paste0("r = ", s$r)),
              tags$span(style="margin-left:8px; color:#64748b;",
                        paste0(strength, " ", direction))
            ),
            tags$div(style="font-size:0.78rem; color:#94a3b8; margin-top:2px;",
              paste0("n = ", s$n, " years | p ", if(!is.na(s$p)) paste0("= ",s$p) else "= N/A",
                     " (", sig_text, ")")
            )
          )
        })
      )
    })

    output$scatter_plot <- renderPlotly({
      req(plot_data())
      df <- plot_data()
      validate(need(nrow(df) >= 3, "Need at least 3 data points to display."))

      palette <- c("#2563eb","#dc2626","#16a34a","#d97706","#7c3aed","#0891b2")
      ctries  <- unique(df$iso2c)
      col_map <- setNames(palette[seq_along(ctries)], ctries)

      p <- plot_ly()

      for (ctry in ctries) {
        df_c  <- df %>% filter(iso2c == ctry)
        cname <- unique(df_c$country)
        col_c <- col_map[ctry]

        p <- p %>% add_trace(
          data=df_c, x=~x_val, y=~y_val,
          type="scatter", mode="markers",
          name=cname,
          marker=list(color=col_c, size=9, opacity=0.78,
                      line=list(width=1, color="white")),
          text=paste0("<b>",cname,"</b> — ",df_c$year,"<br>",
                      var_label(input$x_var),": ",round(df_c$x_val,2)," ",var_unit(input$x_var),"<br>",
                      var_label(input$y_var),": ",round(df_c$y_val,2)," ",var_unit(input$y_var)),
          hoverinfo="text"
        )

        # Year labels
        if (isTRUE(input$show_labels)) {
          p <- p %>% add_trace(
            data=df_c, x=~x_val, y=~y_val,
            type="scatter", mode="text",
            text=~as.character(year),
            textfont=list(size=8, color=col_c),
            textposition="top center",
            showlegend=FALSE, hoverinfo="none"
          )
        }

        # Trend line
        if (isTRUE(input$show_trend) && nrow(df_c) >= 4) {
          tryCatch({
            fit <- lm(y_val ~ x_val, data=df_c)
            x_seq <- seq(min(df_c$x_val, na.rm=TRUE), max(df_c$x_val, na.rm=TRUE), length.out=60)
            y_pred <- predict(fit, newdata=data.frame(x_val=x_seq))
            p <- p %>% add_trace(
              x=x_seq, y=y_pred,
              type="scatter", mode="lines",
              name=paste("Trend:", cname),
              line=list(color=plotly::toRGB(col_c, alpha = 0.65), dash="dash", width=2),
              showlegend=FALSE, hoverinfo="none"
            )
          }, error=function(e) NULL)
        }
      }

      # Reference lines
      shapes <- list()
      if (isTRUE(VARS[[input$x_var]]$zero_line))
        shapes <- c(shapes, list(list(type="line",x0=0,x1=0,y0=0,y1=1,xref="x",yref="paper",
          line=list(color="#94a3b8",dash="dot",width=1))))
      if (isTRUE(VARS[[input$y_var]]$zero_line))
        shapes <- c(shapes, list(list(type="line",x0=0,x1=1,y0=0,y1=0,xref="paper",yref="y",
          line=list(color="#94a3b8",dash="dot",width=1))))

      p %>%
        layout(
          xaxis=list(title=var_label(input$x_var), tickfont=list(size=11), gridcolor="#f1f5f9"),
          yaxis=list(title=var_label(input$y_var), tickfont=list(size=11), gridcolor="#f1f5f9"),
          legend=list(orientation="h",x=0,y=-0.18,font=list(size=11)),
          shapes=shapes,
          margin=list(l=70,r=30,t=20,b=80),
          paper_bgcolor="#ffffff", plot_bgcolor="#ffffff"
        ) %>%
        config(displaylogo=FALSE, responsive=TRUE,
               modeBarButtons=list(list("toImage","zoom2d","pan2d","resetScale2d")),
               toImageButtonOptions=list(format="png",filename="correlation",width=1000,height=600))
    })

    output$interpretation_guide <- renderUI({
      req(cor_stats())
      stats <- cor_stats()[[1]]
      if (is.na(stats$r)) return(NULL)

      r_abs <- abs(stats$r)
      guide_text <- if (r_abs >= 0.7) {
        paste0("The correlation is <b>strong (r = ", stats$r, ")</b>. ",
               "The two variables tend to move closely together for this country in this period. ",
               "But remember: this does not mean one causes the other.")
      } else if (r_abs >= 0.4) {
        paste0("The correlation is <b>moderate (r = ", stats$r, ")</b>. ",
               "There is a noticeable tendency for the variables to move together, ",
               "but with considerable variation. Many other factors are at play.")
      } else {
        paste0("The correlation is <b>weak (r = ", stats$r, ")</b>. ",
               "These variables do not appear to move systematically together for this ",
               "country in this period. Try changing the country or time period — ",
               "the relationship may differ elsewhere.")
      }

      tags$div(
        style="font-size:0.83rem; color:#475569; padding:4px 2px;",
        tags$span("📊 "),
        HTML(guide_text),
        tags$span(style="color:#94a3b8; font-size:0.78rem; margin-left:8px;",
          if (!is.na(stats$p) && stats$p >= 0.05)
            "(Note: p ≥ 0.05 — this correlation may not be statistically significant.)")
      )
    })
  })
}
