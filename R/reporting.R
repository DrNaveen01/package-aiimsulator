#' Extract general and numerically substituted equations
#'
#' @param x An `aiims_ss` object.
#' @param which `"formula"`, `"substituted_values"`, or `"both"`.
#' @param format `"markdown"` for Quarto/Markdown math blocks, `"latex"` for
#'   LaTeX display math, or `"text"` for raw TeX equation strings.
#' @return Character string ready for inline printing or `cat()`.
#' @examples
#' x <- ss_proportion(.5, .05)
#' cat(ss_equation(x, "both", "markdown"))
#' @export
ss_equation <- function(x, which = c("formula", "substituted_values", "both"),
                        format = c("markdown", "latex", "text")) {
  if (!inherits(x, "aiims_ss")) stop("x must be an aiims_ss object.", call. = FALSE)
  which <- match.arg(which)
  format <- match.arg(format)
  equations <- c(if (which %in% c("formula", "both")) x$formula,
                 if (which %in% c("substituted_values", "both")) x$substituted_values)
  if (format == "text") return(paste(equations, collapse = "\n"))
  if (format == "markdown") {
    paste(paste0("$$\n", equations, "\n$$"), collapse = "\n\n")
  } else paste(paste0("\\[\n", equations, "\n\\]"), collapse = "\n\n")
}

ss_latex_escape <- function(s) {
  vapply(s, function(value) {
    chars <- strsplit(value, "", fixed = TRUE)[[1]]
    map <- c("%" = "\\%", "_" = "\\_", "#" = "\\#", "&" = "\\&",
             "$" = "\\$", "{" = "\\{", "}" = "\\}")
    paste0(vapply(chars, function(ch) if (ch %in% names(map)) map[[ch]] else ch,
                  character(1)), collapse = "")
  }, character(1), USE.NAMES = FALSE)
}

ss_report_result <- function(x) {
  if (x$key %in% c("two_means", "two_proportions")) {
    paste0("Estimated complete sample: ", x$n1, " (", x$group1, ") and ",
           x$n2, " (", x$group2, "); total = ", x$n_complete,
           ". Recruitment target: ", x$final1, " and ", x$final2,
           "; total = ", x$n_final, ". Approximate achieved power = ",
           ss_fmt(100 * x$achieved_power, 4), "%. ")
  } else if (x$key == "auc") {
    paste0("Required complete sample = ", x$n_complete,
           "; recruitment target = ", x$n_final, ". Required reference-standard case and control quotas for the first cohort = ",
           x$cases, " and ", x$controls, ".",
           if (!is.null(x$achieved_power)) paste0(" Approximate achieved power = ", ss_fmt(100 * x$achieved_power, 4), "%."),
           if (!is.null(x$achieved_precision)) paste0(" Approximate CI half-width = ", ss_fmt(x$achieved_precision), "."))
  } else if (x$key == "diagnostic") {
    paste0("Required diseased = ", x$cases, "; non-diseased = ", x$controls,
           "; total complete sample = ", x$n_complete,
           "; recruitment target = ", x$n_final, ".",
           if (!is.null(x$achieved_power)) paste0(" Approximate achieved power = ", ss_fmt(100 * x$achieved_power, 4), "%."))
  } else if (x$key == "correlation") {
    paste0("Required complete sample = ", x$n_complete,
           "; recruitment target = ", x$n_final, ".",
           if (!is.null(x$achieved_power)) paste0(" Approximate achieved power = ", ss_fmt(100 * x$achieved_power, 4), "%."),
           if (!is.null(x$achieved_precision)) paste0(" Approximate CI half-width = ", ss_fmt(x$achieved_precision), "."))
  } else {
    paste0("Required analysable sample = ", x$n_complete,
           "; final recruitment target = ", x$n_final, ".")
  }
}

