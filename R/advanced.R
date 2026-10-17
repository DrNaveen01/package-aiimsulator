ss_auc_variance <- function(auc, cases, controls) {
  ss_prob(auc, "auc")
  ss_assert(cases, "cases", 2, Inf)
  ss_assert(controls, "controls", 2, Inf)
  q1 <- auc / (2 - auc)
  q2 <- 2 * auc^2 / (1 + auc)
  (auc * (1 - auc) + (cases - 1) * (q1 - auc^2) +
     (controls - 1) * (q2 - auc^2)) / (cases * controls)
}
ss_strata_counts <- function(cases, controls, prevalence, nonresponse, recruitment) {
  if (recruitment == "population") {
    ss_prob(prevalence, "prevalence")
    complete <- ceiling(max(cases / prevalence, controls / (1 - prevalence)))
    inflated <- ceiling(complete / (1 - nonresponse))
    c(complete = complete, recruitment = inflated)
  } else {
    complete <- cases + controls
    inflated <- ceiling(cases / (1 - nonresponse)) +
      ceiling(controls / (1 - nonresponse))
    c(complete = complete, recruitment = inflated)
  }
}

#' Sample size for ROC area-under-curve planning
#'
#' @param auc Anticipated area under the ROC curve, 0 to 1.
#' @param objective `"estimate"`, `"test"`, `"independent"`, or `"paired"`.
#' @param null_auc Hypothesised AUC under a one-test null.
#' @param auc2 Anticipated AUC of the comparator test for independent/paired tests.
#' @param precision Target normal-interval half-width for estimation.
#' @param confidence Confidence for precision planning.
#' @param alpha,power Error rate and power for testing.
#' @param alternative Normal testing alternative: `"two.sided"`, `"greater"` or `"less"`.
#' @param ratio Expected non-diseased/diseased recruitment ratio in each cohort.
#' @param cohort_ratio Relative number of diseased cases in the second cohort
#'   versus the first (independent comparison only).
#' @param auc_correlation Correlation between estimated paired AUCs; NOT the
#'   correlation between underlying test measurements.
#' @param recruitment `"separate"` case/control strata or `"population"`
#'   (prevalence-based expected recruitment).
#' @param prevalence Anticipated disease prevalence for population recruitment.
#' @param nonresponse Non-response fraction.
#' @return An `aiims_ss` object. Uses Hanley-McNeil variance approximation;
#'   not partial-AUC or pilot DeLong variance planning.
#' @examples
#' ss_auc(auc = .8, objective = "estimate", precision = .05)
#' @export
ss_auc <- function(auc = .8,
                   objective = c("estimate", "test", "independent", "paired"),
                   null_auc = .5, auc2 = .7, precision = .05,
                   confidence = .95, alpha = .05, power = .8,
                   alternative = c("two.sided", "greater", "less"),
                   ratio = 1, cohort_ratio = 1, auc_correlation = .5,
                   recruitment = c("separate", "population"),
                   prevalence = .2, nonresponse = 0) {
  objective <- match.arg(objective)
  alternative <- match.arg(alternative)
  recruitment <- match.arg(recruitment)
  ss_prob(auc, "auc")
  ss_assert(ratio, "ratio", 0, Inf, TRUE)
  ss_nonresponse(nonresponse)
  if (recruitment == "population") ss_prob(prevalence, "prevalence")
  estimation <- objective == "estimate"
  if (estimation) {
    ss_assert(precision, "precision", 0, 1, TRUE, TRUE)
    z <- ss_z(confidence)
  } else {
    ss_assert(alpha, "alpha", 0, .5, TRUE, TRUE)
    ss_assert(power, "power", .5, 1, TRUE, TRUE)
    if (objective == "test") ss_prob(null_auc, "null_auc")
    else ss_prob(auc2, "auc2")
    if (objective == "independent") ss_assert(cohort_ratio, "cohort_ratio", 0, Inf, TRUE)
    if (objective == "paired") ss_assert(auc_correlation, "auc_correlation", -1, 1, TRUE, TRUE)
  }
  n_at <- function(cases) {
    cases <- max(2, cases)
    controls <- max(2, ceiling(cases * ratio))
    if (objective == "independent") {
      c(cases, controls, max(2, ceiling(cases * cohort_ratio)),
        max(2, ceiling(cases * cohort_ratio * ratio)))
    } else c(cases, controls)
  }
  variance_at <- function(ns, hypothesized = FALSE) {
    aa <- if (hypothesized && objective == "test") null_auc else auc
    v1 <- ss_auc_variance(aa, ns[1], ns[2])
    if (objective == "test" || objective == "estimate") return(v1)
    if (objective == "independent") {
      v2 <- ss_auc_variance(if (hypothesized) (auc + auc2) / 2 else auc2,
                            ns[3], ns[4])
      if (hypothesized) v1 <- ss_auc_variance((auc + auc2) / 2, ns[1], ns[2])
      return(v1 + v2)
    }
    v2 <- ss_auc_variance(if (hypothesized) (auc + auc2) / 2 else auc2,
                          ns[1], ns[2])
    if (hypothesized) v1 <- ss_auc_variance((auc + auc2) / 2, ns[1], ns[2])
    v1 + v2 - 2 * auc_correlation * sqrt(v1 * v2)
  }
  effect <- if (objective %in% c("independent", "paired")) auc - auc2 else auc - null_auc
  power_at <- function(ns) ss_normal_power(effect,
    sqrt(variance_at(ns, TRUE)), sqrt(variance_at(ns, FALSE)), alpha, alternative)
  if (!estimation && (effect == 0 ||
      (alternative == "greater" && effect <= 0) ||
      (alternative == "less" && effect >= 0))) {
    stop("Anticipated AUC difference must satisfy the selected alternative.", call. = FALSE)
  }
  minimum <- ss_search_count(function(m) {
    ns <- n_at(m)
    if (estimation) z * sqrt(variance_at(ns)) <= precision
    else power_at(ns) >= power
  }, minimum = 2L)
  ns <- n_at(minimum)
  if (objective == "independent") {
    cc1 <- ss_strata_counts(ns[1], ns[2], prevalence, nonresponse, recruitment)
    cc2 <- ss_strata_counts(ns[3], ns[4], prevalence, nonresponse, recruitment)
    complete <- unname(cc1[1] + cc2[1])
    recruited <- unname(cc1[2] + cc2[2])
  } else {
    cc <- ss_strata_counts(ns[1], ns[2], prevalence, nonresponse, recruitment)
    complete <- unname(cc[1])
    recruited <- unname(cc[2])
  }
  se <- sqrt(variance_at(ns, FALSE))
  achieved <- if (estimation) NULL else power_at(ns)
  frm <- "V(A;m,n)=\\frac{A(1-A)+(m-1)(Q_1-A^2)+(n-1)(Q_2-A^2)}{mn},\\quad Q_1=\\frac{A}{2-A},\\quad Q_2=\\frac{2A^2}{1+A}"
  f2 <- if (estimation) {
    "n:Z_{1-\\alpha/2}\\sqrt{V(A;m,n)}\\le d"
  } else if (alternative == "two.sided") {
    "P=\\Phi((D-z_{1-\\alpha/2}s_0)/s_1)+\\Phi((-D-z_{1-\\alpha/2}s_0)/s_1)"
  } else "P=\\Phi((tD-z_{1-\\alpha}s_0)/s_1)"
  fcmp <- if (objective == "independent") {
    "V_D=V(A_1;m_1,n_1)+V(A_2;m_2,n_2)"
  } else if (objective == "paired") {
    "V_D=V(A_1;m,n)+V(A_2;m,n)-2\\rho\\sqrt{V(A_1;m,n)V(A_2;m,n)}"
  } else character()
  substitutions <- c(paste0("m_1=", ns[1], ",\\quad n_1=", ns[2]),
    if (length(ns) == 4L) paste0("m_2=", ns[3], ",\\quad n_2=", ns[4]),
    paste0("SE=\\sqrt{", ss_fmt(variance_at(ns, FALSE)), "}=", ss_fmt(se)),
    if (estimation) paste0("d_{achieved}=", ss_fmt(z), "\\times", ss_fmt(se),
                            "=", ss_fmt(z * se)) else paste0("P_{achieved}=", ss_fmt(achieved)),
    paste0("N_{complete}=", complete, ",\\quad N_{final}=", recruited))
  ss_new(paste("ROC AUC:", objective), "auc", complete, recruited,
    c(frm, fcmp, f2), substitutions,
    c(cases_1 = ns[1], controls_1 = ns[2],
      if (length(ns) == 4L) c(cases_2 = ns[3], controls_2 = ns[4]),
      if (estimation) c(achieved_half_width = z * se) else c(achieved_power = achieved),
      complete = complete, recruitment = recruited),
    c("Full ROC AUC; Hanley-McNeil variance approximation and normal testing. Not DeLong or partial-AUC planning.",
      "Diseased and non-diseased strata are independently sampled, with an appropriate reference standard.",
      "For paired comparisons rho is the correlation between estimated AUCs, held fixed as sample size changes.",
      "Population recruitment based on prevalence is an expectation, not a guaranteed disease-stratum count."),
    ss_refs$auc,
    list(auc = auc, objective = objective, auc2 = if (objective %in% c("independent", "paired")) auc2 else NULL,
      null_auc = if (objective == "test") null_auc else NULL,
      auc_correlation = if (objective == "paired") auc_correlation else NULL,
      cases = ns[1], controls = ns[2], strata = ns,
      achieved_power = achieved, achieved_precision = if (estimation) z * se else NULL,
      nonresponse = nonresponse, recruitment_mode = recruitment,
      prevalence = if (recruitment == "population") prevalence else NULL),
    if (estimation && (auc - z * se < 0 || auc + z * se > 1)) {
      "Anticipated untransformed normal confidence interval extends beyond [0,1]."
    } else character())
}

