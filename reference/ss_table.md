# Convert a calculation to a tidy parameter/result table

Convert a calculation to a tidy parameter/result table

## Usage

``` r
ss_table(x)
```

## Arguments

- x:

  An aiims_ss result object.

## Value

A two-column data frame of numeric intermediate and final calculations.

## Details

Formulas are approximations for specified sampling and hypothesis-test
designs. Inspect the returned `assumptions`, `references`, and
`warnings` before using any sample size as methodological justification.

## Examples

``` r
ss_table(ss_proportion(.5, .05))
#>             parameter    value
#> 1                  n0 384.1459
#> 2 after_design_effect 384.1459
#> 3           after_fpc 384.1459
#> 4            complete 385.0000
#> 5         recruitment 385.0000
```
