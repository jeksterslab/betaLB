#' Map Smooth Endpoints to Reported Regression Effects
#'
#' Square whole signed intervals and transform overall R-squared without
#' recalibrating its region. Independently verify a feasible zero minimum.
#' @author Ivan Jacob Agaloos Pesigan
#' @param endpoints Two native endpoint records.
#' @param data Analysis covariance statistics.
#' @param target Target descriptor including image type.
#' @param request Native request, or `NULL` for failed calibration.
#' @return Estimate, lower/upper bounds and diagnostic records.
#' @examples
#' # Used after the native batch call; see the interval tests.
#' @noRd
.LBFinish <- function(endpoints, data, target, request) {
  smooth <- .LBEffect(
    sigma = data$sigma, target = target, units = data$units
  )$value
  nonnegative <- target$image != "identity"
  estimate <- if (nonnegative) {
    sum(smooth^2)
  } else {
    smooth[1L]
  }
  bounds <- vapply(
    X = endpoints, FUN = function(x) {
      x$bound
    },
    FUN.VALUE = numeric(length = 1)
  )
  if (nonnegative && length(x = smooth) == 1L) {
    if (all(x = is.finite(x = bounds))) {
      select <- c(which.min(x = bounds^2), which.max(x = bounds^2))
      endpoints <- endpoints[select]
      bounds <- sort(x = bounds^2)
    } else {
      bounds[] <- NA_real_
      endpoints <- lapply(X = endpoints, FUN = function(x) {
        if (x$status %in% c("ok", "boundary_zero")) {
          x$status <- "verification_failed"
        }
        x
      })
    }
    if (!is.null(x = request) && request$null_lr <= request$cutoff) {
      null <- .LBLoss(par = request$null_par, data = data)
      null_effect <- .LBEffect(
        sigma = null$sigma, target = target,
        units = data$units
      )$value
      feasible_zero <- is.finite(x = null$value) &&
        max(abs(x = null_effect)) < 1e-10 &&
        null$value <= request$cutoff * (1 + 1e-10)
      if (feasible_zero) {
        bounds[1L] <- 0
        endpoints[[1L]] <- list(
          bound = 0, par = request$null_par,
          status = "boundary_zero", lr = null$value,
          constraint = 0, stationarity = 0,
          evaluations = 1L, iterations = 0L, retries = 0L,
          backend = "cpp"
        )
      }
    }
  }
  if (target$family %in% c("rsq", "pr", "delta")) {
    invalid <- which(x = is.finite(x = bounds) & (bounds < 0 | bounds >= 1))
    for (j in invalid) {
      bounds[j] <- NA_real_
      endpoints[[j]]$status <- "invalid_effect_bound"
    }
  }
  values <- c(estimate, bounds)
  if (target$image == "fsq") {
    values <- values / (1 - values)
  } else if (target$image == "adjusted") {
    values <- 1 - (1 - values) * (data$n - 1) / (data$n - data$p - 1)
  }
  for (j in 1:2) {
    endpoints[[j]]$smooth_bound <- endpoints[[j]]$bound
    endpoints[[j]]$bound <- values[j + 1L]
    endpoints[[j]]$image <- target$image
  }
  list(
    estimate = values[1L], lower = values[2L], upper = values[3L],
    endpoints = endpoints
  )
}
