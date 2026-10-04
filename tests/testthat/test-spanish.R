test_that("every country, region and income group in the data has a Spanish name", {
  expect_true(all(macro_df$iso2c %in% names(COUNTRY_NAMES_ES)))
  expect_equal(unname(COUNTRY_NAMES_ES[macro_df$iso2c]), macro_df$country)
  expect_true(all(macro_df$region %in% names(REGION_COLORS)))
  expect_true(all(macro_df$income %in% INCOME_NAMES_ES))
  expect_identical(snap("Corea del Sur", 2019, "gdp_growth"),
                   macro_df$gdp_growth[macro_df$iso2c == "KR" & macro_df$year == 2019])
})

test_that("country lists are in Spanish alphabetical order", {
  ch <- names(get_country_choices(macro_df))
  expect_equal(which(ch == "Alemania") < which(ch == "Brasil"), TRUE)
})

test_that("names used by challenges and events exist in the data", {
  countries <- unique(macro_df$country)
  for (ch in CHALLENGES) {
    expect_true(ch$difficulty %in% names(DIFFICULTY_COLORS), label = ch$id)
    for (s in ch$solution_countries) {
      for (name in trimws(strsplit(sub(" \\(.*\\)$", "", s$country), "/")[[1]])) {
        expect_true(name %in% countries, label = paste(ch$id, name))
      }
    }
  }
  for (ev in HISTORICAL_EVENTS) {
    expect_true(all(ev$affected_regions %in% names(REGION_COLORS)), label = ev$id)
  }
})

test_that("numbers are written with a decimal comma", {
  expect_equal(num_es(2.5), "2,5")
  expect_equal(num_es(-1234.567, 2), "-1.234,57")
  expect_equal(num_es(NA), "s/d")
  expect_equal(source_hover("IMF World Economic Outlook"), "<br><i>Fuente: FMI, World Economic Outlook</i>")
})

test_that("synthetic demo data is also in Spanish", {
  demo <- generate_fallback_data()
  expect_true("Corea del Sur" %in% demo$country)
  expect_true(all(demo$region %in% names(REGION_COLORS)))
})
