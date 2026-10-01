# =============================================================================
# DATA UTILITIES
# Handles WDI data fetching, disk caching, processing, and variable metadata
# =============================================================================

# ---------------------------------------------------------------------------
# VARIABLE DEFINITIONS
# Each variable carries metadata used across all modules for consistency
# ---------------------------------------------------------------------------
VARS <- list(
  gdp_growth = list(
    code            = "NY.GDP.MKTP.KD.ZG",
    label           = "GDP Growth (%)",
    short           = "GDP Growth",
    color           = "#2563eb",
    unit            = "%",
    higher_is_better = TRUE,
    zero_line       = TRUE,
    description     = paste0(
      "Annual percentage change in Gross Domestic Product at constant prices. ",
      "Positive values indicate economic expansion; negative values indicate contraction. ",
      "Two consecutive quarters of negative growth define a recession."
    )
  ),
  employment = list(
    code            = "SL.EMP.TOTL.SP.ZS",
    label           = "Employment Rate (%)",
    short           = "Employment",
    color           = "#16a34a",
    unit            = "%",
    higher_is_better = TRUE,
    zero_line       = FALSE,
    description     = paste0(
      "Percentage of the working-age population (15+) that is employed. ",
      "Also called the employment-to-population ratio. Higher values indicate ",
      "a greater share of the population participating in productive work."
    )
  ),
  inflation = list(
    code            = "FP.CPI.TOTL.ZG",
    label           = "Inflation (%)",
    short           = "Inflation",
    color           = "#dc2626",
    unit            = "%",
    higher_is_better = FALSE,
    zero_line       = TRUE,
    description     = paste0(
      "Annual percentage change in consumer prices (CPI). ",
      "Moderate inflation (1–3%) is considered healthy in most economies. ",
      "Very high inflation (hyperinflation) or deflation (negative inflation) ",
      "can cause serious economic disruption."
    )
  ),
  fiscal_balance = list(
    code            = "GC.NLD.TOTL.GD.ZS",
    label           = "Fiscal Balance (% of GDP)",
    short           = "Fiscal Balance",
    color           = "#7c3aed",
    unit            = "% of GDP",
    higher_is_better = TRUE,
    zero_line       = TRUE,
    description     = paste0(
      "General government net lending (+) / net borrowing (–): revenues minus expenditures ",
      "(including net investment), as a percentage of GDP. ",
      "A positive value is a budget surplus (government earns more than it spends). ",
      "A negative value is a deficit (government borrows to cover expenditures)."
    )
  ),
  trade_balance = list(
    code            = "NE.RSB.GNFS.ZS",
    label           = "Trade Balance (% of GDP)",
    short           = "Trade Balance",
    color           = "#d97706",
    unit            = "% of GDP",
    higher_is_better = TRUE,
    zero_line       = TRUE,
    description     = paste0(
      "Exports minus imports of goods and services, as a percentage of GDP. ",
      "A positive value is a trade surplus (more exports than imports). ",
      "A negative value is a trade deficit."
    )
  ),
  population = list(
    code            = "SP.POP.TOTL",
    label           = "Population",
    short           = "Population",
    color           = "#64748b",
    unit            = "people",
    higher_is_better = NA,
    zero_line       = FALSE,
    description     = "Total population of the country."
  )
)

# Named vector of indicator codes for WDI download
ALL_CODES <- setNames(
  sapply(VARS, `[[`, "code"),
  names(VARS)
)

# =============================================================================
# CACHE SETUP
# Uses cachem disk cache; expires after 7 days to stay reasonably up to date
# =============================================================================
.cache_env <- new.env(parent = emptyenv())

setup_cache <- function() {
  if (!is.null(.cache_env$disk_cache)) return(.cache_env$disk_cache)
  cache_dir <- file.path("data", "wdi_cache")
  dir.create(cache_dir, recursive = TRUE, showWarnings = FALSE)
  # The entire dataset (all countries × all years × all indicators) is stored
  # as ONE key. max_age controls when the whole dataset re-downloads.
  # max_size is a safety cap; the actual file is ~5–15 MB so it is never hit.
  .cache_env$disk_cache <- cachem::cache_disk(
    cache_dir,
    max_age  = 60 * 60 * 24 * 7,  # 7 days — full refresh weekly
    max_size = 50 * 1024^2         # 50 MB cap (actual data ~5–15 MB)
  )
  .cache_env$disk_cache
}

# Returns TRUE when df is a non-empty macro dataset with required columns
is_valid_macro_df <- function(df) {
  is.data.frame(df) && nrow(df) > 0 &&
    all(c("iso2c", "year", "country") %in% names(df))
}

