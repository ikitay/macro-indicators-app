test_that("a level becomes an index with the base year at 100", {
  expect_equal(level_index(c(50, 100, 150), 2000:2002, 2000), c(100, 200, 300))
  expect_true(all(is.na(level_index(c(NA, 1), 2000:2001, 2000))))
  expect_true(all(is.na(level_index(c(1, 2), 2000:2001, 1999))))
})

test_that("a log axis is used only for series that span a wide range", {
  expect_false(use_log_axis(c(100, 150, 400)))
  expect_true(use_log_axis(c(100, 5000)))
  expect_false(use_log_axis(c(NA, 100)))
})

test_that("the price index chains the inflation rates shown in the app", {
  testServer(explore_country_server, args = list(data = reactive(macro_df)), {
    session$setInputs(country = "AR", year_range = c(1995, 2023),
                      show_central = group_vars("central"), show_sustainability = character(0),
                      show_other = character(0), show_trend = FALSE, show_recession = TRUE)
    d <- levels_data()
    expect_equal(d$price_index[1], 100)
    infl <- sapply(1996:1998, function(y) snap("Argentina", y, "inflation"))
    expect_equal(d$price_index[d$year == 1998], 100 * prod(1 + infl / 100))
    # Real GDP chained from the growth series matches the World Bank's real GDP level
    g <- sapply(1996:2023, function(y) snap("Argentina", y, "gdp_growth"))
    expect_equal(d$gdp_real[d$year == 2023], 100 * prod(1 + g / 100), tolerance = 1e-6)
    # Nominal GDP grew far more than real GDP: the effect of prices
    expect_gt(d$gdp_nominal[d$year == 2023], 100 * d$gdp_real[d$year == 2023])
    for (nm in c("price_level_plot", "gdp_level_plot", "levels_note")) expect_no_error(output[[nm]])
    expect_match(as.character(output$levels_note$html), "el PBI real por <b>1,7")
  })
})

test_that("countries without local-currency GDP get a message, not an error", {
  testServer(explore_country_server, args = list(data = reactive(macro_df)), {
    session$setInputs(country = "AF", year_range = c(1990, 1995),
                      show_central = group_vars("central"), show_sustainability = character(0),
                      show_other = character(0), show_trend = FALSE, show_recession = FALSE)
    expect_error(output$gdp_level_plot, "No hay datos del PBI")
    expect_null(output$levels_note)
  })
})
