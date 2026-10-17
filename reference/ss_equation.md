# Extract general and numerically substituted equations

Extract general and numerically substituted equations

## Usage

``` r
ss_equation(x, which = c("formula", "substituted_values", "both"),
                          format = c("markdown", "latex", "text"))
```

## Arguments

- x:

  An aiims_ss result object.

- which:

  Select general formula, substituted values or both.

- format:

  Markdown, LaTeX or plain-text output.

## Value

A character string.

## Details

Formulas are approximations for specified sampling and hypothesis-test
designs. Inspect the returned `assumptions`, `references`, and
`warnings` before using any sample size as methodological justification.

## Examples

``` r
ss_equation(ss_proportion(.5, .05), which = "both", format = "text")
#> [1] "n_0=\\frac{Z_{1-\\alpha/2}^{2}p(1-p)}{d^{2}}\nn_{final}=\\left\\lceil\\frac{n_0}{1-r}\\right\\rceil\nn_0=\\frac{1.95996^{2}\\times0.5\\times(1-0.5)}{0.05^{2}}=384.146\nn_{final}=\\lceil384.146\\rceil=385"
```
