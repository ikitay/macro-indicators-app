# Exploring Macroeconomics Through Data

An interactive R Shiny educational application for undergraduate economics students.

## Quick Start

```r
# Install required packages
install.packages(c("shiny","bslib","plotly","dplyr","tidyr",
                   "WDI","cachem","shinyWidgets"))

# Run the app (uses the bundled data/wdi_snapshot.csv)
shiny::runApp(".")
```

## Data

The app loads data in this order:

1. **`data/wdi_snapshot.csv`** — bundled offline snapshot (recommended)
2. Disk cache / live World Bank API
3. Synthetic demo data (25 countries) if nothing else is available

The snapshot is committed to the repo, so the app works right after cloning.

### Rebuild the bundled CSV (optional)

To refresh the snapshot with newer World Bank data:

```r
install.packages(c("dplyr", "tidyr"))
Rscript scripts/prepare_wdi_snapshot.R
```

This downloads the full WDI bulk file (~280 MB zip, ~540 MB extracted) into
`data/wdi_download_tmp/`, which is git-ignored and safe to delete afterwards.
See **`data/README.md`** for manual download steps if the script cannot reach the World Bank.

Optional: force a live API refresh when the API is up:

```r
Sys.setenv(REFRESH_WDI = "1")
shiny::runApp(".")
```

## Structure
```
app.R                         # Entry point
scripts/
  prepare_wdi_snapshot.R        # Builds data/wdi_snapshot.csv from WDI bulk CSV
data/
  wdi_snapshot.csv              # Bundled real data (committed, ~1 MB)
  wdi_snapshot_meta.txt         # Build info for the snapshot
  wdi_cache/                    # Runtime cache (git-ignored)
  wdi_download_tmp/             # Raw WDI bulk download (git-ignored, ~540 MB)
R/
  constants.R                   # Shared constants (CORE_VARS, year range, …)
  data_utils.R                  # Data loading, caching, variable metadata
  glossary.R                  # Term definitions and modal
  events_data.R               # Historical events
  challenges_data.R           # Discovery challenge tasks
  mod_explore_country.R       # Tab 1: Country time series
  mod_compare_countries.R     # Tab 2: Multi-country comparison
  mod_global_explorer.R       # Tab 3: Gapminder scatter
  mod_country_profile.R       # Tab 4: Radar chart
  mod_historical_events.R     # Tab 5: Events overlay
  mod_challenges.R            # Tab 6: Discovery challenges
  mod_correlation.R           # Tab 7: Correlation explorer
www/
  styles.css                  # Custom styles
```

## Data Source
World Bank WDI — prefer the bundled CSV in `data/` (see above).
Live API and synthetic demo data are fallbacks.
