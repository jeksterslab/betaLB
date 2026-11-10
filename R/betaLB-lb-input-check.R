#' Check a Regression Fit for Covariance Likelihood Inference
#'
#' Require complete finite analysis rows and a nonsingular unweighted fit.
#' @author Ivan Jacob Agaloos Pesigan
#' @param object An unweighted scalar-response `lm` fit with an intercept.
#' @return Invisibly returns `TRUE`, or stops on unsupported inputs.
#' @examples
#' .CheckLBInput(object = stats::lm(formula = mpg ~ wt, data = mtcars))
#' @noRd
.CheckLBInput <- function(object) {
  bad_model <- !inherits(x = object, what = "lm") ||
    inherits(x = object, what = "mlm")
  if (bad_model) {
    stop("Use a scalar-response lm fit.")
  }
  if (!is.null(x = object$weights) || !is.null(x = object$offset)) {
    stop("Weights and offsets are not supported.")
  }
  if (is.null(x = object$model)) {
    stop("Refit with model = TRUE so the analysis rows are available.")
  }
  if (attr(x = stats::terms(x = object), which = "intercept") != 1L) {
    stop("An intercept is required.")
  }
  x_mat <- stats::model.matrix(object = object)
  bad_names <- is.null(x = colnames(x = x_mat)) ||
    anyDuplicated(x = colnames(x = x_mat))
  if (bad_names) {
    stop("Require distinct model-matrix column names.")
  }
  y <- stats::model.response(data = object$model)
  bad_data <- !is.numeric(x = y) || !is.null(x = dim(x = y)) ||
    any(x = !is.finite(x = c(x_mat, y)))
  if (bad_data) {
    stop("The analysis response and model matrix must be finite and numeric.")
  }
  bad_rank <- ncol(x = x_mat) < 2L || nrow(x = x_mat) <= ncol(x = x_mat) ||
    object$rank != ncol(x = x_mat)
  if (bad_rank) {
    stop("Require at least one predictor, full column rank, and n > p + 1.")
  }
  z_mat <- cbind(y, x_mat[, -1L, drop = FALSE])
  s_mat <- stats::cov(x = z_mat)
  singular <- any(x = diag(x = s_mat) <= 0) ||
    inherits(
      x = try(expr = chol(x = s_mat), silent = TRUE),
      what = "try-error"
    ) ||
    sum(object$residuals^2) <= .Machine$double.eps *
      sum((y - mean(x = y))^2)
  if (singular) {
    stop(
      "Require positive-definite covariance and nonzero residual variance."
    )
  }
  invisible(x = TRUE)
}
