# Sample size for Pearson correlation estimation and hypothesis testing

Sample size for Pearson correlation estimation and hypothesis testing

## Usage

``` r
ss_correlation(r = .3, objective = c("test", "estimate", "independent"),
                             r0 = 0, r2 = .1, precision = .1,
                             precision_scale = c("correlation", "fisher"),
                             confidence = .95, alpha = .05, power = .8,
                             alternative = c("two.sided", "greater", "less"),
                             ratio = 1, nonresponse = 0)
```

## Arguments

- r:

  Anticipated Pearson correlation.

- objective:

  Type of hypothesis or estimation objective.

- r0:

  Null Pearson correlation for one-sample testing.

- r2:

  Second population correlation for independent comparison.

- precision:

  Requested precision or confidence-interval half-width.

- precision_scale:

  Target precision on Pearson correlation or Fisher z scale.

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
ss_correlation(r = .3)
#> Pearson correlation: test
#> Required complete sample = 85; recruitment target = 85. Approximate achieved power = 80.03%.
```
