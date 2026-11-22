#' Estimate Cohen's f-Squared and Local f-Squared
#' and the Corresponding Likelihood-Based Confidence Intervals
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @details
#' Cohen's f-squared is \eqn{f^{2} = R^{2} / ( 1 - R^{2} )}.
#' The local f-squared of regressor \eqn{j} is
#' \eqn{sr^{2}_{j} / ( 1 - R^{2} )}.
#' The limits of \eqn{f^{2}} are the transformed limits of \eqn{R^{2}}.
#' With `blocks`, the local f-squared is that of a set of regressors;
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
#'     \item{est}{Vector of Cohen's f-squared (`fsq`) and local f-squared.}
#'     \item{intervals}{Data frame of the estimates and the limits
#'       of each significance level.}
#'     \item{diagnostics}{Solver diagnostics of each endpoint.}
#'     \item{fun}{Function used ("FSqLB").}
#'   }
#'
#' @inheritParams RSqLB
#' @param blocks `NULL` or a named list of additional predictor blocks,
#'   given by regressor names or column indices.
#'   Each block adds an element named `block:<name>` to the output.
#'   The default `NULL` gives one element per regressor.
#'
#' @references
#' Selya, A. S., Rose, J. S., Dierker, L. C., Hedeker, D., & Mermelstein,
#' R. J. (2012).
#' A practical guide to calculating Cohen's f2,
#' a measure of local effect size, from PROC MIXED.
#' *Frontiers in Psychology*, *3*, 111.
#' \doi{10.3389/fpsyg.2012.00111}
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
#' # FSqLB --------------------------------------------------------------------
#' out <- FSqLB(object = std, alpha = 0.05)
#'
#' ## Methods -----------------------------------------------------------------
#' print(x = out)
#' summary(object = out)
#' coef(object = out)
#' confint(object = out, level = 0.95)
#'
#' @family Beta Likelihood-Based Functions
#' @keywords betaLB fsq
#' @export
FSqLB <- function(object,
                  alpha = c(0.05, 0.01, 0.001),
                  blocks = NULL) {
  .CheckLB(object = object)
  .ESLB(
    object = object,
    effect = "fsq",
    alpha = alpha,
    blocks = blocks,
    fun = "FSqLB",
    call = match.call()
  )
}
