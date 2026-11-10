#' Check a Batched Likelihood Context
#'
#' Distinguish a fitted context from an extracted effect object.
#' @author Ivan Jacob Agaloos Pesigan
#' @param object Object returned by `LB()`.
#' @return Invisibly returns `TRUE`, or stops.
#' @examples
#' .CheckLBContext(object = structure(list(intervals = data.frame()),
#'   class = "lb"
#' ))
#' @noRd
.CheckLBContext <- function(object) {
  stopifnot(
    inherits(x = object, what = "lb"),
    is.data.frame(x = object$intervals)
  )
  invisible(x = TRUE)
}
