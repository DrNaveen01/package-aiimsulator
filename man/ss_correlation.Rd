\name{ss_correlation}
\alias{ss_correlation}
\title{Sample size for Pearson correlation estimation and hypothesis testing}
\description{Sample size for Pearson correlation estimation and hypothesis testing}
\usage{
ss_correlation(r = .3, objective = c("test", "estimate", "independent"),
                             r0 = 0, r2 = .1, precision = .1,
                             precision_scale = c("correlation", "fisher"),
                             confidence = .95, alpha = .05, power = .8,
                             alternative = c("two.sided", "greater", "less"),
                             ratio = 1, nonresponse = 0)
}
\arguments{
\item{r}{Anticipated Pearson correlation.}
\item{objective}{Type of hypothesis or estimation objective.}
\item{r0}{Null Pearson correlation for one-sample testing.}
\item{r2}{Second population correlation for independent comparison.}
\item{precision}{Requested precision or confidence-interval half-width.}
\item{precision_scale}{Target precision on Pearson correlation or Fisher z scale.}
\item{confidence}{Two-sided confidence level as a fraction.}
\item{alpha}{Significance level; one-sided for directional objectives.}
\item{power}{Target statistical power, as a fraction.}
\item{alternative}{Two-sided, greater or less normal test alternative.}
\item{ratio}{Group-2/group-1 allocation ratio, or negative/diseased allocation as noted.}
\item{nonresponse}{Proportion of incomplete or non-analysable data (0 to less than 1).}
}
\value{An object of class \code{aiims_ss} containing complete and recruitment samples, precision-preserving calculation fields, and reportable equations.}
\details{Formulas are approximations for specified sampling and hypothesis-test designs. Inspect the returned \code{assumptions}, \code{references}, and \code{warnings} before using any sample size as methodological justification.}
\examples{
ss_correlation(r = .3)
}
