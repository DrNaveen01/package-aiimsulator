\name{ss_fpc}
\alias{ss_fpc}
\title{Apply the finite population correction to an unrounded sample size}
\description{Apply the finite population correction to an unrounded sample size}
\usage{
ss_fpc(n, population)
}
\arguments{
\item{n}{Unrounded sample size before finite population correction.}
\item{population}{Finite population size under simple random sampling without replacement.}
}
\value{One unrounded numeric value.}
\details{Formulas are approximations for specified sampling and hypothesis-test designs. Inspect the returned \code{assumptions}, \code{references}, and \code{warnings} before using any sample size as methodological justification.}
\examples{
ss_fpc(384.1459, population = 1000)
}
