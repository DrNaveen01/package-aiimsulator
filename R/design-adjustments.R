#' Compute a design effect
#'
#' @param design_effect Optional supplied design effect (strictly positive).
#' @param icc Optional intra-cluster correlation (0 to 1).
#' @param cluster_size Expected mean cluster size (at least 1).
#' @param cv_cluster_size Coefficient of variation of cluster sizes. The
#'   unequal-cluster-size approximation is applied when greater than zero.
#' @return Numeric design effect. When no adjustment is requested, returns 1.
#' @examples
#' ss_design_effect(icc = 0.02, cluster_size = 20)
#' @export
ss_design_effect <- function(design_effect = NULL, icc = NULL,
                             cluster_size = NULL, cv_cluster_size = 0) {
  if (!is.null(design_effect)) {
    if (!is.null(icc) || !is.null(cluster_size)) {
      stop("Provide either design_effect or icc with cluster_size, not both.", call. = FALSE)
    }
    ss_assert(design_effect, "design_effect", 0, Inf, TRUE)
    return(design_effect)
  }
  if (is.null(icc) && is.null(cluster_size)) {
    if (cv_cluster_size != 0) stop("cv_cluster_size requires icc and cluster_size.", call. = FALSE)
    return(1)
  }
  if (is.null(icc) || is.null(cluster_size)) {
    stop("icc and cluster_size must be provided together.", call. = FALSE)
  }
  ss_assert(icc, "icc", 0, 1)
  ss_assert(cluster_size, "cluster_size", 1, Inf)
  ss_assert(cv_cluster_size, "cv_cluster_size", 0, Inf)
  1 + ((1 + cv_cluster_size^2) * cluster_size - 1) * icc
}

#' Apply the finite population correction to an unrounded sample size
#'
#' @param n Unrounded sample size under sampling with replacement / an infinite population.
#' @param population Finite population size.
#' @return Unrounded corrected sample size. Uses `n / (1 + (n - 1) / N)`;
#'   appropriate for simple random sampling without replacement. Not a general
#'   adjustment for clinical trials or complex multistage designs.
#' @examples
#' ss_fpc(384.1459, population = 1000)
#' @export
ss_fpc <- function(n, population) {
  ss_assert(n, "n", 0, Inf, TRUE)
  ss_integer(population, "population", minimum = 1)
  n / (1 + (n - 1) / population)
}

ss_deff_equations <- function(design_effect, icc, cluster_size,
                              cv_cluster_size, deff) {
  if (!is.null(design_effect)) {
    return(list(formulas = "DEFF=DEFF_{supplied}",
                substituted = paste0("DEFF=", ss_fmt(deff))))
  }
  if (!is.null(icc)) {
    if (cv_cluster_size == 0) {
      return(list(formulas = "DEFF=1+(m-1)\\rho",
                  substituted = paste0("DEFF=1+(", ss_fmt(cluster_size),
                    "-1)\\times", ss_fmt(icc), "=", ss_fmt(deff))))
    }
    return(list(formulas = "DEFF=1+[(1+CV_m^2)m-1]\\rho",
      substituted = paste0("DEFF=1+[(1+", ss_fmt(cv_cluster_size), "^2)\\times",
        ss_fmt(cluster_size), "-1]\\times", ss_fmt(icc), "=", ss_fmt(deff))))
  }
  list(formulas = character(), substituted = character())
}
