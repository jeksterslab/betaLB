#' Estimate R-Squared and Adjusted R-Squared
#' and the Corresponding Likelihood-Based Confidence Intervals
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @details
#' Let \eqn{\boldsymbol{\beta}^{\ast}} be the vector of standardized slopes
#' and \eqn{\boldsymbol{R}_{x}} the correlation matrix of the regressors.
#' The R-squared and the adjusted R-squared are
#' \deqn{R^{2} = \boldsymbol{\beta}^{\ast\prime} \boldsymbol{R}_{x}
#' \boldsymbol{\beta}^{\ast}, \quad \bar{R}^{2} = 1 - \left( 1 - R^{2} \right)
#' \frac{n - 1}{n - k},}
#' where \eqn{n} is the sample size and \eqn{k} is the number of parameters
#' in the regression model, including the intercept.
#' The interval of \eqn{R^{2}} is the profile likelihood interval
#' of a nonnegative quantity;
#' the limits of \eqn{\bar{R}^{2}} are the transformed limits of
#' \eqn{R^{2}}.
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
#'     \item{est}{Vector of R-squared and adjusted R-squared.}
#'     \item{intervals}{Data frame of the estimates and the limits
#'       of each significance level.}
#'     \item{diagnostics}{Solver diagnostics of each endpoint.}
#'     \item{fun}{Function used ("RSqLB").}
#'   }
#'
#' @param object Object of class `betalb`.
#'   The output of [BetaLB()].
#' @param alpha Numeric vector.
#'   Significance level \eqn{\alpha}.
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
#' # RSqLB --------------------------------------------------------------------
#' out <- RSqLB(object = std, alpha = 0.05)
#'
#' ## Methods -----------------------------------------------------------------
#' print(x = out)
#' summary(object = out)
#' coef(object = out)
#' confint(object = out, level = 0.95)
#'
#' @family Beta Likelihood-Based Functions
#' @keywords betaLB rsq
#' @export
RSqLB <- function(object,
                  alpha = c(0.05, 0.01, 0.001)) {
  .CheckLB(object = object)
  .ESLB(
    object = object,
    effect = "rsq",
    alpha = alpha,
    blocks = NULL,
    fun = "RSqLB",
    call = match.call()
  )
}
