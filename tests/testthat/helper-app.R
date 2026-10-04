# Loads the app's code (everything app.R sources) without starting the app.

# The source files are UTF-8 (emoji, accents); read them as such even when the
# session starts in a non-UTF-8 locale such as "C".
if (!isTRUE(l10n_info()[["UTF-8"]])) {
  for (loc in c("C.UTF-8", "en_US.UTF-8", "English_United States.utf8")) {
    if (nzchar(suppressWarnings(Sys.setlocale("LC_CTYPE", loc)))) break
  }
}
suppressPackageStartupMessages({
  library(shiny)
  library(bslib)
  library(plotly)
  library(dplyr)
  library(tidyr)
  library(cachem)
})

app_root <- normalizePath(file.path(testthat::test_path(), "..", ".."))
local({
  old <- setwd(app_root)
  on.exit(setwd(old))
  for (f in c("R/wdi_shim.R", "R/widgets_shim.R", "R/constants.R", "R/country_names_es.R",
              "R/data_utils.R", "R/glossary.R", "R/events_data.R",
              "R/challenges_data.R", "R/mod_explore_country.R",
              "R/mod_compare_countries.R", "R/mod_global_explorer.R",
              "R/mod_country_profile.R", "R/mod_historical_events.R",
              "R/mod_challenges.R", "R/mod_correlation.R")) {
    sys.source(f, envir = globalenv())
  }
})

# The bundled snapshot, loaded once for all tests
macro_df <- local({
  old <- setwd(app_root)
  on.exit(setwd(old))
  suppressMessages(get_macro_data())
})

# Value of one variable for a country-year in the snapshot
snap <- function(country, year, var) {
  macro_df[[var]][macro_df$country == country & macro_df$year == year]
}

# Force every output of a module to render; fails the test on any error
render_all_outputs <- function(output, names) {
  for (nm in names) {
    expect_no_error(output[[nm]], message = nm)
  }
}
