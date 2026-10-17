\name{ss_yamane}
\alias{ss_yamane}
\title{Taro Yamane simplified finite-population sample size}
\description{Taro Yamane simplified finite-population sample size}
\usage{
ss_yamane(population, precision = 0.05, nonresponse = 0)
}
\arguments{
\item{population}{Finite population size under simple random sampling without replacement.}
\item{precision}{Requested precision or confidence-interval half-width.}
\item{nonresponse}{Proportion of incomplete or non-analysable data (0 to less than 1).}
}
\value{An object of class \code{aiims_ss} containing complete and recruitment samples, precision-preserving calculation fields, and reportable equations.}
\details{Formulas are approximations for specified sampling and hypothesis-test designs. Inspect the returned \code{assumptions}, \code{references}, and \code{warnings} before using any sample size as methodological justification.}
\examples{
ss_yamane(population = 1500)
}
