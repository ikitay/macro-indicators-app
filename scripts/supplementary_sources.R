# =============================================================================
# Supplementary sources that fill gaps in the WDI bulk data.
# Sourced by scripts/prepare_wdi_snapshot.R; adds `inflation_source` and
# `fiscal_balance_source` columns so the app can show where each value is from.
#
#   fiscal_balance  IMF World Economic Outlook, general government net
#                   lending/borrowing (GGXCNL_NGDP). It replaces WDI's
#                   central-government series for every country the IMF
#                   covers; WDI is kept only for countries the IMF lacks, so
#                   no single country mixes the two definitions.
#   inflation       WDI, with missing years filled from IMF WEO (PCPIPCH).
#   public_debt     IMF World Economic Outlook, general government gross debt
#                   (GGXWDG_NGDP), for every country the IMF covers.
#   Argentina       Inflation 1990–2016 rebuilt from official Argentine CPIs
#                   published on datos.gob.ar: INDEC's CPI through 2006, then
#                   the median of independent provincial CPIs for 2007–2016,
#                   when INDEC's index was discredited and later suspended.
#
# Every source is fetched over plain HTTPS with no API key. If one is
# unreachable the build warns and keeps the WDI values for that variable.
# =============================================================================

IMF_API <- "https://www.imf.org/external/datamapper/api/v1/"
ARG_API <- "https://apis.datos.gob.ar/series/api/series/"

SRC_WDI   <- "World Bank WDI"
SRC_IMF   <- "IMF World Economic Outlook"
SRC_INDEC <- "INDEC official CPI"
SRC_PROV  <- "Median of provincial CPIs"

# ISO3 codes where WDI and the IMF differ
IMF_ISO3 <- c(XKX = "UVK", PSE = "WBG")

# Argentine CPI series on datos.gob.ar (monthly index levels)
ARG_SERIES <- c(
  indec    = "178.1_NL_GENERAL_0_0_13",       # INDEC historical CPI, 1943–2008
  san_luis = "197.1_NIVEL_GENERAL_2014_0_13", # Provincia de San Luis
  neuquen  = "196.1_NIVEL_GENERAL_2014_0_13", # Provincia de Neuquén
  chaco    = "464.1_IPC_CHACO_NG_0_0_22_93",  # Gran Resistencia, Chaco
  caba     = "193.1_NIVEL_GENERAL_JULI_0_13"  # Ciudad de Buenos Aires (from 2012-07)
)
ARG_OFFICIAL_YEARS   <- 1990:2006
ARG_PROVINCIAL_YEARS <- 2007:2016

# Long data frame (imf_iso3, year, value) for one IMF DataMapper indicator
fetch_imf_indicator <- function(code) {
  js   <- jsonlite::fromJSON(paste0(IMF_API, code), simplifyVector = FALSE)
  vals <- js$values[[code]]
  if (is.null(vals)) stop("IMF returned no values for ", code)
  do.call(rbind, lapply(names(vals), function(iso) {
    v <- vals[[iso]]
    data.frame(
      imf_iso3 = iso,
      year     = as.integer(names(v)),
      value    = vapply(v, function(x) if (is.null(x)) NA_real_ else as.numeric(x), numeric(1)),
      stringsAsFactors = FALSE
    )
  }))
}

# Annual-average inflation for Argentina (year, value, source), same
# definition as WDI/IMF: mean index level over the year vs the previous year
fetch_argentina_inflation <- function() {
  url <- paste0(
    ARG_API, "?ids=", paste(ARG_SERIES, collapse = ","),
    "&format=csv&limit=1000&start_date=1989-01-01&end_date=2016-12-01"
  )
  raw <- read.csv(url, stringsAsFactors = FALSE)
  names(raw) <- c("date", names(ARG_SERIES))
  raw$year <- as.integer(substr(raw$date, 1, 4))

  annual <- raw %>%
    group_by(year) %>%
    summarise(across(all_of(names(ARG_SERIES)),
                     ~ if (sum(!is.na(.x)) == 12) mean(.x) else NA_real_),
              .groups = "drop") %>%
    arrange(year) %>%
    mutate(across(all_of(names(ARG_SERIES)), ~ (.x / lag(.x) - 1) * 100))

  provincial <- setdiff(names(ARG_SERIES), "indec")
  annual$provincial_median <- apply(annual[provincial], 1, function(x) {
    if (all(is.na(x))) NA_real_ else median(x, na.rm = TRUE)
  })

  bind_rows(
    annual %>%
      filter(year %in% ARG_OFFICIAL_YEARS) %>%
      transmute(year, value = indec, source = SRC_INDEC),
    annual %>%
      filter(year %in% ARG_PROVINCIAL_YEARS) %>%
      transmute(year, value = provincial_median, source = SRC_PROV)
  ) %>%
    filter(!is.na(value))
}

