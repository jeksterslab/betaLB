#' Print Method for an Object of Class `betalb`
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @return Prints a matrix of
#'   standardized regression slopes,
#'   and the lower and upper limits of the likelihood intervals.
#'   Endpoints that the solver could not verify are reported below the matrix.
#'
#' @param x Object of class `betalb`.
#' @param ... additional arguments.
#' @param alpha Numeric vector.
#'   Significance level \eqn{\alpha}.
#'   If `alpha = NULL`,
#'   use the argument `alpha` used in `x`.
#' @param digits Digits to print.
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
#' out <- BetaLB(object = object, alpha = 0.05)
#'
#' ## Methods -----------------------------------------------------------------
#' print(x = out)
#'
#' @keywords methods
#' @export
print.betalb <- function(x,
                         alpha = NULL,
                         digits = 4,
                         ...) {
  print.summary.betalb(
    x = summary.betalb(
      object = x,
      alpha = alpha,
      digits = digits
    )
  )
}

#' Summary Method for an Object of Class `betalb`
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @return Returns a matrix of
#'   standardized regression slopes,
#'   and the lower and upper limits of the likelihood intervals.
#'
#' @param object Object of class `betalb`.
#' @param ... additional arguments.
#' @param alpha Numeric vector.
#'   Significance level \eqn{\alpha}.
#'   If `alpha = NULL`,
#'   use the argument `alpha` used in `object`.
#'   Only significance levels that were computed are available.
#' @param digits Digits to print.
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
#' out <- BetaLB(object = object, alpha = 0.05)
#'
#' ## Methods -----------------------------------------------------------------
#' summary(object = out)
#'
#' @keywords methods
#' @export
summary.betalb <- function(object,
                           alpha = NULL,
                           digits = 4,
                           ...) {
  bad_digits <- !is.numeric(x = digits) || length(x = digits) != 1L ||
    !is.finite(x = digits) || digits < 0 || digits != floor(x = digits)
  if (bad_digits) {
    stop("digits must be a nonnegative integer.")
  }
  ci <- .LBCI(
    object = object,
    alpha = alpha
  )
  print_summary <- round(
    x = ci,
    digits = digits
  )
  attr(
    x = print_summary,
    which = "status"
  ) <- NULL
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
  class(x = ci) <- "summary.betalb"
  ci
}

#' Print Method for an Object of Class `summary.betalb`
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @return Prints the matrix returned by `summary.betalb()`.
#'
#' @param x Object of class `summary.betalb`.
#' @param ... additional arguments.
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
#' out <- BetaLB(object = object, alpha = 0.05)
#'
#' ## Methods -----------------------------------------------------------------
#' print(x = summary(object = out))
#'
#' @keywords methods
#' @export
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
  cat("Call:\n")
  base::print(x = object$call)
  cat(
    "\nStandardized regression slopes with",
    toupper(x = object$args$type),
    "likelihood intervals:\n"
  )
  print(x = print_summary)
  status <- attr(
    x = x,
    which = "status"
  )
  failed <- status[
    !(status$lower_status %in% c("ok", "boundary_zero")) |
      !(status$upper_status %in% c("ok", "boundary_zero")), ,
    drop = FALSE
  ]
  if (nrow(x = failed) > 0L) {
    cat("\nEndpoints with a status other than ok:\n")
    print(x = failed, row.names = FALSE)
  }
  invisible(x = x)
}

#' Sampling Covariance Matrix Method for an Object of Class `betalb`
#'
#' Likelihood intervals do not come from a sampling covariance matrix.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @return Stops with an error.
#'
#' @param object Object of class `betalb`.
#' @param ... additional arguments.
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
#' out <- BetaLB(object = object, alpha = 0.05)
#'
#' # try ----------------------------------------------------------------------
#' try(vcov(object = out))
#'
#' @keywords methods
#' @export
vcov.betalb <- function(object,
                        ...) {
  stop("A covariance matrix is not defined for likelihood-based intervals.")
}

#' Estimated Parameters Method for an Object of Class `betalb`
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @return Returns a vector of standardized regression slopes.
#'
#' @param object Object of class `betalb`.
#' @param ... additional arguments.
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
#' out <- BetaLB(object = object, alpha = 0.05)
#'
#' ## Methods -----------------------------------------------------------------
#' coef(object = out)
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
#' @return Returns a matrix of the lower and upper limits
#'   of the likelihood intervals.
#'
#' @param object Object of class `betalb`.
#' @param ... additional arguments.
#' @param parm a specification of which parameters
#'   are to be given confidence intervals,
#'   either a vector of numbers or a vector of names.
#'   If missing, all parameters are considered.
#' @param level the confidence level required.
#'   The likelihood intervals are solved for the significance levels
#'   given in `alpha`, so `level` must equal `1 - alpha`
#'   for one of them.
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
#' out <- BetaLB(object = object, alpha = 0.05)
#'
#' ## Methods -----------------------------------------------------------------
#' confint(object = out, level = 0.95)
#'
#' @keywords methods
#' @export
confint.betalb <- function(object,
                           parm = NULL,
                           level = 0.95,
                           ...) {
  bad_level <- !is.numeric(x = level) || length(x = level) != 1L ||
    !is.finite(x = level) || level <= 0 || level >= 1
  if (bad_level) {
    stop("level must be a single confidence level in (0, 1).")
  }
  if (is.null(x = parm)) {
    parm <- seq_along(along.with = object$est)
  }
  ci <- .LBCI(
    object = object,
    alpha = 1 - level
  )[parm, 2:3, drop = FALSE]
  varnames <- colnames(x = ci)
  varnames <- gsub(
    pattern = "%",
    replacement = " %",
    x = varnames
  )
  colnames(x = ci) <- varnames
  attr(x = ci, which = "status") <- NULL
  ci
}
