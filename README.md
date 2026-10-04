# Exploring Macroeconomics Through Data

An interactive R Shiny educational application for undergraduate economics students.
The app's interface is in Spanish (rioplatense) and follows the course notes
*La mirada macroeconómica: objetivos e indicadores*.

## Quick Start

```r
# Install required packages
install.packages(c("shiny","bslib","plotly","dplyr","tidyr",
                   "WDI","cachem","shinyWidgets"))

# Run the app (uses the bundled data/wdi_snapshot.csv)
shiny::runApp(".")
```

## Tests

```r
install.packages("testthat")
```

Run from the app root:

```sh
Rscript tests/testthat.R
```

The tests load the bundled snapshot, build every tab's UI and render every
chart and panel with real data, so a change that breaks a tab fails the run.

## Data

The app loads data in this order:

1. **`data/wdi_snapshot.csv`** — bundled offline snapshot (recommended)
2. Disk cache / live World Bank API — emergency fallback only if the snapshot is
   missing; World Bank data alone, without the IMF and Argentine supplements
3. Synthetic demo data (25 countries) if nothing else is available

The snapshot is committed to the repo, so the app works right after cloning.

### Rebuild the bundled CSV (optional)

To refresh the snapshot with newer World Bank data:

```r
install.packages(c("dplyr", "tidyr", "jsonlite"))
Rscript scripts/prepare_wdi_snapshot.R
```

This downloads the full WDI bulk file (~280 MB zip, ~540 MB extracted) into
`data/wdi_download_tmp/`, which is git-ignored and safe to delete afterwards.
Later runs reuse the extracted files; set `WDI_FORCE_DOWNLOAD=1` to fetch a fresh copy.
See **`data/README.md`** for manual download steps if the script cannot reach the World Bank.

## Structure
```
app.R                         # Entry point
scripts/
  prepare_wdi_snapshot.R        # Builds data/wdi_snapshot.csv from WDI bulk CSV
  supplementary_sources.R       # IMF + Argentine CPI gap filling used by the build
data/
  wdi_snapshot.csv              # Bundled real data (committed, ~1 MB)
  wdi_snapshot_meta.txt         # Build info for the snapshot
  wdi_cache/                    # Runtime cache (git-ignored)
  wdi_download_tmp/             # Raw WDI bulk download (git-ignored, ~540 MB)
R/
  constants.R                   # Shared constants (CORE_VARS, year range, …)
  country_names_es.R            # Spanish country, region and income-group names
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

## Data Sources

| Variable | Source |
|---|---|
| GDP growth, employment, trade balance, population | World Bank WDI |
| Inflation | World Bank WDI, with missing years filled from IMF World Economic Outlook (`PCPIPCH`) |
| Fiscal balance | IMF World Economic Outlook, general government net lending/borrowing (`GGXCNL_NGDP`) |
| Argentina's inflation, 1990–2016 | INDEC official CPI through 2006; median of independent provincial CPIs (San Luis, Neuquén, Chaco, CABA) for 2007–2016, via [datos.gob.ar](https://datos.gob.ar) |

Inflation and fiscal-balance tooltips in the app show the source of each value.
The supplements are applied by `scripts/supplementary_sources.R` when the
snapshot is built; see `data/README.md` for details.
