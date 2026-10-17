ss_comparison_setup <- function(objective, direction, margin, lower, upper,
                                alpha, power, ratio, n1, n2, nonresponse) {
  objective <- match.arg(objective,
    c("equality", "superiority", "non_inferiority", "equivalence", "noninferiority"))
  if (objective == "noninferiority") objective <- "non_inferiority"
  direction <- match.arg(direction, c("higher", "lower"))
  ss_assert(alpha, "alpha", 0, if (objective == "equality") 1 else .5, TRUE, TRUE)
  if (objective %in% c("superiority", "non_inferiority")) {
    ss_assert(margin, "margin", 0, Inf, objective == "non_inferiority")
  }
  if (objective == "equivalence") {
    if (is.null(lower) || is.null(upper)) {
      stop("Equivalence requires lower and upper margins.", call. = FALSE)
    }
    ss_assert(lower, "lower", -Inf, 0, FALSE, TRUE)
    ss_assert(upper, "upper", 0, Inf, TRUE)
  }
  fixed <- !is.null(n1) || !is.null(n2)
  if (fixed) {
    if (is.null(n1) || is.null(n2)) stop("Provide both n1 and n2 for fixed-size power.", call. = FALSE)
    ss_integer(n1, "n1", 2)
    ss_integer(n2, "n2", 2)
    ratio <- n2 / n1
    if (nonresponse != 0) stop("nonresponse must be zero for a fixed complete-sample power calculation.", call. = FALSE)
  } else {
    ss_assert(power, "power", .5, 1, TRUE, TRUE)
    ss_assert(ratio, "ratio (n2/n1)", 0, Inf, TRUE)
    ss_nonresponse(nonresponse)
  }
  list(objective = objective, direction = direction,
    sign = if (direction == "higher") 1 else -1,
    margin = margin, lower = lower, upper = upper,
    alpha = alpha, power = if (fixed) NULL else power,
    z_alpha = stats::qnorm(1 - alpha / if (objective == "equality") 2 else 1),
    z_beta = if (fixed) NULL else stats::qnorm(power),
    ratio = ratio, fixed = fixed, n1 = n1, n2 = n2,
    nonresponse = nonresponse)
}
ss_equiv_power <- function(delta, se, setup) {
  # Two one-sided tests: the probability of their intersection.
  low <- (setup$lower - delta) / se + setup$z_alpha
  high <- (setup$upper - delta) / se - setup$z_alpha
  if (low >= high) return(0)
  if (low > 0) stats::pnorm(low, lower.tail = FALSE) -
    stats::pnorm(high, lower.tail = FALSE)
  else stats::pnorm(high) - stats::pnorm(low)
}
ss_direction_gap <- function(delta, setup) {
  setup$sign * delta + if (setup$objective == "non_inferiority") setup$margin else -setup$margin
}
ss_direction_power <- function(delta, se, setup) {
  if (setup$objective == "equivalence") return(ss_equiv_power(delta, se, setup))
  stats::pnorm(ss_direction_gap(delta, setup) / se - setup$z_alpha)
}
ss_comparison_n <- function(v, delta, setup) {
  if (setup$objective == "equivalence") {
    if (delta <= setup$lower || delta >= setup$upper) {
      stop("Expected group-2 minus group-1 difference must lie strictly within equivalence margins.", call. = FALSE)
    }
    required_power <- function(n) ss_equiv_power(delta, sqrt(v / n), setup)
    upper_n <- 2
    while (required_power(upper_n) < setup$power) {
      upper_n <- upper_n * 2
      ss_check_n(upper_n)
    }
    return(stats::uniroot(function(n) required_power(n) - setup$power,
                          c(.Machine$double.eps, upper_n), tol = 1e-8)$root)
  }
  gap <- ss_direction_gap(delta, setup)
  if (gap <= 0) stop("The anticipated difference does not satisfy the chosen direction and margin.", call. = FALSE)
  ((setup$z_alpha + setup$z_beta)^2 * v) / gap^2
}
ss_comparison_sizes <- function(n1_base, setup, deff) {
  if (setup$fixed) {
    return(list(n1_base = NULL, n2_base = NULL, n1 = setup$n1,
      n2 = setup$n2, final1 = setup$n1, final2 = setup$n2,
      complete = setup$n1 + setup$n2,
      recruitment = setup$n1 + setup$n2))
  }
  b1 <- deff * n1_base
  b2 <- deff * setup$ratio * n1_base
  a1 <- b1 / (1 - setup$nonresponse)
  a2 <- b2 / (1 - setup$nonresponse)
  ss_check_n(c(b1, b2, a1, a2))
  list(n1_base = n1_base, n2_base = setup$ratio * n1_base,
    n1 = ceiling(b1), n2 = ceiling(b2),
    final1 = ceiling(a1), final2 = ceiling(a2),
    complete = ceiling(b1) + ceiling(b2),
    recruitment = ceiling(a1) + ceiling(a2))
}
ss_group_report <- function(sizes, setup, deff) {
  c(if (!setup$fixed) paste0("n_{1,0}=", ss_fmt(sizes$n1_base),
                               ",\\quad n_{2,0}=", ss_fmt(sizes$n2_base)),
    if (deff != 1 && !setup$fixed) paste0("n_{1,DEFF}=", ss_fmt(sizes$n1_base), "\\times", ss_fmt(deff),
                         ",\\quad n_{2,DEFF}=", ss_fmt(sizes$n2_base), "\\times", ss_fmt(deff)),
    paste0("n_{1,complete}=", sizes$n1, ",\\quad n_{2,complete}=", sizes$n2),
    paste0("n_{1,final}=", sizes$final1, ",\\quad n_{2,final}=", sizes$final2,
           ",\\quad N_{final}=", sizes$recruitment))
}
ss_group_warnings <- function(deff, fixed) {
  c(if (deff != 1) "Multiplying normal independent-group planning counts by a design effect is only an approximation. Cluster-randomized designs require cluster-level power, integer cluster counts, and design-specific variance assumptions.",
    if (fixed && deff != 1) "Achieved power uses effective group sizes (observed n divided by design effect) as an approximation.")
}

