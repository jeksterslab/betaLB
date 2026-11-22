#' Estimate Squared Partial Correlation Coefficients
#' and the Corresponding Likelihood-Based Confidence Intervals
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @details
#' The squared partial correlation of regressor \eqn{j} is
#' \eqn{pr^{2}_{j} = sr^{2}_{j} / ( 1 - R^{2} + sr^{2}_{j} )},
#' the proportion of the variance in the outcome not explained
#' by the other regressors that is explained by regressor \eqn{j}.
#' The intervals are profile likelihood intervals of a nonnegative quantity.
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
#'     \item{est}{Vector of squared partial correlation coefficients.}
#'     \item{intervals}{Data frame of the estimates and the limits
#'       of each significance level.}
#'     \item{diagnostics}{Solver diagnostics of each endpoint.}
#'     \item{fun}{Function used ("PCorLB").}
#'   }
#'
#' @inheritParams RSqLB
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
#' # PCorLB -------------------------------------------------------------------
#' out <- PCorLB(object = std, alpha = 0.05)
#'
#' ## Methods -----------------------------------------------------------------
#' print(x = out)
#' summary(object = out)
#' coef(object = out)
#' confint(object = out, level = 0.95)
#'
#' @family Beta Likelihood-Based Functions
#' @keywords betaLB pcor
#' @export
PCorLB <- function(object,
                   alpha = c(0.05, 0.01, 0.001)) {
  .CheckLB(object = object)
  .ESLB(
    object = object,
    effect = "pcor",
    alpha = alpha,
    blocks = NULL,
    fun = "PCorLB",
    call = match.call()
  )
}
