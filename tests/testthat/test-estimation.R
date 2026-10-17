test_that("Cochran normal proportions match independent tabulated examples", {
  p <- c(.5, .2, .33, .1, .5)
  d <- c(.05, .05, .05, .03, .05)
  conf <- c(.95, .95, .95, .95, .99)
  n <- c(385, 246, 340, 385, 664)
  for (i in seq_along(p)) {
    expect_equal(ss_proportion(p[i], d[i], conf[i])$n_final, n[i])
  }
})
test_that("nonresponse adjustments occur before upward rounding", {
  a <- ss_proportion(.5, .05, nonresponse = .1)
  expect_equal(a$n_final, 427)
  expect_equal(a$n_complete, 385)
  expect_equal(a$n0, 384.145882069412, tolerance = 1e-9)
  expect_equal(a$n_adjusted, a$n0)
  expect_equal(ss_mean(12, 3)$n_final, ceiling((qnorm(.975) * 12 / 3)^2))
})
test_that("ICC and FPC produce correct arithmetic", {
  expect_equal(ss_design_effect(icc = .02, cluster_size = 20), 1.38)
  expect_equal(ss_design_effect(icc = .02, cluster_size = 20, cv_cluster_size = .5), 1.48)
  expect_equal(ss_fpc(384.145882069412, population = 1000),
               384.145882069412 / (1 + 383.145882069412 / 1000))
  a <- ss_proportion(.5, .05, population = 1000)
  expect_equal(a$n_final, ceiling(ss_fpc(a$n0, 1000)))
  b <- ss_proportion(.5, .05, icc = .02, cluster_size = 20)
  expect_equal(b$n_final, ceiling(b$n0 * 1.38))
})
test_that("invalid probabilities, populations and conflicting DEFF inputs error", {
  expect_error(ss_proportion(.5, 0), "precision")
  expect_error(ss_mean(0, 3), "sd")
  expect_error(ss_yamane(10.5), "integer")
  expect_error(ss_design_effect(1.4, .01, 20), "either")
  expect_error(ss_proportion(.5, .05, population = 0), "population")
})