#' Sample size for comparing two independent proportions
#'
#' @param p1 Anticipated proportion in group 1 (fraction).
#' @param p2 Anticipated proportion in group 2; may be derived from `effect`.
#' @param effect_type `"proportions"`, `"or"`, or `"rr"`.
#' @param effect Odds ratio or risk ratio for group 2 relative to group 1.
#' @param objective One of `"equality"`, `"superiority"`,
#'   `"non_inferiority"`, or `"equivalence"`.
#' @param direction Whether a higher or lower group-2 proportion is favourable.
#' @param margin Absolute superiority or non-inferiority margin on the proportion scale.
#' @param lower,upper Lower and upper equivalence boundaries for (p2 - p1).
#' @param alpha Type I error (two-sided for equality; one-sided otherwise).
#' @param power Planned power.
#' @param ratio Desired n2/n1.
#' @param nonresponse Anticipated non-response fraction.
#' @param n1,n2 Optional fixed completed group sizes; both required to calculate power.
#' @param group1,group2 Distinct displayed group labels.
#' @param design_effect Optional approximate inflation for design complexity.
#' @param icc,cluster_size,cv_cluster_size Cluster parameters alternatively used to
#'   estimate the design effect.
#' @return An `aiims_ss` object.
#' @examples
#' ss_two_proportions(.20, .35, power = .8)
#' @export
ss_two_proportions <- function(p1, p2 = NULL, power = .8, alpha = .05,
                               ratio = 1, nonresponse = 0, n1 = NULL, n2 = NULL,
                               effect_type = c("proportions", "or", "rr"), effect = NULL,
                               objective = "equality", direction = "higher", margin = 0,
                               lower = NULL, upper = NULL,
                               group1 = "Group 1", group2 = "Group 2",
                               design_effect = NULL, icc = NULL, cluster_size = NULL,
                               cv_cluster_size = 0) {
  group1 <- ss_check_name(group1, "group1")
  group2 <- ss_check_name(group2, "group2")
  if (identical(group1, group2)) stop("Group labels must differ.", call. = FALSE)
  effect_type <- match.arg(effect_type)
  ss_prob(p1, "p1")
  if (effect_type != "proportions") {
    ss_assert(effect, "effect", 0, Inf, TRUE)
    p2 <- if (effect_type == "or") 1 / (1 + (1 - p1) / p1 / effect) else p1 * effect
  }
  ss_prob(p2, "p2")
  delta <- p2 - p1
  setup <- ss_comparison_setup(objective, direction, margin, lower, upper,
                               alpha, power, ratio, n1, n2, nonresponse)
  if (setup$objective %in% c("superiority", "non_inferiority") && margin >= 1) {
    stop("Proportion margins must be below 1.", call. = FALSE)
  }
  if (setup$objective == "equivalence" && (lower <= -1 || upper >= 1)) {
    stop("Proportion equivalence margins must be strictly inside (-1,1).", call. = FALSE)
  }
  if (setup$objective == "equality" && delta == 0 && !setup$fixed) {
    stop("The anticipated proportions must differ for equality sample-size planning.", call. = FALSE)
  }
  deff <- ss_design_effect(design_effect, icc, cluster_size, cv_cluster_size)
  de <- ss_deff_equations(design_effect, icc, cluster_size, cv_cluster_size, deff)
  k <- setup$ratio
  pbar <- (p1 + k * p2) / (1 + k)
  a <- sqrt((1 + 1 / k) * pbar * (1 - pbar))
  b <- sqrt(p1 * (1 - p1) + p2 * (1 - p2) / k)
  n_base <- if (setup$fixed) NULL else if (setup$objective == "equality") {
    ((setup$z_alpha * a + setup$z_beta * b) / abs(delta))^2
  } else ss_comparison_n(b^2, delta, setup)
  sizes <- ss_comparison_sizes(n_base, setup, deff)
  e1 <- sizes$n1 / deff
  e2 <- sizes$n2 / deff
  pp <- (e1 * p1 + e2 * p2) / (e1 + e2)
  se0 <- sqrt(pp * (1 - pp) * (1 / e1 + 1 / e2))
  se1 <- sqrt(p1 * (1 - p1) / e1 + p2 * (1 - p2) / e2)
  achieved <- if (setup$objective == "equality") {
    ss_normal_power(delta, se0, se1, alpha)
  } else ss_direction_power(delta, se1, setup)
  formula <- if (setup$objective == "equality") {
    "n_{1,0}=\\frac{[Z_{1-\\alpha/2}\\sqrt{(1+1/k)\\bar{p}(1-\\bar{p})}+Z_{1-\\beta}\\sqrt{p_1(1-p_1)+p_2(1-p_2)/k}]^2}{(p_2-p_1)^2}"
  } else if (setup$objective == "equivalence") {
    "P_{TOST}=\\Phi((U-\\Delta)/SE-z_{1-\\alpha})-\\Phi((L-\\Delta)/SE+z_{1-\\alpha})"
  } else {
    "n_{1,0}=\\frac{(Z_{1-\\alpha}+Z_{1-\\beta})^2[p_1(1-p_1)+p_2(1-p_2)/k]}{g^2}"
  }
  substitutions <- c(paste0("\\Delta=", ss_fmt(p2), "-", ss_fmt(p1), "=", ss_fmt(delta)),
    if (!setup$fixed && setup$objective == "equality") paste0("n_{1,0}=\\left[\\frac{", ss_fmt(setup$z_alpha),
      "\\times", ss_fmt(a), "+", ss_fmt(setup$z_beta), "\\times", ss_fmt(b),
      "}{", ss_fmt(abs(delta)), "}\\right]^2=", ss_fmt(n_base)),
    if (!setup$fixed && setup$objective %in% c("superiority", "non_inferiority")) {
      paste0("n_{1,0}=\\frac{(", ss_fmt(setup$z_alpha), "+", ss_fmt(setup$z_beta),
             ")^2\\times", ss_fmt(b^2), "}{", ss_fmt(ss_direction_gap(delta, setup)),
             "^2}=", ss_fmt(n_base))
    },
    if (!setup$fixed && setup$objective == "equivalence") {
      paste0("n_{1,0}=", ss_fmt(n_base), "\\quad (\\mathrm{numerical\\ TOST\\ power\\ solution})")
    }, de$substituted, ss_group_report(sizes, setup, deff),
    paste0("P_{achieved}=", ss_fmt(achieved)))
  warn <- c(ss_group_warnings(deff, setup$fixed),
    if (any(c(sizes$n1 * p1, sizes$n1 * (1 - p1), sizes$n2 * p2,
              sizes$n2 * (1 - p2)) < 10)) "One or more expected group cells are below 10; normal approximation may be inadequate.")
  ss_new(paste("Independent proportions:", setup$objective), "two_proportions",
    sizes$complete, sizes$recruitment,
    c(formula, de$formulas,
      if (setup$objective == "superiority") "g=t\\Delta-M",
      if (setup$objective == "non_inferiority") "g=t\\Delta+M",
      if (deff != 1) "n_{i,DEFF}=DEFF\\times n_{i,0}",
      if (!setup$fixed) paste0("n_{i,final}=\\left\\lceil\\frac{",
        if (deff != 1) "n_{i,DEFF}" else "n_{i,0}",
        "}{1-r}\\right\\rceil")), substitutions,
    c(group1_complete = sizes$n1, group2_complete = sizes$n2,
      group1_recruitment = sizes$final1, group2_recruitment = sizes$final2,
      achieved_power = achieved, complete = sizes$complete, recruitment = sizes$recruitment),
    c("Independent participants within groups; normal approximation; expected outcome proportions are planning assumptions.",
      "Equality uses pooled null and unpooled alternative variance; directional objectives use unpooled alternative variance.",
      "For non-inferiority, superiority and equivalence, alpha is one-sided; equivalence uses joint two one-sided tests.",
      "Group-2 minus group-1 is the signed difference. Margins must be clinically prespecified."),
    ss_refs$two_group,
    list(p1 = p1, p2 = p2, difference = delta, n1 = sizes$n1, n2 = sizes$n2,
      final1 = sizes$final1, final2 = sizes$final2,
      objective = setup$objective, direction = setup$direction, margin = margin,
      lower = lower, upper = upper, group1 = group1, group2 = group2,
      achieved_power = achieved, design_effect = deff, ratio = k,
      nonresponse = nonresponse, n0 = n_base, mode = if (setup$fixed) "power" else "sample_size"), warn)
}

