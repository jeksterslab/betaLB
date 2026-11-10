#' Methods for a Batched Likelihood Context
#'
#' Display or select already-computed results without running the solver.
#' @author Ivan Jacob Agaloos Pesigan
#' @param x Object of class `lb`.
#' @param object Object of class `lb`.
#' @param digits Digits displayed by print methods.
#' @param alpha Stored significance levels; NULL selects all.
#' @param ... Arguments forwarded to the corresponding effect method.
#' @param parm Parameter names or positive row indices; `NULL` selects all.
#' @param level Confidence level already computed by `LB()`.
#' @param type Stored calibration type; `NULL` selects the first type.
#' @return Print methods invisibly return their input; summary returns stored
#'   interval rows; coef returns point estimates; confint returns a two-column
#'   matrix. vcov stops because likelihood intervals do not define a
#'   covariance.
#' @examples
#' fit <- stats::lm(formula = mpg ~ wt, data = mtcars)
#' out <- LB(object = fit, effects = "rsq", type = "mvn", alpha = 0.05)
#' stats::coef(object = out)
#' stats::confint(object = out)
#' @keywords methods
#' @export
print.lb <- function(x, alpha = NULL, digits = 4, type = NULL, ...) {
  .CheckLBContext(object = x)
  print.betalb(x = x, alpha = alpha, digits = digits, type = type, ...)
}
#' @rdname print.lb
#' @author Ivan Jacob Agaloos Pesigan
#' @export
summary.lb <- function(object, alpha = NULL, digits = 4, type = NULL, ...) {
  .CheckLBContext(object = object)
  summary.betalb(
    object = object, alpha = alpha, digits = digits, type = type, ...
  )
}
#' @rdname print.lb
#' @author Ivan Jacob Agaloos Pesigan
#' @export
coef.lb <- function(object, ...) {
  .CheckLBContext(object = object)
  object$est
}
#' @rdname print.lb
#' @author Ivan Jacob Agaloos Pesigan
#' @export
confint.lb <- function(object, parm = NULL, level = 0.95, type = NULL, ...) {
  .CheckLBContext(object = object)
  .LBIntervals(object = object, parm = parm, level = level, type = type)
}
#' @rdname print.lb
#' @author Ivan Jacob Agaloos Pesigan
#' @export
vcov.lb <- function(object, ...) {
  .CheckLBContext(object = object)
  vcov.betalb(object = object, ...)
}
