#' Estimate Improvement in R-Squared
#' and the Corresponding Likelihood-Based Confidence Intervals
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @details
#' The improvement in R-squared of regressor \eqn{j} is
#' \eqn{sr^{2}_{j}}, the change in \eqn{R^{2}}
#' when regressor \eqn{j} is added last.
#' The intervals are profile likelihood intervals of a nonnegative quantity.
#' With `blocks`, the improvement is that of a set of regressors;
#' the intervals are conservative (vector projection).
#' The `type` and `control` stored in `object` are used.
#'
#' @return Returns an object of class `eslb`
#'   which is a list with the following elements:
#'   \describe{
#'     \item{call}{Function call.}
#'     \item{fit}{The argument `object`.}
#'     \item{args}{Function arguments.}
#'     \item{lm_process}{Sample size, number of regressors,
#'       and regressor names.}
#'     \item{est}{Vector of improvements in R-squared.}
#'     \item{intervals}{Data frame of the estimates and the limits
#'       of each significance level.}
#'     \item{diagnostics}{Solver diagnostics of each endpoint.}
#'     \item{fun}{Function used ("DeltaRSqLB").}
#'   }
#'
#' @inheritParams RSqLB
#' @param blocks `NULL` or a named list of additional predictor blocks,
#'   given by regressor names or column indices.
#'   Each block adds an element named `block:<name>` to the output.
#'   The default `NULL` gives one element per regressor.
#'
#' @references
#' Algina, J., Keselman, H. J., & Penfield, R. D. (2007).
#' Confidence intervals for an effect size measure
#' in multiple linear regression.
#' *Educational and Psychological Measurement*, *67*(2), 207--218.
#' \doi{10.1177/0013164406292030}
#'
#' Algina, J., Keselman, H. J., & Penfield, R. D. (2008a).
#' Confidence intervals for the squared multiple semipartial
#' correlation coefficient.
#' *Journal of Modern Applied Statistical Methods*, *7*(1), 2--10.
#' \doi{10.22237/jmasm/1209614460}
#'
#' Algina, J., Keselman, H. J., & Penfield, R. D. (2008b).
#' Note on a confidence interval for the squared semipartial
#' correlation coefficient.
#' *Educational and Psychological Measurement*, *68*(5), 734--741.
#' \doi{10.1177/0013164407313371}
#'
#' Algina, J., Keselman, H. J., & Penfield, R. D. (2010).
#' Confidence intervals for squared semipartial correlation coefficients:
#' The effect of nonnormality.
#' *Educational and Psychological Measurement*, *70*(6), 926--940.
#' \doi{10.1177/0013164410379335}
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
#' # DeltaRSqLB ---------------------------------------------------------------
#' out <- DeltaRSqLB(object = std, alpha = 0.05)
#'
#' ## Methods -----------------------------------------------------------------
#' print(x = out)
#' summary(object = out)
#' coef(object = out)
#' confint(object = out, level = 0.95)
#'
#' @family Beta Likelihood-Based Functions
#' @keywords betaLB deltarsq
#' @export
DeltaRSqLB <- function(object,
                       alpha = c(0.05, 0.01, 0.001),
                       blocks = NULL) {
  .CheckLB(
    object = object,
    p_min = 2
  )
  .ESLB(
    object = object,
    effect = "deltarsq",
    alpha = alpha,
    blocks = blocks,
    fun = "DeltaRSqLB",
    call = match.call()
  )
}
