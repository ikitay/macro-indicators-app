# Smoke tests: every tab's UI builds and every server output renders on real data.

data_r <- reactive(macro_df)

test_that("every module UI builds", {
  for (ui_fn in list(explore_country_ui, compare_countries_ui, global_explorer_ui,
                     country_profile_ui, diagnosis_ui, historical_events_ui, challenges_ui,
                     correlation_ui)) {
    expect_no_error(htmltools::renderTags(ui_fn("m")))
  }
  expect_no_error(htmltools::renderTags(glossary_modal()))
})

test_that("Explore Country renders", {
  testServer(explore_country_server, args = list(data = data_r), {
    session$setInputs(country = "AR", year_range = c(1990, 2023),
                      show_central = group_vars("central"),
                      show_sustainability = group_vars("sustainability"),
                      show_other = group_vars("other"),
                      show_trend = TRUE, show_recession = TRUE)
    render_all_outputs(output, c("chart_title", "summary_cards", "main_plot", "plot_container"))
    expect_equal(shown_vars(), CORE_VARS)
    expect_match(as.character(output$summary_cards$html), "Estabilidad de precios · Inflación")
    # Only the central objectives
    session$setInputs(show_sustainability = character(0), show_other = character(0))
    expect_equal(shown_vars(), c("gdp_growth", "unemployment", "inflation"))
    render_all_outputs(output, c("summary_cards", "main_plot"))
  })
})

test_that("Compare Countries renders in every display mode", {
  testServer(compare_countries_server, args = list(data = data_r), {
    for (v in CORE_VARS) {
      for (mode in c("raw", "indexed")) {
        session$setInputs(countries = c("US", "AR", "DE"), variable = v,
                          year_range = c(1990, 2023), display_mode = mode,
                          base_year = 2000, show_crisis = TRUE,
                          smooth_lines = FALSE, show_table = TRUE)
        render_all_outputs(output, c("chart_title", "compare_plot", "data_table", "change_note"))
      }
    }
  })
})

test_that("Global Explorer renders", {
  testServer(global_explorer_server, args = list(data = data_r), {
    for (size in c("population", "equal", "inflation")) {
      session$setInputs(x_var = "inflation", y_var = "gdp_growth", size_var = size,
                        regions = names(REGION_COLORS), static_year = 2019,
                        log_size = TRUE, show_labels = TRUE)
      render_all_outputs(output, c("chart_title", "scatter_plot"))
    }
  })
})

test_that("Country Profile renders", {
  testServer(country_profile_server, args = list(data = data_r), {
    session$setInputs(countries = c("US", "DE", "KR", "AR"), year = 2019, fill_area = TRUE)
    render_all_outputs(output, c("chart_title", "radar_plot", "score_table", "sustainability_table"))
  })
})

test_that("Historical Events renders", {
  testServer(historical_events_server, args = list(data = data_r), {
    for (v in CORE_VARS) {
      session$setInputs(events = names(HISTORICAL_EVENTS), countries = c("AR", "US", "KR"),
                        variable = v, year_range = c(1990, 2023),
                        shade_periods = TRUE, show_annotations = TRUE)
      render_all_outputs(output, c("chart_title", "event_cards", "event_plot", "lesson_box"))
    }
  })
})

test_that("Discovery Challenges renders every challenge", {
  testServer(challenges_server, args = list(data = data_r), {
    for (i in seq_along(CHALLENGES)) {
      session$setInputs(challenge_select = as.character(i), instructor_mode = TRUE,
                        show_hint = 1, show_solution = 1)
      render_all_outputs(output, c("challenge_card", "hint_panel",
                                   "instructor_panel", "solution_panel"))
    }
  })
})

test_that("Correlation Explorer renders", {
  testServer(correlation_server, args = list(data = data_r), {
    for (multi in c(FALSE, TRUE)) {
      session$setInputs(country = "AR", x_var = "inflation", y_var = "gdp_growth",
                        year_range = c(1990, 2023), multi_country = multi,
                        extra_countries = c("BR", "CL"), show_trend = TRUE,
                        show_labels = TRUE)
      render_all_outputs(output, c("chart_title", "interpretation_guide",
                                   "scatter_plot", "stats_summary"))
    }
  })
})

test_that("glossary has the terms the course notes rely on", {
  terms <- sapply(GLOSSARY_TERMS, `[[`, "term")
  for (t in c("Balanza de pagos", "Sostenibilidad fiscal", "PBI nominal", "Inflación",
              "Recesión", "Saldo comercial", "Tasa de desempleo", "Pleno empleo",
              "IPC (Índice de Precios al Consumidor)", "Objetivo e indicador")) {
    expect_true(t %in% terms, label = t)
  }
  for (cat in sapply(GLOSSARY_TERMS, `[[`, "category")) expect_false(is.na(category_color(cat)))
  for (f in c("All", unique(sapply(GLOSSARY_TERMS, `[[`, "category")))) {
    expect_no_error(htmltools::renderTags(render_glossary(f)))
  }
})

test_that("indicators are grouped into central and sustainability objectives", {
  ch <- core_var_choices()
  expect_equal(names(ch), unname(OBJECTIVE_GROUPS))
  expect_equal(unname(ch[[1]]), c("gdp_growth", "unemployment", "inflation"))
  expect_equal(unname(ch[[2]]), c("fiscal_balance", "public_debt", "trade_balance",
                                  "current_account", "fdi_inflows"))
  expect_equal(unname(ch[[3]]), "employment")
  expect_equal(VARS$unemployment$objective, "Pleno empleo")
  expect_false("public_debt" %in% names(ALL_CODES))  # from the IMF, not the World Bank
  expect_equal(sort(unlist(ch, use.names = FALSE)), sort(CORE_VARS))
  for (v in CORE_VARS) expect_false(is.null(VARS[[v]]$objective), label = v)
  expect_equal(var_objective_label("inflation"), "Estabilidad de precios: Inflación (%)")
})

test_that("Explore Country shades the years in which GDP fell, keeping the zero lines", {
  testServer(explore_country_server, args = list(data = data_r), {
    session$setInputs(country = "AR", year_range = c(1995, 2005),
                      show_central = group_vars("central"),
                      show_sustainability = character(0),
                      show_trend = FALSE, show_recession = TRUE)
    built <- jsonlite::fromJSON(output$main_plot, simplifyVector = FALSE)$x$layout$shapes
    rects <- Filter(function(s) identical(s$type, "rect"), built)
    falls <- sum(sapply(1995:2005, function(y) snap("Argentina", y, "gdp_growth")) < 0)
    expect_equal(length(rects), falls)
    expect_gt(length(built), length(rects))  # zero lines are still there
    session$setInputs(show_recession = FALSE)
    built <- jsonlite::fromJSON(output$main_plot, simplifyVector = FALSE)$x$layout$shapes
    expect_length(Filter(function(s) identical(s$type, "rect"), built), 0)
  })
})
