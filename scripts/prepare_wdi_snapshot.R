#!/usr/bin/env Rscript
# =============================================================================
# Build data/wdi_snapshot.csv from the World Bank WDI bulk CSV download.
#
# Run from the project root:
#   Rscript scripts/prepare_wdi_snapshot.R
#
# Requires: dplyr, tidyr (same as the Shiny app)
# =============================================================================

args <- commandArgs(trailingOnly = FALSE)
script_path <- sub("^--file=", "", args[grep("^--file=", args)])
if (length(script_path)) {
  root <- normalizePath(file.path(dirname(script_path), ".."), winslash = "/")
  setwd(root)
}

suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
})

source("R/constants.R")
source("R/country_names_es.R")
source("R/data_utils.R")
source("scripts/supplementary_sources.R")

WDI_ZIP_URL <- "https://databankfiles.worldbank.org/public/ddpext_download/WDI_CSV.zip"
TMP_DIR     <- file.path("data", "wdi_download_tmp")
OUT_PATH    <- WDI_SNAPSHOT_PATH

dir.create("data", recursive = TRUE, showWarnings = FALSE)
dir.create(TMP_DIR, recursive = TRUE, showWarnings = FALSE)

find_col <- function(nms, patterns) {
  for (p in patterns) {
    hit <- grep(p, nms, ignore.case = TRUE, value = TRUE)
    if (length(hit)) return(hit[1])
  }
  stop("Could not find column matching: ", paste(patterns, collapse = ", "))
}

pick_csv <- function(dir, patterns) {
  for (pat in patterns) {
    hits <- list.files(dir, pattern = pat, full.names = TRUE, ignore.case = TRUE)
    if (length(hits)) return(hits[1])
  }
  stop("No file matching [", paste(patterns, collapse = ", "), "] in ", dir)
}

# Reuse previously extracted CSVs (e.g. a manual download) unless
# WDI_FORCE_DOWNLOAD=1 is set.
force_download <- tolower(Sys.getenv("WDI_FORCE_DOWNLOAD", "false")) %in% c("true", "1", "yes")
have_extracted <- length(list.files(TMP_DIR, pattern = "^WDICSV\\.csv$", ignore.case = TRUE)) > 0

if (have_extracted && !force_download) {
  message("Using existing CSVs in ", TMP_DIR, " (set WDI_FORCE_DOWNLOAD=1 to re-download).")
} else {
  message("Downloading WDI bulk CSV (~280 MB)…")
  zip_path <- file.path(TMP_DIR, "WDI_CSV.zip")
  tryCatch(
    download.file(WDI_ZIP_URL, zip_path, mode = "wb", quiet = TRUE),
    error = function(e) {
      stop(
        "Download failed: ", conditionMessage(e),
        "\n\nManual fallback:\n",
        "  1. Open https://databank.worldbank.org/source/world-development-indicators\n",
        "  2. Download CSV, unzip, and re-run this script\n",
        "  3. Or place the unzipped CSVs in ", TMP_DIR
      )
    }
  )

  message("Extracting…")
  utils::unzip(zip_path, exdir = TMP_DIR)
}

data_csv    <- pick_csv(TMP_DIR, c("^WDICSV\\.csv$", "^WDI.?Data\\.csv$", "Data\\.csv$"))
country_csv <- pick_csv(TMP_DIR, c("^WDICountry\\.csv$"))

message("Reading ", basename(data_csv), " …")
wdi_raw <- read.csv(data_csv, stringsAsFactors = FALSE, check.names = FALSE)

message("Reading ", basename(country_csv), " …")
country_raw <- read.csv(country_csv, stringsAsFactors = FALSE, check.names = FALSE)

data_nms    <- names(wdi_raw)
country_nms <- names(country_raw)

country_name_col <- find_col(data_nms, c("^Country Name$", "^Country\\.Name$"))
country_code_col <- find_col(data_nms, c("^Country Code$", "^Country\\.Code$"))
indicator_col    <- find_col(data_nms, c("^Indicator Code$", "^Indicator\\.Code$"))

iso2_col    <- find_col(country_nms, c("2-alpha code", "2.alpha.code", "^ISO2$"))
region_col  <- find_col(country_nms, c("^Region$"))
income_col  <- find_col(country_nms, c("Income Group", "Income.group", "IncomeGroup"))
meta_code_col <- find_col(country_nms, c("^Country Code$", "^Country\\.Code$"))

year_cols <- grep("^[0-9]{4}$", data_nms, value = TRUE)
year_cols <- year_cols[as.integer(year_cols) >= YEAR_MIN & as.integer(year_cols) <= YEAR_MAX]
if (length(year_cols) == 0) {
  stop("No year columns found between ", YEAR_MIN, " and ", YEAR_MAX)
}

