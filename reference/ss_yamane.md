# Taro Yamane simplified finite-population sample size

Taro Yamane simplified finite-population sample size

## Usage

``` r
ss_yamane(population, precision = 0.05, nonresponse = 0)
```

## Arguments

- population:

  Finite population size under simple random sampling without
  replacement.

- precision:

  Requested precision or confidence-interval half-width.

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
ss_yamane(population = 1500)
#> Yamane simplified finite-population formula
#> Required analysable sample = 316; final recruitment target = 316.
```
