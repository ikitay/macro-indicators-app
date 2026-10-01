# Minimal WDI shim — used only when WDI package is unavailable
if (!requireNamespace("WDI", quietly = TRUE)) {
  WDI <- function(country="all", indicator=NULL, start=1990, end=2023, extra=FALSE, cache=NULL) {
    message("[WDI shim] WDI package not installed — using fallback data")
    NULL
  }
  assign("WDI", WDI, envir = .GlobalEnv)
}
