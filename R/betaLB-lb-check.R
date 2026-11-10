#' Check the Input of the Effect-Size LB Functions
#'
#' Validate the class and minimum regressor count for scaffold methods.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @param object Object of class `betalb`.
#' @param p_min Positive integer.
#'   Minimum number of regressors.
#'
#' @return Invisible `TRUE` when checks pass.
#'
#' @family Beta Profile Likelihood Functions
#' @keywords betaLB internal
#' @examples
#' object <- structure(list(lm_process = list(p = 2)), class = "betalb")
#' .CheckLB(object = object)
#' @noRd
.CheckLB <- function(object,
                     p_min = 1) {
  stopifnot(
    inherits(
      x = object,
      what = "betalb"
    )
  )
  stopifnot(
    is.numeric(x = p_min),
    length(x = p_min) == 1L,
    is.finite(x = p_min),
    p_min >= 1,
    p_min == floor(x = p_min),
    is.numeric(x = object$lm_process$p),
    length(x = object$lm_process$p) == 1L,
    is.finite(x = object$lm_process$p)
  )
  if (object$lm_process$p < p_min) {
    stop(paste("At least", p_min, "regressors are required."))
  } else {
    invisible(x = TRUE)
  }
}
