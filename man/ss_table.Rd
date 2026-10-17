\name{ss_table}
\alias{ss_table}
\title{Convert a calculation to a tidy parameter/result table}
\description{Convert a calculation to a tidy parameter/result table}
\usage{
ss_table(x)
}
\arguments{
\item{x}{An aiims_ss result object.}
}
\value{A two-column data frame of numeric intermediate and final calculations.}
\details{Formulas are approximations for specified sampling and hypothesis-test designs. Inspect the returned \code{assumptions}, \code{references}, and \code{warnings} before using any sample size as methodological justification.}
\examples{
ss_table(ss_proportion(.5, .05))
}
