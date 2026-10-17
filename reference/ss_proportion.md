# Sample size for estimating a single population proportion

Sample size for estimating a single population proportion

## Usage

``` r
ss_proportion(p, precision, confidence = 0.95,
                            precision_type = c("absolute", "relative"),
                            nonresponse = 0, design_effect = NULL,
                            icc = NULL, cluster_size = NULL,
                            cv_cluster_size = 0, population = NULL)
```

## Arguments

- p:

  Anticipated population proportion.

- precision:

  Requested precision or confidence-interval half-width.

- confidence:

  Two-sided confidence level as a fraction.

- precision_type:

  Absolute or relative precision.

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
x <- ss_proportion(p = .5, precision = .05, nonresponse = .1)
x$n_final
#> [1] 427
ss_report(x, format = "text")
#> [1] "General formula\nn_0=\\frac{Z_{1-\\alpha/2}^{2}p(1-p)}{d^{2}}\nn_{final}=\\left\\lceil\\frac{n_0}{1-r}\\right\\rceil\n\nNumerical substitution\nn_0=\\frac{1.95996^{2}\\times0.5\\times(1-0.5)}{0.05^{2}}=384.146\nn_{final}=\\left\\lceil\\frac{384.146}{1-0.1}\\right\\rceil=427\n\nSample size result\nRequired analysable sample = 385; final recruitment target = 427."
```
