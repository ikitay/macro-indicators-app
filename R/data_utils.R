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
    objective       = "Crecimiento económico",
    group           = "central",
    dimension       = "Producción",
    source          = "wdi",
    code            = "NY.GDP.MKTP.KD.ZG",
    label           = "Crecimiento del PBI real (%)",
    short           = "Crecimiento del PBI",
    color           = "#2563eb",
    unit            = "%",
    zero_line       = TRUE,
    description     = paste0(
      "Variación porcentual anual del PBI a precios constantes (PBI real). ",
      "Los valores positivos indican que la producción aumentó; los negativos, que cayó. ",
      "Es el principal indicador del objetivo de crecimiento económico."
    )
  ),
  unemployment = list(
    objective       = "Pleno empleo",
    group           = "central",
    dimension       = "Empleo",
    source          = "wdi",
    code            = "SL.UEM.TOTL.ZS",
    label           = "Tasa de desempleo (%)",
    short           = "Tasa de desempleo",
    color           = "#16a34a",
    unit            = "%",
    zero_line       = FALSE,
    description     = paste0(
      "Porcentaje de la población económicamente activa que busca trabajo y no lo ",
      "encuentra (estimación de la OIT, desde 1991). Es el principal indicador del pleno empleo."
    )
  ),
  inflation = list(
    objective       = "Estabilidad de precios",
    group           = "central",
    dimension       = "Precios",
    source          = "wdi",
    code            = "FP.CPI.TOTL.ZG",
    label           = "Inflación (%)",
    short           = "Inflación",
    color           = "#dc2626",
    unit            = "%",
    zero_line       = TRUE,
    description     = paste0(
      "Variación porcentual anual del Índice de Precios al Consumidor (IPC). ",
      "Lo que se busca evitar es una inflación elevada o inestable; la deflación ",
      "(caída sostenida del nivel general de precios) tampoco es deseable."
    )
  ),
  fiscal_balance = list(
    objective       = "Sostenibilidad fiscal",
    group           = "sustainability",
    dimension       = "Situación fiscal",
    source          = "wdi",
    code            = "GC.NLD.TOTL.GD.ZS",
    label           = "Resultado fiscal (% del PBI)",
    short           = "Resultado fiscal",
    color           = "#7c3aed",
    unit            = "% del PBI",
    zero_line       = TRUE,
    description     = paste0(
      "Ingresos menos gastos del gobierno general, en porcentaje del PBI. ",
      "Un valor positivo es un superávit fiscal; uno negativo, un déficit fiscal."
    )
  ),
  public_debt = list(
    objective       = "Sostenibilidad fiscal",
    group           = "sustainability",
    dimension       = "Situación fiscal",
    source          = "imf",
    code            = "GGXWDG_NGDP",
    label           = "Deuda pública (% del PBI)",
    short           = "Deuda pública",
    color           = "#a21caf",
    unit            = "% del PBI",
    zero_line       = FALSE,
    description     = paste0(
      "Deuda bruta del gobierno general, en porcentaje del PBI (FMI). Para la ",
      "sostenibilidad fiscal importa su trayectoria: si crece, se mantiene o baja."
    )
  ),
  trade_balance = list(
    objective       = "Sostenibilidad externa",
    group           = "sustainability",
    dimension       = "Sector externo",
    source          = "wdi",
    code            = "NE.RSB.GNFS.ZS",
    label           = "Saldo comercial de bienes y servicios (% del PBI)",
    short           = "Saldo comercial",
    color           = "#d97706",
    unit            = "% del PBI",
    zero_line       = TRUE,
    description     = paste0(
      "Exportaciones menos importaciones de bienes y servicios, en porcentaje del PBI. ",
      "Un valor positivo es un superávit comercial; uno negativo, un déficit comercial. ",
      "Es más acotado que la balanza de pagos."
    )
  ),
  current_account = list(
    objective       = "Sostenibilidad externa",
    group           = "sustainability",
    dimension       = "Sector externo",
    source          = "wdi",
    code            = "BN.CAB.XOKA.GD.ZS",
    label           = "Cuenta corriente (% del PBI)",
    short           = "Cuenta corriente",
    color           = "#0891b2",
    unit            = "% del PBI",
    zero_line       = TRUE,
    description     = paste0(
      "Saldo de la cuenta corriente de la balanza de pagos: comercio de bienes y ",
      "servicios más ingresos y transferencias con el resto del mundo. Un déficit ",
      "tiene que financiarse con ingresos de capital, por ejemplo inversiones o préstamos."
    )
  ),
  fdi_inflows = list(
    objective       = "Sostenibilidad externa",
    group           = "sustainability",
    dimension       = "Sector externo",
    source          = "wdi",
    code            = "BX.KLT.DINV.WD.GD.ZS",
    label           = "Inversión extranjera directa, ingreso neto (% del PBI)",
    short           = "Inversión extranjera directa",
    color           = "#65a30d",
    unit            = "% del PBI",
    zero_line       = TRUE,
    description     = paste0(
      "Ingreso neto de inversión extranjera directa, en porcentaje del PBI: una de las ",
      "formas de financiar un déficit de cuenta corriente."
    )
  ),
  employment = list(
    objective       = "Pleno empleo",
    group           = "other",
    dimension       = "Empleo",
    source          = "wdi",
    code            = "SL.EMP.TOTL.SP.ZS",
    label           = "Tasa de empleo (%)",
    short           = "Tasa de empleo",
    color           = "#15803d",
    unit            = "%",
    zero_line       = FALSE,
    description     = paste0(
      "Porcentaje de la población de 15 años o más que tiene empleo. ",
      "No es la tasa de desempleo, que mide qué parte de la población económicamente ",
      "activa busca trabajo y no lo encuentra."
    )
  ),
  population = list(
    source          = "wdi",
    code            = "SP.POP.TOTL",
    label           = "Población",
    short           = "Población",
    color           = "#64748b",
    unit            = "personas",
    zero_line       = FALSE,
    description     = "Población total del país."
  )
)

