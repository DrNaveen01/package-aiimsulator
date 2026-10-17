\name{ss_diagnostic}
\alias{ss_diagnostic}
\title{Sample size for sensitivity and specificity precision or benchmark tests}
\description{Sample size for sensitivity and specificity precision or benchmark tests}
\usage{
ss_diagnostic(objective = c("sensitivity", "specificity", "joint",
                                      "test_sensitivity", "test_specificity"),
                            sensitivity = .85, specificity = .90,
                            precision_sens = .05, precision_spec = .05,
                            confidence = .95, interval = c("wilson", "wald"),
                            benchmark = .7, alpha = .05, power = .8,
                            alternative = c("greater", "two.sided", "less"),
                            recruitment = c("population", "separate"),
                            prevalence = .2, nonresponse = 0)
}
\arguments{
\item{objective}{Type of hypothesis or estimation objective.}
\item{sensitivity}{Anticipated index-test sensitivity.}
\item{specificity}{Anticipated index-test specificity.}
\item{precision_sens}{Desired sensitivity CI half-width.}
\item{precision_spec}{Desired specificity CI half-width.}
\item{confidence}{Two-sided confidence level as a fraction.}
\item{interval}{Wilson or Wald expected interval method.}
\item{benchmark}{Benchmark (null) diagnostic sensitivity/specificity for testing.}
\item{alpha}{Significance level; one-sided for directional objectives.}
\item{power}{Target statistical power, as a fraction.}
\item{alternative}{Two-sided, greater or less normal test alternative.}
\item{recruitment}{Separate disease-status strata or prevalence-based population recruitment.}
\item{prevalence}{Disease prevalence in the source population.}
\item{nonresponse}{Proportion of incomplete or non-analysable data (0 to less than 1).}
}
\value{An object of class \code{aiims_ss} containing complete and recruitment samples, precision-preserving calculation fields, and reportable equations.}
\details{Formulas are approximations for specified sampling and hypothesis-test designs. Inspect the returned \code{assumptions}, \code{references}, and \code{warnings} before using any sample size as methodological justification.}
\examples{
ss_diagnostic(objective = "joint", sensitivity = .85, specificity = .9)
}
