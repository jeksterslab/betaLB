#' Likelihood Intervals for Regression Effect Sizes
#'
#' Fit covariance-likelihood regions for independently sampled random
#' regressors. Compute requested effects, types and confidence levels in one
#' native batch, then use the effect extractors to select stored results.
#'
#' Normal theory uses divisor-n Gaussian covariance likelihood. Robust
#' calibration uses empirical fourth moments. Signed scalar targets use a
#' target-specific variance ratio; multi-coefficient nonnegative effects use
#' conservative vector projection and a largest-eigenvalue robust cutoff.
#' These are asymptotic procedures, without a finite-sample coverage guarantee.
#' @author Ivan Jacob Agaloos Pesigan
#' @param object Unweighted, full-rank scalar-response `lm` fit with an
#'   intercept, stored model frame, no offsets and positive residual variance.
#' @param type Character vector containing `mvn`, `robust`, or both.
#' @param alpha Distinct significance levels in (0, 1).
#' @param effects Requested families: `beta`, `rsq`, `scor`, `pcor`,
#'   `deltarsq`, `diffbeta`, and `fsq`.
#' @param std_y Whether to standardize the response for slope targets.
#' @param std_x Logical flags or names of model-matrix predictors to
#'   standardize for slope targets. Other effects keep their definitions.
#' @param blocks Named list of additional predictor blocks, identified by
#'   model-matrix column names or indices, for increments and local f-squared.
#' @param control Named list: `maxeval` is the native evaluation budget per
#'   endpoint; `tolerance` is its normalized verification tolerance.
#' @return Context of class `lb`, containing named point estimates, a long
#'   `intervals` table and per-row endpoint `diagnostics`. Failed endpoints
#'   are `NA` with a specific status. Extractors return `betalb` objects.
#'   Slope/contrast target IDs retain their standardization flags.
#' @examples
#' fit <- stats::lm(formula = mpg ~ wt, data = mtcars)
#' out <- LB(object = fit, type = "mvn", alpha = 0.05, effects = "rsq")
#' RSqLB(object = out)
#' @export
LB <- function(object, type = c("mvn", "robust"),
               alpha = c(0.05, 0.01, 0.001),
               effects = c(
                 "beta", "rsq", "scor", "pcor", "deltarsq",
                 "diffbeta", "fsq"
               ),
               std_y = TRUE, std_x = TRUE, blocks = list(), control = list()) {
  data <- .LBData(object = object)
  args <- .CheckLBArguments(
    type = type, alpha = alpha, effects = effects,
    std_y = std_y, std_x = std_x, blocks = blocks,
    control = control, data = data
  )
  targets <- .LBTargets(data = data, args = args)
  base <- list()
  views <- list()
  for (target in targets) {
    for (type in args$type) {
      for (alpha in args$alpha) {
        key <- paste(target$family, paste(target$index, collapse = ","),
          type, sprintf(fmt = "%.17g", alpha),
          sep = ":"
        )
        if (!key %in% names(x = base)) {
          calibration <- .LBCalibration(
            data = data, target = target,
            type = type, alpha = alpha
          )
          request <- if (calibration$status == "ok") {
            .LBRequest(data = data, target = target, calibration = calibration)
          } else {
            NULL
          }
          failure <- list(
            bound = NA_real_, status = calibration$status,
            lr = NA_real_, constraint = NA_real_,
            stationarity = NA_real_, evaluations = 0L,
            iterations = 0L, retries = 0L, backend = "cpp"
          )
          base[[key]] <- list(
            request = request, calibration = calibration,
            endpoints = list(failure, failure)
          )
        }
        views[[length(x = views) + 1L]] <- list(
          target = target, key = key,
          type = type, alpha = alpha
        )
      }
    }
  }
  valid <- which(x = vapply(X = base, FUN = function(x) {
    !is.null(x = x$request)
  }, FUN.VALUE = logical(length = 1)))
  if (length(x = valid) > 0L) {
    solved <- .LBBatchCpp(
      sample = data$sigma, units = data$units, n = data$n,
      requests = lapply(X = base[valid], FUN = function(x) {
        x$request
      }),
      tolerance = args$control$tolerance,
      maxeval = as.integer(x = args$control$maxeval)
    )
    for (j in seq_along(along.with = valid)) {
      base[[valid[j]]]$endpoints <- solved[[j]]
    }
  }
  diagnostics <- new.env(parent = emptyenv())
  rows <- lapply(X = views, FUN = function(view) {
    fit <- base[[view$key]]
    result <- .LBFinish(
      endpoints = fit$endpoints, data = data,
      target = view$target, request = fit$request
    )
    id <- paste(view$target$id, view$type,
      sprintf(fmt = "%.17g", view$alpha),
      sep = "|"
    )
    result$endpoints <- lapply(X = result$endpoints, FUN = function(endpoint) {
      endpoint$type <- view$type
      endpoint$alpha <- view$alpha
      endpoint$target <- view$target$id
      endpoint$estimate <- result$estimate
      endpoint$calibration <- fit$calibration$calibration
      endpoint$dimension <- fit$calibration$dimension
      endpoint$cutoff <- fit$calibration$cutoff
      endpoint$scale <- fit$calibration$scale
      endpoint$eigenvalues <- fit$calibration$eigenvalues
      endpoint$null_lr <- if (is.null(x = fit$request)) {
        NA_real_
      } else {
        fit$request$null_lr
      }
      endpoint
    })
    diagnostics[[id]] <- result$endpoints
    data.frame(
      effect = view$target$id, label = view$target$label,
      family = view$target$kind, type = view$type, alpha = view$alpha,
      estimate = result$estimate, lower = result$lower,
      upper = result$upper,
      lower_status = result$endpoints[[1L]]$status,
      upper_status = result$endpoints[[2L]]$status,
      calibration = fit$calibration$calibration,
      dimension = fit$calibration$dimension,
      cutoff = fit$calibration$cutoff, scale = fit$calibration$scale,
      diagnostic_id = id, stringsAsFactors = FALSE
    )
  })
  intervals <- do.call(what = rbind, args = rows)
  first <- !duplicated(x = intervals$effect)
  estimates <- stats::setNames(
    object = intervals$estimate[first],
    nm = intervals$effect[first]
  )
  structure(.Data = list(
    est = estimates, intervals = intervals,
    diagnostics = as.list(x = diagnostics), args = args, call = match.call(),
    lm_process = list(
      p = data$p, n = data$n,
      xnames = data$xnames, rows = data$rows
    ),
    data = data
  ), class = "lb")
}