# ---------------------------------------------------------------------------
# EXTRA SERIES
# Levels kept in the snapshot for the levels-vs-rates view: they are not
# indicators of an objective, so they do not appear in the indicator menus.
# `source` is "wdi" (World Bank bulk file) or "imf" (IMF DataMapper).
# ---------------------------------------------------------------------------
EXTRA_SERIES <- list(
  cpi_index = list(
    source = "wdi", code = "FP.CPI.TOTL",
    label  = "IPC (índice, 2010 = 100)", unit = "",
    description = "Índice de Precios al Consumidor. La inflación es su variación porcentual."
  ),
  gdp_nominal_lcu = list(
    source = "wdi", code = "NY.GDP.MKTP.CN",
    label  = "PBI nominal (moneda local corriente)", unit = "",
    description = "PBI valuado a los precios de cada año."
  ),
  gdp_real_lcu = list(
    source = "wdi", code = "NY.GDP.MKTP.KN",
    label  = "PBI real (moneda local constante)", unit = "",
    description = "PBI valuado a precios de un año base: descuenta el efecto de los cambios de precios."
  )
)

# World Bank codes of the extra series, named by column
EXTRA_WDI_CODES <- local({
  wdi <- Filter(function(s) s$source == "wdi", EXTRA_SERIES)
  setNames(sapply(wdi, `[[`, "code"), names(wdi))
})

# World Bank codes of the indicators (the IMF ones come from
# scripts/supplementary_sources.R), named by column
ALL_CODES <- local({
  wdi <- Filter(function(s) s$source == "wdi", VARS)
  setNames(sapply(wdi, `[[`, "code"), names(wdi))
})

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
      any_of(paste0(names(VARS), "_source")),
      any_of(names(EXTRA_SERIES)),
      any_of(paste0(names(EXTRA_SERIES), "_source"))
    ) %>%
    mutate(across(any_of(c(CORE_VARS, names(EXTRA_SERIES))), as.numeric),
           across(any_of("population"), as.numeric)) %>%
    filter(nchar(iso2c) == 2) %>%
    translate_country_fields() %>%
    arrange(country, year)
}

