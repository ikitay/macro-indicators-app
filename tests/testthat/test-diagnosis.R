test_that("rows hold each objective's value, the previous year and five years earlier", {
  r <- diagnosis_rows(macro_df, "AR", 2017)
  expect_equal(r$var, unlist(DIAGNOSIS_OBJECTIVES, use.names = FALSE))
  expect_equal(unique(r$objective_id), c("growth", "employment", "prices", "fiscal", "external"))
  expect_setequal(r$var, CORE_VARS)  # every indicator appears under its objective
  expect_equal(r$group, unname(sapply(r$var, function(v) VARS[[v]]$group)))
  expect_equal(r$value[r$var == "inflation"], snap("Argentina", 2017, "inflation"))
  expect_equal(r$previous[r$var == "inflation"], snap("Argentina", 2016, "inflation"))
  expect_equal(r$past[r$var == "fiscal_balance"], snap("Argentina", 2012, "fiscal_balance"))
})

test_that("missing years give NA instead of an error", {
  r <- diagnosis_rows(macro_df, "AF", 1995)
  expect_true(is.na(r$value[r$var == "gdp_growth"]))
  expect_true(all(nzchar(diagnosis_reading(r))))
  expect_match(diagnosis_reading(r)[1], "No hay datos")
})

test_that("the claim lists only the favourable central results", {
  r <- diagnosis_rows(macro_df, "AR", 2017)  # GDP grew, inflation fell
  expect_equal(diagnosis_claim(r, "Argentina"),
               "La economía de Argentina está bien porque el PBI creció y la inflación bajó.")
  # The notes' own claim: "el PBI creció y el desempleo bajó"
  r2 <- r
  r2$value[r2$var == "unemployment"] <- r2$previous[r2$var == "unemployment"] - 1
  expect_equal(diagnosis_claim(r2, "Argentina"),
               "La economía de Argentina está bien porque el PBI creció, el desempleo bajó y la inflación bajó.")
  r$value[r$var == "gdp_growth"] <- -1
  r$value[r$var == "inflation"]  <- r$previous[r$var == "inflation"] + 1
  expect_null(diagnosis_claim(r, "Argentina"))
})

test_that("the guided reading describes without judging", {
  reading <- diagnosis_reading(diagnosis_rows(macro_df, "AR", 2017))
  r <- diagnosis_rows(macro_df, "AR", 2017)
  at <- function(v) reading[r$var == v]
  expect_match(at("gdp_growth"), "^La producción aumentó: el PBI real creció un 2,8%")
  expect_match(at("inflation"), "Bajó 12,5 puntos")
  expect_match(at("fiscal_balance"), "^Déficit fiscal del 6,7% del PBI\\. 5 años antes: -3,0% del PBI\\.$")
  expect_match(at("unemployment"), "población económicamente activa")
  expect_match(at("public_debt"), "^La deuda pública equivalía al")
  expect_match(at("current_account"), "^Déficit de cuenta corriente del")
  expect_false(any(grepl("bien|mal|bueno|malo|problema", reading)))
})

test_that("the tab renders, with no text boxes and nothing to download", {
  html <- as.character(diagnosis_ui("d"))
  expect_false(grepl("<textarea", html))
  expect_false(grepl("download", html, ignore.case = TRUE))
  expect_match(html, "la app no guarda respuestas")
  testServer(diagnosis_server, args = list(data = reactive(macro_df)), {
    session$setInputs(country = "AR", year = 2017, show_reading = TRUE)
    expect_no_error(output$title)
    expect_match(as.character(output$claim_box$html), "el PBI creció y la inflación bajó")
    html <- as.character(output$table$html)
    expect_match(html, "Objetivos centrales")
    expect_match(html, "2012:")  # sustainability rows show five years earlier
    expect_match(html, "La producción aumentó")
    expect_false(grepl("<textarea", html))
  })
})

test_that("a random case picks a country-year with every indicator", {
  testServer(diagnosis_server, args = list(data = reactive(macro_df)), {
    session$setInputs(country = "AR", year = 2017, show_reading = FALSE)
    expect_no_error(session$setInputs(random_case = 1))
  })
})
