#' Sample size for estimating a single population proportion
#'
#' @param p Anticipated prevalence (fraction, not percentage).
#' @param precision Desired absolute margin of error or relative fraction of p.
#' @param confidence Confidence level, as a fraction.
#' @param precision_type `"absolute"` or `"relative"`.
#' @param nonresponse Anticipated fraction without analysable data.
#' @param design_effect Optional known design effect; alternatively supply `icc`
#'   and `cluster_size`.
#' @param icc Intracluster correlation (for equal or approximately equal clusters).
#' @param cluster_size Mean observations per cluster.
#' @param cv_cluster_size Coefficient of variation in cluster sizes.
#' @param population Optional finite population size (simple random sampling
#'   without replacement only). Design-effect plus FPC uses an approximation.
#' @return An `aiims_ss` object containing full precision results and equations.
#' @examples
#' ss_proportion(p = .5, precision = .05, nonresponse = .1)
#' @export
ss_proportion <- function(p, precision, confidence = 0.95,
                          precision_type = c("absolute", "relative"),
                          nonresponse = 0, design_effect = NULL,
                          icc = NULL, cluster_size = NULL,
                          cv_cluster_size = 0, population = NULL) {
  precision_type <- match.arg(precision_type)
  ss_prob(p, "p")
  ss_assert(precision, "precision", 0, 1, TRUE)
  z <- ss_z(confidence)
  d <- if (precision_type == "relative") p * precision else precision
  base <- z^2 * p * (1 - p) / d^2
  deff <- ss_design_effect(design_effect, icc, cluster_size, cv_cluster_size)
  a <- ss_adjust(base, nonresponse, deff, population)
  de <- ss_deff_equations(design_effect, icc, cluster_size, cv_cluster_size, deff)
  details <- list(p = p, precision = precision, precision_type = precision_type,
                  d = d, confidence = confidence, z = z, n0 = base,
                  n_adjusted = a$after_fpc, design_effect = deff,
                  population = population, nonresponse = nonresponse)
  warnings <- character()
  if (a$n_complete * p < 10 || a$n_complete * (1 - p) < 10) {
    warnings <- c(warnings, "Normal approximation may be inadequate: an expected cell count is below 10.")
  }
  if (!is.null(population) && !is.null(design_effect)) {
    warnings <- c(warnings, "Combining a design effect with SRS finite-population correction is approximate; validate complex design variance independently.")
  }
  if (!is.null(population) && a$n_final > population) {
    warnings <- c(warnings, "Recruitment target exceeds the finite population; the target is infeasible under the assumed non-response rate.")
  }
  ss_new("Single proportion: Wald normal precision", "proportion",
    a$n_complete, a$n_final,
    c("n_0=\\frac{Z_{1-\\alpha/2}^{2}p(1-p)}{d^{2}}",
      de$formulas,
      if (deff != 1) "n_{DEFF}=n_0\\times DEFF",
      if (!is.null(population)) {
        if (deff == 1) "n_{FPC}=\\frac{n_0}{1+(n_0-1)/N}"
        else "n_{FPC}=\\frac{n_{DEFF}}{1+(n_{DEFF}-1)/N}"
      },
      paste0("n_{final}=\\left\\lceil\\frac{",
        if (!is.null(population)) "n_{FPC}" else if (deff != 1) "n_{DEFF}" else "n_0",
        "}{1-r}\\right\\rceil")),
    c(paste0("n_0=\\frac{", ss_fmt(z), "^{2}\\times", ss_fmt(p), "\\times(1-", ss_fmt(p),
             ")}{", ss_fmt(d), "^{2}}=", ss_fmt(base)),
      de$substituted, ss_adjust_lines(a, nonresponse)),
    c(n0 = base, after_design_effect = a$after_design, after_fpc = a$after_fpc,
      complete = a$n_complete, recruitment = a$n_final),
    c("Independent observations for the base formula; a normal approximation to the binomial distribution.",
      "Precision is an absolute half-width on the proportion scale; relative precision is multiplied by anticipated p.",
      "Design-effect inflation assumes an appropriate design variance model. SRS FPC assumes sampling without replacement.",
      "All adjustments are performed before final upward rounding."), ss_refs$estimation,
    details, warnings)
}

