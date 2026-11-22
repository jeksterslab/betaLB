#' Likelihood Intervals in the Layout of the Wald Intervals
#'
#' One row per effect; the columns are the estimate and the lower and upper
#' limits of each significance level, in increasing order of the percentile.
#' @author Ivan Jacob Agaloos Pesigan
#' @param object Object of class `betalb` or `eslb`.
#' @param alpha Numeric vector.
#'   Significance levels already computed, or `NULL` for all of them.
#' @return Numeric matrix with the attribute `status`, a data frame of the
#'   endpoint statuses.
#' @examples
#' # Used by the summary and confint methods.
#' @noRd
.LBCI <- function(object,
                  alpha = NULL) {
  stored <- object$args$alpha
  if (is.null(x = alpha)) {
    alpha <- stored
  }
  bad_alpha <- !is.numeric(x = alpha) || length(x = alpha) == 0L ||
    anyNA(x = alpha) ||
    any(x = vapply(
      X = alpha,
      FUN = function(a) {
        all(x = abs(x = stored - a) > 1e-12)
      },
      FUN.VALUE = logical(length = 1)
    ))
  if (bad_alpha) {
    stop("The requested significance level was not computed.")
  }
  intervals <- object$intervals
  effects <- names(x = object$est)
  cols <- lapply(
    X = alpha,
    FUN = function(a) {
      rows <- intervals[abs(x = intervals$alpha - a) <= 1e-12, , drop = FALSE]
      rows <- rows[match(x = effects, table = rows$effect), , drop = FALSE]
      out <- cbind(rows$lower, rows$upper)
      colnames(x = out) <- paste0(
        c(0.5 * a, 1 - 0.5 * a) * 100,
        "%"
      )
      out
    }
  )
  ci <- do.call(what = "cbind", args = cols)
  pct <- sub(pattern = "%", replacement = "", x = colnames(x = ci))
  ord <- order(as.numeric(x = pct))
  ci <- ci[, ord, drop = FALSE]
  out <- cbind(est = unname(obj = object$est), ci)
  rownames(x = out) <- effects
  status <- intervals[
    intervals$alpha %in% alpha,
    c("effect", "alpha", "lower_status", "upper_status"),
    drop = FALSE
  ]
  attr(x = out, which = "status") <- status
  out
}
