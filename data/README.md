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

The script downloads the official WDI CSV zip (~280 MB) from the World Bank, extracts the six indicators for 1990–2023, fills gaps from the sources below, and writes `data/wdi_snapshot.csv`. Later runs reuse the extracted CSVs in `wdi_download_tmp/`; set `WDI_FORCE_DOWNLOAD=1` to download again.

### Supplementary sources

`scripts/supplementary_sources.R` adds data the World Bank lacks. Each is fetched over HTTPS without an API key; if one is unreachable the build warns and keeps the World Bank values.

| What | Source | Why |
|---|---|---|
| Fiscal balance (all countries) | [IMF DataMapper API](https://www.imf.org/external/datamapper/api/v1/GGXCNL_NGDP), WEO `GGXCNL_NGDP` | WDI retired its cash-balance series; its replacement covers only central government and ~50% of country-years. The IMF series covers general government for ~80%. WDI is used only for countries the IMF does not cover, so no country mixes the two definitions. |
| Inflation gaps | [IMF DataMapper API](https://www.imf.org/external/datamapper/api/v1/PCPIPCH), WEO `PCPIPCH` | Fills years WDI leaves blank (e.g. Venezuela). Where both exist they agree closely (median difference 0.04 points). |
| Argentina inflation 1990–2006 | INDEC historical CPI, [datos.gob.ar](https://datos.gob.ar) series `178.1_NL_GENERAL_0_0_13` | WDI omits Argentina's CPI before 2018. |
| Argentina inflation 2007–2016 | Median of provincial CPIs on datos.gob.ar: San Luis `197.1_NIVEL_GENERAL_2014_0_13`, Neuquén `196.1_NIVEL_GENERAL_2014_0_13`, Chaco `464.1_IPC_CHACO_NG_0_0_22_93`, CABA `193.1_NIVEL_GENERAL_JULI_0_13` (from 2014) | INDEC's CPI was discredited from 2007 and suspended in 2015–16. These provincial indices were produced independently of INDEC and agree closely with each other. (Mendoza and Tucumán are excluded because they tracked the official index.) |

All inflation figures are annual averages (mean index level over the year vs. the previous year), the same definition WDI and the IMF use. The snapshot records each value's origin in the `inflation_source` and `fiscal_balance_source` columns.

### Manual download (if the script fails)

1. Open [World Development Indicators on DataBank](https://databank.worldbank.org/source/world-development-indicators).
2. Select **Download → CSV**.
3. Unzip the file.
4. Re-run `scripts/prepare_wdi_snapshot.R` (it looks for extracted CSVs in `data/wdi_download_tmp/`),  
   **or** place the unzipped `WDICSV.csv` and `WDICountry.csv` files in `data/wdi_download_tmp/` and run the script again.

Direct bulk URL (same file the script uses):

https://databankfiles.worldbank.org/public/ddpext_download/WDI_CSV.zip

### Other folders

| Path | Purpose |
|------|---------|
| `wdi_snapshot.csv` | Bundled real WDI data (committed; rebuild with script above) |
| `wdi_snapshot_meta.txt` | Auto-written when the snapshot is built |
| `wdi_cache/` | Runtime cache (auto-created; safe to delete) |
| `wdi_download_tmp/` | Raw bulk download, ~540 MB (git-ignored; safe to delete) |
