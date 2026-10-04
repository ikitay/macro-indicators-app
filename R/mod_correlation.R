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
          "Explorá si dos indicadores se mueven juntos en un país y un período. ",
          "Cada punto es un año. La línea muestra la tendencia estadística."
        )
      ),

      selectizeInput(ns("country"), "🌍 País",
        choices=NULL, selected="US",
        options=list(placeholder="Escribí para buscar…", maxOptions=300)
      ),
      selectInput(ns("x_var"), "↔ Variable del eje X",
        choices=core_var_choices(), selected="gdp_growth"),
      selectInput(ns("y_var"), "↕ Variable del eje Y",
        choices=core_var_choices(), selected="employment"),
      sliderInput(ns("year_range"), "📅 Período",
        min=YEAR_MIN, max=YEAR_MAX, value=c(1995,YEAR_MAX), step=1, sep=""
      ),
      hr(),
      checkboxInput(ns("show_trend"),  "Mostrar línea de tendencia", value=TRUE),
      checkboxInput(ns("show_labels"), "Rotular los años",           value=TRUE),
      checkboxInput(ns("multi_country"), "Comparar entre países",    value=FALSE),
      conditionalPanel(
        condition=paste0("input['",ns("multi_country"),"']"),
        selectizeInput(ns("extra_countries"), "Otros países",
          choices=NULL, selected=c("DE","KR","AR"),
          multiple=TRUE,
          options=list(maxItems=5, placeholder="Escribí para buscar…", maxOptions=300)
        ),
        tags$small(style="color:#64748b; font-size:0.78rem;",
          "Cada país tiene su propio color. Compará si la relación se cumple en todos.")
      )
    ),

    tags$div(
      # Correlation warning — always visible
      tags$div(
        style="background:#fff7ed; border:1px solid #fed7aa; border-radius:8px;
               padding:12px 16px; margin-bottom:12px;",
        tags$span(style="font-size:1.1rem;","⚠️ "),
        tags$span(style="font-weight:700; color:#c2410c;","Correlación ≠ causalidad: "),
        tags$span(style="color:#7c2d12; font-size:0.87rem;",
          "Una correlación estadística indica que dos variables tienden a moverse juntas, ",
          "pero NO que una cause la otra. Puede haber una tercera variable que mueva a ",
          "ambas, la relación puede ser casual, o la causalidad puede ir en el sentido ",
          "contrario al que esperás."
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
      validate(need(input$x_var != input$y_var, "Elegí variables distintas para los ejes X e Y."))

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
        paste(var_short(input$y_var), "vs.", var_short(input$x_var)))
    })

    output$stats_summary <- renderUI({
      req(cor_stats())
      stats <- cor_stats()

      tags$div(
        style="display:flex; gap:10px; flex-wrap:wrap; margin-bottom:4px;",
        lapply(stats, function(s) {
          if (is.na(s$r)) return(NULL)
          r_abs   <- abs(s$r)
          strength <- if (r_abs >= 0.7) "Fuerte" else if (r_abs >= 0.4) "Moderada" else "Débil"
          direction <- if (s$r > 0) "positiva ↗" else "negativa ↘"
          sig_text  <- if (!is.na(s$p) && s$p < 0.05) "significativa" else "no significativa"
          stat_col  <- if (r_abs >= 0.7) "#1e3a5f" else if (r_abs >= 0.4) "#d97706" else "#64748b"

          tags$div(
            style=paste0("background:white; border:1px solid #e2e8f0; border-radius:8px; ",
                         "padding:10px 14px; min-width:200px; flex:1;"),
            tags$div(style=paste0("font-weight:700; color:",stat_col,"; font-size:0.9rem;"),
                     s$country),
            tags$div(style="margin-top:4px; font-size:0.85rem; color:#334155;",
              tags$span(style=paste0("font-weight:700; font-size:1.1rem; color:",stat_col,";"),
                        paste0("r = ", num_es(s$r, 3))),
              tags$span(style="margin-left:8px; color:#64748b;",
                        paste0(strength, " ", direction))
            ),
            tags$div(style="font-size:0.78rem; color:#94a3b8; margin-top:2px;",
              paste0("n = ", s$n, " años | p ", if(!is.na(s$p)) paste0("= ", num_es(s$p, 4)) else "= s/d",
                     " (", sig_text, ")")
            )
          )
        })
      )
    })

    output$scatter_plot <- renderPlotly({
      req(plot_data())
      df <- plot_data()
      validate(need(nrow(df) >= 3, "Se necesitan al menos 3 años con datos."))

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
                      var_label(input$x_var),": ",num_es(df_c$x_val,2)," ",var_unit(input$x_var),"<br>",
                      var_label(input$y_var),": ",num_es(df_c$y_val,2)," ",var_unit(input$y_var)),
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
              name=paste("Tendencia:", cname),
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
        config(displaylogo = FALSE, locale = "es", responsive=TRUE,
               modeBarButtons=list(list("toImage","zoom2d","pan2d","resetScale2d")),
               toImageButtonOptions=list(format="png",filename="correlacion",width=1000,height=600))
    })

    output$interpretation_guide <- renderUI({
      req(cor_stats())
      stats <- cor_stats()[[1]]
      if (is.na(stats$r)) return(NULL)

      r_abs <- abs(stats$r)
      guide_text <- if (r_abs >= 0.7) {
        paste0("La correlación es <b>fuerte (r = ", num_es(stats$r, 3), ")</b>. ",
               "Las dos variables tienden a moverse muy juntas en este país y este período. ",
               "Pero recordá: eso no significa que una cause la otra.")
      } else if (r_abs >= 0.4) {
        paste0("La correlación es <b>moderada (r = ", num_es(stats$r, 3), ")</b>. ",
               "Hay una tendencia visible a que las variables se muevan juntas, ",
               "pero con bastante variación. Influyen muchos otros factores.")
      } else {
        paste0("La correlación es <b>débil (r = ", num_es(stats$r, 3), ")</b>. ",
               "Estas variables no parecen moverse juntas de manera sistemática en este ",
               "país y este período. Probá con otro país u otro período: ",
               "la relación puede ser distinta.")
      }

      tags$div(
        style="font-size:0.83rem; color:#475569; padding:4px 2px;",
        tags$span("📊 "),
        HTML(guide_text),
        tags$span(style="color:#94a3b8; font-size:0.78rem; margin-left:8px;",
          if (!is.na(stats$p) && stats$p >= 0.05)
            "(Nota: p ≥ 0,05, así que esta correlación puede no ser estadísticamente significativa.)")
      )
    })
  })
}
