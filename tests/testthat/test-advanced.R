test_that("Wilson planning produces half-width within requested precision", {
  x <- ss_diagnostic(objective = "joint", sensitivity = .85,
                     specificity = .9, recruitment = "separate")
  expect_lte(aiimsulator:::ss_wilson_halfwidth(.85, x$cases, .95), .05)
  expect_lte(aiimsulator:::ss_wilson_halfwidth(.9, x$controls, .95), .05)
  expect_equal(x$n_complete, x$cases + x$controls)
})
test_that("Hanley-McNeil variance is positive and AUC power methods work", {
  x <- ss_auc(auc = .8, objective = "estimate", precision = .05)
  expect_lte(x$achieved_precision, .05)
  y <- ss_auc(auc = .8, objective = "test", null_auc = .5)
  expect_gte(y$achieved_power, .8)
  z <- ss_auc(auc = .8, auc2 = .7, objective = "paired")
  expect_gte(z$achieved_power, .8)
})
test_that("uncorrected Fisher-z correlation analysis returns required precision", {
  x <- ss_correlation(r = .3, objective = "estimate", precision = .1)
  expect_lte(x$achieved_precision, .1)
  expect_gte(x$n_final, 4)
  y <- ss_correlation(r = .3, objective = "test", r0 = 0)
  expect_gte(y$achieved_power, .8)
  z <- ss_correlation(r = .3, r2 = .1, objective = "independent")
  expect_gte(z$achieved_power, .8)
})

test_that("independent advanced numeric fixtures match Hanley-McNeil and Fisher arithmetic", {
  a <- ss_auc(auc = .8, objective = "estimate", precision = .05,
              recruitment = "separate", ratio = 1)
  expect_equal(a$cases, 151)
  expect_equal(a$controls, 151)
  expect_equal(a$n_final, 302)

  b <- ss_auc(auc = .8, objective = "test", null_auc = .5,
              recruitment = "separate", ratio = 1)
  expect_equal(b$cases, 14)
  expect_equal(b$controls, 14)

  c <- ss_diagnostic(objective = "joint", sensitivity = .85,
                     specificity = .90, interval = "wilson",
                     recruitment = "separate")
  expect_equal(c$cases, 196)
  expect_equal(c$controls, 141)
  expect_equal(c$n_final, 337)

  d <- ss_correlation(r = .3, objective = "test", r0 = 0)
  expect_equal(d$n_final, 85)
})
