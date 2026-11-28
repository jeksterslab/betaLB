betaLB
================
Ivan Jacob Agaloos Pesigan
2026-11-28 05:43:47

<!-- README.md is generated from README.Rmd. Please edit that file -->

<!-- badges: start -->
[![pages-build-deployment](https://github.com/jeksterslab/betaLB/actions/workflows/pages/pages-build-deployment/badge.svg)](https://github.com/jeksterslab/betaLB/actions/workflows/pages/pages-build-deployment)
[![codecov](https://codecov.io/gh/jeksterslab/betaLB/branch/main/graph/badge.svg?token=KVLUET3DJ6)](https://codecov.io/gh/jeksterslab/betaLB)
[![Make Project (make all)](https://github.com/jeksterslab/betaLB/actions/workflows/make-all.yml/badge.svg)](https://github.com/jeksterslab/betaLB/actions/workflows/make-all.yml)
[![Make Project](https://github.com/jeksterslab/betaLB/actions/workflows/make.yml/badge.svg)](https://github.com/jeksterslab/betaLB/actions/workflows/make.yml)
[![R-CMD-check-full](https://github.com/jeksterslab/betaLB/actions/workflows/check-full.yml/badge.svg)](https://github.com/jeksterslab/betaLB/actions/workflows/check-full.yml)
[![R-CMD-check-oldrel](https://github.com/jeksterslab/betaLB/actions/workflows/check-oldrel.yml/badge.svg)](https://github.com/jeksterslab/betaLB/actions/workflows/check-oldrel.yml)
[![R-CMD-check-standard](https://github.com/jeksterslab/betaLB/actions/workflows/check-standard.yml/badge.svg)](https://github.com/jeksterslab/betaLB/actions/workflows/check-standard.yml)
[![Compile LaTeX](https://github.com/jeksterslab/betaLB/actions/workflows/latex.yml/badge.svg)](https://github.com/jeksterslab/betaLB/actions/workflows/latex.yml)
[![Lint R Package](https://github.com/jeksterslab/betaLB/actions/workflows/lint.yml/badge.svg)](https://github.com/jeksterslab/betaLB/actions/workflows/lint.yml)
[![Non-ASCII Check](https://github.com/jeksterslab/betaLB/actions/workflows/non-ascii-check.yml/badge.svg)](https://github.com/jeksterslab/betaLB/actions/workflows/non-ascii-check.yml)
[![Package Website (GitHub Pages)](https://github.com/jeksterslab/betaLB/actions/workflows/pkgdown-gh-pages.yml/badge.svg)](https://github.com/jeksterslab/betaLB/actions/workflows/pkgdown-gh-pages.yml)
[![rhub 1 (essential)](https://github.com/jeksterslab/betaLB/actions/workflows/rhub-1-essential.yml/badge.svg)](https://github.com/jeksterslab/betaLB/actions/workflows/rhub-1-essential.yml)
[![rhub 2 (memory)](https://github.com/jeksterslab/betaLB/actions/workflows/rhub-2-memory.yml/badge.svg)](https://github.com/jeksterslab/betaLB/actions/workflows/rhub-2-memory.yml)
[![rhub 3 (numerics), review only](https://github.com/jeksterslab/betaLB/actions/workflows/rhub-3-numerics.yml/badge.svg)](https://github.com/jeksterslab/betaLB/actions/workflows/rhub-3-numerics.yml)
[![rhub 4 (compilers), review only](https://github.com/jeksterslab/betaLB/actions/workflows/rhub-4-compilers.yml/badge.svg)](https://github.com/jeksterslab/betaLB/actions/workflows/rhub-4-compilers.yml)
[![Shell Check](https://github.com/jeksterslab/betaLB/actions/workflows/shellcheck.yml/badge.svg)](https://github.com/jeksterslab/betaLB/actions/workflows/shellcheck.yml)
[![Source Code](https://github.com/jeksterslab/betaLB/actions/workflows/source.yml/badge.svg)](https://github.com/jeksterslab/betaLB/actions/workflows/source.yml)
[![R Package Test Coverage](https://github.com/jeksterslab/betaLB/actions/workflows/test-coverage.yml/badge.svg)](https://github.com/jeksterslab/betaLB/actions/workflows/test-coverage.yml)
<!-- badges: end -->

## Description

Generates profile likelihood confidence intervals for standardized
regression coefficients (beta) and other effect sizes, including
multiple correlation, semipartial correlations, improvement in
R-squared, squared partial correlations, differences in standardized
regression coefficients, and Cohen’s f-squared, for models fitted by
`lm()`. The intervals invert the Gaussian likelihood-ratio test of the
covariance matrix of the outcome and the regressors, with a
normal-theory or a robust (fourth-moment) cutoff.

## Installation

You can install the development version of `betaLB` from
[GitHub](https://github.com/jeksterslab/betaLB) with:

``` r
if (!require("pak")) install.packages("pak")
pak::pkg_install("jeksterslab/betaLB")
```

## Example

In this example, a multiple regression model is fitted using program
quality ratings (`QUALITY`) as the regressand/outcome variable and
number of published articles attributed to the program faculty members
(`NARTIC`), percent of faculty members holding research grants
(`PCTGRT`), and percentage of program graduates who received support
(`PCTSUPP`) as regressor/predictor variables using a data set from 1982
ratings of 46 doctoral programs in psychology in the USA (National
Research Council, 1982). Likelihood-based confidence intervals for the
standardized regression coefficients are generated using the `BetaLB()`
function from the `betaLB` package.

``` r
library(package = betaLB)
```

``` r
df <- betaLB::nas1982
```

### Fit the regression model using the `lm()` function.

``` r
object <- stats::lm(formula = QUALITY ~ NARTIC + PCTGRT + PCTSUPP, data = df)
```

### Estimate the standardized regression slopes and the corresponding likelihood-based confidence intervals.

``` r
BetaLB(object = object, type = "mvn", alpha = 0.05)
#> Call:
#> BetaLB(object = object, type = "mvn", alpha = 0.05)
#> 
#> Standardized regression slopes with MVN likelihood intervals:
#>            est   2.5%  97.5%
#> NARTIC  0.4951 0.3423 0.6394
#> PCTGRT  0.3915 0.2395 0.5426
#> PCTSUPP 0.2632 0.1179 0.4148
```

## Other Features

The package provides the following functions.

| Function | Purpose |
|----|----|
| `BetaLB()` | Standardized regression coefficients with normal-theory (`type = "mvn"`) or robust (`type = "robust"`) likelihood intervals |
| `RSqLB()` | R-squared and adjusted R-squared |
| `DiffBetaLB()` | Differences of standardized regression coefficients |
| `SCorLB()` | Semipartial correlations |
| `SCorSqLB()` | Squared semipartial correlations (squared signed interval) |
| `PCorLB()` | Squared partial correlations |
| `DeltaRSqLB()` | Improvement in R-squared |
| `FSqLB()` | Cohen’s f-squared and local f-squared |

The `coef()`, `confint()`, `summary()`, and `print()` methods are
available for the returned objects. The effect-size functions take the
output of `BetaLB()` and use its `type` and `control`. Scalar targets
use profile-likelihood regions; multi-coefficient targets use a
conservative vector projection, and the output names the calibration and
its dimension. An unverified endpoint is `NA`; no Wald endpoint is
substituted. Robust calibration assumes independently sampled random
regressors and finite fourth moments. Examples for each function are in
the package vignettes.

## Effect Sizes

The definitions, formulas, and notes on the intervals are in the help
pages of the functions and in the vignette [betaLB: Example Using the
Effect Size
Functions](https://jeksterslab.github.io/betaLB/articles/example-es-lb.html).

## Documentation

See [GitHub Pages](https://jeksterslab.github.io/betaLB/index.html) for
package documentation.

## Citation

To cite `betaLB` in publications, please run `citation("betaLB")`.

## References

<div id="refs" class="references csl-bib-body hanging-indent"
data-entry-spacing="0" data-line-spacing="2">

<div id="ref-Dudgeon-2017" class="csl-entry">

Dudgeon, P. (2017). Some improvements in confidence intervals for
standardized regression coefficients. *Psychometrika*, *82*(4), 928–951.
<https://doi.org/10.1007/s11336-017-9563-z>

</div>

<div id="ref-NationalResearchCouncil-1982" class="csl-entry">

National Research Council. (1982). *An assessment of research-doctorate
programs in the United States: Social and behavioral sciences*. National
Academies Press. <https://doi.org/10.17226/9781>

</div>

<div id="ref-RCoreTeam-2026" class="csl-entry">

R Core Team. (2026). *R: A language and environment for statistical
computing*. R Foundation for Statistical Computing.
<https://www.R-project.org/>

</div>

</div>
