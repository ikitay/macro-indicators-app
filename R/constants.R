# =============================================================================
# APP CONSTANTS
# Shared values used across modules. Source this file before any other R/ scripts.
# =============================================================================

# The indicators shown in the app (excluding population), grouped by objective
# in VARS (R/data_utils.R)
CORE_VARS <- c("gdp_growth", "unemployment", "inflation",
               "fiscal_balance", "public_debt", "trade_balance", "current_account",
               "fdi_inflows", "employment")

# The two kinds of macroeconomic objectives, each with the question it answers
OBJECTIVE_GROUPS <- c(
  central        = "Objetivos centrales: ¿qué está ocurriendo?",
  sustainability = "Objetivos de sostenibilidad: ¿puede sostenerse?",
  other          = "Otros indicadores"
)

# Default year range
YEAR_MIN <- 1990
YEAR_MAX <- 2023

# Argentina is the default country everywhere in the app; the others are the
# comparators preselected next to it
DEFAULT_COUNTRY   <- "AR"
DEFAULT_COUNTRIES <- c("AR", "US", "DE", "CN", "KR", "ZA")   # up to 6 countries
DEFAULT_PEERS     <- c("AR", "US", "DE", "KR")               # up to 4 countries

# World Bank regions (used for color coding)
# (names match the Spanish region names in R/country_names_es.R)
REGION_COLORS <- c(
  "Asia oriental y Pacífico"        = "#e74c3c",
  "Europa y Asia central"           = "#3498db",
  "América Latina y el Caribe"      = "#f39c12",
  "Medio Oriente y Norte de África" = "#27ae60",
  "América del Norte"               = "#8e44ad",
  "Asia meridional"                 = "#e67e22",
  "África subsahariana"             = "#16a085",
  "Otras"                           = "#95a5a6"
)

# Desafíos: the hints, solutions and teacher notes stay hidden up to and
# including this date, e.g. during a graded assignment on the same countries.
# Example: as.Date("2026-10-20"). NULL never hides them.
CHALLENGE_ANSWERS_HIDDEN_UNTIL <- NULL

# Bundled offline WDI snapshot (see scripts/prepare_wdi_snapshot.R)
WDI_SNAPSHOT_PATH <- file.path("data", "wdi_snapshot.csv")