load_bundled_snapshot <- function(start_year = YEAR_MIN, end_year = YEAR_MAX) {
  if (!file.exists(WDI_SNAPSHOT_PATH)) return(NULL)

  df <- tryCatch(
    read.csv(WDI_SNAPSHOT_PATH, stringsAsFactors = FALSE, encoding = "UTF-8"),
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
  cache_key  <- paste0("wdi_macro_", start_year, "_", end_year, "_v6")
  demo_key   <- paste0("demo_macro_", start_year, "_", end_year, "_v2")

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
# SCORES FOR THE COUNTRY PROFILE
# =============================================================================
# Only the three central objectives are scored. The fiscal and trade balances
# are sustainability information: a deficit is not automatically worse than a
# surplus, so they are shown with context but never scored.
CENTRAL_VARS <- c("gdp_growth", "unemployment", "inflation")
SUSTAINABILITY_VARS <- c("fiscal_balance", "public_debt", "trade_balance", "current_account")

# Inflation closest to this rate scores best on price stability; deflation and
# high inflation both score lower.
INFLATION_TARGET <- 2

#' Score the central objectives as percentile ranks (0–100) against every
#' country-year in df: a score of 70 means better than 70% of observations.
#' Price stability is ranked by distance from INFLATION_TARGET.
#'
#' @param df  Wide data frame with CENTRAL_VARS columns
#' @return  df with additional *_score columns (NA where the value is missing)
score_central_objectives <- function(df) {
  # Higher "goodness" is better for every variable
  goodness <- list(
    gdp_growth = df$gdp_growth,
    unemployment = -df$unemployment,
    inflation  = -abs(df$inflation - INFLATION_TARGET)
  )
  for (v in CENTRAL_VARS) {
    g   <- goodness[[v]]
    obs <- sort(g[!is.na(g)])
    df[[paste0(v, "_score")]] <- if (length(obs) == 0) {
      NA_real_
    } else {
      # Share of observations strictly worse than this one
      ifelse(is.na(g), NA_real_,
             100 * findInterval(g, obs, left.open = TRUE) / length(obs))
    }
  }
  df
}

# =============================================================================
# HELPER ACCESSORS
# =============================================================================
var_label <- function(v)  if (v %in% names(VARS)) VARS[[v]]$label  else v
var_short  <- function(v)  if (v %in% names(VARS)) VARS[[v]]$short  else v
var_color  <- function(v)  if (v %in% names(VARS)) VARS[[v]]$color  else "#666"
var_unit   <- function(v)  if (v %in% names(VARS)) VARS[[v]]$unit   else ""
var_objective <- function(v) if (v %in% names(VARS)) VARS[[v]]$objective else v
# "Economic growth: GDP Growth (%)"
var_objective_label <- function(v) paste0(var_objective(v), ": ", var_label(v))

# Per-row data source for variable v (NA when the data has no source column)
var_source <- function(df, v) {
  col <- paste0(v, "_source")
  if (col %in% names(df)) df[[col]] else rep(NA_character_, nrow(df))
}

# Spanish names of the data sources recorded in the snapshot's *_source columns
SOURCE_NAMES_ES <- c(
  "World Bank WDI"             = "Banco Mundial (WDI)",
  "IMF World Economic Outlook" = "FMI, World Economic Outlook",
  "INDEC official CPI"         = "IPC oficial del INDEC",
  "Median of provincial CPIs"  = "Mediana de IPC provinciales"
)

# Tooltip line naming the data source ("" when unknown)
source_hover <- function(src) {
  ifelse(is.na(src) | src == "", "",
         paste0("<br><i>Fuente: ", translate_values(src, SOURCE_NAMES_ES), "</i>"))
}

# Number with a decimal comma, as written in Argentina: num_es(2.5) -> "2,5"
num_es <- function(x, digits = 1) {
  ifelse(is.na(x), "s/d",
         formatC(round(x, digits), format = "f", digits = digits,
                 decimal.mark = ",", big.mark = "."))
}

# Indicators grouped by the kind of objective they observe, labelled
# "Objective: indicator", for selectInput (the names become option groups)
core_var_choices <- function() {
  group_choices <- function(g) {
    vs <- CORE_VARS[sapply(CORE_VARS, function(v) VARS[[v]]$group == g)]
    setNames(vs, sapply(vs, var_objective_label))
  }
  groups <- names(OBJECTIVE_GROUPS)
  setNames(lapply(groups, group_choices), unname(OBJECTIVE_GROUPS[groups]))
}

# Variables of one objective group, in CORE_VARS order
group_vars <- function(g) CORE_VARS[sapply(CORE_VARS, function(v) VARS[[v]]$group == g)]

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

  df <- dplyr::bind_rows(result_list)
  # The demo data has no series for the other indicators
  for (v in setdiff(names(VARS), names(df))) df[[v]] <- NA_real_
  translate_country_fields(df)
}