# Run a fetch, returning NULL with a warning if the source is unreachable
try_fetch <- function(label, expr) {
  tryCatch(expr, error = function(e) {
    warning(label, " unavailable (", conditionMessage(e), "); continuing without it.",
            call. = FALSE)
    NULL
  })
}

# `snapshot` must carry an `iso3` column. Returns it with supplemented
# inflation / fiscal_balance values and their *_source columns, and a
# "supplement_log" attribute summarising what was filled.
apply_supplements <- function(snapshot) {
  snapshot <- snapshot %>%
    mutate(
      imf_iso3              = ifelse(iso3 %in% names(IMF_ISO3), IMF_ISO3[iso3], iso3),
      inflation_source      = ifelse(is.na(inflation), NA_character_, SRC_WDI),
      fiscal_balance_source = ifelse(is.na(fiscal_balance), NA_character_, SRC_WDI)
    )
  log <- character()

  # ── Fiscal balance: IMF replaces WDI wherever the IMF covers the country ──
  message("Fetching IMF fiscal balance (GGXCNL_NGDP)…")
  imf_fis <- try_fetch("IMF fiscal balance", fetch_imf_indicator("GGXCNL_NGDP"))
  if (!is.null(imf_fis)) {
    imf_fis <- filter(imf_fis, !is.na(value))
    covered <- unique(imf_fis$imf_iso3)
    snapshot <- snapshot %>%
      left_join(rename(imf_fis, imf_fis = value), by = c("imf_iso3", "year")) %>%
      mutate(
        use_imf               = imf_iso3 %in% covered,
        fiscal_balance        = ifelse(use_imf, imf_fis, fiscal_balance),
        fiscal_balance_source = ifelse(use_imf,
                                       ifelse(is.na(imf_fis), NA_character_, SRC_IMF),
                                       fiscal_balance_source)
      ) %>%
      select(-imf_fis, -use_imf)
    log <- c(log, paste0("fiscal_balance: IMF WEO for ",
                         sum(unique(snapshot$imf_iso3) %in% covered), " countries"))
  }

  # ── Inflation: fill WDI gaps from the IMF ─────────────────────────────────
  message("Fetching IMF inflation (PCPIPCH)…")
  imf_inf <- try_fetch("IMF inflation", fetch_imf_indicator("PCPIPCH"))
  if (!is.null(imf_inf)) {
    snapshot <- snapshot %>%
      left_join(rename(imf_inf, imf_inf = value), by = c("imf_iso3", "year")) %>%
      mutate(
        fill             = is.na(inflation) & !is.na(imf_inf),
        inflation        = ifelse(fill, imf_inf, inflation),
        inflation_source = ifelse(fill, SRC_IMF, inflation_source)
      )
    log <- c(log, paste0("inflation: ", sum(snapshot$fill), " gaps filled from IMF WEO"))
    snapshot <- select(snapshot, -imf_inf, -fill)
  }

  # ── Public debt: IMF only (WDI's central-government debt is too sparse) ──
  message("Fetching IMF public debt (GGXWDG_NGDP)…")
  imf_debt <- try_fetch("IMF public debt", fetch_imf_indicator("GGXWDG_NGDP"))
  if (!is.null(imf_debt)) {
    snapshot <- snapshot %>%
      left_join(rename(imf_debt, public_debt = value), by = c("imf_iso3", "year")) %>%
      mutate(public_debt_source = ifelse(is.na(public_debt), NA_character_, SRC_IMF))
    log <- c(log, paste0("public_debt: IMF WEO, ",
                         sum(!is.na(snapshot$public_debt)), " country-years"))
  }

  # ── Argentina: official and provincial CPIs override 1990–2016 ────────────
  message("Fetching Argentine CPIs (datos.gob.ar)…")
  arg <- try_fetch("datos.gob.ar", fetch_argentina_inflation())
  if (!is.null(arg)) {
    snapshot <- snapshot %>%
      left_join(rename(arg, arg_value = value, arg_source = source),
                by = "year", relationship = "many-to-one") %>%
      mutate(
        is_arg           = iso3 == "ARG" & !is.na(arg_value),
        inflation        = ifelse(is_arg, arg_value, inflation),
        inflation_source = ifelse(is_arg, arg_source, inflation_source)
      )
    log <- c(log, paste0("inflation (Argentina): ", sum(snapshot$is_arg),
                         " years from INDEC / provincial CPIs"))
    snapshot <- select(snapshot, -arg_value, -arg_source, -is_arg)
  }

  snapshot <- select(snapshot, -imf_iso3)
  attr(snapshot, "supplement_log") <- log
  snapshot
}
