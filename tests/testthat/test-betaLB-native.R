## ---- test-betaLB-native
lapply(X = 1, FUN = function(i, text) {
  testthat::skip_on_cran()
  testthat::skip_if_not_installed(pkg = "nloptr")
  testthat::test_that(
    desc = paste(text, "agrees with independent R endpoints"),
    code = {
      d <- betaLB:::.LBData(
        object = stats::lm(formula = mpg ~ wt + hp, data = mtcars)
      )
      for (family in c(
        "beta", "diff", "sr", "pr", "local_f",
        "rsq", "delta", "block_f"
      )) {
        target <- list(
          family = family,
          index = if (family %in% c("diff", "block_f")) {
            c(1L, 2L)
          } else {
            1L
          }, image = if (family %in% c("beta", "diff", "sr")) {
            "identity"
          } else {
            "square"
          }
        )
        for (type in c("mvn", "robust")) {
          calibration <- betaLB:::.LBCalibration(
            data = d, target = target,
            type = type, alpha = 0.05
          )
          request <- betaLB:::.LBRequest(
            data = d, target = target,
            calibration = calibration
          )
          par <- betaLB:::.LBPack(sigma = d$sigma) + 0.01
          native <- betaLB:::.LBInspectCpp(
            par = par, sample = d$sigma, units = d$units, n = d$n,
            family = request$family, index = request$index,
            std_x = request$std_x, std_y = request$std_y,
            squared = request$squared
          )
          expected <- betaLB:::.LBObjective(
            par = par, data = d, target = target,
            squared = request$squared
          )
          testthat::expect_equal(
            object = drop(x = native$gradient),
            expected = expected$gradient, tolerance = 1e-8
          )
          testthat::expect_equal(
            object = native$value,
            expected = expected$value, tolerance = 1e-8
          )
          raw <- betaLB:::.LBBatchCpp(
            sample = d$sigma, units = d$units, n = d$n,
            requests = list(request), tolerance = 1e-8, maxeval = 10000L
          )[[1L]]
          actual <- betaLB:::.LBFinish(
            endpoints = raw, data = d,
            target = target, request = request
          )
          reference <- .LBReference(data = d, target = target, type = type)
          testthat::expect_identical(
            object = reference$status, expected = "ok"
          )
          testthat::expect_equal(
            object = c(actual$lower, actual$upper),
            expected = unname(obj = reference$interval),
            tolerance = 1e-6
          )
          testthat::expect_true(object = all(x = vapply(
            X = raw, FUN = function(x) {
              x$evaluations <= 10000L
            },
            FUN.VALUE = logical(length = 1)
          )))
        }
      }
    }
  )
}, text = "test-betaLB-native")