# Persist only usable datasets; silently skip empty or malformed frames
cache_macro_data <- function(cache, key, df) {
  if (!is_valid_macro_df(df)) return(invisible(FALSE))
  tryCatch(cache$set(key, df), error = function(e) NULL)
  invisible(TRUE)
}

# Quick probe — avoids hammering WDI with dozens of paginated requests when API is down
wdi_api_available <- function(timeout = 5) {
  if (tolower(Sys.getenv("USE_DEMO_DATA", "false")) %in% c("true", "1", "yes")) {
    return(FALSE)
  }
  probe_url <- paste0(
    "https://api.worldbank.org/v2/en/country/all/indicator/",
    ALL_CODES[["gdp_growth"]],
    "?format=json&date=", YEAR_MAX, "&per_page=1&page=1"
  )
  tryCatch({
    con <- url(probe_url, open = "rb", timeout = timeout)
    on.exit(close(con), add = TRUE)
    first <- readLines(con, n = 1, warn = FALSE)
    length(first) > 0 && grepl("^\\[", first)
  }, error = function(e) FALSE)
}

load_fallback_data <- function(cache, demo_key, reason) {
  message("[macro_data] ", reason)
  message("[macro_data] Using synthetic demo data.")
  df <- generate_fallback_data()
  attr(df, "data_source") <- "demo"
  cache_macro_data(cache, demo_key, df)
  df
}

# Standardise raw WDI output (API or rebuilt snapshot) into app schema
clean_wdi_dataframe <- function(df_raw, start_year = YEAR_MIN, end_year = YEAR_MAX) {
  # Indicators the source lacks become all-NA columns, so modules never see NULL
  for (v in setdiff(names(VARS), names(df_raw))) {
    message("[macro_data] Indicator '", v, "' missing from source; filling with NA.")
    df_raw[[v]] <- NA_real_
  }

  df_raw %>%
    filter(!is.na(region), region != "Aggregates") %>%
    filter(year >= start_year, year <= end_year) %>%
    select(
      country, iso2c, year, region, income,
      any_of(names(VARS)),
      any_of(paste0(names(VARS), "_source"))
    ) %>%
    mutate(across(any_of(CORE_VARS), as.numeric),
           across(any_of("population"), as.numeric)) %>%
    filter(nchar(iso2c) == 2) %>%
    arrange(country, year)
}

load_bundled_snapshot <- function(start_year = YEAR_MIN, end_year = YEAR_MAX) {
  if (!file.exists(WDI_SNAPSHOT_PATH)) return(NULL)

  df <- tryCatch(
    read.csv(WDI_SNAPSHOT_PATH, stringsAsFactors = FALSE),
    error = function(e) {
      message("[macro_data] Could not read bundled snapshot: ", conditionMessage(e))
      NULL
    }
  )
  if (is.null(df)) return(NULL)

  df <- clean_wdi_dataframe(df, start_year, end_year)
  if (!is_valid_macro_df(df)) {
    message("[macro_data] Bundled snapshot at ", WDI_SNAPSHOT_PATH, " is invalid or empty.")
    return(NULL)
  }

  message("[macro_data] Loaded bundled snapshot (", WDI_SNAPSHOT_PATH, ").")
  attr(df, "data_source") <- "bundled"
  df
}

fetch_wdi_from_api <- function(cache, cache_key, demo_key,
                               start_year = YEAR_MIN, end_year = YEAR_MAX) {
  if (!wdi_api_available()) {
    return(NULL)
  }

  message("[macro_data] Downloading from World Bank API…")
  df_raw <- tryCatch({
    WDI(
      country   = "all",
      indicator = ALL_CODES,
      start     = start_year,
      end       = end_year,
      extra     = TRUE,
      cache     = NULL
    )
  }, error = function(e) {
    message("[macro_data] WDI download failed: ", conditionMessage(e))
    NULL
  })

  if (is.null(df_raw) || nrow(df_raw) == 0) return(NULL)

  df <- clean_wdi_dataframe(df_raw, start_year, end_year)
  if (!is_valid_macro_df(df)) return(NULL)

  attr(df, "data_source") <- "wdi"
  cache_macro_data(cache, cache_key, df)
  message("[macro_data] Done. ", nrow(df), " rows, ",
          length(unique(df$iso2c)), " countries.")
  df
}

