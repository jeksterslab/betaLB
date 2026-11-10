#' Evaluate Smooth Regression Targets and Covariance Derivatives
#'
#' Return signed scalar targets or whitened vectors before squaring them.
#' Directional matrix calculus avoids differencing eigenvector signs.
#' @author Ivan Jacob Agaloos Pesigan
#' @param sigma Candidate covariance in the analysis units.
#' @param target List with family, index and optional standardization flags.
#' @param units Original variable SDs; use ones for original-unit covariance.
#' @return List with the smooth target vector and its vech Jacobian.
#' @examples
#' .LBEffect(
#'   sigma = diag(x = 2),
#'   target = list(family = "sr", index = 1), units = c(1, 1)
#' )
#' @noRd
.LBEffect <- function(
  sigma, target, units = rep(x = 1, times = nrow(x = sigma))
) {
  k <- nrow(x = sigma)
  p <- k - 1L
  ij <- which(x = lower.tri(x = sigma, diag = TRUE), arr.ind = TRUE)
  sigma <- sigma * tcrossprod(x = units)
  a_mat <- sigma[-1L, -1L, drop = FALSE]
  c_vec <- sigma[-1L, 1L]
  vy <- sigma[1L, 1L]
  inverse <- chol2inv(x = chol(x = a_mat))
  beta <- drop(x = inverse %*% c_vec)
  error <- vy - sum(c_vec * beta)
  singular <- !all(x = is.finite(x = inverse)) ||
    !is.finite(x = error) || error <= 0
  if (singular) {
    stop("Candidate covariance is numerically singular.")
  }
  idx <- target$index
  family <- match.arg(
    arg = target$family,
    choices = c(
      "beta", "diff", "sr", "pr", "local_f",
      "rsq", "delta", "block_f"
    )
  )
  std_x <- target$std_x
  if (is.null(x = std_x)) {
    std_x <- rep(x = TRUE, times = p)
  }
  std_y <- target$std_y
  if (is.null(x = std_y)) {
    std_y <- TRUE
  }
  beta_scale <- diag(x = a_mat)^(std_x / 2) / vy^(std_y / 2)
  if (family %in% c("beta", "diff")) {
    value <- beta[idx] * beta_scale[idx]
    if (family == "diff") {
      value <- value[1L] - value[2L]
    }
  } else if (family %in% c("sr", "pr", "local_f")) {
    vj <- 1 / inverse[idx, idx]
    denominator <- switch(EXPR = family,
      sr = vy,
      pr = error + beta[idx]^2 * vj,
      local_f = error
    )
    value <- beta[idx] * sqrt(x = vj / denominator)
  } else {
    if (family == "rsq") {
      idx <- seq_len(length.out = p)
    }
    complement <- setdiff(x = seq_len(length.out = p), y = idx)
    a_cond <- a_mat[idx, idx, drop = FALSE]
    c_cond <- c_vec[idx]
    if (length(x = complement) > 0L) {
      inverse_c <- chol2inv(
        x = chol(x = a_mat[complement, complement, drop = FALSE])
      )
      projection <- inverse_c %*% a_mat[complement, idx, drop = FALSE]
      beta_c <- drop(x = inverse_c %*% c_vec[complement])
      a_cond <- a_cond - a_mat[idx, complement, drop = FALSE] %*% projection
      c_cond <- c_cond - drop(
        x = a_mat[idx, complement, drop = FALSE] %*% beta_c
      )
    }
    sd_cond <- sqrt(x = diag(x = a_cond))
    r_mat <- a_cond / tcrossprod(x = sd_cond)
    eig <- eigen(x = r_mat, symmetric = TRUE)
    if (any(x = !is.finite(x = eig$values)) || min(eig$values) <= 0) {
      stop("Candidate conditional covariance is numerically singular.")
    }
    roots <- sqrt(x = eig$values)
    inverse_root <- tcrossprod(
      x = sweep(
        x = eig$vectors, MARGIN = 2L,
        STATS = roots, FUN = "/"
      ),
      y = eig$vectors
    )
    denominator <- if (family == "block_f") {
      error
    } else {
      vy
    }
    r_vec <- c_cond / sd_cond / sqrt(x = denominator)
    value <- drop(x = inverse_root %*% r_vec)
  }
  # Differentiate each covariance coordinate, including both symmetric entries.
  jacobian <- vapply(
    X = seq_len(length.out = nrow(x = ij)),
    FUN = function(q) {
      d_sigma <- matrix(data = 0, nrow = k, ncol = k)
      i <- ij[q, 1L]
      j <- ij[q, 2L]
      d_sigma[i, j] <- d_sigma[j, i] <- units[i] * units[j]
      d_a <- d_sigma[-1L, -1L, drop = FALSE]
      d_c <- d_sigma[-1L, 1L]
      d_vy <- d_sigma[1L, 1L]
      d_beta <- drop(x = inverse %*% (d_c - d_a %*% beta))
      d_error <- d_vy - 2 * sum(d_c * beta) +
        drop(x = crossprod(x = beta, y = d_a %*% beta))
      if (family %in% c("beta", "diff")) {
        derivative <- beta_scale * d_beta + beta * beta_scale * (
          std_x * diag(x = d_a) / diag(x = a_mat) / 2 -
            std_y * d_vy / vy / 2
        )
        derivative <- derivative[idx]
        if (family == "diff") {
          derivative <- derivative[1L] - derivative[2L]
        }
      } else if (family %in% c("sr", "pr", "local_f")) {
        d_vj <- vj^2 * (inverse %*% d_a %*% inverse)[idx, idx]
        d_denominator <- switch(
          EXPR = family,
          sr = d_vy,
          local_f = d_error,
          pr = d_error + 2 * beta[idx] * d_beta[idx] * vj +
            beta[idx]^2 * d_vj
        )
        derivative <- d_beta[idx] * sqrt(x = vj / denominator) +
          value / 2 * (d_vj / vj - d_denominator / denominator)
      } else {
        d_ac <- d_a[idx, idx, drop = FALSE]
        d_cc <- d_c[idx]
        if (length(x = complement) > 0L) {
          d_acc <- d_a[complement, complement, drop = FALSE]
          d_atc <- d_a[idx, complement, drop = FALSE]
          d_ac <- d_ac - d_atc %*% projection -
            t(x = projection) %*% t(x = d_atc) +
            t(x = projection) %*% d_acc %*% projection
          adjusted_c <- d_c[complement] - d_acc %*% beta_c
          d_cc <- d_cc - drop(x = d_atc %*% beta_c) -
            drop(
              x = a_mat[idx, complement, drop = FALSE] %*%
                inverse_c %*% adjusted_c
            )
        }
        ratio <- diag(x = d_ac) / diag(x = a_cond) / 2
        d_r <- d_ac / tcrossprod(x = sd_cond) -
          r_mat * outer(X = ratio, Y = ratio, FUN = "+")
        d_denominator <- if (family == "block_f") {
          d_error
        } else {
          d_vy
        }
        d_rvec <- d_cc / sd_cond / sqrt(x = denominator) -
          r_vec * (ratio + d_denominator / denominator / 2)
        # Frechet derivative of x^(-1/2), stable at repeated eigenvalues.
        root_products <- outer(X = roots, Y = roots, FUN = "*")
        root_sums <- outer(X = roots, Y = roots, FUN = "+")
        divided <- -1 / (root_products * root_sums)
        d_root <- eig$vectors %*% (
          divided * (t(x = eig$vectors) %*% d_r %*% eig$vectors)
        ) %*% t(x = eig$vectors)
        derivative <- drop(x = inverse_root %*% d_rvec + d_root %*% r_vec)
      }
      as.numeric(x = derivative)
    }, FUN.VALUE = numeric(length = length(x = value))
  )
  list(
    value = as.numeric(x = value),
    jacobian = matrix(data = jacobian, nrow = length(x = value))
  )
}
