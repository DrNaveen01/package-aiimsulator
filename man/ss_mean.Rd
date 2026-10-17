\name{ss_mean}
\alias{ss_mean}
\title{Sample size for estimating a single population mean}
\description{Sample size for estimating a single population mean}
\usage{
ss_mean(sd, precision, confidence = 0.95,
                      nonresponse = 0, design_effect = NULL,
                      icc = NULL, cluster_size = NULL,
                      cv_cluster_size = 0, population = NULL)
}
\arguments{
\item{sd}{Anticipated standard deviation.}
\item{precision}{Requested precision or confidence-interval half-width.}
\item{confidence}{Two-sided confidence level as a fraction.}
\item{nonresponse}{Proportion of incomplete or non-analysable data (0 to less than 1).}
\item{design_effect}{Directly specified design effect, when applicable.}
\item{icc}{Intra-cluster correlation for design-effect approximation.}
\item{cluster_size}{Mean observations per cluster.}
\item{cv_cluster_size}{Coefficient of variation in cluster sizes.}
\item{population}{Finite population size under simple random sampling without replacement.}
}
\value{An object of class \code{aiims_ss} containing complete and recruitment samples, precision-preserving calculation fields, and reportable equations.}
\details{Formulas are approximations for specified sampling and hypothesis-test designs. Inspect the returned \code{assumptions}, \code{references}, and \code{warnings} before using any sample size as methodological justification.}
\examples{
ss_mean(sd = 12, precision = 3)
}
