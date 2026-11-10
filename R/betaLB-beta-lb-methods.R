#' Print Method for an Object of Class `betalb`
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @return Prints a matrix of estimates and confidence intervals.
#'
#' @param x Object of class `betalb`.
#' @param ... Additional arguments.
#' @param alpha Numeric vector.
#'   Significance level \eqn{\alpha}.
#'   If `alpha = NULL`,
#'   show all stored significance levels.
#' @param digits Digits to print.
#' @param type Stored calibration type; `NULL` selects all for printing.
#'
#' @examples
#' object <- structure(
#'   list(est = c(x = 0.5), args = list(type = "mvn", alpha = 0.05)),
#'   class = "betalb"
#' )
#' print(x = object)
#'
#' @keywords methods
#' @export
print.betalb <- function(x,
                         alpha = NULL,
                         digits = 4,
                         type = NULL,
                         ...) {
  print.summary.betalb(
    x = summary.betalb(
      object = x,
      alpha = alpha,
      digits = digits,
      type = type
    )
  )
  invisible(x = x)
}
#' Summary Method for an Object of Class `betalb`
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @return Returns a matrix or list of estimates and confidence intervals.
#'
#' @param object Object of class `betalb`.
#' @param ... Additional arguments.
#' @param alpha Numeric vector.
#'   Significance level \eqn{\alpha}.
#'   If `alpha = NULL`,
#'   show all stored significance levels.
#' @param digits Digits to print.
#' @param type Stored calibration type; `NULL` selects all.
#'
#' @examples
#' object <- structure(
#'   list(est = c(x = 0.5), args = list(type = "mvn", alpha = 0.05)),
#'   class = "betalb"
#' )
#' summary(object = object)
#'
#' @keywords methods
#' @export
summary.betalb <- function(object,
                           alpha = NULL,
                           digits = 4,
                           type = NULL,
                           ...) {
  bad_digits <- !is.numeric(x = digits) || length(x = digits) != 1L ||
    !is.finite(x = digits) || digits < 0 || digits != floor(x = digits)
  if (bad_digits) {
    stop("digits must be a nonnegative integer.")
  }
  if (!is.null(x = object$intervals)) {
    ci <- object$intervals
    if (!is.null(x = alpha)) {
      bad_alpha <- !is.numeric(x = alpha) || anyNA(x = alpha) ||
        any(x = !alpha %in% object$args$alpha)
      if (bad_alpha) {
        stop("The requested significance levels were not computed.")
      }
      ci <- ci[ci$alpha %in% alpha, , drop = FALSE]
    }
    if (!is.null(x = type)) {
      bad_type <- !is.character(x = type) || anyNA(x = type) ||
        any(x = !type %in% object$args$type)
      if (bad_type) {
        stop("The requested calibration types were not computed.")
      }
      ci <- ci[ci$type %in% type, , drop = FALSE]
    }
    print_summary <- ci[, c(
      "effect", "type", "alpha", "estimate", "lower",
      "upper", "lower_status", "upper_status",
      "calibration", "dimension"
    ), drop = FALSE]
    for (name in c("estimate", "lower", "upper")) {
      print_summary[[name]] <- round(
        x = print_summary[[name]], digits = digits
      )
    }
  } else {
    if (!is.null(x = alpha)) {
      stop("Selecting alpha is unavailable; use stored intervals.")
    }
    ci <- if (!is.null(x = object$ci)) {
      object$ci
    } else {
      matrix(
        data = object$est, ncol = 1,
        dimnames = list(names(x = object$est), "est")
      )
    }
    print_summary <- round(x = ci, digits = digits)
  }
  attr(
    x = ci,
    which = "fit"
  ) <- object
  attr(
    x = ci,
    which = "print_summary"
  ) <- print_summary
  attr(
    x = ci,
    which = "alpha"
  ) <- alpha
  attr(
    x = ci,
    which = "digits"
  ) <- digits
  class(x = ci) <- c("summary.betalb", class(x = ci))
  ci
}
#' Print a Likelihood Summary
#'
#' Display stored estimates and intervals without computing new intervals.
#' @author Ivan Jacob Agaloos Pesigan
#' @param x Object of class `summary.betalb`.
#' @param ... Additional arguments.
#' @return Invisibly returns `x`.
#' @examples
#' object <- structure(list(est = c(x = 0.5)), class = "betalb")
#' print(x = summary(object = object))
#' @noRd
#' @keywords internal
#' @exportS3Method print summary.betalb
print.summary.betalb <- function(x,
                                 ...) {
  print_summary <- attr(
    x = x,
    which = "print_summary"
  )
  object <- attr(
    x = x,
    which = "fit"
  )
  type <- object$args$type
  cat("Call:\n")
  print(x = object$call)
  cat(
    paste0(
      "\nLikelihood intervals (vector projections are conservative)\n",
      "type = ",
      "\"",
      paste(type, collapse = ", "),
      "\"",
      "\n"
    )
  )
  print(x = print_summary)
  invisible(x = x)
}
#' Sampling Variance-Covariance Matrix Method for an Object of Class `betalb`
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @return Stops with an error because profile likelihood intervals do not
#'   define a covariance matrix.
#'
#' @param object Object of class `betalb`.
#' @param ... Additional arguments.
#'
#' @examples
#' object <- structure(
#'   list(est = c(x = 0.5), args = list(type = "mvn", alpha = 0.05)),
#'   class = "betalb"
#' )
#' try(stats::vcov(object = object))
#'
#' @keywords methods
#' @export
vcov.betalb <- function(object,
                        ...) {
  stop("A covariance matrix is not defined for likelihood-based intervals.")
}
#' Estimated Parameter Method for an Object of Class `betalb`
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @return Returns a vector of estimated parameters.
#'
#' @param object Object of class `betalb`.
#' @param ... Additional arguments.
#'
#' @examples
#' object <- structure(
#'   list(est = c(x = 0.5), args = list(type = "mvn", alpha = 0.05)),
#'   class = "betalb"
#' )
#' stats::coef(object = object)
#'
#' @keywords methods
#' @export
coef.betalb <- function(object,
                        ...) {
  object$est
}
#' Confidence Intervals Method for an Object of Class `betalb`
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @return Returns a matrix of confidence intervals.
#'
#' @param object Object of class `betalb`.
#' @param ... Additional arguments.
#' @param parm A specification of which parameters
#'   are to be given confidence intervals.
#' @param level Confidence level of stored intervals.
#'   Only already-computed levels are available.
#' @param type Stored calibration type; `NULL` selects the first type.
#'
#' @examples
#' object <- structure(
#'   list(est = c(x = 0.5), args = list(type = "mvn", alpha = 0.05)),
#'   class = "betalb"
#' )
#' try(stats::confint(object = object))
#'
#' @keywords methods
#' @export
confint.betalb <- function(object,
                           parm = NULL,
                           level = 0.95,
                           type = NULL,
                           ...) {
  if (!is.null(x = object$intervals)) {
    ci <- .LBIntervals(
      object = object, parm = parm, level = level, type = type
    )
  } else {
    stored_alpha <- object$args$alpha
    if (is.null(x = stored_alpha)) {
      stored_alpha <- 0.05
    }
    if (!isTRUE(x = all.equal(target = level, current = 1 - stored_alpha))) {
      stop("Only the stored confidence level is available in the scaffold.")
    }
    if (is.null(x = object$ci)) {
      stop("Confidence intervals are not available.")
    } else {
      ci <- object$ci
      if (is.null(x = parm)) {
        ci
      } else {
        ci <- ci[parm, , drop = FALSE]
      }
    }
  }
  ci
}
