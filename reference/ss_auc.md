# Sample size for ROC area-under-curve planning

Sample size for ROC area-under-curve planning

## Usage

``` r
ss_auc(auc = .8,
                     objective = c("estimate", "test", "independent", "paired"),
                     null_auc = .5, auc2 = .7, precision = .05,
                     confidence = .95, alpha = .05, power = .8,
                     alternative = c("two.sided", "greater", "less"),
                     ratio = 1, cohort_ratio = 1, auc_correlation = .5,
                     recruitment = c("separate", "population"),
                     prevalence = .2, nonresponse = 0)
```

## Arguments

- auc:

  Anticipated AUC for a diagnostic index test.

- objective:

  Type of hypothesis or estimation objective.

- null_auc:

  Benchmark AUC under null hypothesis.

- auc2:

  Anticipated AUC for a second diagnostic test.

- precision:

  Requested precision or confidence-interval half-width.

- confidence:

  Two-sided confidence level as a fraction.

- alpha:

  Significance level; one-sided for directional objectives.

- power:

  Target statistical power, as a fraction.

- alternative:

  Two-sided, greater or less normal test alternative.

- ratio:

  Group-2/group-1 allocation ratio, or negative/diseased allocation as
  noted.

- cohort_ratio:

  Second cohort to first cohort allocation for independent AUC
  comparison.

- auc_correlation:

  Correlation between the two estimated AUCs for paired comparisons.

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
ss_auc(auc = .8, objective = "estimate", precision = .05)
#> ROC AUC: estimate
#> Required complete sample = 302; recruitment target = 302. Required reference-standard case and control quotas for the first cohort = 151 and 151. Approximate CI half-width = 0.0499796.
```
