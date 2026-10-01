# Minimal shinyWidgets shim
if (!requireNamespace("shinyWidgets", quietly = TRUE)) {
  radioGroupButtons <- function(inputId, label=NULL, choices=NULL, selected=NULL,
                                 size="normal", status="default", ...) {
    radioButtons(inputId, label=label, choices=choices, selected=selected)
  }
  assign("radioGroupButtons", radioGroupButtons, envir = .GlobalEnv)
}
