#' Fit a Zero Slope-Block Null Under Joint Gaussian Likelihood
#'
#' Regress the response on the complement and retain the sample predictor
#' covariance. The LR is independently checked using residual sums of squares.
#' @author Ivan Jacob Agaloos Pesigan
#' @param data Analysis statistics from `.LBData()`.
#' @param index Predictor columns fixed to zero; omit for all predictors.
#' @return Restricted covariance, Cholesky parameters and zero-null LR.
#' @examples
#' d <- .LBData(object = stats::lm(formula = mpg ~ wt, data = mtcars))
#' .LBNull(data = d)
#' @noRd
.LBNull <- function(data, index = seq_len(length.out = data$p)) {
  a_mat <- data$sigma[-1L, -1L, drop = FALSE]
  c_vec <- data$sigma[-1L, 1L]
  complement <- setdiff(x = seq_len(length.out = data$p), y = index)
  beta <- rep(x = 0, times = data$p)
  if (length(x = complement) > 0L) {
    beta[complement] <- solve(
      a = a_mat[complement, complement, drop = FALSE],
      b = c_vec[complement]
    )
  }
  error_reduced <- data$sigma[1L, 1L] - sum(c_vec * beta)
  error_full <- data$sigma[1L, 1L] -
    sum(c_vec * solve(a = a_mat, b = c_vec))
  sigma <- data$sigma
  sigma[-1L, 1L] <- sigma[1L, -1L] <- drop(x = a_mat %*% beta)
  par <- .LBPack(sigma = sigma)
  list(
    sigma = sigma, par = par,
    loss = data$n * log(x = error_reduced / error_full)
  )
}
