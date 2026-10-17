\name{ss_report}
\alias{ss_report}
\title{Produce a selective manuscript-ready sample-size report}
\description{Produce a selective manuscript-ready sample-size report}
\usage{
ss_report(x, formula = TRUE, substituted_values = TRUE,
                        results = TRUE, assumptions = FALSE, references = FALSE,
                        warnings = TRUE, format = c("markdown", "latex", "text"))
}
\arguments{
\item{x}{An aiims_ss result object.}
\item{formula}{Include general equation block.}
\item{substituted_values}{Include numerically substituted equation block.}
\item{results}{Include the final sample size and/or achieved power text.}
\item{assumptions}{Include methodological assumptions.}
\item{references}{Include method citations.}
\item{warnings}{Include calculation warnings.}
\item{format}{Markdown, LaTeX or plain-text output.}
}
\value{A character string.}
\details{Formulas are approximations for specified sampling and hypothesis-test designs. Inspect the returned \code{assumptions}, \code{references}, and \code{warnings} before using any sample size as methodological justification.}
\examples{
ss_report(ss_proportion(.5, .05), formula = TRUE, results = TRUE)
}
