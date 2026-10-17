test_that("report flags include only requested sections", {
  x <- ss_proportion(.5, .05, nonresponse = .1)
  t <- ss_report(x, formula = FALSE, substituted_values = FALSE,
                 results = TRUE, warnings = FALSE, format = "text")
  expect_match(t, "427")
  expect_false(grepl("General formula", t, fixed = TRUE))
  expect_false(grepl("Numerical substitution", t, fixed = TRUE))
  expect_equal(ss_report(x, formula = FALSE, substituted_values = FALSE,
                         results = FALSE, warnings = FALSE), "")
  eq <- ss_equation(x, which = "both", format = "markdown")
  expect_match(eq, "n_0", fixed = TRUE)
  expect_match(eq, "384.146", fixed = TRUE)
  expect_equal(ss_table(x)$value[ss_table(x)$parameter == "recruitment"], 427)
})
