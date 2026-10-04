test_that("extreme values are flagged only when far from the bulk", {
  x <- c(rep(c(1, 2, 3, 2, 3), 4), 19906)
  expect_equal(which(extreme_flags(x)), 21)
  expect_false(any(extreme_flags(c(1, 2, 3, 4, 5, 6, 7, 20))))   # mild spread
  expect_false(any(extreme_flags(c(1, 100))))                      # too few values
  expect_equal(extreme_flags(c(NA, x))[1], FALSE)
})

test_that("the symmetric log scale keeps sign and order and accepts zero", {
  expect_equal(symlog(c(-9, 0, 9, 99)), c(-1, 0, 1, 2))
  expect_true(all(diff(symlog(c(-1000, -3, 0, 2, 50, 19906))) > 0))
  tk <- symlog_ticks(c(-3, 0.5, 19906))
  expect_equal(tk$text, c("-1", "0", "1", "10", "100", "1.000", "10.000"))
  expect_equal(tk$vals, symlog(c(-1, 0, 1, 10, 100, 1000, 10000)))
})

test_that("on the real data, 2019 inflation: only the hyperinflation is set aside", {
  d <- macro_df[macro_df$year == 2019 & !is.na(macro_df$inflation), ]
  far <- d$country[extreme_flags(d$inflation)]
  expect_true("Venezuela" %in% far)
  expect_false("Argentina" %in% far)    # 53%: very high, but the same order as other cases
  expect_lt(length(far), 6)
})

test_that("Global Explorer: outlier filter and symmetric log scale", {
  testServer(global_explorer_server, args = list(data = reactive(macro_df)), {
    base <- list(x_var = "gdp_growth", y_var = "inflation", size_var = "population",
                 regions = names(REGION_COLORS), static_year = 2019,
                 log_size = TRUE, show_labels = TRUE)
    do.call(session$setInputs, c(base, list(scale_mode = "linear")))
    n_all <- nrow(plot_data())
    expect_equal(nrow(attr(plot_data(), "excluded")), 0)
    expect_equal(max(plot_data()$y_plot), 19906)

    do.call(session$setInputs, c(base, list(scale_mode = "trim")))
    ex <- attr(plot_data(), "excluded")
    expect_true("Venezuela" %in% ex$country)
    expect_equal(nrow(plot_data()) + nrow(ex), n_all)
    expect_lt(max(plot_data()$y_plot), 1000)
    expect_match(as.character(output$scale_note$html), "Fuera del gráfico: .*Venezuela")
    expect_no_error(output$scatter_plot)

    do.call(session$setInputs, c(base, list(scale_mode = "symlog")))
    expect_equal(nrow(plot_data()), n_all)
    expect_lt(max(plot_data()$y_plot), 5)                           # log10(19907) = 4.3
    expect_lt(min(plot_data()$y_plot), 0)                           # deflation is kept
    expect_match(as.character(plot_data()$hover_text[plot_data()$country == "Venezuela"]), "19\\.906")
    expect_no_error(output$scatter_plot)
    expect_match(as.character(output$scale_note$html), "multiplica el valor por 10")
  })
})
