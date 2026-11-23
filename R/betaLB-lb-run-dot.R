#' Solve the Likelihood Intervals of One Effect Family
#'
#' Build the targets of one effect family, calibrate the cutoffs, and solve all
#' endpoints in one native batch.
#' @author Ivan Jacob Agaloos Pesigan
#' @param data Analysis statistics from `.LBData()`.
#' @param args Validated options from `.CheckLBArguments()` with the element
#'   `effects` (one family) added.
#' @return List with `est`, `intervals`, and `diagnostics`.
#' @examples
#' d <- .LBData(object = stats::lm(formula = mpg ~ wt, data = mtcars))
#' args <- .CheckLBArguments(
#'   type = "mvn", alpha = 0.05, std_y = TRUE, std_x = NULL,
#'   blocks = NULL, control = list(), data = d
#' )
#' args$effects <- "rsq"
#' .LBRun(data = d, args = args)
#' @noRd
.LBRun <- function(data, args) {
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
      effect = view$target$label, family = view$target$kind,
      type = view$type, alpha = view$alpha,
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
  list(
    est = stats::setNames(
      object = intervals$estimate[first],
      nm = intervals$effect[first]
    ),
    intervals = intervals,
    diagnostics = as.list(x = diagnostics)
  )
}
