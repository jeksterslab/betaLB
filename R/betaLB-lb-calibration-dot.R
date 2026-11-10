#' Calibrate a Scalar or Projected Vector Likelihood Region
#'
#' Freeze the robust scale at the unrestricted fit. Vector regions use the
#' largest generalized eigenvalue, with no inverse of the full ADF matrix.
#' @author Ivan Jacob Agaloos Pesigan
#' @param data Analysis statistics from `.LBData()`.
#' @param target Smooth target descriptor.
#' @param type Either `mvn` or `robust`.
#' @param alpha Scalar significance level in (0, 1).
#' @return Calibration, cutoff, covariance matrices, eigenvalues and status.
#' @examples
#' d <- .LBData(object = stats::lm(formula = mpg ~ wt, data = mtcars))
#' .LBCalibration(
#'   data = d, target = list(family = "sr", index = 1),
#'   type = "mvn", alpha = 0.05
#' )
#' @noRd
.LBCalibration <- function(data, target, type, alpha) {
  type <- match.arg(arg = type, choices = c("mvn", "robust"))
  stopifnot(
    is.numeric(x = alpha), length(x = alpha) == 1L,
    is.finite(x = alpha), alpha > 0, alpha < 1
  )
  effect <- .LBEffect(sigma = data$sigma, target = target, units = data$units)
  b_mat <- effect$jacobian
  r <- nrow(x = b_mat)
  v_n <- b_mat %*% data$gamma_n %*% t(x = b_mat)
  v_r <- b_mat %*% data$gamma_adf %*% t(x = b_mat)
  out <- list(
    dimension = r, cutoff = NA_real_, scale = NA_real_,
    eigenvalues = rep(x = NA_real_, times = r), v_n = v_n,
    v_r = v_r, status = "rank_failure",
    calibration = if (r == 1L) {
      "scalar_profile"
    } else {
      "vector_projection"
    }
  )
  eig_n <- eigen(x = v_n, symmetric = TRUE, only.values = TRUE)$values
  full_rank <- all(x = is.finite(x = eig_n)) &&
    min(eig_n) > max(eig_n) * 1e-12
  if (full_rank) {
    if (type == "mvn") {
      out$scale <- 1
      out$eigenvalues <- rep(x = 1, times = r)
      out$status <- "ok"
    } else {
      inverse <- backsolve(r = chol(x = v_n), x = diag(x = r))
      eigenvalues <- eigen(
        x = t(x = inverse) %*% v_r %*% inverse,
        symmetric = TRUE, only.values = TRUE
      )$values
      valid_scale <- all(x = is.finite(x = eigenvalues)) &&
        min(eigenvalues) > max(eigenvalues) * 1e-12 &&
        max(eigenvalues) > 0
      if (valid_scale) {
        out$eigenvalues <- eigenvalues
        out$scale <- max(eigenvalues)
        out$status <- "ok"
      } else {
        out$status <- "degenerate_robust_scale"
      }
    }
    if (out$status == "ok") {
      out$cutoff <- out$scale * stats::qchisq(
        p = alpha, df = r,
        lower.tail = FALSE
      )
      if (!is.finite(x = out$cutoff) || out$cutoff <= 0) {
        out$status <- "nonfinite_cutoff"
      }
    }
  }
  out
}
