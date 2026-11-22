#' Print Method for an Object of Class `eslb`
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @return Prints a matrix of
#'   effect sizes,
#'   and the lower and upper limits of the likelihood intervals.
#'   Endpoints that the solver could not verify are reported below the matrix.
#'
#' @param x Object of class `eslb`.
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
#' std <- BetaLB(object = object, alpha = 0.05)
#'
#' # RSqLB --------------------------------------------------------------------
#' out <- RSqLB(object = std, alpha = 0.05)
#'
#' ## Methods -----------------------------------------------------------------
#' print(x = out)
#'
#' @keywords methods
#' @export
print.eslb <- function(x,
                       alpha = NULL,
                       digits = 4,
                       ...) {
  print.summary.eslb(
    x = summary.eslb(
      object = x,
      alpha = alpha,
      digits = digits
    )
  )
}

#' Summary Method for an Object of Class `eslb`
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @return Returns a matrix of
#'   effect sizes,
#'   and the lower and upper limits of the likelihood intervals.
#'
#' @param object Object of class `eslb`.
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
#' std <- BetaLB(object = object, alpha = 0.05)
#'
#' # RSqLB --------------------------------------------------------------------
#' out <- RSqLB(object = std, alpha = 0.05)
#'
#' ## Methods -----------------------------------------------------------------
#' summary(object = out)
#'
#' @keywords methods
#' @export
summary.eslb <- function(object,
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
  class(x = ci) <- "summary.eslb"
  ci
}

#' Print Method for an Object of Class `summary.eslb`
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @return Prints the matrix returned by `summary.eslb()`.
#'
#' @param x Object of class `summary.eslb`.
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
#' std <- BetaLB(object = object, alpha = 0.05)
#'
#' # RSqLB --------------------------------------------------------------------
#' out <- RSqLB(object = std, alpha = 0.05)
#'
#' ## Methods -----------------------------------------------------------------
#' print(x = summary(object = out))
#'
#' @keywords methods
#' @export
print.summary.eslb <- function(x,
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
  label <- switch(
    EXPR = object$fun,
    RSqLB = "R-squared and adjusted R-squared",
    SCorLB = "Semipartial correlations",
    PCorLB = "Squared partial correlations",
    DeltaRSqLB = "Improvement in R-squared",
    FSqLB = "Cohen's f-squared (fsq) and local f-squared",
    DiffBetaLB = "Differences of standardized regression slopes"
  )
  cat(
    "\n",
    label,
    " with ",
    toupper(x = object$fit$args$type),
    " likelihood intervals:\n",
    sep = ""
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

#' Sampling Covariance Matrix Method for an Object of Class `eslb`
#'
#' Likelihood intervals do not come from a sampling covariance matrix.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @return Stops with an error.
#'
#' @param object Object of class `eslb`.
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
#' std <- BetaLB(object = object, alpha = 0.05)
#'
#' # RSqLB --------------------------------------------------------------------
#' out <- RSqLB(object = std, alpha = 0.05)
#'
#' # try ----------------------------------------------------------------------
#' try(vcov(object = out))
#'
#' @keywords methods
#' @export
vcov.eslb <- function(object,
                      ...) {
  stop("A covariance matrix is not defined for likelihood-based intervals.")
}

#' Estimated Parameters Method for an Object of Class `eslb`
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @return Returns a vector of effect sizes.
#'
#' @param object Object of class `eslb`.
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
#' std <- BetaLB(object = object, alpha = 0.05)
#'
#' # RSqLB --------------------------------------------------------------------
#' out <- RSqLB(object = std, alpha = 0.05)
#'
#' ## Methods -----------------------------------------------------------------
#' coef(object = out)
#'
#' @keywords methods
#' @export
coef.eslb <- function(object,
                      ...) {
  object$est
}

#' Confidence Intervals Method for an Object of Class `eslb`
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @return Returns a matrix of the lower and upper limits
#'   of the likelihood intervals.
#'
#' @param object Object of class `eslb`.
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
#' std <- BetaLB(object = object, alpha = 0.05)
#'
#' # RSqLB --------------------------------------------------------------------
#' out <- RSqLB(object = std, alpha = 0.05)
#'
#' ## Methods -----------------------------------------------------------------
#' confint(object = out, level = 0.95)
#'
#' @keywords methods
#' @export
confint.eslb <- function(object,
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
