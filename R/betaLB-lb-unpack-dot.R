#' Decode Unconstrained Covariance Parameters
#'
#' Construct a lower Cholesky factor and its covariance matrix.
#' @author Ivan Jacob Agaloos Pesigan
#' @param par Numeric vector produced by `.LBPack()`.
#' @param k Positive integer, the covariance dimension.
#' @return A list containing the factor, covariance and triangle indices.
#' @examples
#' .LBUnpack(par = c(0, 0, 0), k = 2)
#' @noRd
.LBUnpack <- function(par, k) {
  l_mat <- matrix(data = 0, nrow = k, ncol = k)
  ij <- which(x = lower.tri(x = l_mat, diag = TRUE), arr.ind = TRUE)
  value <- par
  diagonal <- ij[, 1L] == ij[, 2L]
  value[diagonal] <- exp(x = value[diagonal])
  l_mat[ij] <- value
  list(l = l_mat, sigma = tcrossprod(x = l_mat), ij = ij)
}
