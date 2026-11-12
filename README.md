betaLB
================
Ivan Jacob Agaloos Pesigan
2026-11-12

<!-- README.md is generated from .setup/readme/README.Rmd. Please edit that file -->

<!-- badges: start -->
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
`lm()`.

## Installation

You can install the development version of `betaLB` from
[GitHub](https://github.com/jeksterslab/betaLB) with:

``` r
if (!requireNamespace(package = "pak", quietly = TRUE)) {
  utils::install.packages(pkgs = "pak")
}
pak::pkg_install(pkg = "jeksterslab/betaLB")
```

## Likelihood intervals

Fit once for the effect families, calibration types and confidence
levels needed. Extractors select stored results without refitting.

``` r
fit <- stats::lm(formula = mpg ~ wt + hp, data = mtcars)
out <- betaLB::LB(
  object = fit,
  effects = c("beta", "rsq"),
  type = c("mvn", "robust"),
  alpha = c(0.05, 0.10)
)
betaLB::BetaLB(object = out)
#> Call:
#> betaLB::LB(object = fit, type = c("mvn", "robust"), alpha = c(0.05, 
#>     0.1), effects = c("beta", "rsq"))
#> 
#> Likelihood intervals (vector projections are conservative)
#> type = "mvn, robust"
#>   effect   type alpha estimate   lower   upper lower_status upper_status
#> 1     wt    mvn  0.05  -0.6296 -0.7934 -0.4347           ok           ok
#> 2     wt    mvn  0.10  -0.6296 -0.7691 -0.4683           ok           ok
#> 3     wt robust  0.05  -0.6296 -0.7579 -0.4831           ok           ok
#> 4     wt robust  0.10  -0.6296 -0.7385 -0.5079           ok           ok
#> 5     hp    mvn  0.05  -0.3615 -0.5538 -0.1628           ok           ok
#> 6     hp    mvn  0.10  -0.3615 -0.5231 -0.1959           ok           ok
#> 7     hp robust  0.05  -0.3615 -0.4911 -0.2297           ok           ok
#> 8     hp robust  0.10  -0.3615 -0.4703 -0.2512           ok           ok
#>      calibration dimension
#> 1 scalar_profile         1
#> 2 scalar_profile         1
#> 3 scalar_profile         1
#> 4 scalar_profile         1
#> 5 scalar_profile         1
#> 6 scalar_profile         1
#> 7 scalar_profile         1
#> 8 scalar_profile         1
stats::confint(object = betaLB::RSqLB(object = out), type = "robust")
#>         lower     upper
#> rsq 0.6661115 0.9146316
#> adj 0.6430847 0.9087442
```

Scalar targets use profile-likelihood regions. Multi-coefficient
R-squared and block effects use conservative vector projection; the
output identifies this calibration and its dimension. Robust calibration
assumes independently sampled random regressors and finite fourth
moments. It does not supply fixed-regressor or clustered-data inference.

`out$intervals` contains every computed band and its endpoint statuses.
`out$diagnostics` retains numerical verification details. An unverified
endpoint is `NA`; no Wald endpoint is substituted. Adjusted R-squared is
an explicitly sample-size-dependent transformation, and its interval can
have a negative lower bound.
