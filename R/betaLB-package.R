#' betaLB: Likelihood-Based Confidence Intervals for Regression Effect Sizes
#'
#' Generates profile likelihood confidence intervals
#' for standardized regression coefficients
#' and other effect sizes
#' for models fitted by [stats::lm()]
#' with independently sampled random regressors.
#' The functions and arguments follow the `betaSandwich` package.
#'
#' @section Standardized regression coefficients:
#' [BetaLB()] estimates the standardized regression coefficients
#' and their likelihood intervals.
#' The argument `type` is `"mvn"` (multivariate normal theory)
#' or `"robust"` (empirical fourth moments).
#'
#' @section Functions of the standardized coefficients:
#' [RSqLB()] (R-squared and adjusted R-squared),
#' [DiffBetaLB()] (differences of standardized slopes),
#' [SCorLB()] and [SCorSqLB()] (semipartial correlations),
#' [PCorLB()] (squared partial correlations),
#' [DeltaRSqLB()] (improvement in R-squared), and
#' [FSqLB()] (Cohen's f-squared and local f-squared).
#' These functions take the output of [BetaLB()].
#'
#' @section Methods:
#' The `coef()`, `confint()`, `summary()`, and `print()` methods are
#' available for objects of class `betalb` and `eslb`.
#' A covariance matrix is not defined for likelihood intervals,
#' so `vcov()` stops with a message.
#'
#' @references
#' Dudgeon, P. (2017).
#' Some improvements in confidence intervals for standardized regression
#' coefficients.
#' *Psychometrika*, *82*(4), 928--951.
#' \doi{10.1007/s11336-017-9563-z}
#'
#' @aliases betaLB-package
#' @keywords internal
"_PACKAGE"
## usethis namespace: start
#' @importFrom Rcpp sourceCpp
#' @useDynLib betaLB, .registration = TRUE
## usethis namespace: end
NULL
