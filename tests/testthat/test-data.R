test_that("bundled snapshot loads with every core variable", {
  expect_identical(attr(macro_df, "data_source"), "bundled")
  expect_true(all(c("country", "iso2c", "year", CORE_VARS) %in% names(macro_df)))
  expect_gt(length(unique(macro_df$iso2c)), 200)
  expect_equal(range(macro_df$year), c(YEAR_MIN, YEAR_MAX))
})

test_that("a missing indicator becomes an all-NA column instead of an error", {
  raw <- read.csv(file.path(app_root, WDI_SNAPSHOT_PATH), stringsAsFactors = FALSE)
  raw$fiscal_balance <- NULL
  df <- suppressMessages(clean_wdi_dataframe(raw))
  expect_true("fiscal_balance" %in% names(df))
  expect_true(all(is.na(df$fiscal_balance)))
})
