# While CHALLENGE_ANSWERS_HIDDEN_UNTIL is in the future, the Desafíos tab must
# not send any hint, solution or teacher note to the browser.

data_r <- reactive(macro_df)

# Runs code with CHALLENGE_ANSWERS_HIDDEN_UNTIL set to `until`
with_lock <- function(until, code) {
  old <- CHALLENGE_ANSWERS_HIDDEN_UNTIL
  assign("CHALLENGE_ANSWERS_HIDDEN_UNTIL", until, envir = globalenv())
  on.exit(assign("CHALLENGE_ANSWERS_HIDDEN_UNTIL", old, envir = globalenv()))
  code
}

test_that("challenge_answers_hidden follows the date, inclusive", {
  expect_false(challenge_answers_hidden(as.Date("2026-10-20"), NULL))
  expect_true(challenge_answers_hidden(as.Date("2026-10-19"), as.Date("2026-10-20")))
  expect_true(challenge_answers_hidden(as.Date("2026-10-20"), as.Date("2026-10-20")))
  expect_false(challenge_answers_hidden(as.Date("2026-10-21"), as.Date("2026-10-20")))
  expect_true(challenge_answers_hidden(as.Date("2026-10-19"), "2026-10-20"))
})

test_that("while hidden, no hint, solution or teacher note reaches the page", {
  with_lock(Sys.Date() + 7, {
    testServer(challenges_server, args = list(data = data_r), {
      for (i in seq_along(CHALLENGES)) {
        ch <- CHALLENGES[[i]]
        # Even if the inputs arrive (a crafted request), the panels stay empty
        session$setInputs(challenge_select = as.character(i), instructor_mode = TRUE,
                          show_hint = 1, show_solution = 1)
        for (nm in c("hint_panel", "solution_panel", "instructor_panel")) {
          expect_error(output[[nm]], class = "shiny.silent.error", label = nm)
        }
        page <- paste(output$challenge_card$html, output$answer_buttons$html,
                      output$instructor_toggle$html)
        secrets <- c(ch$hint, ch$pedagogical_note,
                     sapply(ch$solution_countries, `[[`, "note"))
        for (s in secrets) expect_false(grepl(s, page, fixed = TRUE), label = ch$id)
        expect_match(output$answer_buttons$html, "desactivadas")
        expect_false(grepl("show_solution", output$answer_buttons$html))
        expect_null(output$instructor_toggle$html)
      }
    })
  })
})

test_that("after the date, the hints and solutions are back", {
  with_lock(Sys.Date() - 1, {
    testServer(challenges_server, args = list(data = data_r), {
      session$setInputs(challenge_select = "1", instructor_mode = TRUE,
                        show_hint = 1, show_solution = 1)
      expect_match(output$answer_buttons$html, "show_solution")
      expect_match(output$hint_panel$html, "Pista")
      expect_match(output$solution_panel$html, CHALLENGES[[1]]$solution_countries[[1]]$country)
      expect_match(output$instructor_panel$html, "Notas para docentes")
    })
  })
})
