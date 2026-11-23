#' Estimate Squared Semipartial Correlation Coefficients
#' and the Corresponding Confidence Intervals
#' From the Signed Intervals
#'
#' Square the signed interval as a set, with lower limit zero if it
#' contains zero.
#' This differs from an interval of squared draws.
#' No draws are generated and no endpoints are clipped to one.
#' Failed signed endpoints remain missing.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @details
#' The semipartial correlation \eqn{sr_{j}} (see [SCorLB()]) is signed,
#' and its confidence interval \eqn{\left[ l, u \right]} may contain zero.
#' The interval for \eqn{sr^{2}_{j}} is the image of that interval under
#' squaring.
#' The squared interval is
#' \eqn{\left[ l^{2}, u^{2} \right]} if \eqn{0 < l},
#' \eqn{\left[ u^{2}, l^{2} \right]} if \eqn{u < 0},
#' and \eqn{\left[ 0, \max \left( l^{2}, u^{2} \right) \right]}
#' if the signed interval contains zero.
#' This is not a likelihood interval for \eqn{sr^{2}_{j}},
#' and it is not an interval for [DeltaRSqLB()].
#'
#' @return Data frame with est, lower and upper columns and predictor
#'   row names.
#'   The point estimate is the squared signed estimate.
#'   No standard error is implied by this interval transformation.
#'
#' @param object Object of class `betalb`.
#'   The output of [BetaLB()].
#' @param level Single confidence level in (0, 1).
#'
#' @examples
#' # Data ---------------------------------------------------------------------
#' data("nas1982", package = "betaLB")
#'
#' # Fit Model in lm ----------------------------------------------------------
#' object <- stats::lm(
#'   formula = QUALITY ~ NARTIC + PCTGRT + PCTSUPP,
#'   data = nas1982
#' )
#'
#' # BetaLB -------------------------------------------------------------------
#' std <- BetaLB(object = object, alpha = 0.05)
#'
#' # SCorSqLB -----------------------------------------------------------------
#' SCorSqLB(object = std, level = 0.95)
#'
#' @family Beta Likelihood-Based Functions
#' @keywords betaLB scor
#' @export
SCorSqLB <- function(object, level = 0.95) {
  bad_level <- !is.numeric(x = level) || length(x = level) != 1L ||
    !is.finite(x = level) || level <= 0 || level >= 1
  if (bad_level) {
    stop("level must be a single confidence level in (0, 1).")
  }
  signed <- SCorLB(object = object, alpha = 1 - level)
  ci <- stats::confint(object = signed, level = level)
  .SCorSqCI(est = stats::coef(object = signed), ci = ci)
}
