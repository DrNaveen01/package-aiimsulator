\name{ss_design_effect}
\alias{ss_design_effect}
\title{Compute a design effect}
\description{Compute a design effect}
\usage{
ss_design_effect(design_effect = NULL, icc = NULL,
                               cluster_size = NULL, cv_cluster_size = 0)
}
\arguments{
\item{design_effect}{Directly specified design effect, when applicable.}
\item{icc}{Intra-cluster correlation for design-effect approximation.}
\item{cluster_size}{Mean observations per cluster.}
\item{cv_cluster_size}{Coefficient of variation in cluster sizes.}
}
\value{One unrounded numeric value.}
\details{Formulas are approximations for specified sampling and hypothesis-test designs. Inspect the returned \code{assumptions}, \code{references}, and \code{warnings} before using any sample size as methodological justification.}
\examples{
ss_design_effect(icc = .02, cluster_size = 20)
}
