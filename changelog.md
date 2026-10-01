# Changelog

Notable changes to *Exploring Macroeconomics Through Data*.

## 2026-10-01

### Added
- **IMF data to fill World Bank gaps.** Fiscal balance now comes from the IMF
  World Economic Outlook (general government net lending/borrowing), raising
  coverage from 49% to 78% of country-years; Japan and China now have full
  series. Missing inflation years are filled from the IMF as well
  (coverage 80% → 87%).
- **Rebuilt inflation series for Argentina, 1990–2016.** INDEC's official CPI
  is used through 2006. For 2007–2016, when the official index was discredited
  and later suspended, the app uses the median of independent provincial CPIs
  (San Luis, Neuquén, Chaco and, from 2014, the City of Buenos Aires), taken
  from [datos.gob.ar](https://datos.gob.ar).
- **Data sources in tooltips.** Hovering over an inflation or fiscal-balance
  value in Explore Country, Compare Countries or Historical Events shows where
  it comes from.
- Sources for each variable are listed in the About window, `README.md` and
  `data/README.md`.

### Changed
- The snapshot build (`scripts/prepare_wdi_snapshot.R`) reuses the World Bank
  files already downloaded to `data/wdi_download_tmp/`. Set
  `WDI_FORCE_DOWNLOAD=1` to download them again.
- The build stops with a clear message if the World Bank retires one of the
  app's indicators, instead of silently producing a snapshot without it.
- `data/wdi_snapshot.csv` is now committed to the repository, so the app runs
  right after cloning.

### Fixed
- **Explore Country** showed a blank page with "Argumento no numérico para una
  función matemática" (non-numeric argument to mathematical function), and
  **Country Profile** showed an error. Both happened because the World Bank
  retired the fiscal balance indicator, leaving that column missing. The app
  now treats any missing indicator as empty data instead of crashing.
- **Discovery Challenges:** the "Choose a challenge" list was cut off by its
  card and had to be scrolled; it now opens fully.

### Removed
- The `REFRESH_WDI` setting. It loaded World Bank data directly and skipped the
  IMF and Argentine additions. To get newer data, run
  `Rscript scripts/prepare_wdi_snapshot.R`.

## Before version control

- Seven interactive tabs: Explore Country, Compare Countries, Global Explorer,
  Country Profile, Historical Events, Discovery Challenges and Correlation
  Explorer, plus a glossary.
- Offline data snapshot built from the World Bank WDI bulk download
  (`scripts/prepare_wdi_snapshot.R`), so the app no longer calls the World Bank
  API on every launch. If the snapshot is missing, the app falls back to a disk
  cache, then the live API, then synthetic demo data.
