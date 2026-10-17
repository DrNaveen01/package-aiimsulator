# Sample size for sensitivity and specificity precision or benchmark tests

Sample size for sensitivity and specificity precision or benchmark tests

## Usage

``` r
ss_diagnostic(objective = c("sensitivity", "specificity", "joint",
                                      "test_sensitivity", "test_specificity"),
                            sensitivity = .85, specificity = .90,
                            precision_sens = .05, precision_spec = .05,
                            confidence = .95, interval = c("wilson", "wald"),
                            benchmark = .7, alpha = .05, power = .8,
                            alternative = c("greater", "two.sided", "less"),
                            recruitment = c("population", "separate"),
                            prevalence = .2, nonresponse = 0)
```

## Arguments

- objective:

  Type of hypothesis or estimation objective.

- sensitivity:

  Anticipated index-test sensitivity.

- specificity:

  Anticipated index-test specificity.

- precision_sens:

  Desired sensitivity CI half-width.

- precision_spec:

  Desired specificity CI half-width.

- confidence:

  Two-sided confidence level as a fraction.

- interval:

  Wilson or Wald expected interval method.

- benchmark:

  Benchmark (null) diagnostic sensitivity/specificity for testing.

- alpha:

  Significance level; one-sided for directional objectives.

- power:

  Target statistical power, as a fraction.

- alternative:

  Two-sided, greater or less normal test alternative.

- recruitment:

  Separate disease-status strata or prevalence-based population
  recruitment.

- prevalence:

  Disease prevalence in the source population.

- nonresponse:

  Proportion of incomplete or non-analysable data (0 to less than 1).

## Value

An object of class `aiims_ss` containing complete and recruitment
samples, precision-preserving calculation fields, and reportable
equations.

## Details

Formulas are approximations for specified sampling and hypothesis-test
designs. Inspect the returned `assumptions`, `references`, and
`warnings` before using any sample size as methodological justification.

## Examples

``` r
ss_diagnostic(objective = "joint", sensitivity = .85, specificity = .9)
#> Diagnostic accuracy: joint
#> Required diseased = 196; non-diseased = 141; total complete sample = 980; recruitment target = 980.
```