# =============================================================================
# MAIN DATA LOADING FUNCTION
# =============================================================================
#' Fetch macroeconomic data from WDI or local cache
#'
#' Returns a data frame with columns:
#'   country, iso2c, year, region, income,
#'   gdp_growth, employment, inflation, fiscal_balance, trade_balance, population
#'
get_macro_data <- function(start_year = YEAR_MIN, end_year = YEAR_MAX) {

  cache      <- setup_cache()
  cache_key  <- paste0("wdi_macro_", start_year, "_", end_year, "_v5")
  demo_key   <- paste0("demo_macro_", start_year, "_", end_year, "_v1")

  # ── Bundled CSV snapshot (primary offline source) ───────────────────────────
  bundled <- load_bundled_snapshot(start_year, end_year)
  if (!is.null(bundled)) return(bundled)

  # ── Try WDI disk cache ──────────────────────────────────────────────────────
  cached <- tryCatch(cache$get(cache_key), error = function(e) NULL)
  if (!inherits(cached, "key_missing") && is_valid_macro_df(cached)) {
    message("[macro_data] Loaded from disk cache.")
    attr(cached, "data_source") <- "cache"
    return(cached)
  }
  if (!inherits(cached, "key_missing") && !is_valid_macro_df(cached)) {
    tryCatch(cache$remove(cache_key), error = function(e) NULL)
  }

  # ── Try demo cache ──────────────────────────────────────────────────────────
  demo_cached <- tryCatch(cache$get(demo_key), error = function(e) NULL)
  if (!inherits(demo_cached, "key_missing") && is_valid_macro_df(demo_cached)) {
    message("[macro_data] Loaded demo data from disk cache.")
    attr(demo_cached, "data_source") <- "demo"
    return(demo_cached)
  }

  # ── Live API (last resort before synthetic demo) ──────────────────────────
  live <- fetch_wdi_from_api(cache, cache_key, demo_key, start_year, end_year)
  if (!is.null(live)) return(live)

  if (wdi_api_available()) {
    load_fallback_data(cache, demo_key, "WDI returned no usable data.")
  } else {
    load_fallback_data(
      cache, demo_key,
      paste0(
        "No bundled snapshot at ", WDI_SNAPSHOT_PATH,
        " and World Bank API unavailable. ",
        "Run scripts/prepare_wdi_snapshot.R to rebuild it."
      )
    )
  }
}

# =============================================================================
# COUNTRY SELECTOR HELPER
# =============================================================================
#' Return a named vector suitable for selectInput choices
#' @param df  The full macro data frame
get_country_choices <- function(df) {
  df %>%
    select(country, iso2c) %>%
    distinct() %>%
    arrange(country) %>%
    { setNames(.$iso2c, .$country) }
}

# =============================================================================
# NORMALIZATION FOR RADAR CHART
# =============================================================================
#' Normalize core variables to [0,1] based on global percentile distribution.
#' Inflation is reverse-scaled so that "higher score = better performance".
#'
#' @param df  Wide data frame with CORE_VARS columns
#' @return  df with additional *_norm columns
normalize_for_radar <- function(df) {
  df_out <- df
  for (v in CORE_VARS) {
    if (!v %in% names(df)) next
    vals    <- df[[v]]
    if (all(is.na(vals))) { df_out[[paste0(v, "_norm")]] <- NA_real_; next }
    lo      <- quantile(vals, 0.05, na.rm = TRUE)
    hi      <- quantile(vals, 0.95, na.rm = TRUE)
    if (hi <= lo) { df_out[[paste0(v, "_norm")]] <- 0.5; next }
    norm    <- (vals - lo) / (hi - lo)
    norm    <- pmax(0, pmin(1, norm))
    # Reverse inflation: lower inflation → better score
    if (v == "inflation") norm <- 1 - norm
    df_out[[paste0(v, "_norm")]] <- norm
  }
  df_out
}

# =============================================================================
# HELPER ACCESSORS
# =============================================================================
var_label <- function(v)  if (v %in% names(VARS)) VARS[[v]]$label  else v
var_short  <- function(v)  if (v %in% names(VARS)) VARS[[v]]$short  else v
var_color  <- function(v)  if (v %in% names(VARS)) VARS[[v]]$color  else "#666"
var_unit   <- function(v)  if (v %in% names(VARS)) VARS[[v]]$unit   else ""

# Per-row data source for variable v (NA when the data has no source column)
var_source <- function(df, v) {
  col <- paste0(v, "_source")
  if (col %in% names(df)) df[[col]] else rep(NA_character_, nrow(df))
}

# Tooltip line naming the data source ("" when unknown)
source_hover <- function(src) {
  ifelse(is.na(src) | src == "", "", paste0("<br><i>Source: ", src, "</i>"))
}

# Choices list for variable selectors (core 5 only)
core_var_choices <- function() {
  setNames(CORE_VARS, sapply(CORE_VARS, var_label))
}