#' Produce a selective manuscript-ready sample-size report
#'
#' @param x An `aiims_ss` result object.
#' @param formula Include general equations.
#' @param substituted_values Include numerical substitution equations.
#' @param results Include estimated sample size, group sizes, and/or power.
#' @param assumptions Include methodological assumptions.
#' @param references Include the method references.
#' @param warnings Include approximation/feasibility warnings.
#' @param format One of `"markdown"`, `"latex"`, `"text"`.
#' @return One character string. Use `cat()` in a Quarto chunk with
#'   `#| output: asis` to render math and formatted Markdown.
#' @examples
#' x <- ss_proportion(.5, .05, nonresponse = .1)
#' cat(ss_report(x, formula = TRUE, substituted_values = TRUE))
#' cat(ss_report(x, formula = FALSE, substituted_values = FALSE,
#'               results = TRUE, format = "text"))
#' @export
ss_report <- function(x, formula = TRUE, substituted_values = TRUE,
                      results = TRUE, assumptions = FALSE, references = FALSE,
                      warnings = TRUE, format = c("markdown", "latex", "text")) {
  if (!inherits(x, "aiims_ss")) stop("x must be an aiims_ss object.", call. = FALSE)
  format <- match.arg(format)
  selected <- list()
  add <- function(section, text) {
    if (format == "markdown") paste0("### ", section, "\n\n", text)
    else if (format == "latex") paste0("\\subsection*{", section, "}\n", text)
    else paste0(section, "\n", text)
  }
  if (formula) {
    selected <- c(selected, add("General formula",
      ss_equation(x, "formula", format)))
  }
  if (substituted_values) {
    selected <- c(selected, add("Numerical substitution",
      ss_equation(x, "substituted_values", format)))
  }
  if (results) {
    result_text <- ss_report_result(x)
    if (format == "latex") result_text <- ss_latex_escape(result_text)
    selected <- c(selected, add("Sample size result", result_text))
  }
  if (assumptions) {
    entries <- if (format == "latex") ss_latex_escape(x$assumptions) else x$assumptions
    selected <- c(selected, add("Assumptions",
      paste(if (format == "markdown") paste0("- ", entries) else entries,
            collapse = "\n")))
  }
  if (references) {
    entries <- if (format == "latex") ss_latex_escape(x$references) else x$references
    selected <- c(selected, add("Method references",
      paste(if (format == "markdown") paste0("- ", entries) else entries,
            collapse = "\n")))
  }
  if (warnings && length(x$warnings)) {
    entries <- if (format == "latex") ss_latex_escape(x$warnings) else x$warnings
    selected <- c(selected, add("Warnings",
      paste(if (format == "markdown") paste0("- ", entries) else entries,
            collapse = "\n")))
  }
  paste(selected, collapse = "\n\n")
}

#' Convert a calculation to a tidy parameter/result table
#'
#' @param x An `aiims_ss` object.
#' @return Data frame with fields `parameter` and `value`. Rounding is not
#'   applied to numeric quantities in the underlying object.
#' @examples
#' ss_table(ss_mean(12, 3))
#' @export
ss_table <- function(x) {
  if (!inherits(x, "aiims_ss")) stop("x must be an aiims_ss object.", call. = FALSE)
  vals <- x$calculations
  data.frame(parameter = names(vals), value = as.numeric(vals), row.names = NULL)
}

#' @export
as.data.frame.aiims_ss <- function(x, row.names = NULL, optional = FALSE, ...) {
  ss_table(x)
}

#' @export
print.aiims_ss <- function(x, ...) {
  cat(x$method, "\n", ss_report_result(x), "\n", sep = "")
  if (length(x$warnings)) cat("Warnings: ", paste(x$warnings, collapse = " | "), "\n", sep = "")
  invisible(x)
}

#' @export
summary.aiims_ss <- function(object, ...) {
  structure(list(method = object$method, calculation = ss_table(object),
                 assumptions = object$assumptions,
                 references = object$references,
                 warnings = object$warnings), class = "summary.aiims_ss")
}

#' @export
print.summary.aiims_ss <- function(x, ...) {
  cat(x$method, "\n\n")
  print(x$calculation, row.names = FALSE)
  cat("\nAssumptions:\n", paste0("- ", x$assumptions, collapse = "\n"), "\n", sep = "")
  if (length(x$warnings)) cat("\nWarnings:\n", paste0("- ", x$warnings, collapse = "\n"), "\n", sep = "")
  invisible(x)
}
