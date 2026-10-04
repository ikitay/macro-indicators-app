test_that("Argentina is the default country in every country selector", {
  expect_equal(DEFAULT_COUNTRY, "AR")
  expect_equal(DEFAULT_COUNTRIES[1], "AR")
  expect_equal(DEFAULT_PEERS[1], "AR")
  expect_lte(length(DEFAULT_COUNTRIES), 6)
  expect_lte(length(DEFAULT_PEERS), 4)
  for (ui_fn in list(explore_country_ui, compare_countries_ui, country_profile_ui,
                     diagnosis_ui, historical_events_ui, correlation_ui)) {
    html <- as.character(ui_fn("x"))
    expect_false(grepl("<option value=\"US\" selected", html, fixed = TRUE))
  }
})

test_that("Historical Events opens with the 2008 crisis and COVID-19 ticked", {
  html <- as.character(historical_events_ui("x"))
  for (ev in c("gfc", "covid"))
    expect_match(html, paste0("value=\"", ev, "\" checked"), fixed = TRUE)
  expect_false(grepl("value=\"asia97\" checked", html, fixed = TRUE))
  testServer(historical_events_server, args = list(data = reactive(macro_df)), {
    session$setInputs(events = c("gfc", "covid"), countries = DEFAULT_PEERS,
                      variable = "gdp_growth", year_range = c(1995, 2023),
                      shade_periods = TRUE, show_annotations = TRUE)
    expect_length(selected_events(), 2)
    render_all_outputs(output, c("chart_title", "event_cards", "event_plot", "lesson_box"))
    expect_match(as.character(output$event_cards$html), "COVID-19")
  })
})
