# Data files

## Bundled snapshot (recommended)

The app reads **`wdi_snapshot.csv`** from this folder first. This avoids hammering the World Bank API on every launch.
The snapshot is committed to the repository, so you only need to rebuild it to pick up newer data.

### Rebuild the snapshot (~2–5 minutes)

From the project root in R or a terminal:

```r
# Install tidyr if needed
install.packages(c("dplyr", "tidyr"))

# Build data/wdi_snapshot.csv from the official WDI bulk download
Rscript scripts/prepare_wdi_snapshot.R
```

Or inside RStudio:

```r
setwd("path/to/macro_app")
source("scripts/prepare_wdi_snapshot.R")
```

The script downloads the official WDI CSV zip (~280 MB) from the World Bank, extracts your six indicators for 1990–2023, and writes `data/wdi_snapshot.csv`.

### Manual download (if the script fails)

1. Open [World Development Indicators on DataBank](https://databank.worldbank.org/source/world-development-indicators).
2. Select **Download → CSV**.
3. Unzip the file.
4. Re-run `scripts/prepare_wdi_snapshot.R` (it looks for extracted CSVs in `data/wdi_download_tmp/`),  
   **or** place the unzipped `WDICSV.csv` and `WDICountry.csv` files in `data/wdi_download_tmp/` and run the script again.

Direct bulk URL (same file the script uses):

https://databankfiles.worldbank.org/public/ddpext_download/WDI_CSV.zip

### Optional: refresh from the live API

When the API is healthy and you want to bypass the bundled file:

```r
Sys.setenv(REFRESH_WDI = "1")
shiny::runApp(".")
```

### Other folders

| Path | Purpose |
|------|---------|
| `wdi_snapshot.csv` | Bundled real WDI data (committed; rebuild with script above) |
| `wdi_snapshot_meta.txt` | Auto-written when the snapshot is built |
| `wdi_cache/` | Runtime cache (auto-created; safe to delete) |
| `wdi_download_tmp/` | Raw bulk download, ~540 MB (git-ignored; safe to delete) |
