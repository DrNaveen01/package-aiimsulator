---
editor_options: 
  markdown: 
    wrap: 72
---

# CRAN submission checklist — incomplete until verified

## Blocking items

-   [ ] maintainer email is
    [aiims.drnaveen\@gmail.com](mailto:aiims.drnaveen@gmail.com){.email}
-   [ ] Verify package name availability and appropriateness of
    institutional name.
-   [ ] Confirm authorship, rights and attribution for code
    extracted/adapted from the Shiny repository.
-   [ ] Run `R CMD build` and `R CMD check --as-cran` on the built
    `.tar.gz`.
-   [ ] Review all `testthat` tests under the current R release,
    R-devel, Windows and macOS; independent methods validation before
    publication.
-   [ ] Review numeric substitution in every equation against
    computation and resolve any differences; verify invalid and boundary
    input handling.
-   [ ] Test vignettes and Markdown/LaTeX manuscript output in Quarto
    HTML, DOCX, PDF.
-   [ ] Update package URL, BugReports and citation to final package
    GitHub repo.
-   [ ] Check any third-party formula/code license and citation
    requirements.

## Recommended before first CRAN release

-   [ ] Use `devtools::document()` with `roxygen2` installed to
    regenerate documentation and NAMESPACE (verify generated results
    against source files).
-   [ ] Run `covr::package_coverage()`; add independent fixtures for all
    advanced objectives.
-   [ ] Compare calculations against at least two established
    references/software implementations wherever applicable.
-   [ ] Use `devtools::spell_check()` and `urlchecker::url_check()`.
-   [ ] Confirm `R CMD check` has no ERROR, WARNING, or unexpected NOTE.
-   [ ] Link the Shiny calculator to this R package, rather than copying
    calculations.
-   [ ] Add pkgdown site, contribution guide, signed release and Zenodo
    DOI as appropriate.

Official policy: <https://cran.r-project.org/web/packages/policies.html>
Official manual:
<https://cran.r-project.org/doc/manuals/r-release/R-exts.html>

**Important:** The provided ZIP is a source project. CRAN accepts source
archives created by `R CMD build`, not arbitrary ZIP files.