ss_wilson_halfwidth <- function(p, n, confidence) {
  z <- ss_z(confidence)
  z * sqrt(p * (1 - p) / n + z^2 / (4 * n^2)) / (1 + z^2 / n)
}

#' Sample size for sensitivity and specificity precision or benchmark tests
#'
#' @param objective `"sensitivity"`, `"specificity"`, `"joint"`,
#'   `"test_sensitivity"` or `"test_specificity"`.
#' @param sensitivity,specificity Anticipated diagnostic accuracy fractions.
#' @param precision_sens,precision_spec Desired CI half-widths.
#' @param confidence Confidence for interval planning.
#' @param interval Expected-interval method, `"wilson"` or `"wald"`.
#' @param benchmark Null sensitivity or specificity for hypothesis testing.
#' @param alpha,power,alternative Test-planning parameters.
#' @param recruitment `"population"` (using `prevalence`) or `"separate"`
#'   disease-status quotas.
#' @param prevalence Expected disease prevalence in the recruitment population.
#' @param nonresponse Anticipated fraction without analysable data.
#' @return An `aiims_ss` object. Joint planning does not ensure simultaneous CI coverage.
#' @examples
#' ss_diagnostic(objective = "joint", sensitivity = .85, specificity = .9)
#' @export
ss_diagnostic <- function(objective = c("sensitivity", "specificity", "joint",
                                    "test_sensitivity", "test_specificity"),
                          sensitivity = .85, specificity = .90,
                          precision_sens = .05, precision_spec = .05,
                          confidence = .95, interval = c("wilson", "wald"),
                          benchmark = .7, alpha = .05, power = .8,
                          alternative = c("greater", "two.sided", "less"),
                          recruitment = c("population", "separate"),
                          prevalence = .2, nonresponse = 0) {
  objective <- match.arg(objective)
  interval <- match.arg(interval)
  alternative <- match.arg(alternative)
  recruitment <- match.arg(recruitment)
  ss_nonresponse(nonresponse)
  sens <- objective %in% c("sensitivity", "joint", "test_sensitivity")
  spec <- objective %in% c("specificity", "joint", "test_specificity")
  estimation <- !startsWith(objective, "test_")
  if (sens) ss_prob(sensitivity, "sensitivity")
  if (spec) ss_prob(specificity, "specificity")
  if (recruitment == "population") ss_prob(prevalence, "prevalence")
  if (estimation) {
    z <- ss_z(confidence)
    half <- function(p, n) if (interval == "wilson") {
      ss_wilson_halfwidth(p, n, confidence)
    } else z * sqrt(p * (1 - p) / n)
    n_sens <- if (sens) {
      ss_assert(precision_sens, "precision_sens", 0, 1, TRUE, TRUE)
      ss_search_count(function(n) half(sensitivity, n) <= precision_sens)
    } else 0
    n_spec <- if (spec) {
      ss_assert(precision_spec, "precision_spec", 0, 1, TRUE, TRUE)
      ss_search_count(function(n) half(specificity, n) <= precision_spec)
    } else 0
    achieved <- NULL
    frm <- if (interval == "wald") {
      "n=\\frac{Z_{1-\\alpha/2}^2p(1-p)}{d^2}"
    } else "h(n)=\\frac{z\\sqrt{p(1-p)/n+z^2/(4n^2)}}{1+z^2/n}\\le d"
  } else {
    ss_prob(benchmark, "benchmark")
    ss_assert(alpha, "alpha", 0, .5, TRUE, TRUE)
    ss_assert(power, "power", .5, 1, TRUE, TRUE)
    p <- if (sens) sensitivity else specificity
    effect <- p - benchmark
    if (effect == 0 || (alternative == "greater" && effect <= 0) ||
        (alternative == "less" && effect >= 0)) {
      stop("Anticipated accuracy must satisfy selected benchmark hypothesis.", call. = FALSE)
    }
    pow <- function(n) ss_normal_power(effect,
      sqrt(benchmark * (1 - benchmark) / n), sqrt(p * (1 - p) / n),
      alpha, alternative)
    n_required <- ss_search_count(function(n) pow(n) >= power)
    n_sens <- if (sens) n_required else 0
    n_spec <- if (spec) n_required else 0
    achieved <- pow(n_required)
    frm <- "s_0=\\sqrt{p_0(1-p_0)/n},\\quad s_1=\\sqrt{p_1(1-p_1)/n}"
  }
  if (recruitment == "population") {
    complete <- ceiling(max(if (n_sens) n_sens / prevalence else 0,
                            if (n_spec) n_spec / (1 - prevalence) else 0))
    recruited <- ceiling(complete / (1 - nonresponse))
  } else {
    complete <- n_sens + n_spec
    recruited <- ceiling(n_sens / (1 - nonresponse)) +
      ceiling(n_spec / (1 - nonresponse))
  }
  ss_new(paste("Diagnostic accuracy:", objective), "diagnostic", complete, recruited,
    c(frm, if (recruitment == "population") "N=\\max(n_D/\\pi,n_{ND}/(1-\\pi))"),
    c(paste0("n_D=", n_sens, ",\\quad n_{ND}=", n_spec),
      if (estimation && sens) paste0("h_{Se}=", ss_fmt(half(sensitivity, n_sens))),
      if (estimation && spec) paste0("h_{Sp}=", ss_fmt(half(specificity, n_spec))),
      if (!estimation) paste0("P_{achieved}=", ss_fmt(achieved)),
      paste0("N_{complete}=", complete, ",\\quad N_{final}=", recruited)),
    c(cases = n_sens, noncases = n_spec,
      if (!estimation) c(achieved_power = achieved),
      complete = complete, recruitment = recruited),
    c("Sensitivity is conditional on disease and specificity on non-disease, as defined by the reference standard.",
      "Wilson planning uses anticipated confidence-interval half-width, not guaranteed realised precision.",
      "Wald or normal score testing is approximate; for sparse counts use simulation or exact binomial planning.",
      "Joint planning applies individual confidence levels, not simultaneous coverage.",
      "Population recruitment requires monitoring of realised disease-status counts."),
    c(ss_refs$diagnostic, ss_refs$wilson),
    list(objective = objective, cases = n_sens, controls = n_spec,
      achieved_power = achieved, interval = if (estimation) interval else NULL,
      recruitment_mode = recruitment, nonresponse = nonresponse,
      prevalence = if (recruitment == "population") prevalence else NULL),
    if (!estimation && min(n_required * c(p, 1 - p, benchmark, 1 - benchmark)) < 10) {
      "Expected count below 10 under one planning hypothesis; normal approximation may be unreliable."
    } else character())
}