# =============================================================================
# FALLBACK DATA
# Generated when WDI API is unavailable (e.g., no internet connection).
# Uses plausible stylized patterns to preserve educational value.
# =============================================================================
generate_fallback_data <- function() {
  set.seed(2024)
  countries <- data.frame(
    country = c(
      "Argentina","Australia","Brazil","Canada","Chile","China","Colombia",
      "Egypt","France","Germany","Ghana","India","Indonesia","Japan","Kenya",
      "South Korea","Mexico","Nigeria","Poland","Russia",
      "South Africa","Spain","Turkey","United Kingdom","United States"
    ),
    iso2c = c(
      "AR","AU","BR","CA","CL","CN","CO","EG","FR","DE","GH","IN","ID",
      "JP","KE","KR","MX","NG","PL","RU","ZA","ES","TR","GB","US"
    ),
    region = c(
      "Latin America & Caribbean","East Asia & Pacific",
      "Latin America & Caribbean","North America",
      "Latin America & Caribbean","East Asia & Pacific",
      "Latin America & Caribbean","Middle East & North Africa",
      "Europe & Central Asia","Europe & Central Asia",
      "Sub-Saharan Africa","South Asia","East Asia & Pacific",
      "East Asia & Pacific","Sub-Saharan Africa",
      "East Asia & Pacific","Latin America & Caribbean",
      "Sub-Saharan Africa","Europe & Central Asia",
      "Europe & Central Asia","Sub-Saharan Africa",
      "Europe & Central Asia","Europe & Central Asia",
      "Europe & Central Asia","North America"
    ),
    income = c(
      "Upper middle income","High income","Upper middle income",
      "High income","High income","Upper middle income",
      "Upper middle income","Lower middle income","High income",
      "High income","Lower middle income","Lower middle income",
      "Lower middle income","High income","Lower middle income",
      "High income","Upper middle income","Lower middle income",
      "High income","Upper middle income","Upper middle income",
      "High income","Upper middle income","High income","High income"
    ),
    base_gdp   = c( 2, 3, 3, 2.5, 4, 8, 4, 4, 1.5, 1.5, 5, 6, 5, 1, 5.5,
                    5, 3,  5, 4, 3, 3, 2, 4, 2, 2.5),
    base_emp   = c(53,60,57,60,54,65,57,43,55,58,57,53,62,60,65,
                   62,58,52,57,60,43,55,50,60,60),
    base_inf   = c(15, 3, 7, 2, 5, 4, 8, 9,  2,  2, 19, 7, 7, 1, 14,
                    3, 8,17, 5, 14,  7, 3,25, 2,  3),
    base_fis   = c(-3, -1,-3,-1,-1,-1,-3,-8, -3,-1,-5,-5,-2, -6,-4,
                    0,-3,-3,-3,-3,-4,-3,-3,-3,-3),
    base_trd   = c( 1,  3, 1, 0, 3, 3,-2,-3, -1,  5,-3,-2, 2,  2,-4,
                    4,-2, 2, 0,  7,-2,-2,-3,-2,-3),
    stringsAsFactors = FALSE
  )

  years <- seq(YEAR_MIN, YEAR_MAX)
  n     <- length(years)

  # Simulate plausible correlated time series per country
  result_list <- lapply(seq_len(nrow(countries)), function(i) {
    set.seed(i * 17)
    # GDP with business cycles
    gdp_cyc <- sin(seq(0, 4 * pi, length.out = n)) * 1.5
    gdp     <- countries$base_gdp[i] + gdp_cyc + rnorm(n, 0, 1.2)
    # Crisis years
    gdp[years == 2009] <- gdp[years == 2009] - 4
    gdp[years == 2020] <- gdp[years == 2020] - 5
    gdp[years == 2021] <- gdp[years == 2021] + 4

    emp     <- pmax(35, pmin(80,
      countries$base_emp[i] + cumsum(rnorm(n, 0, 0.25)) + gdp * 0.3))
    inf     <- pmax(0.2,
      countries$base_inf[i] + cumsum(rnorm(n, -0.1, 1.5)))
    fis     <- countries$base_fis[i] + rnorm(n, 0, 1.2)
    fis[years == 2009] <- fis[years == 2009] - 3
    fis[years == 2020] <- fis[years == 2020] - 5
    trd     <- countries$base_trd[i] + rnorm(n, 0, 1.5)
    pop     <- 20e6 * exp(rnorm(1, 2, 0.8)) * (1.013^seq_along(years))

    data.frame(
      country       = countries$country[i],
      iso2c         = countries$iso2c[i],
      year          = years,
      region        = countries$region[i],
      income        = countries$income[i],
      gdp_growth    = round(gdp, 2),
      employment    = round(emp, 1),
      inflation     = round(inf, 1),
      fiscal_balance= round(fis, 2),
      trade_balance  = round(trd, 2),
      population    = round(pop),
      stringsAsFactors = FALSE
    )
  })

  dplyr::bind_rows(result_list)
}
