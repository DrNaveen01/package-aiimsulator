# Sample size for comparing two independent proportions

Sample size for comparing two independent proportions

## Usage

``` r
ss_two_proportions(p1, p2 = NULL, power = .8, alpha = .05,
                                 ratio = 1, nonresponse = 0, n1 = NULL, n2 = NULL,
                                 effect_type = c("proportions", "or", "rr"), effect = NULL,
                                 objective = "equality", direction = "higher", margin = 0,
                                 lower = NULL, upper = NULL,
                                 group1 = "Group 1", group2 = "Group 2",
                                 design_effect = NULL, icc = NULL, cluster_size = NULL,
                                 cv_cluster_size = 0)
```

## Arguments

- p1:

  Anticipated proportion in group 1.

- p2:

  Anticipated proportion in group 2.

- power:

  Target statistical power, as a fraction.

- alpha:

  Significance level; one-sided for directional objectives.

- ratio:

  Group-2/group-1 allocation ratio, or negative/diseased allocation as
  noted.

- nonresponse:

  Proportion of incomplete or non-analysable data (0 to less than 1).

- n1:

  Optional fixed complete group-1 sample size.

- n2:

  Optional fixed complete group-2 sample size.

- effect_type:

  Choose direct proportions or derive from odds ratio or risk ratio.

- effect:

  Anticipated odds ratio or risk ratio.

- objective:

  Type of hypothesis or estimation objective.

- direction:

  Whether a higher or lower group-2 value is favourable.

- margin:

  Absolute superiority/non-inferiority margin.

- lower:

  Lower equivalence margin.

- upper:

  Upper equivalence margin.

- group1:

  Label for group 1.

- group2:

  Label for group 2.

- design_effect:

  Directly specified design effect, when applicable.

- icc:

  Intra-cluster correlation for design-effect approximation.

- cluster_size:

  Mean observations per cluster.

- cv_cluster_size:

  Coefficient of variation in cluster sizes.

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
ss_two_proportions(.20, .35)
#> Independent proportions: equality
#> Estimated complete sample: 138 (Group 1) and 138 (Group 2); total = 276. Recruitment target: 138 and 138; total = 276. Approximate achieved power = 80.02%. 
```
