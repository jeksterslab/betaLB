#' Chain a Smooth Regression Target Through Cholesky Parameters
#'
#' Evaluate a signed scalar or squared norm and its analytic gradient.
#' @author Ivan Jacob Agaloos Pesigan
#' @param par Unconstrained Cholesky parameters.
#' @param data Analysis statistics from `.LBData()`.
#' @param target Target descriptor accepted by `.LBEffect()`.
#' @param squared Logical; whether to profile the vector's squared norm.
#' @return List with objective, parameter gradient and smooth target details.
#' @examples
#' d <- .LBData(object = stats::lm(formula = mpg ~ wt, data = mtcars))
#' .LBObjective(
#'   par = .LBPack(sigma = d$sigma), data = d,
#'   target = list(family = "rsq"), squared = TRUE
#' )
#' @noRd
.LBObjective <- function(par, data, target, squared = FALSE) {
  decoded <- .LBUnpack(par = par, k = nrow(x = data$sigma))
  effect <- .LBEffect(
    sigma = decoded$sigma, target = target,
    units = data$units
  )
  if (squared) {
    value <- sum(effect$value^2)
    derivative <- drop(x = 2 * crossprod(
      x = effect$value,
      y = effect$jacobian
    ))
  } else {
    value <- effect$value[1L]
    derivative <- effect$jacobian[1L, ]
  }
  g_mat <- matrix(
    data = 0, nrow = nrow(x = data$sigma),
    ncol = ncol(x = data$sigma)
  )
  diagonal <- decoded$ij[, 1L] == decoded$ij[, 2L]
  derivative[!diagonal] <- derivative[!diagonal] / 2
  g_mat[decoded$ij] <- derivative
  g_mat <- g_mat + t(x = g_mat) - diag(x = diag(x = g_mat))
  g_l <- 2 * g_mat %*% decoded$l
  gradient <- g_l[decoded$ij]
  gradient[diagonal] <- gradient[diagonal] * diag(x = decoded$l)
  list(value = value, gradient = gradient, effect = effect)
}
