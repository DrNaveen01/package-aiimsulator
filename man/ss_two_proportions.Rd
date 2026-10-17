\name{ss_two_proportions}
\alias{ss_two_proportions}
\title{Sample size for comparing two independent proportions}
\description{Sample size for comparing two independent proportions}
\usage{
ss_two_proportions(p1, p2 = NULL, power = .8, alpha = .05,
                                 ratio = 1, nonresponse = 0, n1 = NULL, n2 = NULL,
                                 effect_type = c("proportions", "or", "rr"), effect = NULL,
                                 objective = "equality", direction = "higher", margin = 0,
                                 lower = NULL, upper = NULL,
                                 group1 = "Group 1", group2 = "Group 2",
                                 design_effect = NULL, icc = NULL, cluster_size = NULL,
                                 cv_cluster_size = 0)
}
\arguments{
\item{p1}{Anticipated proportion in group 1.}
\item{p2}{Anticipated proportion in group 2.}
\item{power}{Target statistical power, as a fraction.}
\item{alpha}{Significance level; one-sided for directional objectives.}
\item{ratio}{Group-2/group-1 allocation ratio, or negative/diseased allocation as noted.}
\item{nonresponse}{Proportion of incomplete or non-analysable data (0 to less than 1).}
\item{n1}{Optional fixed complete group-1 sample size.}
\item{n2}{Optional fixed complete group-2 sample size.}
\item{effect_type}{Choose direct proportions or derive from odds ratio or risk ratio.}
\item{effect}{Anticipated odds ratio or risk ratio.}
\item{objective}{Type of hypothesis or estimation objective.}
\item{direction}{Whether a higher or lower group-2 value is favourable.}
\item{margin}{Absolute superiority/non-inferiority margin.}
\item{lower}{Lower equivalence margin.}
\item{upper}{Upper equivalence margin.}
\item{group1}{Label for group 1.}
\item{group2}{Label for group 2.}
\item{design_effect}{Directly specified design effect, when applicable.}
\item{icc}{Intra-cluster correlation for design-effect approximation.}
\item{cluster_size}{Mean observations per cluster.}
\item{cv_cluster_size}{Coefficient of variation in cluster sizes.}
}
\value{An object of class \code{aiims_ss} containing complete and recruitment samples, precision-preserving calculation fields, and reportable equations.}
\details{Formulas are approximations for specified sampling and hypothesis-test designs. Inspect the returned \code{assumptions}, \code{references}, and \code{warnings} before using any sample size as methodological justification.}
\examples{
ss_two_proportions(.20, .35)
}


