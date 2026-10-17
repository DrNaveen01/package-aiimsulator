# Apply the finite population correction to an unrounded sample size

Apply the finite population correction to an unrounded sample size

## Usage

``` r
ss_fpc(n, population)
```

## Arguments

- n:

  Unrounded sample size before finite population correction.

- population:

  Finite population size under simple random sampling without
  replacement.

## Value

One unrounded numeric value.

## Details

Formulas are approximations for specified sampling and hypothesis-test
designs. Inspect the returned `assumptions`, `references`, and
`warnings` before using any sample size as methodological justification.

## Examples

``` r
ss_fpc(384.1459, population = 1000)
#> [1] 277.7335
```
