# The challenge solutions quote the bundled data. These tests fail if a claim
# stops matching the snapshot (for example after rebuilding it).

yrs <- function(country, from, to, var) {
  sapply(from:to, function(y) snap(country, y, var))
}
central_ok <- function(country, from, to) {
  emp_avg <- mean(macro_df$employment[macro_df$country == country], na.rm = TRUE)
  all(yrs(country, from, to, "gdp_growth") > 2) &&
    all(yrs(country, from, to, "employment") > emp_avg) &&
    all(yrs(country, from, to, "inflation") >= 0 & yrs(country, from, to, "inflation") < 5)
}

test_that("C01 growth without jobs: growth every year, employment rate lower at the end", {
  for (k in list(c("China", 1991, 2005), c("Thailand", 2010, 2019), c("Serbia", 2000, 2008))) {
    a <- as.integer(k[2]); b <- as.integer(k[3])
    expect_true(all(yrs(k[1], a, b, "gdp_growth") > 0), label = k[1])
    expect_lt(snap(k[1], b, "employment"), snap(k[1], a, "employment"))
  }
})

test_that("C02 disinflation cases: inflation more than halves and employment falls", {
  for (k in list(c("Argentina", 1991, 1994), c("Brazil", 1992, 1996), c("Poland", 1991, 1994))) {
    a <- as.integer(k[2]); b <- as.integer(k[3])
    expect_lt(snap(k[1], b, "inflation"), snap(k[1], a, "inflation") / 2, label = k[1])
    expect_lt(snap(k[1], b, "employment"), snap(k[1], a, "employment"), label = k[1])
  }
  # Counter-example: inflation falls, employment rises
  expect_lt(snap("Argentina", 2004, "inflation"), snap("Argentina", 2002, "inflation"))
  expect_gt(snap("Argentina", 2004, "employment"), snap("Argentina", 2002, "employment"))
})

test_that("C03 trade surplus with fiscal deficit in every quoted year", {
  for (k in list(c("Japan", 1993, 2010), c("Germany", 2002, 2005), c("Malaysia", 1998, 2023))) {
    a <- as.integer(k[2]); b <- as.integer(k[3])
    expect_true(all(yrs(k[1], a, b, "trade_balance") > 0), label = k[1])
    expect_true(all(yrs(k[1], a, b, "fiscal_balance") < 0), label = k[1])
  }
  expect_true(all(yrs("Japan", 2011, 2014, "trade_balance") < 0))
})

test_that("C04 cases meet the three central criteria; sustainability notes hold", {
  expect_true(central_ok("Spain", 2001, 2007))
  expect_true(central_ok("Greece", 1998, 2004))
  expect_true(central_ok("Korea, Rep.", 2013, 2019))
  expect_true(all(yrs("Spain", 2001, 2007, "trade_balance") < 0))
  expect_true(all(yrs("Greece", 1998, 2004, "fiscal_balance") <= -4))
  expect_true(all(yrs("Greece", 1998, 2004, "trade_balance") <= -8.5))
  expect_true(all(yrs("Korea, Rep.", 2013, 2019, "fiscal_balance") > 0))
  expect_true(all(yrs("Korea, Rep.", 2013, 2019, "trade_balance") > 0))
})

test_that("C05 persistent surpluses", {
  expect_true(all(yrs("Germany", 1993, 2023, "trade_balance") > 0))
  expect_true(all(yrs("China", 1994, 2023, "trade_balance") > 0))
  expect_true(all(yrs("Korea, Rep.", 1998, 2007, "trade_balance") > 0))
  expect_true(all(yrs("Korea, Rep.", 2009, 2023, "trade_balance") > 0))
  expect_lt(snap("Korea, Rep.", 2008, "trade_balance"), 0)
})

test_that("C07 stagflation years: inflation above 10% with growth below 2%", {
  for (k in list(c("Argentina", 2014), c("Argentina", 2016), c("Argentina", 2018),
                 c("Argentina", 2019), c("Turkiye", 2019), c("Nigeria", 2016))) {
    y <- as.integer(k[2])
    expect_gt(snap(k[1], y, "inflation"), 10, label = paste(k, collapse = " "))
    expect_lt(snap(k[1], y, "gdp_growth"), 2, label = paste(k, collapse = " "))
  }
})

test_that("glossary hyperinflation example matches the data", {
  expect_gt(snap("Argentina", 1990, "inflation"), 2300)
  expect_lt(snap("Argentina", 2023, "inflation"), 200)
})
