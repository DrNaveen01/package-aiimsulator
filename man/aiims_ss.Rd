\name{aiims_ss}
\alias{print.aiims_ss}
\alias{summary.aiims_ss}
\alias{print.summary.aiims_ss}
\alias{as.data.frame.aiims_ss}
\title{Print, summarize and tabulate aiims_ss results}
\description{Default console display and structured summary methods for sample-size calculations.}
\usage{
\method{print}{aiims_ss}(x, ...)
\method{summary}{aiims_ss}(object, ...)
\method{print}{summary.aiims_ss}(x, ...)
\method{as.data.frame}{aiims_ss}(x, row.names = NULL, optional = FALSE, ...)
}
\arguments{
\item{x}{An aiims_ss result object or a summary.aiims_ss summary.}
\item{object}{An aiims_ss object.}
\item{row.names}{Unused; retained for method compatibility.}
\item{optional}{Unused; retained for method compatibility.}
\item{...}{Additional arguments, currently ignored.}
}
\value{Print methods invisibly return their input. The summary method returns
a structured list with an aiims_ss summary class, and as.data.frame returns a two-column numeric data frame.}
