test_that("rows hold each objective's value, the previous year and five years earlier", {
  r <- diagnosis_rows(macro_df, "AR", 2017)
  expect_equal(r$var, CORE_VARS)
  expect_equal(r$group, unname(sapply(CORE_VARS, function(v) VARS[[v]]$group)))
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
  r <- diagnosis_rows(macro_df, "AR", 2017)  # GDP grew, inflation fell, employment fell
  expect_equal(diagnosis_claim(r, "Argentina"),
               "La economía de Argentina está bien porque el PBI creció y la inflación bajó.")
  r$value[r$var == "gdp_growth"] <- -1
  r$value[r$var == "inflation"]  <- r$previous[r$var == "inflation"] + 1
  expect_null(diagnosis_claim(r, "Argentina"))
})

test_that("the guided reading describes without judging", {
  reading <- diagnosis_reading(diagnosis_rows(macro_df, "AR", 2017))
  expect_match(reading[1], "^La producción aumentó: el PBI real creció un 2,8%")
  expect_match(reading[3], "Bajó 12,5 puntos")
  expect_match(reading[4], "^Déficit del 6,7% del PBI\\. 5 años antes: -3,0% del PBI\\.$")
  expect_false(any(grepl("bien|mal|bueno|malo|problema", reading)))
})

test_that("the tab renders, keeps typed notes and downloads the answers", {
  testServer(diagnosis_server, args = list(data = reactive(macro_df)), {
    session$setInputs(country = "AR", year = 2017, show_reading = TRUE)
    expect_no_error(output$title)
    expect_no_error(output$claim_box)
    html <- as.character(output$table$html)
    expect_match(html, "Objetivos centrales")
    expect_match(html, "2012:")  # sustainability rows show five years earlier
    expect_match(html, "La producción aumentó")

    session$setInputs(note_inflation = "Alta, pero bajando",
                      interpret = "Crece, pero con inflación alta.",
                      evaluate = "No alcanza.", missing = "Deuda pública.")
    # Notes survive a re-render (e.g. toggling the guided reading)
    session$setInputs(show_reading = FALSE)
    expect_match(as.character(output$table$html), "Alta, pero bajando")

    file <- output$download
    txt <- readLines(file, encoding = "UTF-8")
    expect_match(txt[1], "Argentina, 2017")
    expect_true(any(grepl("Inflación (%): 25,7% (2016: 38,2%", txt, fixed = TRUE)))
    expect_true(any(grepl("-6,7% del PBI", txt, fixed = TRUE)))
    expect_true(any(grepl("¿Qué muestra\\?: Alta, pero bajando", txt)))
    expect_true(any(grepl("el PBI creció y la inflación bajó", txt)))
    expect_true(any(grepl("Deuda pública.", txt, fixed = TRUE)))
    expect_true(any(grepl("(sin responder)", txt, fixed = TRUE)))  # untouched rows
  })
})

test_that("a random case picks a country-year with every indicator", {
  testServer(diagnosis_server, args = list(data = reactive(macro_df)), {
    session$setInputs(country = "AR", year = 2017, show_reading = FALSE)
    expect_no_error(session$setInputs(random_case = 1))
  })
})
