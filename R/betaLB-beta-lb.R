#' Likelihood Intervals for Standardized Regression Slopes
#'
#' Extract already-computed point estimates and intervals from an LB context.
#' For multi-coefficient nonnegative effects, vector projection is
#' conservative.
#' @author Ivan Jacob Agaloos Pesigan
#' @param object Context returned by `LB()`, with this family computed.
#' @return Object of class `betalb`; use `coef()`, `confint()` or `summary()`.
#' @examples
#' fit <- stats::lm(formula = mpg ~ wt + hp, data = mtcars)
#' out <- LB(object = fit, effects = "beta", type = "mvn", alpha = 0.05)
#' BetaLB(object = out)
#' @family Likelihood Effect Extractors
#' @export
BetaLB <- function(object) {
  .LBExtract(object = object, family = "beta")
}
