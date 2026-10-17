\name{ss_auc}
\alias{ss_auc}
\title{Sample size for ROC area-under-curve planning}
\description{Sample size for ROC area-under-curve planning}
\usage{
ss_auc(auc = .8,
                     objective = c("estimate", "test", "independent", "paired"),
                     null_auc = .5, auc2 = .7, precision = .05,
                     confidence = .95, alpha = .05, power = .8,
                     alternative = c("two.sided", "greater", "less"),
                     ratio = 1, cohort_ratio = 1, auc_correlation = .5,
                     recruitment = c("separate", "population"),
                     prevalence = .2, nonresponse = 0)
}
\arguments{
\item{auc}{Anticipated AUC for a diagnostic index test.}
\item{objective}{Type of hypothesis or estimation objective.}
\item{null_auc}{Benchmark AUC under null hypothesis.}
\item{auc2}{Anticipated AUC for a second diagnostic test.}
\item{precision}{Requested precision or confidence-interval half-width.}
\item{confidence}{Two-sided confidence level as a fraction.}
\item{alpha}{Significance level; one-sided for directional objectives.}
\item{power}{Target statistical power, as a fraction.}
\item{alternative}{Two-sided, greater or less normal test alternative.}
\item{ratio}{Group-2/group-1 allocation ratio, or negative/diseased allocation as noted.}
\item{cohort_ratio}{Second cohort to first cohort allocation for independent AUC comparison.}
\item{auc_correlation}{Correlation between the two estimated AUCs for paired comparisons.}
\item{recruitment}{Separate disease-status strata or prevalence-based population recruitment.}
\item{prevalence}{Disease prevalence in the source population.}
\item{nonresponse}{Proportion of incomplete or non-analysable data (0 to less than 1).}
}
\value{An object of class \code{aiims_ss} containing complete and recruitment samples, precision-preserving calculation fields, and reportable equations.}
\details{Formulas are approximations for specified sampling and hypothesis-test designs. Inspect the returned \code{assumptions}, \code{references}, and \code{warnings} before using any sample size as methodological justification.}
\examples{
ss_auc(auc = .8, objective = "estimate", precision = .05)
}
