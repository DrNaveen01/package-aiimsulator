# Produce a selective manuscript-ready sample-size report

Produce a selective manuscript-ready sample-size report

## Usage

``` r
ss_report(x, formula = TRUE, substituted_values = TRUE,
                        results = TRUE, assumptions = FALSE, references = FALSE,
                        warnings = TRUE, format = c("markdown", "latex", "text"))
```

## Arguments

- x:

  An aiims_ss result object.

- formula:

  Include general equation block.

- substituted_values:

  Include numerically substituted equation block.

- results:

  Include the final sample size and/or achieved power text.

- assumptions:

  Include methodological assumptions.

- references:

  Include method citations.

- warnings:

  Include calculation warnings.

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
ss_report(ss_proportion(.5, .05), formula = TRUE, results = TRUE)
#> [1] "### General formula\n\n$$\nn_0=\\frac{Z_{1-\\alpha/2}^{2}p(1-p)}{d^{2}}\n$$\n\n$$\nn_{final}=\\left\\lceil\\frac{n_0}{1-r}\\right\\rceil\n$$\n\n### Numerical substitution\n\n$$\nn_0=\\frac{1.95996^{2}\\times0.5\\times(1-0.5)}{0.05^{2}}=384.146\n$$\n\n$$\nn_{final}=\\lceil384.146\\rceil=385\n$$\n\n### Sample size result\n\nRequired analysable sample = 385; final recruitment target = 385."
```
