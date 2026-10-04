# The snapshot build (scripts/prepare_wdi_snapshot.R) with its network
# sources replaced by fixed data, so it runs offline.

local({
  old <- setwd(app_root)
  on.exit(setwd(old))
  sys.source("scripts/supplementary_sources.R", envir = globalenv())
})

fake_imf <- function(code) {
  values <- switch(code,
    GGXCNL_NGDP = c(-3, -4),
    PCPIPCH     = c(5, 6),
    GGXWDG_NGDP = c(60, 65),
    stop("unexpected IMF code ", code))
  data.frame(imf_iso3 = "AAA", year = c(2000L, 2001L), value = values)
}

# AAA is covered by the fake IMF data; BBB is not
wdi_rows <- data.frame(
  iso3           = c("AAA", "AAA", "BBB"),
  year           = c(2000L, 2001L, 2000L),
  inflation      = c(NA, 2, 3),
  fiscal_balance = c(-1, -1, -2)
)

with_fakes <- function(code) {
  real_imf <- fetch_imf_indicator
  real_arg <- fetch_argentina_inflation
  assign("fetch_imf_indicator", fake_imf, envir = globalenv())
  assign("fetch_argentina_inflation", function() stop("offline"), envir = globalenv())
  on.exit({
    assign("fetch_imf_indicator", real_imf, envir = globalenv())
    assign("fetch_argentina_inflation", real_arg, envir = globalenv())
  })
  code
}

test_that("public debt comes from the IMF, with its source recorded", {
  out <- with_fakes(suppressWarnings(suppressMessages(apply_supplements(wdi_rows))))
  expect_equal(out$public_debt, c(60, 65, NA))
  expect_equal(out$public_debt_source, c(SRC_IMF, SRC_IMF, NA))
  expect_true(any(grepl("^public_debt: IMF WEO, 2 country-years$", attr(out, "supplement_log"))))
})

test_that("existing supplements still behave as before", {
  out <- with_fakes(suppressWarnings(suppressMessages(apply_supplements(wdi_rows))))
  # IMF fiscal balance replaces WDI for covered countries only
  expect_equal(out$fiscal_balance, c(-3, -4, -2))
  # IMF inflation only fills WDI gaps
  expect_equal(out$inflation, c(5, 2, 3))
  expect_equal(out$inflation_source, c(SRC_IMF, SRC_WDI, SRC_WDI))
})

test_that("an unreachable source is skipped with a warning", {
  real_imf <- fetch_imf_indicator
  real_arg <- fetch_argentina_inflation
  assign("fetch_imf_indicator", function(code) stop("offline"), envir = globalenv())
  assign("fetch_argentina_inflation", function() stop("offline"), envir = globalenv())
  on.exit({
    assign("fetch_imf_indicator", real_imf, envir = globalenv())
    assign("fetch_argentina_inflation", real_arg, envir = globalenv())
  })
  expect_warning(out <- suppressMessages(apply_supplements(wdi_rows)), "public debt unavailable")
  expect_false("public_debt" %in% names(out))
  expect_equal(out$fiscal_balance, wdi_rows$fiscal_balance)
})

test_that("extra series are kept when the app loads a snapshot that has them", {
  raw <- read.csv(file.path(app_root, WDI_SNAPSHOT_PATH), stringsAsFactors = FALSE)
  raw$unemployment <- 7.5
  raw$public_debt  <- 50
  df <- suppressMessages(clean_wdi_dataframe(raw))
  expect_true(all(c("unemployment", "public_debt") %in% names(df)))
  expect_true(all(names(EXTRA_WDI_CODES) %in% names(EXTRA_SERIES)))
  expect_false("public_debt" %in% names(EXTRA_WDI_CODES))  # from the IMF, not the World Bank
})
