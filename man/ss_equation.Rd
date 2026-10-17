\name{ss_equation}
\alias{ss_equation}
\title{Extract general and numerically substituted equations}
\description{Extract general and numerically substituted equations}
\usage{
ss_equation(x, which = c("formula", "substituted_values", "both"),
                          format = c("markdown", "latex", "text"))
}
\arguments{
\item{x}{An aiims_ss result object.}
\item{which}{Select general formula, substituted values or both.}
\item{format}{Markdown, LaTeX or plain-text output.}
}
\value{A character string.}
\details{Formulas are approximations for specified sampling and hypothesis-test designs. Inspect the returned \code{assumptions}, \code{references}, and \code{warnings} before using any sample size as methodological justification.}
\examples{
ss_equation(ss_proportion(.5, .05), which = "both", format = "text")
}
