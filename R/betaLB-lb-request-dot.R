#' Prepare Deterministic Native Endpoint Requests
#'
#' Use covariance-based Wald directions only for starts and normalization;
#' reported endpoints must satisfy the likelihood and KKT checks.
#' @author Ivan Jacob Agaloos Pesigan
#' @param data Analysis covariance statistics.
#' @param target Smooth target descriptor and image type.
#' @param calibration Successful fixed-cutoff calibration.
#' @return Native request with starts, target encoding and independent null
#'   fit.
#' @examples
#' d <- .LBData(object = stats::lm(formula = mpg ~ wt, data = mtcars))
#' t <- list(family = "sr", index = 1, image = "identity")
#' .LBRequest(data = d, target = t, calibration = .LBCalibration(
#'   data = d, target = t, type = "mvn", alpha = 0.05
#' ))
#' @noRd
.LBRequest <- function(data, target, calibration) {
  k <- nrow(x = data$sigma)
  par <- .LBPack(sigma = data$sigma)
  decoded <- .LBUnpack(par = par, k = k)
  smooth <- .LBEffect(sigma = data$sigma, target = target, units = data$units)
  r <- length(x = smooth$value)
  j_par <- vapply(
    X = seq_along(along.with = par), FUN = function(j) {
      dl <- matrix(data = 0, nrow = k, ncol = k)
      i <- decoded$ij[j, 1L]
      q <- decoded$ij[j, 2L]
      dl[i, q] <- if (i == q) {
        decoded$l[i, i]
      } else {
        1
      }
      ds <- dl %*% t(x = decoded$l) + decoded$l %*% t(x = dl)
      ds[decoded$ij]
    }, FUN.VALUE = numeric(length = length(x = par))
  )
  j_inverse <- solve(a = j_par)
  cov_par <- j_inverse %*% data$gamma_n %*% t(x = j_inverse) / data$n
  gradients <- t(x = j_par) %*% t(x = smooth$jacobian)
  starts <- matrix(data = par, ncol = 1L)
  for (j in seq_len(length.out = r)) {
    direction <- drop(x = cov_par %*% gradients[, j])
    direction <- direction / sqrt(x = sum(direction * gradients[, j]))
    starts <- cbind(
      starts, par + 0.25 * sqrt(x = calibration$cutoff) * direction,
      par - 0.25 * sqrt(x = calibration$cutoff) * direction
    )
  }
  squared <- r > 1L
  objective <- .LBObjective(
    par = par, data = data, target = target,
    squared = squared
  )
  scale <- if (squared) {
    projected_gradient <- cov_par %*% objective$gradient
    gradient_variance <- sum(objective$gradient * projected_gradient)
    max(
      sqrt(x = calibration$cutoff * gradient_variance),
      calibration$cutoff * max(diag(x = calibration$v_n)) / data$n, 1e-10
    )
  } else {
    sqrt(x = calibration$cutoff * calibration$v_n[1L, 1L] / data$n)
  }
  nonnegative <- target$family %in% c(
    "pr", "rsq", "delta", "local_f", "block_f"
  )
  index <- if (target$family == "rsq") {
    seq_len(length.out = data$p)
  } else {
    target$index
  }
  null <- if (nonnegative) {
    .LBNull(data = data, index = index)
  } else {
    list(loss = Inf, par = numeric(length = 0))
  }
  std_x <- target$std_x
  if (is.null(x = std_x)) {
    std_x <- rep(x = TRUE, times = data$p)
  }
  std_y <- target$std_y
  if (is.null(x = std_y)) {
    std_y <- TRUE
  }
  families <- c(
    "beta", "diff", "sr", "pr", "local_f", "rsq", "delta", "block_f"
  )
  list(
    family = match(x = target$family, table = families) - 1L,
    index = as.integer(x = index - 1L), std_x = as.numeric(x = std_x),
    std_y = std_y, squared = squared, starts = starts, scale = scale,
    cutoff = calibration$cutoff, null_lr = null$loss, null_par = null$par,
    key = paste(target$family, paste(index, collapse = ","),
      paste(std_x, collapse = ","), std_y,
      sep = ":"
    )
  )
}
