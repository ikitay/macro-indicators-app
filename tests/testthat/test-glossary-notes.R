# The glossary of the app follows the glossary of the course notes
# "La mirada macroeconómica: objetivos e indicadores"

# Terms of the notes' glossary (their names in the app, where they differ)
NOTES_GLOSSARY <- c(
  "Macroeconomía", "Objetivo macroeconómico", "Indicador", "Sostenibilidad",
  "Crecimiento económico", "PBI (Producto Bruto Interno)", "PBI nominal", "PBI real",
  "Pleno empleo", "Empleo", "Desempleo", "Población económicamente activa", "Tasa de desempleo",
  "Estabilidad de precios", "Nivel general de precios", "Inflación", "Deflación",
  "IPC (Índice de Precios al Consumidor)",
  "Sostenibilidad fiscal", "Resultado fiscal", "Déficit fiscal", "Superávit fiscal", "Deuda pública",
  "Sostenibilidad externa", "Sector externo", "Balanza de pagos", "Balanza comercial"
)

glossary_entry <- function(term) GLOSSARY_TERMS[[match(term, sapply(GLOSSARY_TERMS, `[[`, "term"))]]

test_that("every term of the notes' glossary is in the app's glossary", {
  expect_setequal(intersect(NOTES_GLOSSARY, sapply(GLOSSARY_TERMS, `[[`, "term")), NOTES_GLOSSARY)
})

test_that("terms are not repeated and follow the order of the notes", {
  terms <- sapply(GLOSSARY_TERMS, `[[`, "term")
  expect_false(anyDuplicated(terms) > 0)
  expect_setequal(terms, GLOSSARY_ORDER)
  expect_equal(terms, GLOSSARY_ORDER)
  # the notes' terms keep their relative order
  expect_equal(intersect(terms, NOTES_GLOSSARY), NOTES_GLOSSARY)
})

test_that("related terms exist in the glossary", {
  terms <- sapply(GLOSSARY_TERMS, `[[`, "term")
  strip <- function(x) trimws(sub(" \\(.*\\)$", "", x))
  for (t in GLOSSARY_TERMS) {
    rel <- trimws(strsplit(t$related, ",")[[1]])
    for (r in rel) expect_true(strip(r) %in% strip(terms), label = paste(t$term, "->", r))
  }
})

test_that("definitions keep the notes' key distinctions", {
  has <- function(term, pattern) expect_match(glossary_entry(term)$definition, pattern, label = term)
  has("Crecimiento económico", "Crecimiento económico ≠ PBI")
  has("PBI nominal", "Puede aumentar solo")
  has("PBI real", "descuenta el efecto de los cambios de precios")
  has("Pleno empleo", "No significa desempleo cero")
  has("Tasa de desempleo", "población económicamente activa")
  has("Inflación", "El IPC no es la inflación")
  has("Estabilidad de precios", "inflación elevada e inestable")
  has("Déficit fiscal", "≠\\s+necesariamente un problema")
  has("Sostenibilidad fiscal", "trayectoria de la deuda pública")
  has("Balanza comercial", "balanza comercial ≠ balanza de pagos")
  has("Déficit y superávit externo", "≠\\s+necesariamente\\s+insostenibilidad externa")
  has("Sostenibilidad externa", "balanza de pagos")
})

test_that("info icons used in the app point to existing terms", {
  for (t in c("Objetivo macroeconómico", "Sostenibilidad")) expect_false(is.null(info_icon(t)))
  expect_true(all(sapply(GLOSSARY_TERMS, function(t) t$category %in% names(GLOSSARY_CATEGORY_COLORS))))
  expect_equal(names(GLOSSARY_CATEGORY_COLORS)[1], "Conceptos generales")
})
