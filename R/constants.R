# =============================================================================
# APP CONSTANTS
# Shared values used across modules. Source this file before any other R/ scripts.
# =============================================================================

# The five core macroeconomic variables (excluding population)
CORE_VARS <- c("gdp_growth", "employment", "inflation", "fiscal_balance", "trade_balance")

# The two kinds of macroeconomic objectives, each with the question it answers
OBJECTIVE_GROUPS <- c(
  central        = "Objetivos centrales: ¿qué está ocurriendo?",
  sustainability = "Objetivos de sostenibilidad: ¿puede sostenerse?"
)

# Default year range
YEAR_MIN <- 1990
YEAR_MAX <- 2023

# Default featured countries (interesting for comparisons)
DEFAULT_COUNTRIES <- c("US", "DE", "CN", "AR", "KR", "ZA")

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

# Bundled offline WDI snapshot (see scripts/prepare_wdi_snapshot.R)
WDI_SNAPSHOT_PATH <- file.path("data", "wdi_snapshot.csv")
