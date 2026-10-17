# Reproducible Sample Size Calculations with aiimsulator

## Calculation and selective reporting

Calculate complete and recruitment targets using the same structured
object.

``` r

library(aiimsulator)
x <- ss_proportion(.50, .05, nonresponse = .10)
x
#> Single proportion: Wald normal precision
#> Required analysable sample = 385; final recruitment target = 427.
ss_table(x)
#>             parameter    value
#> 1                  n0 384.1459
#> 2 after_design_effect 384.1459
#> 3           after_fpc 384.1459
#> 4            complete 385.0000
#> 5         recruitment 427.0000
```

Get the general equation, substitution and report separately:

``` r

ss_equation(x, "formula", "text")
#> [1] "n_0=\\frac{Z_{1-\\alpha/2}^{2}p(1-p)}{d^{2}}\nn_{final}=\\left\\lceil\\frac{n_0}{1-r}\\right\\rceil"
ss_equation(x, "substituted_values", "text")
#> [1] "n_0=\\frac{1.95996^{2}\\times0.5\\times(1-0.5)}{0.05^{2}}=384.146\nn_{final}=\\left\\lceil\\frac{384.146}{1-0.1}\\right\\rceil=427"
ss_report(x, formula = FALSE, substituted_values = FALSE,
          results = TRUE, assumptions = TRUE, format = "text")
#> [1] "Sample size result\nRequired analysable sample = 385; final recruitment target = 427.\n\nAssumptions\nIndependent observations for the base formula; a normal approximation to the binomial distribution.\nPrecision is an absolute half-width on the proportion scale; relative precision is multiplied by anticipated p.\nDesign-effect inflation assumes an appropriate design variance model. SRS FPC assumes sampling without replacement.\nAll adjustments are performed before final upward rounding."
```

## Additional methods

``` r

ss_mean(sd = 12, precision = 3)
#> Single mean: normal precision
#> Required analysable sample = 62; final recruitment target = 62.
ss_two_means(difference = 5, pooled_sd = 12)
#> Independent means: equality
#> Estimated complete sample: 91 (Group 1) and 91 (Group 2); total = 182. Recruitment target: 91 and 91; total = 182. Approximate achieved power = 80.25%.
ss_two_proportions(.20, .35)
#> Independent proportions: equality
#> Estimated complete sample: 138 (Group 1) and 138 (Group 2); total = 276. Recruitment target: 138 and 138; total = 276. Approximate achieved power = 80.02%.
ss_yamane(1500)
#> Yamane simplified finite-population formula
#> Required analysable sample = 316; final recruitment target = 316.
ss_diagnostic(objective = "joint", sensitivity = .85,
              specificity = .9, recruitment = "separate")
#> Diagnostic accuracy: joint
#> Required diseased = 196; non-diseased = 141; total complete sample = 337; recruitment target = 337.
ss_correlation(r = .3)
#> Pearson correlation: test
#> Required complete sample = 85; recruitment target = 85. Approximate achieved power = 80.03%.
ss_auc(auc = .80, precision = .05)
#> ROC AUC: estimate
#> Required complete sample = 302; recruitment target = 302. Required reference-standard case and control quotas for the first cohort = 151 and 151. Approximate CI half-width = 0.0499796.
```

## Study-design qualifications

Do not use this package to justify clinically meaningful margins or
effect sizes without external scientific evidence. Normal, Fisher-z and
Hanley-McNeil planning approximations have design limitations. A
cluster-randomized trial cannot generally be planned correctly by simple
multiplication of an independent individual sample size by a design
effect. The accompanying documentation records these boundaries.
