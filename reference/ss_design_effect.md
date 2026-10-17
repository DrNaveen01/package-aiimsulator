# Compute a design effect

Compute a design effect

## Usage

``` r
ss_design_effect(design_effect = NULL, icc = NULL,
                               cluster_size = NULL, cv_cluster_size = 0)
```

## Arguments

- design_effect:

  Directly specified design effect, when applicable.

- icc:

  Intra-cluster correlation for design-effect approximation.

- cluster_size:

  Mean observations per cluster.

- cv_cluster_size:

  Coefficient of variation in cluster sizes.

## Value

One unrounded numeric value.

## Details

Formulas are approximations for specified sampling and hypothesis-test
designs. Inspect the returned `assumptions`, `references`, and
`warnings` before using any sample size as methodological justification.

## Examples

``` r
ss_design_effect(icc = .02, cluster_size = 20)
#> [1] 1.38
```
