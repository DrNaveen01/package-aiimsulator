1# All calculations use proportions in [0,1], not percentages.
ss_assert <- function(x, label, lower = -Inf, upper = Inf,
                      lower_open = FALSE, upper_open = FALSE) {
  if (!is.numeric(x) || length(x) != 1L || is.na(x) || !is.finite(x)) {
    stop(label, " must be a single finite numeric value.", call. = FALSE)
  }
  if (if (lower_open) x <= lower else x < lower) {
    stop(label, " must be ", if (lower_open) "greater than " else "at least ", lower, ".", call. = FALSE)
  }
  if (if (upper_open) x >= upper else x > upper) {
    stop(label, " must be ", if (upper_open) "less than " else "at most ", upper, ".", call. = FALSE)
  }
  invisible(x)
}
ss_prob <- function(x, name) ss_assert(x, name, 0, 1, TRUE, TRUE)
ss_nonresponse <- function(x) ss_assert(x, "nonresponse", 0, 1, FALSE, TRUE)
ss_integer <- function(x, name, minimum = 1) {
  ss_assert(x, name, minimum, 2^53 - 1)
  if (x != floor(x)) stop(name, " must be an integer.", call. = FALSE)
  invisible(x)
}
ss_check_n <- function(x) {
  if (any(!is.finite(x)) || any(x <= 0) || any(x > 2^53 - 1)) {
    stop("Sample size is outside the supported numeric range.", call. = FALSE)
  }
  invisible(x)
}
ss_fmt <- function(x, digits = 6L) {
  if (is.null(x)) return("NA")
  format(signif(x, digits), scientific = FALSE, trim = TRUE)
}
ss_z <- function(confidence) {
  ss_prob(confidence, "confidence")
  stats::qnorm((1 + confidence) / 2)
}
ss_check_name <- function(x, label) {
  if (!is.character(x) || length(x) != 1L || is.na(x) ||
      !nzchar(trimws(x)) || nchar(x) > 100 || grepl("[[:cntrl:]]", x)) {
    stop(label, " must be single-line text with 1 to 100 characters.", call. = FALSE)
  }
  trimws(x)
}
ss_new <- function(method, key, complete, recruitment, formula, substituted_values,
                   calculations, assumptions, references, details = list(), warnings = character()) {
  ss_check_n(c(complete, recruitment))
  structure(c(list(method = method, key = key,
    n_complete = as.numeric(complete), n_final = as.numeric(recruitment),
    formula = formula, substituted_values = substituted_values,
    calculations = calculations, assumptions = assumptions,
    references = references, warnings = warnings), details), class = "aiims_ss")
}
ss_adjust <- function(base, nonresponse, design_effect = NULL,
                      population = NULL, allow_fpc = TRUE) {
  ss_check_n(base)
  ss_nonresponse(nonresponse)
  deff <- ss_design_effect(design_effect = design_effect)
  inflated <- base * deff
  adjusted <- if (is.null(population)) inflated else {
    if (!allow_fpc) stop("Finite-population correction is not implemented for this comparison design.", call. = FALSE)
    ss_fpc(inflated, population)
  }
  required <- ceiling(adjusted)
  final <- ceiling(adjusted / (1 - nonresponse))
  ss_check_n(c(inflated, adjusted, required, final))
  list(base = base, design_effect = deff, after_design = inflated,
       population = population, after_fpc = adjusted,
       n_complete = required, n_final = final)
}
ss_adjust_lines <- function(a, nonresponse) {
  out <- character()
  if (a$design_effect != 1) {
    out <- c(out, paste0("n_{DEFF}=", ss_fmt(a$base), "\\times", ss_fmt(a$design_effect),
                         "=", ss_fmt(a$after_design)))
  }
  if (!is.null(a$population)) {
    out <- c(out, paste0("n_{FPC}=\\frac{", ss_fmt(a$after_design),
                         "}{1+(", ss_fmt(a$after_design), "-1)/", ss_fmt(a$population),
                         "}=", ss_fmt(a$after_fpc)))
  }
  if (nonresponse > 0) {
    out <- c(out, paste0("n_{final}=\\left\\lceil\\frac{", ss_fmt(a$after_fpc),
                         "}{1-", ss_fmt(nonresponse), "}\\right\\rceil=", a$n_final))
  } else out <- c(out, paste0("n_{final}=\\lceil", ss_fmt(a$after_fpc),
                                "\\rceil=", a$n_final))
  out
}
ss_normal_power <- function(effect, se_null, se_alt, alpha, alternative = "two.sided") {
  alternative <- match.arg(alternative, c("two.sided", "greater", "less"))
  if (se_null <= 0 || se_alt <= 0) stop("Standard errors must be positive.", call. = FALSE)
  za <- stats::qnorm(1 - alpha / if (alternative == "two.sided") 2 else 1)
  if (alternative == "two.sided") {
    stats::pnorm((effect - za * se_null) / se_alt) +
      stats::pnorm((-effect - za * se_null) / se_alt)
  } else {
    stats::pnorm((if (alternative == "greater") effect else -effect) / se_alt - za * se_null / se_alt)
  }
}
ss_search_count <- function(predicate, minimum = 2L, maximum = 100000000L) {
  if (!isTRUE(predicate(maximum))) {
    stop("Required sample size exceeds 100 million.", call. = FALSE)
  }
  low <- minimum - 1L
  high <- minimum
  while (!isTRUE(predicate(high))) {
    low <- high
    high <- min(maximum, high * 2L)
  }
  while (high - low > 1) {
    mid <- floor((high + low) / 2)
    if (isTRUE(predicate(mid))) high <- mid else low <- mid
  }
  high
}
ss_refs <- list(
  estimation = "Cochran WG. Sampling Techniques. 3rd ed. Wiley; 1977.",
  two_group = "Chow SC, Shao J, Wang H, Lokhnygina Y. Sample Size Calculations in Clinical Research. 3rd ed. CRC Press; 2017.",
  auc = "Hanley JA, McNeil BJ. Radiology. 1982;143(1):29-36. doi:10.1148/radiology.143.1.7063747",
  diagnostic = "Buderer NM. Acad Emerg Med. 1996;3(9):895-900. doi:10.1111/j.1553-2712.1996.tb03538.x",
  wilson = "Wilson EB. J Am Stat Assoc. 1927;22(158):209-212. doi:10.1080/01621459.1927.10502953",
  correlation = "Fisher RA. Metron. 1921;1:3-32."
)