indicator_codes <- unname(c(ALL_CODES, EXTRA_WDI_CODES))
code_to_var     <- setNames(c(names(ALL_CODES), names(EXTRA_WDI_CODES)),
                            c(ALL_CODES, EXTRA_WDI_CODES))

country_meta <- country_raw %>%
  transmute(
    iso3   = .data[[meta_code_col]],
    iso2c  = toupper(trimws(.data[[iso2_col]])),
    region = .data[[region_col]],
    income = .data[[income_col]]
  ) %>%
  filter(!is.na(iso2c), iso2c != "", nchar(iso2c) == 2,
         !is.na(region), region != "", region != "Aggregates",
         !is.na(income), income != "")

available_codes <- unique(wdi_raw[[indicator_col]])
missing_codes <- setdiff(unname(ALL_CODES), available_codes)
if (length(missing_codes)) {
  stop(
    "Indicator code(s) not found in the WDI bulk file: ",
    paste0(missing_codes, " (", code_to_var[missing_codes], ")", collapse = ", "),
    "\nThe World Bank may have retired them; update VARS in R/data_utils.R."
  )
}
# The extra series are not used by the tabs yet: build without a missing one
missing_extra <- setdiff(unname(EXTRA_WDI_CODES), available_codes)
if (length(missing_extra)) {
  warning(
    "Extra series not found in the WDI bulk file, left out of the snapshot: ",
    paste0(missing_extra, " (", code_to_var[missing_extra], ")", collapse = ", "),
    "\nUpdate EXTRA_SERIES in R/data_utils.R.", call. = FALSE
  )
  indicator_codes <- setdiff(indicator_codes, missing_extra)
}

message("Filtering ", length(indicator_codes), " indicators, ",
        length(year_cols), " years…")

wdi_long <- wdi_raw %>%
  filter(.data[[indicator_col]] %in% indicator_codes) %>%
  mutate(
    country  = .data[[country_name_col]],
    iso3     = .data[[country_code_col]],
    variable = code_to_var[.data[[indicator_col]]]
  ) %>%
  select(country, iso3, variable, all_of(year_cols)) %>%
  pivot_longer(
    cols      = all_of(year_cols),
    names_to  = "year",
    values_to = "value"
  ) %>%
  mutate(
    year  = as.integer(year),
    value = suppressWarnings(as.numeric(value))
  ) %>%
  filter(!is.na(variable))

snapshot <- wdi_long %>%
  pivot_wider(names_from = variable, values_from = value) %>%
  left_join(country_meta, by = "iso3") %>%
  filter(!is.na(region), region != "Aggregates", nchar(iso2c) == 2) %>%
  apply_supplements()

supplement_log <- attr(snapshot, "supplement_log")

snapshot <- snapshot %>%
  select(country, iso2c, year, region, income, any_of(names(VARS)),
         any_of(paste0(names(VARS), "_source")), any_of(names(EXTRA_SERIES)),
         any_of(paste0(names(EXTRA_SERIES), "_source"))) %>%
  arrange(country, year)

if (!is_valid_macro_df(snapshot)) {
  stop("Built snapshot failed validation — check indicator codes and year range.")
}

write.csv(snapshot, OUT_PATH, row.names = FALSE)

# One line per series: how many country-years have data, or "missing"
all_series <- c(VARS[setdiff(names(VARS), "population")], EXTRA_SERIES)
extra_series_log <- sapply(names(all_series), function(v) {
  n <- if (v %in% names(snapshot)) sum(!is.na(snapshot[[v]])) else 0
  paste0("Series: ", v, " (", all_series[[v]]$code, "): ",
         if (n > 0) paste(n, "country-years") else "missing")
}, USE.NAMES = FALSE)

meta_path <- file.path("data", "wdi_snapshot_meta.txt")
writeLines(c(
  paste("Generated:", format(Sys.time(), tz = "UTC", usetz = TRUE)),
  paste("Rows:", nrow(snapshot)),
  paste("Countries:", length(unique(snapshot$iso2c))),
  paste("Years:", min(snapshot$year), "-", max(snapshot$year)),
  paste("Source:", WDI_ZIP_URL),
  if (length(supplement_log)) paste("Supplemented:", supplement_log),
  extra_series_log
), meta_path)

message("Saved ", OUT_PATH)
message("  ", nrow(snapshot), " rows, ",
        length(unique(snapshot$iso2c)), " countries, ",
        min(snapshot$year), "–", max(snapshot$year))
for (line in c(supplement_log, extra_series_log)) message("  ", line)
message("Restart the app — it will load the bundled snapshot without calling the API.")
