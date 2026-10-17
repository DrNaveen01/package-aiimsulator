# Sample size for estimating a single population mean

Sample size for estimating a single population mean

## Usage

``` r
ss_mean(sd, precision, confidence = 0.95,
                      nonresponse = 0, design_effect = NULL,
                      icc = NULL, cluster_size = NULL,
                      cv_cluster_size = 0, population = NULL)
```

## Arguments

- sd:

  Anticipated standard deviation.

- precision:

  Requested precision or confidence-interval half-width.

- confidence:

  Two-sided confidence level as a fraction.

- nonresponse:

  Proportion of incomplete or non-analysable data (0 to less than 1).

- design_effect:

  Directly specified design effect, when applicable.

- icc:

  Intra-cluster correlation for design-effect approximation.

- cluster_size:

  Mean observations per cluster.

- cv_cluster_size:

  Coefficient of variation in cluster sizes.

- population:

  Finite population size under simple random sampling without
  replacement.

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
ss_mean(sd = 12, precision = 3)
#> Single mean: normal precision
#> Required analysable sample = 62; final recruitment target = 62.
```
