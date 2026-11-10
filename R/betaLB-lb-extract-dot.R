#' Extract One Stored Likelihood Effect Family
#'
#' Select intervals without invoking a solver or recalibrating a region.
#' @author Ivan Jacob Agaloos Pesigan
#' @param object Context returned by `LB()`.
#' @param family Requested effect-family code.
#' @return Object of class `betalb` with family-specific parameter names.
#' @examples
#' # Used by the exported effect extractors after LB().
#' @noRd
.LBExtract <- function(object, family) {
  .CheckLBContext(object = object)
  rows <- object$intervals$family == family
  if (!any(x = rows)) {
    stop("The effect family was not computed or requires more predictors.")
  }
  intervals <- object$intervals[rows, , drop = FALSE]
  intervals$effect <- intervals$label
  first <- !duplicated(x = intervals$effect)
  out <- object
  out$intervals <- intervals
  out$est <- stats::setNames(
    object = intervals$estimate[first],
    nm = intervals$effect[first]
  )
  out$diagnostics <- object$diagnostics[intervals$diagnostic_id]
  out$family <- family
  class(x = out) <- "betalb"
  out
}
