# The challenge solutions quote the bundled data. These tests fail if a claim
# stops matching the snapshot (for example after rebuilding it).

yrs <- function(country, from, to, var) {
  sapply(from:to, function(y) snap(country, y, var))
}
central_ok <- function(country, from, to) {
  unemp_avg <- mean(macro_df$unemployment[macro_df$country == country], na.rm = TRUE)
  all(yrs(country, from, to, "gdp_growth") > 2) &&
    all(yrs(country, from, to, "unemployment") < unemp_avg) &&
    all(yrs(country, from, to, "inflation") >= 0 & yrs(country, from, to, "inflation") < 5)
}

test_that("C01 growth without jobs: growth every year, employment rate lower at the end", {
  for (k in list(c("China", 1991, 2005), c("Tailandia", 2010, 2019), c("Serbia", 2000, 2008))) {
    a <- as.integer(k[2]); b <- as.integer(k[3])
    expect_true(all(yrs(k[1], a, b, "gdp_growth") > 0), label = k[1])
    expect_lt(snap(k[1], b, "employment"), snap(k[1], a, "employment"))
  }
})

test_that("C02 disinflation cases: inflation more than halves while unemployment rises", {
  for (k in list(c("Argentina", 1991, 1994), c("Brasil", 1992, 1996), c("Polonia", 1991, 1994))) {
    a <- as.integer(k[2]); b <- as.integer(k[3])
    expect_lt(snap(k[1], b, "inflation"), snap(k[1], a, "inflation") / 2, label = k[1])
    expect_gt(snap(k[1], b, "unemployment"), snap(k[1], a, "unemployment"), label = k[1])
  }
  expect_equal(round(c(snap("Argentina", 1991, "unemployment"), snap("Argentina", 1994, "unemployment")), 1),
               c(5.4, 11.8))
  # Counter-example: inflation and unemployment fall together
  expect_lt(snap("Argentina", 2004, "inflation"), snap("Argentina", 2002, "inflation"))
  expect_lt(snap("Argentina", 2004, "unemployment"), snap("Argentina", 2002, "unemployment"))
})

test_that("C03 trade surplus with fiscal deficit in every quoted year", {
  for (k in list(c("Japón", 1993, 2010), c("Alemania", 2002, 2005), c("Malasia", 1998, 2023))) {
    a <- as.integer(k[2]); b <- as.integer(k[3])
    expect_true(all(yrs(k[1], a, b, "trade_balance") > 0), label = k[1])
    expect_true(all(yrs(k[1], a, b, "fiscal_balance") < 0), label = k[1])
  }
  expect_true(all(yrs("Japón", 2011, 2014, "trade_balance") < 0))
})

test_that("C04 cases meet the three central criteria; sustainability notes hold", {
  for (k in list(c("España", 2001, 2007), c("Grecia", 1998, 2004), c("Chequia", 2015, 2019))) {
    expect_true(central_ok(k[1], as.integer(k[2]), as.integer(k[3])), label = k[1])
  }
  # Spain: debt fell while the current account deficit doubled
  expect_equal(round(c(snap("España", 2001, "public_debt"), snap("España", 2007, "public_debt"))), c(54, 36))
  expect_equal(round(c(snap("España", 2001, "current_account"), snap("España", 2007, "current_account")), 1),
               c(-4.3, -9.4))
  expect_equal(round(max(yrs("España", 2008, 2016, "unemployment"))), 26)
  # Greece: debt above 100%, fiscal and current account deficits, debt above 140% in 2010
  expect_true(all(yrs("Grecia", 1998, 2004, "public_debt") > 100))
  expect_true(all(yrs("Grecia", 1998, 2004, "fiscal_balance") <= -4))
  ca <- yrs("Grecia", 1999, 2004, "current_account")
  expect_true(all(ca <= -5 & ca >= -8))
  expect_gt(snap("Grecia", 2010, "public_debt"), 140)
  # Czechia: falling debt, balanced budget, current account surplus
  expect_equal(round(c(snap("Chequia", 2015, "public_debt"), snap("Chequia", 2019, "public_debt"))), c(40, 30))
  expect_true(all(abs(yrs("Chequia", 2015, 2019, "fiscal_balance")) < 2))
  expect_true(all(yrs("Chequia", 2015, 2019, "current_account") > 0))
  expect_lt(snap("Chequia", 2020, "gdp_growth"), 0)
})

test_that("C05 persistent surpluses", {
  expect_true(all(yrs("Alemania", 1993, 2023, "trade_balance") > 0))
  expect_true(all(yrs("China", 1994, 2023, "trade_balance") > 0))
  expect_true(all(yrs("Corea del Sur", 1998, 2007, "trade_balance") > 0))
  expect_true(all(yrs("Corea del Sur", 2009, 2023, "trade_balance") > 0))
  expect_lt(snap("Corea del Sur", 2008, "trade_balance"), 0)
})

test_that("C06 recoveries: GDP and unemployment", {
  expect_equal(round(c(snap("Alemania", 2008, "unemployment"), snap("Alemania", 2009, "unemployment"),
                       snap("Alemania", 2012, "unemployment")), 1), c(7.5, 7.9, 5.4))
  expect_lt(snap("Alemania", 2009, "gdp_growth"), -5)
  expect_gt(snap("Alemania", 2010, "gdp_growth"), 0)
  for (c in c("España", "Grecia")) {
    expect_gt(snap(c, 2013, "unemployment"), 26, label = c)
    expect_gt(snap(c, 2016, "unemployment"), 19, label = c)
  }
  us_2007 <- snap("Estados Unidos", 2007, "unemployment")
  expect_gt(snap("Estados Unidos", 2010, "gdp_growth"), 0)
  expect_true(all(yrs("Estados Unidos", 2008, 2016, "unemployment") >= us_2007))
  expect_lt(snap("Estados Unidos", 2017, "unemployment"), us_2007)
})

test_that("C07 stagflation years: inflation above 10% with growth below 2%", {
  for (k in list(c("Argentina", 2014), c("Argentina", 2016), c("Argentina", 2018),
                 c("Argentina", 2019), c("Turquía", 2019), c("Nigeria", 2016))) {
    y <- as.integer(k[2])
    expect_gt(snap(k[1], y, "inflation"), 10, label = paste(k, collapse = " "))
    expect_lt(snap(k[1], y, "gdp_growth"), 2, label = paste(k, collapse = " "))
  }
})

test_that("glossary hyperinflation example matches the data", {
  expect_gt(snap("Argentina", 1990, "inflation"), 2300)
  expect_lt(snap("Argentina", 2023, "inflation"), 200)
})
