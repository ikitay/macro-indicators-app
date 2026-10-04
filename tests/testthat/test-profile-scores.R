toy <- data.frame(
  gdp_growth = c(-2, 0, 2, 4, NA),
  employment = c(50, 60, 70, 80, 55),
  inflation  = c(2, 5, -3, 50, 1)
)

test_that("a score is the share of observations that are strictly worse", {
  s <- score_central_objectives(toy)
  expect_equal(s$gdp_growth_score, c(0, 25, 50, 75, NA))  # 4 observed values
  expect_equal(s$employment_score, c(0, 40, 60, 80, 20))
})

test_that("price stability rewards inflation near 2%; deflation does not score best", {
  s <- score_central_objectives(toy)
  # Distances from 2%: 0, 3, 5, 48, 1
  expect_equal(s$inflation_score, c(80, 40, 20, 0, 60))
  expect_lt(s$inflation_score[3], s$inflation_score[2])  # -3% is worse than 5%
})

test_that("missing values stay missing instead of scoring zero", {
  s <- score_central_objectives(toy)
  expect_true(is.na(s$gdp_growth_score[5]))
})

test_that("on real data, scores are percentiles and deflation is not top-scored", {
  s <- score_central_objectives(macro_df)
  expect_true(all(s$gdp_growth_score >= 0 & s$gdp_growth_score < 100, na.rm = TRUE))
  expect_equal(median(s$gdp_growth_score, na.rm = TRUE), 50, tolerance = 1)
  deflation <- s$inflation_score[!is.na(s$inflation) & s$inflation < -2]
  near_target <- s$inflation_score[!is.na(s$inflation) & abs(s$inflation - 2) < 0.5]
  expect_lt(max(deflation), min(near_target))
})

test_that("Country Profile shows unscored sustainability information with its 5-year path", {
  testServer(country_profile_server, args = list(data = reactive(macro_df)), {
    session$setInputs(countries = c("GR", "ES"), year = 2007, fill_area = TRUE)
    sd <- sustainability_data()
    expect_equal(sd$fiscal_balance[sd$country == "Greece"], snap("Greece", 2007, "fiscal_balance"))
    expect_equal(sd$trade_balance_past[sd$country == "Spain"], snap("Spain", 2002, "trade_balance"))
    html <- as.character(output$sustainability_table$html)
    expect_match(html, "not scored")
    expect_match(html, "2002:")
    expect_false(any(grepl("balance_score", names(profile_data()))))
  })
})

test_that("Country Profile handles a country-year with missing data", {
  testServer(country_profile_server, args = list(data = reactive(macro_df)), {
    # Afghanistan 1990 has no growth, employment or inflation data
    session$setInputs(countries = c("AF", "US"), year = 1990, fill_area = FALSE)
    expect_true(is.na(profile_data()$gdp_growth_score[profile_data()$iso2c == "AF"]))
    expect_match(as.character(output$score_table$html), "no data")
    expect_no_error(output$radar_plot)
  })
})
