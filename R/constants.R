# =============================================================================
# APP CONSTANTS
# Shared values used across modules. Source this file before any other R/ scripts.
# =============================================================================

# The five core macroeconomic variables (excluding population)
CORE_VARS <- c("gdp_growth", "employment", "inflation", "fiscal_balance", "trade_balance")

# Default year range
YEAR_MIN <- 1990
YEAR_MAX <- 2023

# Default featured countries (interesting for comparisons)
DEFAULT_COUNTRIES <- c("US", "DE", "CN", "AR", "KR", "ZA")

# World Bank regions (used for color coding)
REGION_COLORS <- c(
  "East Asia & Pacific"         = "#e74c3c",
  "Europe & Central Asia"       = "#3498db",
  "Latin America & Caribbean"   = "#f39c12",
  "Middle East & North Africa"  = "#27ae60",
  "North America"               = "#8e44ad",
  "South Asia"                  = "#e67e22",
  "Sub-Saharan Africa"          = "#16a085",
  "Other"                       = "#95a5a6"
)

# Bundled offline WDI snapshot (see scripts/prepare_wdi_snapshot.R)
WDI_SNAPSHOT_PATH <- file.path("data", "wdi_snapshot.csv")