#' Sample size for estimating a single population mean
#'
#' @param sd Anticipated population standard deviation.
#' @param precision Desired absolute margin of error in outcome units.
#' @param confidence Two-sided confidence level.
#' @param nonresponse Anticipated fraction without analysable data.
#' @param design_effect Optional known design effect.
#' @param icc,cluster_size,cv_cluster_size Optional cluster planning parameters.
#' @param population Optional finite sampling frame size for simple random sampling
#'   without replacement.
#' @return An `aiims_ss` object.
#' @examples
#' ss_mean(sd = 12, precision = 3)
#' @export
ss_mean <- function(sd, precision, confidence = 0.95,
                    nonresponse = 0, design_effect = NULL,
                    icc = NULL, cluster_size = NULL,
                    cv_cluster_size = 0, population = NULL) {
  ss_assert(sd, "sd", 0, Inf, TRUE)
  ss_assert(precision, "precision", 0, Inf, TRUE)
  z <- ss_z(confidence)
  base <- (z * sd / precision)^2
  deff <- ss_design_effect(design_effect, icc, cluster_size, cv_cluster_size)
  a <- ss_adjust(base, nonresponse, deff, population)
  de <- ss_deff_equations(design_effect, icc, cluster_size, cv_cluster_size, deff)
  warnings <- if (a$n_complete < 30) {
    "Small sample: consider a t-based approach if the SD is estimated rather than known."
  } else character()
  if (!is.null(population) && a$n_final > population) warnings <- c(warnings, "Recruitment target exceeds the finite population.")
  ss_new("Single mean: normal precision", "mean", a$n_complete, a$n_final,
    c("n_0=\\left(\\frac{Z_{1-\\alpha/2}\\sigma}{d}\\right)^2",
      de$formulas,
      if (deff != 1) "n_{DEFF}=n_0\\times DEFF",
      if (!is.null(population)) {
        if (deff == 1) "n_{FPC}=\\frac{n_0}{1+(n_0-1)/N}"
        else "n_{FPC}=\\frac{n_{DEFF}}{1+(n_{DEFF}-1)/N}"
      },
      paste0("n_{final}=\\left\\lceil\\frac{",
        if (!is.null(population)) "n_{FPC}" else if (deff != 1) "n_{DEFF}" else "n_0",
        "}{1-r}\\right\\rceil")),
    c(paste0("n_0=\\left(\\frac{", ss_fmt(z), "\\times", ss_fmt(sd), "}{", ss_fmt(precision),
             "}\\right)^2=", ss_fmt(base)),
      de$substituted, ss_adjust_lines(a, nonresponse)),
    c(n0 = base, after_design_effect = a$after_design, after_fpc = a$after_fpc,
      complete = a$n_complete, recruitment = a$n_final),
    c("Normal precision formula with a prespecified standard deviation.",
      "Optional design effect and finite-population correction require an appropriate sampling design."),
    ss_refs$estimation,
    list(sd = sd, precision = precision, confidence = confidence, z = z, n0 = base,
         n_adjusted = a$after_fpc, design_effect = deff,
         population = population, nonresponse = nonresponse), warnings)
}

#' Taro Yamane simplified finite-population sample size
#'
#' @param population Whole-number population size.
#' @param precision Desired simplified precision fraction.
#' @param nonresponse Non-response fraction.
#' @return An `aiims_ss` object. This is a simplified heuristic and should
#'   not substitute for an explicitly justified precision calculation.
#' @examples
#' ss_yamane(1500)
#' @export
ss_yamane <- function(population, precision = 0.05, nonresponse = 0) {
  ss_integer(population, "population", 1)
  ss_prob(precision, "precision")
  ss_nonresponse(nonresponse)
  base <- population / (1 + population * precision^2)
  total <- ceiling(base / (1 - nonresponse))
  ss_check_n(total)
  warnings <- if (total > population) "The target exceeds the population size." else character()
  ss_new("Yamane simplified finite-population formula", "yamane",
    ceiling(base), total, "n_0=\\frac{N}{1+Ne^2}",
    c(paste0("n_0=\\frac{", population, "}{1+", population, "\\times", ss_fmt(precision),
             "^2}=", ss_fmt(base)),
      paste0("n_{final}=\\left\\lceil", ss_fmt(base), "/(1-", ss_fmt(nonresponse),
             ")\\right\\rceil=", total)),
    c(n0 = base, complete = ceiling(base), recruitment = total),
    c("Simplified finite-population expression; it does not explicitly accept a prevalence estimate or arbitrary confidence level.",
      "Use a design-specific derivation when valid population variance information is available."),
    "Yamane T. Statistics: An Introductory Analysis. 2nd ed. Harper and Row; 1967.",
    list(population = population, precision = precision,
         nonresponse = nonresponse, n0 = base), warnings)
}
