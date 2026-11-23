#' Likelihood Intervals for a Function of the Standardized Parameters
#'
#' Solve the likelihood intervals of one effect family
#' for the model stored in a `betalb` object.
#' @author Ivan Jacob Agaloos Pesigan
#' @param object Object of class `betalb`.
#' @param effect Character string. Effect family
#'   (`"rsq"`, `"scor"`, `"pcor"`, `"deltarsq"`, `"diffbeta"`, or `"fsq"`).
#' @param alpha Numeric vector.
#'   Significance level \eqn{\alpha}.
#' @param blocks `NULL` or a named list of predictor blocks.
#' @param fun Character string. Name of the calling function.
#' @param call Function call.
#' @return Object of class `eslb`.
#' @examples
#' # Used by the exported effect size functions.
#' @noRd
.ESLB <- function(object,
                  effect,
                  alpha,
                  blocks,
                  fun,
                  call) {
  args <- .CheckLBArguments(
    type = object$args$type,
    alpha = alpha,
    std_y = TRUE,
    std_x = NULL,
    blocks = blocks,
    control = object$args$control,
    data = object$data
  )
  args$effects <- effect
  run <- .LBRun(
    data = object$data,
    args = args
  )
  out <- list(
    call = call,
    fit = object,
    args = list(
      object = object,
      alpha = alpha,
      blocks = blocks
    ),
    lm_process = object$lm_process,
    est = run$est,
    intervals = run$intervals,
    diagnostics = run$diagnostics,
    fun = fun
  )
  class(x = out) <- c(
    "eslb",
    class(x = out)
  )
  out
}
