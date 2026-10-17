<!-- badges: start -->
  [![R-CMD-check](https://github.com/DrNaveen01/package-aiimsulator/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/DrNaveen01/package-aiimsulator/actions/workflows/R-CMD-check.yaml)
  
  
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.23441808.svg)](https://doi.org/10.5281/zenodo.23441808)

  <!-- badges: end -->


# aiimsulator

**Development source package (version 0.1.0): a reproducible sample-size engine for R, Quarto and manuscripts.**

> **Release status:** Not on CRAN.



## Installation from an unzipped source folder

```bash
# From the parent directory of the aiimsulator/ project:
R CMD INSTALL aiimsulator
```

```r
library(aiimsulator)
```

Alternatively, with `pak`:

```r
pak::pak("DrNaveen01/package-aiimsulator")
```

## Basic example

```r
library(aiimsulator)

x <- ss_proportion(
  p = 0.50, precision = 0.05,
  confidence = 0.95, nonresponse = 0.10
)
x$n0           # 384.1459... (no rounding in computation)
x$n_complete   # 385
x$n_final      # 427

# Choose exactly what to emit
cat(ss_report(
  x,
  formula = TRUE,
  substituted_values = TRUE,
  results = TRUE,
  assumptions = FALSE,
  references = TRUE,
  format = "markdown"
))

# Results only, for a manuscript statement
cat(ss_report(x, formula = FALSE,
              substituted_values = FALSE, results = TRUE,
              warnings = FALSE, format = "text"))

# Equation components without explanatory text
cat(ss_equation(x, which = "substituted_values", format = "latex"))

# Tidy numeric table for manuscript output or QA
ss_table(x)
```

### Optional design effect and finite population correction

```r
ss_design_effect(icc = 0.02, cluster_size = 20)

# Two alternative design-effect inputs; do not supply both at once
ss_proportion(.50, .05, design_effect = 1.38)
ss_proportion(.50, .05, icc = .02, cluster_size = 20)

# SRS without replacement only
ss_proportion(.50, .05, population = 1000)
ss_fpc(384.145882, population = 1000)
```

When `population` is supplied, correction uses `n / (1 + (n-1)/N)`.
Combining clustering and the simple SRS FPC is a rough approximation, not a
cluster-sampling variance model. Independent-group sample sizes may use an
approximate design-effect inflation, which **does not replace dedicated
cluster-randomized-trial planning**. Finite-population adjustments are therefore
intentionally not exposed for independent-group hypothesis tests.

### Other planning functions

```r
ss_mean(sd = 12, precision = 3)
ss_yamane(population = 1500)

# Difference directly, common pooled SD supplied directly
ss_two_means(difference = 5, pooled_sd = 12,
             power = .8, objective = "equality")

# Derive within-group pooled SD from reference-study group SDs and sample sizes
ss_two_means(mean1 = 20, mean2 = 25,
             sd1 = 10, sd2 = 14, ref_n1 = 51, ref_n2 = 51)

ss_two_proportions(p1 = .20, p2 = .35, objective = "equality")

ss_two_means(difference = -2, pooled_sd = 10,
             objective = "non_inferiority", direction = "higher", margin = 5)

ss_two_means(difference = 0, pooled_sd = 5,
             objective = "equivalence", lower = -3, upper = 3)

ss_auc(auc = .8, objective = "estimate", precision = .05)
ss_diagnostic(objective = "joint", sensitivity = .85,
              specificity = .90, prevalence = .2)
ss_correlation(r = .3, objective = "test", r0 = 0)
```

## Manuscript / Quarto use

In a `.qmd` manuscript:

````markdown
```{r}
#| output: asis
#| echo: false
library(aiimsulator)
result <- ss_proportion(p = .5, precision = .05, nonresponse = .1)
cat(ss_report(result, formula = TRUE,
              substituted_values = TRUE,
              results = TRUE, format = "markdown"))
```

The recruitment target was `r result$n_final` participants.
````

The included vignette and `inst/extdata/manuscript-example.qmd` demonstrate the
format. The software emits a calculation report, **not a study-specific rationale
for every input**. Cite the source literature used to choose precision,
prevalence, clinical margins, ICC and anticipated effects separately.

## Current methodological boundaries

- Proportions and means: normal/Wald planning with explicit approximation warnings.
- Two independent groups: normal approximations; superiority, non-inferiority,
  equality and TOST equivalence; one-sided alpha for directional objectives.
- AUC: full ROC AUC with Hanley-McNeil approximate variance, not empirical
  DeLong pilot covariance, exact tests or partial-AUC planning.
- Diagnostic: expected Wilson or Wald precision, and normal approximate
  benchmark tests. Joint endpoints use individual rather than simultaneous CIs.
- Correlation: Pearson's r with uncorrected Fisher-z approximation, not the
  exact noncentral-t calculation, Spearman, repeated or dependent correlations.
- Non-response: inflation is applied **before** upward rounding.
- A calculation must be reviewed for sampling design, estimand, hypothesized
  effect, clinically meaningful margins and feasibility. The software does
  not validate the study design automatically.


<!--

## Developer checks (required before CRAN)

```r
install.packages(c("devtools", "testthat", "rcmdcheck", "knitr", "rmarkdown"))

devtools::document()    # roxygen if documentation is updated

devtools::test()
devtools::check(args = "--as-cran")

# Then from a shell, in the parent directory:
# R CMD build aiimsulator
# R CMD check --as-cran aiimsulator_0.1.0.tar.gz
```
-->

GitHub Actions includes checks on Linux, Windows and macOS. The source archive
provided here is a **development archive**, not an `R CMD build` product.


