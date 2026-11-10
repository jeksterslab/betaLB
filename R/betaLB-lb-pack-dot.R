#' Encode a Positive-Definite Matrix for Likelihood Optimization
#'
#' Store the lower Cholesky triangle in column order with logged diagonals.
#' @author Ivan Jacob Agaloos Pesigan
#' @param sigma Positive-definite covariance matrix.
#' @return Numeric vector of unconstrained Cholesky parameters.
#' @examples
#' .LBPack(sigma = diag(x = 2))
#' @noRd
.LBPack <- function(sigma) {
  l_mat <- t(x = chol(x = sigma))
  ij <- which(x = lower.tri(x = l_mat, diag = TRUE), arr.ind = TRUE)
  out <- l_mat[ij]
  diagonal <- ij[, 1L] == ij[, 2L]
  out[diagonal] <- log(x = out[diagonal])
  out
}
