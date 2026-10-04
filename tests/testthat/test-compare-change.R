test_that("growth rates are chained into a real GDP index", {
  yr <- 2000:2004
  g  <- c(5, 10, -10, 0, 20)
  idx <- change_since_base(g, yr, 2001, chain_growth = TRUE)
  # 2001 = 100; 2002: -10% -> 90; 2003: 0% -> 90; 2004: +20% -> 108
  # 2000: 2001 grew 10%, so 2000 = 100 / 1.1
  expect_equal(idx, c(100 / 1.1, 100, 90, 90, 108))
})

test_that("growth that goes from 2% to 4% is not a doubling of the economy", {
  idx <- change_since_base(c(NA, 2, 4), 2000:2002, 2000, chain_growth = TRUE)
  expect_equal(idx[3], 100 * 1.02 * 1.04)
})

test_that("a missing year breaks the chain instead of being skipped", {
  idx <- change_since_base(c(1, 2, NA, 3, 4), 2000:2004, 2001, chain_growth = TRUE)
  expect_equal(idx[1:2], c(100 / 1.02, 100))
  expect_true(all(is.na(idx[3:5])))
  idx <- change_since_base(c(1, 2, 3), c(2000, 2001, 2003), 2001, chain_growth = TRUE)
  expect_true(is.na(idx[3]))  # 2002 absent
})

test_that("rates and ratios become percentage-point changes", {
  expect_equal(change_since_base(c(2, 4, -1), 2000:2002, 2000, FALSE), c(0, 2, -3))
  # A negative or zero base no longer flips signs or divides by zero
  expect_equal(change_since_base(c(-2, 0, 3), 2000:2002, 2000, FALSE), c(0, 2, 5))
  expect_true(all(is.na(change_since_base(c(NA, 1), 2000:2001, 2000, FALSE))))
  expect_true(all(is.na(change_since_base(c(1, 1), 2000:2001, 1995, FALSE))))
})

test_that("real GDP index on real data: Argentina's 2001-02 collapse", {
  testServer(compare_countries_server, args = list(data = reactive(macro_df)), {
    session$setInputs(countries = c("AR"), variable = "gdp_growth",
                      year_range = c(2001, 2005), display_mode = "indexed",
                      base_year = 1998, show_crisis = FALSE,
                      smooth_lines = FALSE, show_table = FALSE)
    df <- plot_data()
    expect_equal(range(df$year), c(2001, 2005))  # base year outside the plotted range
    g <- sapply(1999:2002, function(y) snap("Argentina", y, "gdp_growth"))
    expect_equal(df$val[df$year == 2002], 100 * prod(1 + g / 100))
    expect_lt(df$val[df$year == 2002], 85)
    expect_match(as.character(output$change_note$html), "Real GDP index")

    session$setInputs(variable = "inflation")
    expect_match(as.character(output$change_note$html), "percentage points")
    expect_equal(plot_data()$val[plot_data()$year == 2002],
                 snap("Argentina", 2002, "inflation") - snap("Argentina", 1998, "inflation"))
  })
})
