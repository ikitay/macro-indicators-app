# Every value shown on hover names its source, as the assignment tells students

test_that("every indicator with a value has a source", {
  for (v in c(CORE_VARS, "gdp_real_lcu", "gdp_nominal_lcu")) {
    src <- var_source(macro_df, v)
    has_value <- !is.na(macro_df[[v]])
    expect_false(anyNA(src[has_value]), label = v)
    expect_true(all(is.na(src[!has_value])), label = v)
    expect_true(all(src[has_value] %in% names(SOURCE_NAMES_ES)), label = v)
  }
})

test_that("recorded sources win over the series' default", {
  ar <- macro_df[macro_df$iso2c == "AR", ]
  expect_equal(unique(var_source(ar[ar$year == 2015, ], "inflation")), "Median of provincial CPIs")
  expect_equal(unique(var_source(ar, "unemployment")[!is.na(ar$unemployment)]), "World Bank WDI")
})
