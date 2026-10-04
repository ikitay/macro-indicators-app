# Smoke tests: every tab's UI builds and every server output renders on real data.

data_r <- reactive(macro_df)

test_that("every module UI builds", {
  for (ui_fn in list(explore_country_ui, compare_countries_ui, global_explorer_ui,
                     country_profile_ui, historical_events_ui, challenges_ui,
                     correlation_ui)) {
    expect_no_error(htmltools::renderTags(ui_fn("m")))
  }
  expect_no_error(htmltools::renderTags(glossary_modal()))
})

test_that("Explore Country renders", {
  testServer(explore_country_server, args = list(data = data_r), {
    session$setInputs(country = "AR", year_range = c(1990, 2023),
                      show_vars = CORE_VARS, show_trend = TRUE, show_recession = TRUE)
    render_all_outputs(output, c("chart_title", "summary_cards", "main_plot"))
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
        render_all_outputs(output, c("chart_title", "compare_plot", "data_table"))
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
    render_all_outputs(output, c("chart_title", "radar_plot", "score_table"))
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
  for (t in c("Balance of Payments", "Fiscal Sustainability", "Nominal GDP",
              "Inflation", "Recession", "Trade Balance")) {
    expect_true(t %in% terms, label = t)
  }
  for (cat in sapply(GLOSSARY_TERMS, `[[`, "category")) expect_false(is.na(category_color(cat)))
  for (f in c("All", unique(sapply(GLOSSARY_TERMS, `[[`, "category")))) {
    expect_no_error(htmltools::renderTags(render_glossary(f)))
  }
})
