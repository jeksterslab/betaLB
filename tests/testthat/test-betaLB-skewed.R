## ---- test-betaLB-skewed
lapply(X = 1, FUN = function(i, text) {
  testthat::skip_on_cran()
  testthat::skip_if_not_installed(pkg = "nloptr")
  testthat::test_that(
    desc = paste(text, "matches R for skewed near-zero targets"),
    code = {
      set.seed(seed = 61108)
      fixture <- data.frame(
        a = exp(x = stats::rnorm(n = 48L)),
        b = stats::rnorm(n = 48L), e = exp(x = stats::rnorm(n = 48L))
      )
      residual <- stats::residuals(object = stats::lm(
        formula = e ~ a + b, data = fixture
      ))
      fixture$y <- 0.01 * fixture$a - 0.02 * fixture$b + residual
      data <- betaLB:::.LBData(object = stats::lm(
        formula = y ~ a + b, data = fixture
      ))
      for (family in c("diff", "delta")) {
        target <- list(
          family = family, index = 1:2,
          image = if (family == "diff") {
            "identity"
          } else {
            "square"
          }
        )
        for (type in c("mvn", "robust")) {
          for (alpha in c(0.05, 0.10)) {
            calibration <- betaLB:::.LBCalibration(
              data = data, target = target, type = type, alpha = alpha
            )
            request <- betaLB:::.LBRequest(
              data = data, target = target, calibration = calibration
            )
            native <- betaLB:::.LBBatchCpp(
              sample = data$sigma, units = data$units, n = data$n,
              requests = list(request), tolerance = 1e-8, maxeval = 10000L
            )[[1L]]
            actual <- betaLB:::.LBFinish(
              endpoints = native, data = data, target = target,
              request = request
            )
            reference <- .LBReference(
              data = data, target = target, type = type, alpha = alpha
            )
            testthat::expect_identical(
              object = reference$status, expected = "ok"
            )
            testthat::expect_equal(
              object = c(actual$lower, actual$upper),
              expected = unname(obj = reference$interval), tolerance = 1e-6
            )
          }
        }
      }
    }
  )
}, text = "test-betaLB-skewed")
