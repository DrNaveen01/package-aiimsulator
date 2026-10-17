# Sample size for comparing two independent means

Sample size for comparing two independent means

## Usage

``` r
ss_two_means(mean1 = NULL, mean2 = NULL, difference = NULL,
                           sd1 = NULL, sd2 = sd1, pooled_sd = NULL,
                           ref_n1 = NULL, ref_n2 = NULL,
                           power = .8, alpha = .05, ratio = 1, nonresponse = 0,
                           n1 = NULL, n2 = NULL, objective = "equality",
                           direction = "higher", margin = 0, lower = NULL, upper = NULL,
                           group1 = "Group 1", group2 = "Group 2",
                           design_effect = NULL, icc = NULL, cluster_size = NULL,
                           cv_cluster_size = 0)
```

## Arguments

- mean1:

  Expected mean in group 1.

- mean2:

  Expected mean in group 2.

- difference:

  Expected mean in group 2 minus group 1, supplied instead of both
  means.

- sd1:

  First group standard deviation or SD reported in reference study.

- sd2:

  Second group standard deviation or SD reported in reference study.

- pooled_sd:

  Direct reported pooled standard deviation, when available.

- ref_n1:

  First group reference-study sample size for pooled SD.

- ref_n2:

  Second group reference-study sample size for pooled SD.

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
ss_two_means(difference = 5, pooled_sd = 12)
#> Independent means: equality
#> Estimated complete sample: 91 (Group 1) and 91 (Group 2); total = 182. Recruitment target: 91 and 91; total = 182. Approximate achieved power = 80.25%. 
```
