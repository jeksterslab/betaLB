#' Estimate Semipartial Correlation Coefficients
#' and the Corresponding Likelihood-Based Confidence Intervals
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @details
#' The semipartial correlation of regressor \eqn{j} is
#' \eqn{sr_{j} = \beta^{\ast}_{j} \sqrt{1 - R^{2}_{j \cdot -j}}},
#' where \eqn{R^{2}_{j \cdot -j}} is the R-squared from regressing regressor
#' \eqn{j} on the other regressors.
#' The intervals are signed profile likelihood intervals of a scalar.
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
#'     \item{est}{Vector of semipartial correlations.}
#'     \item{intervals}{Data frame of the estimates and the limits
#'       of each significance level.}
#'     \item{diagnostics}{Solver diagnostics of each endpoint.}
#'     \item{fun}{Function used ("SCorLB").}
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
#' # SCorLB -------------------------------------------------------------------
#' out <- SCorLB(object = std, alpha = 0.05)
#'
#' ## Methods -----------------------------------------------------------------
#' print(x = out)
#' summary(object = out)
#' coef(object = out)
#' confint(object = out, level = 0.95)
#'
#' @family Beta Likelihood-Based Functions
#' @keywords betaLB scor
#' @export
SCorLB <- function(object,
                   alpha = c(0.05, 0.01, 0.001)) {
  .CheckLB(object = object)
  .ESLB(
    object = object,
    effect = "scor",
    alpha = alpha,
    blocks = NULL,
    fun = "SCorLB",
    call = match.call()
  )
}
