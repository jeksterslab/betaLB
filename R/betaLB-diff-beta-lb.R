#' Estimate Differences of Standardized Regression Coefficients
#' and the Corresponding Likelihood-Based Confidence Intervals
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @details
#' Differences are taken over all pairs of standardized slopes,
#' \eqn{\beta^{\ast}_{i} - \beta^{\ast}_{j}}.
#' Two or more regressors are required,
#' and `object` must have fully standardized slopes
#' (`std_y = TRUE` and `std_x = NULL` in [BetaLB()]).
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
#'     \item{est}{Vector of differences of standardized slopes.}
#'     \item{intervals}{Data frame of the estimates and the limits
#'       of each significance level.}
#'     \item{diagnostics}{Solver diagnostics of each endpoint.}
#'     \item{fun}{Function used ("DiffBetaLB").}
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
#' # DiffBetaLB ---------------------------------------------------------------
#' out <- DiffBetaLB(object = std, alpha = 0.05)
#'
#' ## Methods -----------------------------------------------------------------
#' print(x = out)
#' summary(object = out)
#' coef(object = out)
#' confint(object = out, level = 0.95)
#'
#' @family Beta Likelihood-Based Functions
#' @keywords betaLB diff
#' @export
DiffBetaLB <- function(object,
                       alpha = c(0.05, 0.01, 0.001)) {
  .CheckLB(
    object = object,
    p_min = 2
  )
  if (isFALSE(x = attributes(x = object)$std)) {
    stop("Differences need fully standardized slopes.")
  }
  .ESLB(
    object = object,
    effect = "diffbeta",
    alpha = alpha,
    blocks = NULL,
    fun = "DiffBetaLB",
    call = match.call()
  )
}