#' Sample size for comparing two independent means
#'
#' @param mean1,mean2 Anticipated group means. Alternatively enter `difference`.
#' @param difference Signed difference (mean2 minus mean1), when group means
#'   are not supplied.
#' @param sd1,sd2 Anticipated SDs for independent groups. SD2 defaults to SD1.
#' @param pooled_sd Directly supplied common SD (overrides individual SDs),
#'   unless `ref_n1` and `ref_n2` are supplied.
#' @param ref_n1,ref_n2 Sample sizes in a reference study for weighted pooling
#'   of its `sd1` and `sd2` values.
#' @inheritParams ss_two_proportions
#' @return An `aiims_ss` object.
#' @examples
#' ss_two_means(difference = 5, pooled_sd = 12)
#' @export
ss_two_means <- function(mean1 = NULL, mean2 = NULL, difference = NULL,
                         sd1 = NULL, sd2 = sd1, pooled_sd = NULL,
                         ref_n1 = NULL, ref_n2 = NULL,
                         power = .8, alpha = .05, ratio = 1, nonresponse = 0,
                         n1 = NULL, n2 = NULL, objective = "equality",
                         direction = "higher", margin = 0, lower = NULL, upper = NULL,
                         group1 = "Group 1", group2 = "Group 2",
                         design_effect = NULL, icc = NULL, cluster_size = NULL,
                         cv_cluster_size = 0) {
  group1 <- ss_check_name(group1, "group1")
  group2 <- ss_check_name(group2, "group2")
  if (identical(group1, group2)) stop("Group labels must differ.", call. = FALSE)
  if (!is.null(difference)) {
    if (!is.null(mean1) || !is.null(mean2)) stop("Provide difference OR both group means, not both.", call. = FALSE)
    ss_assert(difference, "difference")
    delta <- difference
  } else {
    ss_assert(mean1, "mean1")
    ss_assert(mean2, "mean2")
    delta <- mean2 - mean1
  }
  if (!is.null(ref_n1) || !is.null(ref_n2)) {
    if (!is.null(pooled_sd)) stop("Choose directly supplied pooled_sd or reference-study pooling.", call. = FALSE)
    ss_integer(ref_n1, "ref_n1", 2)
    ss_integer(ref_n2, "ref_n2", 2)
    ss_assert(sd1, "sd1", 0, Inf, TRUE)
    ss_assert(sd2, "sd2", 0, Inf, TRUE)
    sp <- sqrt(((ref_n1 - 1) * sd1^2 + (ref_n2 - 1) * sd2^2) /
                 (ref_n1 + ref_n2 - 2))
    sd_source <- "reference_pooled"
  } else if (!is.null(pooled_sd)) {
    ss_assert(pooled_sd, "pooled_sd", 0, Inf, TRUE)
    sp <- pooled_sd
    sd_source <- "direct_pooled"
  } else {
    ss_assert(sd1, "sd1", 0, Inf, TRUE)
    ss_assert(sd2, "sd2", 0, Inf, TRUE)
    sp <- NULL
    sd_source <- "separate"
  }
  sd1_used <- if (is.null(sp)) sd1 else sp
  sd2_used <- if (is.null(sp)) sd2 else sp
  setup <- ss_comparison_setup(objective, direction, margin, lower, upper,
                               alpha, power, ratio, n1, n2, nonresponse)
  if (setup$objective == "equality" && delta == 0 && !setup$fixed) {
    stop("Expected mean difference must be nonzero for equality sample-size planning.", call. = FALSE)
  }
  deff <- ss_design_effect(design_effect, icc, cluster_size, cv_cluster_size)
  de <- ss_deff_equations(design_effect, icc, cluster_size, cv_cluster_size, deff)
  v <- sd1_used^2 + sd2_used^2 / setup$ratio
  n_base <- if (setup$fixed) NULL else if (setup$objective == "equality") {
    (setup$z_alpha + setup$z_beta)^2 * v / delta^2
  } else ss_comparison_n(v, delta, setup)
  sizes <- ss_comparison_sizes(n_base, setup, deff)
  se <- sqrt(deff * (sd1_used^2 / sizes$n1 + sd2_used^2 / sizes$n2))
  achieved <- if (setup$objective == "equality") {
    ss_normal_power(delta, se, se, alpha)
  } else ss_direction_power(delta, se, setup)
  f <- if (setup$objective == "equality") {
    "n_{1,0}=\\frac{(Z_{1-\\alpha/2}+Z_{1-\\beta})^2(\\sigma_1^2+\\sigma_2^2/k)}{\\Delta^2}"
  } else if (setup$objective == "equivalence") {
    "P_{TOST}=\\Phi((U-\\Delta)/SE-z_{1-\\alpha})-\\Phi((L-\\Delta)/SE+z_{1-\\alpha})"
  } else {
    "n_{1,0}=\\frac{(Z_{1-\\alpha}+Z_{1-\\beta})^2(\\sigma_1^2+\\sigma_2^2/k)}{g^2}"
  }
  substitutions <- c(if (sd_source == "reference_pooled") paste0("s_p=\\sqrt{\\frac{(", ref_n1,
    "-1)\\times", ss_fmt(sd1), "^2+(", ref_n2, "-1)\\times", ss_fmt(sd2),
    "^2}{", ref_n1, "+", ref_n2, "-2}}=", ss_fmt(sp)),
    paste0("\\Delta=", ss_fmt(delta), ",\\quad V=", ss_fmt(sd1_used), "^2+",
           ss_fmt(sd2_used), "^2/", ss_fmt(setup$ratio), "=", ss_fmt(v)),
    if (!setup$fixed && setup$objective != "equivalence") {
      paste0("n_{1,0}=\\frac{(", ss_fmt(setup$z_alpha), "+", ss_fmt(setup$z_beta),
             ")^2\\times", ss_fmt(v), "}{", ss_fmt(if (setup$objective == "equality") delta else ss_direction_gap(delta, setup)),
             "^2}=", ss_fmt(n_base))
    },
    if (!setup$fixed && setup$objective == "equivalence") {
      paste0("n_{1,0}=", ss_fmt(n_base), "\\quad (\\mathrm{numerical\\ TOST\\ power\\ solution})")
    }, de$substituted, ss_group_report(sizes, setup, deff), paste0("P_{achieved}=", ss_fmt(achieved)))
  ss_new(paste("Independent means:", setup$objective), "two_means",
    sizes$complete, sizes$recruitment,
    c(f, de$formulas,
      if (setup$objective == "superiority") "g=t\\Delta-M",
      if (setup$objective == "non_inferiority") "g=t\\Delta+M",
      if (deff != 1) "n_{i,DEFF}=DEFF\\times n_{i,0}",
      if (!setup$fixed) paste0("n_{i,final}=\\left\\lceil\\frac{",
        if (deff != 1) "n_{i,DEFF}" else "n_{i,0}",
        "}{1-r}\\right\\rceil")), substitutions,
    c(group1_complete = sizes$n1, group2_complete = sizes$n2,
      group1_recruitment = sizes$final1, group2_recruitment = sizes$final2,
      achieved_power = achieved, complete = sizes$complete, recruitment = sizes$recruitment),
    c("Independent observations and specified planning SDs; uses a normal approximation rather than a noncentral t or Welch power calculation.",
      "Signed effect is group-2 minus group-1; higher/lower objective direction and clinical margins must be prespecified.",
      "An SD pooled from a reference study is a within-group degrees-of-freedom-weighted SD, assuming common variances."),
    ss_refs$two_group,
    list(mean1 = mean1, mean2 = mean2, difference = delta, sd1 = sd1_used,
      sd2 = sd2_used, pooled_sd = sp, sd_source = sd_source,
      n1 = sizes$n1, n2 = sizes$n2, final1 = sizes$final1, final2 = sizes$final2,
      group1 = group1, group2 = group2, achieved_power = achieved,
      objective = setup$objective, direction = direction, margin = margin,
      lower = lower, upper = upper, design_effect = deff, ratio = setup$ratio,
      nonresponse = nonresponse, n0 = n_base,
      mode = if (setup$fixed) "power" else "sample_size"),
    c(ss_group_warnings(deff, setup$fixed),
      if (min(sizes$n1, sizes$n2) < 30) "At least one complete group has fewer than 30 observations; a t-based calculation may differ."))
}
