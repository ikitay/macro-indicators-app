# Changelog

Notable changes to *Exploring Macroeconomics Through Data*.

## 2026-10-04 (Global Explorer scales)

### Added
- **Global Explorer: "Escala de los ejes"** with three options. The default is
  unchanged (all countries, linear). "Sin los valores extremos" leaves out the
  countries that are orders of magnitude away from the rest (more than 10 times
  as far from the median as the 90th percentile of distances), so one case such
  as Venezuela 2019 (19.906% inflation) no longer flattens the chart, and says
  in the sidebar which countries are not drawn and their values. Argentina 2019
  (53%) stays. "Escala logarítmica simétrica" plots sign(x)·log10(1+|x|), which
  also handles zero and negative values (deflation, recessions), with ticks in
  the original units; the tooltips always show the real values.
- Tests in `tests/testthat/test-global-scales.R`.

## 2026-10-04 (data rebuild)

### Added
- **New indicators from the rebuilt snapshot**: unemployment rate (now the main
  indicator of full employment, as in the course notes), public debt, current
  account and foreign direct investment inflows. The employment rate stays
  available under "Otros indicadores".
- **Country Profile:** the radar scores unemployment (lower is better) instead
  of the employment rate, and the sustainability table shows the fiscal balance,
  public debt, trade balance and current account with their values five years
  earlier.
- Glossary entries for Cuenta corriente and Inversión extranjera directa.
- **Explore Country: "Niveles y tasas"**, below the main chart: a price index
  built from the inflation series next to its yearly rates (IPC ≠ inflación),
  and nominal vs real GDP as indices (PBI nominal ≠ PBI real), with a log scale
  when the range is very wide. For Argentina 1995–2023, nominal GDP grew 746-fold
  and real GDP 1.7-fold.
- **Challenges** use the new series: C02 (cost of disinflation) and C06
  (recoveries) use the unemployment rate; C04 (good today, sustainable
  tomorrow?) uses unemployment, public debt and the current account, contrasting
  Spain (external imbalance), Greece (fiscal and external) and Czechia (neither).
- **Diagnóstico** lists every indicator under its objective, as in the notes'
  table: full employment shows the unemployment and employment rates, fiscal
  sustainability the fiscal balance and public debt, external sustainability the
  trade balance, current account and FDI inflows. The claim to assess now uses
  the notes' wording ("el PBI creció y el desempleo bajó") when the data allow.

## 2026-10-04

Changes to bring the app in line with the course notes *La mirada
macroeconómica: objetivos e indicadores*.

### Changed
- **Country Profile** now scores only the three central objectives: growth,
  employment and price stability. Fiscal and trade balances are shown beside
  the chart with their value five years earlier, and are not scored, because a
  deficit is not automatically worse than a surplus.
- Country Profile scores are now true percentile ranks, so "70 means better
  than 70% of all observations" is accurate. Price stability rewards inflation
  near 2%: deflation no longer gets the top score. Missing data shows as
  "no data" instead of a score of zero.
- **Compare Countries:** "Indexed (base = 100)" is now "Change since base
  year". GDP growth becomes a real GDP index (base year = 100); the other
  indicators show the change in percentage points. Dividing rates by their
  base-year value gave meaningless results (2% → 4% growth showed as 200).
- **Discovery Challenges:** C02 is now "The Cost of Bringing Inflation Down",
  and C04 "Good Today, Sustainable Tomorrow?" scores the central objectives
  first, then asks about fiscal and external sustainability.
- **Glossary:** recession, inflation, GDP growth, fiscal balance and trade
  balance follow the course definitions (real vs nominal GDP, CPI vs inflation,
  "a deficit is not necessarily a problem"). New entries: Balance of Payments,
  Fiscal Sustainability, Nominal GDP.

- **The app is now in Spanish**, using the course's terms (PBI, IPC, resultado
  fiscal, pleno empleo, balanza de pagos). Country, region and income-group
  names are in Spanish too, so students can search "Alemania" or "Corea del Sur".
  Numbers in text use a decimal comma (2,5%).
- Indicators are grouped into central objectives ("¿qué está ocurriendo?") and
  sustainability objectives ("¿puede sostenerse?") in every tab, and labelled
  "Objetivo: indicador". The About window explains the difference between an
  objective and its indicator.
- New glossary entries from the course notes: Pleno empleo, Población
  económicamente activa, Tasa de desempleo, IPC, Deflación, Deuda pública,
  Sostenibilidad externa, Objetivo e indicador, Sostenibilidad.

### Fixed
- **Explore Country:** "Shade negative GDP years" did nothing; the years in
  which GDP fell are now shaded.
- **Compare Countries:** the data table had one row per country and year, mostly
  empty; it now has one row per year and one column per country.
- Challenge solutions that the app's own data contradicted (for example,
  Russia 1999–2008 as "growth without jobs", when its employment rate rose).
  Every quoted solution is now checked against the data by the tests.
- Hyperinflation example: Argentina 1990 (2,314%) instead of 2023, which was
  far below the 50%-a-month definition.
- The glossary failed to open when the shinyWidgets package was not installed.

### Added
- **New tab "🩺 Diagnóstico" (¿Cómo está esta economía?)**: the course notes'
  integrative case with real data. Students pick a country and a year, read each
  objective's indicator (sustainability rows also show the value five years
  earlier), write what each one shows, assess a claim built from that case
  ("La economía de … está bien porque el PBI creció…"), list the information
  they would still need, and download their answers as a text file. An optional
  guided reading describes the numbers without judging them.
- **Snapshot build collects the series the notes rely on** (not yet shown in the
  tabs): unemployment rate, public debt (IMF), current account, FDI inflows,
  CPI index, and nominal and real GDP levels. Rebuild the snapshot with
  `Rscript scripts/prepare_wdi_snapshot.R` to include them; see `data/README.md`.
- Automated tests (`Rscript tests/testthat.R`).

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
