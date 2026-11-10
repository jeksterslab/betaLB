#' Evaluate Gaussian Covariance Likelihood Loss and Gradient
#'
#' Compare a candidate covariance with its unrestricted divisor-n estimate.
#' @author Ivan Jacob Agaloos Pesigan
#' @param par Unconstrained lower-Cholesky parameters.
#' @param data A list produced by `.LBData()`.
#' @return A list containing LR loss, parameter gradient and covariance.
#' @examples
#' d <- .LBData(object = stats::lm(formula = mpg ~ wt, data = mtcars))
#' .LBLoss(par = .LBPack(sigma = d$sigma), data = d)
#' @noRd
.LBLoss <- function(par, data) {
  k <- nrow(x = data$sigma)
  decoded <- .LBUnpack(par = par, k = k)
  inv_l <- backsolve(r = t(x = decoded$l), x = diag(x = k))
  inverse <- tcrossprod(x = inv_l)
  whitened <- forwardsolve(l = decoded$l, x = data$sigma)
  whitened <- forwardsolve(l = decoded$l, x = t(x = whitened))
  value <- data$n * (
    2 * sum(log(x = diag(x = decoded$l))) -
      2 * sum(log(x = diag(x = chol(x = data$sigma)))) +
      sum(diag(x = whitened)) - k
  )
  g_mat <- data$n * (inverse - inverse %*% data$sigma %*% inverse)
  g_l <- 2 * g_mat %*% decoded$l
  gradient <- g_l[decoded$ij]
  diagonal <- decoded$ij[, 1L] == decoded$ij[, 2L]
  gradient[diagonal] <- gradient[diagonal] * diag(x = decoded$l)
  list(value = value, gradient = gradient, sigma = decoded$sigma)
}
