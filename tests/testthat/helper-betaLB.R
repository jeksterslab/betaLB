# Shared test helpers (testthat sources helper-*.R before the tests).
# rProject writes this file once; it is yours after that.
#' Reuse One Small Batched Test Fit
#'
#' Avoid repeatedly solving the same fixture in extractor tests.
#' @author Ivan Jacob Agaloos Pesigan
#' @return An LB context with two predictors, types and confidence levels.
#' @examples
#' .LBFixture()
#' @noRd
.LBFixture <- local(expr = {
  cache <- NULL
  function() {
    if (is.null(x = cache)) {
      cache <<- betaLB::LB(
        object = stats::lm(formula = mpg ~ wt + hp, data = mtcars),
        type = c("mvn", "robust"), alpha = c(0.05, 0.10),
        blocks = list(both = c("wt", "hp"))
      )
    }
    cache
  }
})
# Slow tests: run on CI and on request, skipped in local builds and on CRAN.
.SkipSlow <- function() {
  testthat::skip_on_cran()
  testthat::skip_if_not(
    condition = Sys.getenv(x = "CI") == "true" ||
      Sys.getenv(x = "RPROJECT_SLOW_TESTS") == "true",
    message = "set RPROJECT_SLOW_TESTS=true to run slow tests"
  )
}
# Proprietary software: never on CI or CRAN, and only where it is found.
.SkipIfMissing <- function(program) {
  testthat::skip_on_cran()
  testthat::skip_on_ci()
  testthat::skip_if(
    condition = Sys.which(names = program) == "",
    message = paste0(program, " is not installed")
  )
}
#' Solve a Likelihood Region Independently with SLSQP
#'
#' This test-only reference does not call the native optimizer. Target and
#' likelihood gradients are checked separately against finite differences.
#' @author Ivan Jacob Agaloos Pesigan
#' @param data Analysis statistics from `.LBData()`.
#' @param target Smooth target descriptor.
#' @param type Normal-theory or robust calibration.
#' @param alpha Scalar significance level.
#' @param control Reference optimizer limits and verification tolerance.
#' @return Point estimate, interval, calibration and endpoint diagnostics.
#' @examples
#' # Called by the likelihood-reference tests after loading the package.
#' @noRd
.LBReference <- function(data, target, type = "mvn", alpha = 0.05,
                         control = list()) {
  control <- utils::modifyList(
    x = list(maxeval = 1000L, tolerance = 1e-8, starts = TRUE), val = control
  )
  k <- nrow(x = data$sigma)
  par0 <- betaLB:::.LBPack(sigma = data$sigma)
  decoded <- betaLB:::.LBUnpack(par = par0, k = k)
  smooth <- betaLB:::.LBEffect(
    sigma = data$sigma, target = target,
    units = data$units
  )
  calibration <- betaLB:::.LBCalibration(
    data = data, target = target,
    type = type, alpha = alpha
  )
  r <- length(x = smooth$value)
  nonnegative <- target$family %in% c(
    "pr", "rsq", "delta", "local_f", "block_f"
  )
  squared <- r > 1L
  estimate <- if (nonnegative) {
    sum(smooth$value^2)
  } else {
    smooth$value[1L]
  }
  if (calibration$status != "ok") {
    out <- list(
      estimate = estimate, interval = c(lower = NA_real_, upper = NA_real_),
      calibration = calibration, endpoints = list(),
      status = calibration$status
    )
  } else {
    cutoff <- calibration$cutoff
    # Exact covariance-to-Cholesky differential for deterministic Wald starts.
    j_par <- vapply(
      X = seq_along(along.with = par0), FUN = function(j) {
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
      }, FUN.VALUE = numeric(length = length(x = par0))
    )
    j_inverse <- solve(a = j_par)
    cov_par <- j_inverse %*% data$gamma_n %*% t(x = j_inverse) / data$n
    gradients <- t(x = j_par) %*% t(x = smooth$jacobian)
    starts <- list(par0)
    if (control$starts) {
      for (j in seq_len(length.out = r)) {
        direction <- drop(x = cov_par %*% gradients[, j])
        direction <- direction / sqrt(x = sum(direction * gradients[, j]))
        starts <- c(starts, list(
          par0 + 0.25 * sqrt(x = cutoff) * direction,
          par0 - 0.25 * sqrt(x = cutoff) * direction
        ))
      }
    }
    objective0 <- betaLB:::.LBObjective(
      par = par0, data = data,
      target = target, squared = squared
    )
    scale <- if (squared) {
      projected_gradient <- cov_par %*% objective0$gradient
      gradient_variance <- sum(objective0$gradient * projected_gradient)
      max(
        sqrt(x = cutoff * gradient_variance),
        cutoff * max(diag(x = calibration$v_n)) / data$n, 1e-10
      )
    } else {
      sqrt(x = cutoff * calibration$v_n[1L, 1L] / data$n)
    }
    null <- if (nonnegative) {
      betaLB:::.LBNull(data = data, index = if (target$family == "rsq") {
        seq_len(length.out = data$p)
      } else {
        target$index
      })
    } else {
      NULL
    }
    endpoints <- vector(mode = "list", length = 2L)
    for (side_id in 1:2) {
      side <- c(1, -1)[side_id]
      if (squared && side_id == 1L && null$loss <= cutoff) {
        endpoints[[side_id]] <- list(
          bound = 0, status = "boundary_zero",
          par = null$par, lr = null$loss,
          constraint = 0, stationarity = 0,
          optimizer = NA_integer_, attempts = list()
        )
      } else {
        candidates <- lapply(X = starts, FUN = function(start) {
          fit <- tryCatch(
            expr = nloptr::nloptr(
              x0 = start,
              eval_f = function(x) {
                z <- tryCatch(expr = betaLB:::.LBObjective(
                  par = x, data = data, target = target, squared = squared
                ), error = function(e) {
                  NULL
                })
                invalid <- is.null(x = z) || !is.finite(x = z$value) ||
                  any(x = !is.finite(x = z$gradient))
                if (invalid) {
                  list(
                    objective = 1e100,
                    gradient = numeric(length = length(x = x))
                  )
                } else {
                  list(
                    objective = side * z$value / scale,
                    gradient = side * z$gradient / scale
                  )
                }
              },
              eval_g_ineq = function(x) {
                z <- tryCatch(
                  expr = betaLB:::.LBLoss(par = x, data = data),
                  error = function(e) {
                    NULL
                  }
                )
                invalid <- is.null(x = z) || !is.finite(x = z$value) ||
                  any(x = !is.finite(x = z$gradient))
                if (invalid) {
                  list(
                    constraints = 1e100,
                    jacobian = numeric(length = length(x = x))
                  )
                } else {
                  list(
                    constraints = z$value / cutoff - 1,
                    jacobian = z$gradient / cutoff
                  )
                }
              },
              opts = list(
                algorithm = "NLOPT_LD_SLSQP", xtol_rel = 1e-11,
                ftol_rel = 1e-12, maxeval = control$maxeval,
                tol_constraints_ineq = 1e-10, print_level = 0
              )
            ), error = function(e) {
              e
            }
          )
          if (inherits(x = fit, what = "error")) {
            candidate <- list(
              bound = NA_real_, status = "optimizer_error",
              message = conditionMessage(c = fit)
            )
          } else {
            if (fit$status %in% 1:4) {
              fit$solution <- .LBReferencePolish(
                par = fit$solution, data = data, target = target,
                squared = squared, side = side, scale = scale, cutoff = cutoff
              )
            }
            z <- betaLB:::.LBObjective(
              par = fit$solution, data = data,
              target = target, squared = squared
            )
            loss <- betaLB:::.LBLoss(par = fit$solution, data = data)
            g <- side * z$gradient / scale
            h <- loss$gradient / cutoff
            multiplier <- -sum(g * h) / sum(h^2)
            residual <- max(abs(x = g + multiplier * h)) /
              max(1, max(abs(x = g)), abs(x = multiplier) * max(abs(x = h)))
            constraint <- abs(x = loss$value / cutoff - 1)
            ok <- fit$status %in% 1:4 && is.finite(x = residual) &&
              residual <= control$tolerance &&
              constraint <= control$tolerance &&
              multiplier >= -control$tolerance &&
              side * (z$value - objective0$value) <= control$tolerance
            candidate <- list(
              bound = if (ok) {
                z$value
              } else {
                NA_real_
              },
              status = if (ok) {
                "ok"
              } else {
                "verification_failed"
              },
              par = fit$solution, lr = loss$value,
              constraint = constraint, stationarity = residual,
              optimizer = fit$status, iterations = fit$iterations
            )
          }
          candidate
        })
        valid <- which(x = vapply(X = candidates, FUN = function(x) {
          x$status == "ok"
        }, FUN.VALUE = logical(length = 1)))
        if (length(x = valid) == 0L) {
          endpoints[[side_id]] <- list(
            bound = NA_real_,
            status = "verification_failed",
            attempts = candidates
          )
        } else {
          best <- valid[which.min(x = vapply(
            X = candidates[valid],
            FUN = function(x) {
              side * x$bound
            },
            FUN.VALUE = numeric(length = 1)
          ))]
          endpoints[[side_id]] <- candidates[[best]]
          endpoints[[side_id]]$attempts <- candidates
        }
      }
    }
    bounds <- vapply(
      X = endpoints, FUN = function(x) {
        x$bound
      },
      FUN.VALUE = numeric(length = 1)
    )
    if (nonnegative && !squared && all(x = is.finite(x = bounds))) {
      endpoints <- endpoints[
        c(which.min(x = bounds^2), which.max(x = bounds^2))
      ]
      bounds <- sort(x = bounds^2)
      if (null$loss <= cutoff) {
        bounds[1L] <- 0
        endpoints[[1L]] <- list(
          bound = 0, status = "boundary_zero",
          par = null$par, lr = null$loss,
          constraint = 0, stationarity = 0
        )
      }
      for (j in 1:2) {
        endpoints[[j]]$signed_bound <- endpoints[[j]]$bound
        endpoints[[j]]$bound <- bounds[j]
      }
    }
    names(x = bounds) <- c("lower", "upper")
    out <- list(
      estimate = estimate, interval = bounds, calibration = calibration,
      endpoints = endpoints, null_lr = if (is.null(x = null)) {
        NA_real_
      } else {
        null$loss
      },
      status = if (all(x = is.finite(x = bounds))) {
        "ok"
      } else {
        "failed"
      }
    )
  }
  out
}
#' Polish an Independently Optimized Reference Endpoint
#'
#' Solve the equality-endpoint KKT equations after successful SLSQP, using a
#' numerically differentiated Hessian of the analytic gradient.
#' @author Ivan Jacob Agaloos Pesigan
#' @param par Successful SLSQP endpoint parameters.
#' @param data Analysis covariance statistics.
#' @param target Smooth target descriptor.
#' @param squared Whether to optimize the squared norm.
#' @param side One for the lower endpoint, minus one for the upper.
#' @param scale Positive objective normalization.
#' @param cutoff Positive LR cutoff.
#' @return Polished parameters; retains the input if no improvement is
#'   possible.
#' @examples
#' # Used by .LBReference() only after successful SLSQP convergence.
#' @noRd
.LBReferencePolish <- function(
  par, data, target, squared, side, scale, cutoff
) {
  m <- length(x = par)
  z <- betaLB:::.LBObjective(
    par = par, data = data, target = target,
    squared = squared
  )
  loss <- betaLB:::.LBLoss(par = par, data = data)
  h <- loss$gradient / cutoff
  multiplier <- -sum(side * z$gradient / scale * h) / sum(h^2)
  for (i in 1:4) {
    z <- betaLB:::.LBObjective(
      par = par, data = data, target = target,
      squared = squared
    )
    loss <- betaLB:::.LBLoss(par = par, data = data)
    h <- loss$gradient / cutoff
    residual <- c(
      side * z$gradient / scale + multiplier * h,
      loss$value / cutoff - 1
    )
    if (max(abs(x = residual)) < 1e-11) {
      break
    }
    hessian <- stats::optimHess(
      par = par,
      fn = function(x) {
        side * betaLB:::.LBObjective(
          par = x, data = data, target = target,
          squared = squared
        )$value / scale +
          multiplier *
            (betaLB:::.LBLoss(par = x, data = data)$value / cutoff - 1)
      },
      gr = function(x) {
        side * betaLB:::.LBObjective(
          par = x, data = data, target = target,
          squared = squared
        )$gradient / scale +
          multiplier * betaLB:::.LBLoss(par = x, data = data)$gradient / cutoff
      }
    )
    system <- rbind(cbind(hessian, h), c(h, 0))
    step <- tryCatch(
      expr = solve(a = system, b = residual),
      error = function(e) {
        NULL
      }
    )
    if (is.null(x = step)) {
      break
    }
    accepted <- FALSE
    for (fraction in 2^-(0:12)) {
      candidate <- par - fraction * step[seq_len(length.out = m)]
      next_multiplier <- multiplier - fraction * step[m + 1L]
      trial <- tryCatch(expr = {
        zz <- betaLB:::.LBObjective(
          par = candidate, data = data,
          target = target, squared = squared
        )
        ll <- betaLB:::.LBLoss(par = candidate, data = data)
        c(
          side * zz$gradient / scale + next_multiplier * ll$gradient / cutoff,
          ll$value / cutoff - 1
        )
      }, error = function(e) {
        rep(x = Inf, times = m + 1L)
      })
      improved <- all(x = is.finite(x = trial)) &&
        sum(trial^2) < sum(residual^2)
      if (improved) {
        par <- candidate
        multiplier <- next_multiplier
        accepted <- TRUE
        break
      }
    }
    if (!accepted) {
      break
    }
  }
  par
}
