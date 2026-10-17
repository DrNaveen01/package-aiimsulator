test_that("two proportions use the independent-group equality expression", {
  p1 <- .2; p2 <- .35; k <- 1; alpha <- .05; power <- .8
  pbar <- (p1 + p2) / 2
  na <- ((qnorm(1 - alpha / 2) * sqrt(2 * pbar * (1 - pbar)) +
          qnorm(power) * sqrt(p1 * (1 - p1) + p2 * (1 - p2))) /
         (p2 - p1))^2
  x <- ss_two_proportions(p1, p2)
  expect_equal(x$n0, na, tolerance = 1e-8)
  expect_equal(x$n1, ceiling(na))
  expect_equal(x$n_final, 2 * ceiling(na))
})
test_that("two-means direct difference, pooled and reference SD work", {
  x <- ss_two_means(difference = 5, pooled_sd = 12)
  expected <- (qnorm(.975) + qnorm(.8))^2 * (12^2 + 12^2) / 5^2
  expect_equal(x$n0, expected)
  expect_equal(x$n_final, 2 * ceiling(expected))
  z <- ss_two_means(mean1 = 20, mean2 = 25, sd1 = 10, sd2 = 14,
                    ref_n1 = 51, ref_n2 = 51)
  expect_equal(z$pooled_sd, sqrt((10^2 + 14^2) / 2))
})
test_that("non-inferiority direction and equivalence constraints are enforced", {
  expect_error(ss_two_means(difference = -8, pooled_sd = 10,
    objective = "non_inferiority", direction = "higher", margin = 5), "difference")
  x <- ss_two_means(difference = -2, pooled_sd = 10,
    objective = "non_inferiority", direction = "higher", margin = 5)
  expect_true(x$n_final > 0)
  y <- ss_two_means(difference = 0, pooled_sd = 5,
    objective = "equivalence", lower = -3, upper = 3, alpha = .05)
  expect_true(y$n_final > 0)
  expect_gte(y$achieved_power, .8 - 1e-6)
  expect_error(ss_two_means(difference = 4, pooled_sd = 5,
    objective = "equivalence", lower = -3, upper = 3), "strictly")
})
test_that("fixed sizes result in approximate achieved power", {
  x <- ss_two_proportions(.2, .35, n1 = 150, n2 = 150)
  expect_equal(x$n_final, 300)
  expect_true(x$achieved_power > 0 && x$achieved_power < 1)
})