#' Sample size for Pearson correlation estimation and hypothesis testing
#'
#' @param r Anticipated Pearson correlation coefficient.
#' @param objective `"test"`, `"estimate"` or `"independent"`.
#' @param r0 Null correlation (one-sample test).
#' @param r2 Anticipated second-population correlation (independent comparison).
#' @param precision Desired CI half-width, on correlation or Fisher-z scale.
#' @param precision_scale `"correlation"` or `"fisher"`.
#' @param confidence Confidence for precision planning.
#' @param alpha,power,alternative Hypothesis-test planning parameters.
#' @param ratio Anticipated population-2 to population-1 allocation ratio.
#' @param nonresponse Non-response fraction.
#' @return An `aiims_ss` object using uncorrected Fisher z transformation.
#' @examples
#' ss_correlation(r = .3, objective = "test")
#' @export
ss_correlation <- function(r = .3, objective = c("test", "estimate", "independent"),
                           r0 = 0, r2 = .1, precision = .1,
                           precision_scale = c("correlation", "fisher"),
                           confidence = .95, alpha = .05, power = .8,
                           alternative = c("two.sided", "greater", "less"),
                           ratio = 1, nonresponse = 0) {
  objective <- match.arg(objective)
  precision_scale <- match.arg(precision_scale)
  alternative <- match.arg(alternative)
  ss_assert(r, "r", -1, 1, TRUE, TRUE)
  ss_nonresponse(nonresponse)
  estimation <- objective == "estimate"
  if (objective == "test") ss_assert(r0, "r0", -1, 1, TRUE, TRUE)
  if (objective == "independent") {
    ss_assert(r2, "r2", -1, 1, TRUE, TRUE)
    ss_assert(ratio, "ratio", 0, Inf, TRUE)
  }
  z1 <- atanh(r)
  z2 <- if (objective == "independent") atanh(r2) else atanh(r0)
  if (estimation) {
    ss_assert(precision, "precision", 0, if (precision_scale == "correlation") 1 else Inf, TRUE)
    zcrit <- ss_z(confidence)
  } else {
    ss_assert(alpha, "alpha", 0, .5, TRUE, TRUE)
    ss_assert(power, "power", .5, 1, TRUE, TRUE)
  }
  sizes_at <- function(n) if (objective == "independent") {
    c(n, max(4, ceiling(n * ratio)))
  } else c(n)
  se_at <- function(ns) sqrt(1 / (ns[1] - 3) +
                               if (length(ns) == 2L) 1 / (ns[2] - 3) else 0)
  precision_at <- function(n) {
    se <- 1 / sqrt(n - 3)
    if (precision_scale == "fisher") return(zcrit * se)
    diff(tanh(z1 + c(-1, 1) * zcrit * se)) / 2
  }
  effect <- z1 - z2
  pow_at <- function(ns) ss_normal_power(effect, se_at(ns), se_at(ns),
                                         alpha, alternative)
  if (!estimation && (effect == 0 || (alternative == "greater" && effect <= 0) ||
      (alternative == "less" && effect >= 0))) {
    stop("Fisher-z difference must satisfy the selected alternative.", call. = FALSE)
  }
  base <- ss_search_count(function(n) {
    if (estimation) precision_at(n) <= precision
    else pow_at(sizes_at(n)) >= power
  }, minimum = 4L)
  ns <- sizes_at(base)
  complete <- sum(ns)
  recruited <- sum(ceiling(ns / (1 - nonresponse)))
  se <- se_at(ns)
  achieved <- if (estimation) NULL else pow_at(ns)
  ss_new(paste("Pearson correlation:", objective), "correlation", complete, recruited,
    c("z(r)=\\operatorname{atanh}(r)=\\frac{1}{2}\\log\\frac{1+r}{1-r}",
      if (objective == "independent") "SE=\\sqrt{1/(n_1-3)+1/(n_2-3)}" else "SE=1/\\sqrt{n-3}",
      if (estimation) "CI_r=\\tanh[z(r)\\pm Z_{1-\\alpha/2}/\\sqrt{n-3}]" else
        "P=\\Phi(D/SE-z_{1-\\alpha/2})+\\Phi(-D/SE-z_{1-\\alpha/2})"),
    c(paste0("z(r)=\\operatorname{atanh}(", ss_fmt(r), ")=", ss_fmt(z1)),
      paste0("n_1=", ns[1], if (length(ns) == 2L) paste0(",\\quad n_2=", ns[2]) else ""),
      paste0("SE=", ss_fmt(se)),
      if (estimation) paste0("d_{achieved}=", ss_fmt(precision_at(base))) else
        paste0("P_{achieved}=", ss_fmt(achieved)),
      paste0("N_{final}=", recruited)),
    c(if (length(ns) == 2L) c(group1_complete = ns[1], group2_complete = ns[2])
      else c(complete = ns[1]),
      if (!estimation) c(achieved_power = achieved),
      recruitment = recruited),
    c("Independent participant pairs with approximate bivariate normality.",
      "Uncorrected Fisher z variance of 1/(n-3); not exact Pearson t-test power.",
      "Independent group correlations assume independent populations. Dependent correlations are not supported.",
      "Correlation-scale precision uses half of total expected interval width, not a symmetric interval around r."),
    ss_refs$correlation,
    list(r = r, objective = objective, n1 = ns[1],
      n2 = if (length(ns) == 2L) ns[2] else NULL,
      achieved_power = achieved,
      achieved_precision = if (estimation) precision_at(base) else NULL,
      interval = if (estimation) tanh(z1 + c(-1, 1) * zcrit / sqrt(base - 3)) else NULL,
      nonresponse = nonresponse))
}
