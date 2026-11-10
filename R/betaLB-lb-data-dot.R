#' Prepare Standardized Covariance-Likelihood Statistics
#'
#' Center the actual analysis rows and retain units for partial
#' standardization.
#' Both moment covariance matrices describe sqrt(n) statistics.
#' @author Ivan Jacob Agaloos Pesigan
#' @param object An `lm` fit accepted by `.CheckLBInput()`.
#' @return A list containing data, units, covariance and moment covariances.
#' @examples
#' .LBData(object = stats::lm(formula = mpg ~ wt, data = mtcars))
#' @noRd
.LBData <- function(object) {
  .CheckLBInput(object = object)
  x_mat <- stats::model.matrix(object = object)[, -1L, drop = FALSE]
  z_mat <- cbind(stats::model.response(data = object$model), x_mat)
  n <- nrow(x = z_mat)
  k <- ncol(x = z_mat)
  d_mat <- sweep(
    x = z_mat, MARGIN = 2L,
    STATS = colMeans(x = z_mat), FUN = "-"
  )
  units <- sqrt(x = colSums(x = d_mat^2) / n)
  d_mat <- sweep(x = d_mat, MARGIN = 2L, STATS = units, FUN = "/")
  s_mat <- crossprod(x = d_mat) / n
  ij <- which(x = lower.tri(x = s_mat, diag = TRUE), arr.ind = TRUE)
  u_mat <- vapply(
    X = seq_len(length.out = nrow(x = ij)),
    FUN = function(j) {
      d_mat[, ij[j, 1L]] * d_mat[, ij[j, 2L]]
    }, FUN.VALUE = numeric(length = n)
  )
  u_mat <- sweep(
    x = u_mat, MARGIN = 2L,
    STATS = s_mat[ij], FUN = "-"
  )
  gamma_adf <- crossprod(x = u_mat) / n
  gamma_n <- matrix(data = 0, nrow = nrow(x = ij), ncol = nrow(x = ij))
  for (a in seq_len(length.out = nrow(x = ij))) {
    for (b in seq_len(length.out = nrow(x = ij))) {
      i <- ij[a, 1L]
      j <- ij[a, 2L]
      r <- ij[b, 1L]
      s <- ij[b, 2L]
      gamma_n[a, b] <- s_mat[i, r] * s_mat[j, s] +
        s_mat[i, s] * s_mat[j, r]
    }
  }
  list(
    sigma = s_mat, n = n, p = k - 1L, units = units, ij = ij,
    gamma_n = gamma_n, gamma_adf = gamma_adf,
    xnames = colnames(x = x_mat), rows = rownames(x = x_mat),
    call = stats::getCall(x = object)
  )
}
