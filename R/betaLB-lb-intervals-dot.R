#' Select Stored Likelihood Confidence Intervals
#'
#' Match a single confidence level and calibration type, retaining dimensions.
#' @author Ivan Jacob Agaloos Pesigan
#' @param object Likelihood context or extracted effect object.
#' @param parm Parameter names or positive integer row indices; `NULL` for all.
#' @param level Scalar confidence level already computed by `LB()`.
#' @param type Stored calibration type; `NULL` selects the first type.
#' @return Matrix with lower and upper columns.
#' @examples
#' # Called by the confint methods; it never recomputes intervals.
#' @noRd
.LBIntervals <- function(object, parm, level, type) {
  bad_level <- !is.numeric(x = level) || length(x = level) != 1L ||
    !is.finite(x = level) || level <= 0 || level >= 1
  if (bad_level) {
    stop("level must be a single confidence level in (0, 1).")
  }
  distance <- abs(x = object$args$alpha - (1 - level))
  if (length(x = distance) == 0L || min(distance) > 1e-12) {
    stop("The requested confidence level was not computed.")
  }
  alpha <- object$args$alpha[which.min(x = distance)]
  if (is.null(x = type)) {
    type <- object$args$type[1L]
  }
  bad_type <- !is.character(x = type) || length(x = type) != 1L ||
    is.na(x = type) || !type %in% object$args$type
  if (bad_type) {
    stop("The requested calibration type was not computed.")
  }
  rows <- object$intervals$type == type & object$intervals$alpha == alpha
  intervals <- object$intervals[rows, , drop = FALSE]
  if (is.null(x = parm)) {
    select <- seq_len(length.out = nrow(x = intervals))
  } else if (is.character(x = parm) && !anyNA(x = parm)) {
    select <- match(x = parm, table = intervals$effect)
    if (anyNA(x = select)) {
      stop("parm contains an unknown parameter name.")
    }
  } else {
    valid_indices <- is.numeric(x = parm) && all(x = is.finite(x = parm)) &&
      all(x = parm == floor(x = parm)) &&
      all(x = parm >= 1 & parm <= nrow(x = intervals))
    if (valid_indices) {
      select <- as.integer(x = parm)
    } else {
      stop("parm must contain parameter names or positive row indices.")
    }
  }
  out <- as.matrix(x = intervals[select, c("lower", "upper"), drop = FALSE])
  rownames(x = out) <- intervals$effect[select]
  out
}
