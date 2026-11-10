## ---- test-betaLB-calibration
lapply(
  X = 1,
  FUN = function(i, text) {
    testthat::skip_on_cran()
    testthat::test_that(
      desc = paste(
        text, "recovers the normal law and rejects degenerate scales"
      ),
      code = {
        d <- betaLB:::.LBData(
          object = stats::lm(formula = mpg ~ wt + hp, data = mtcars)
        )
        d$gamma_adf <- d$gamma_n
        target <- list(family = "rsq")
        out <- betaLB:::.LBCalibration(
          data = d, target = target,
          type = "robust", alpha = 0.05
        )
        testthat::expect_equal(object = out$eigenvalues, expected = c(1, 1))
        testthat::expect_equal(
          object = out$cutoff,
          expected = stats::qchisq(p = 0.95, df = 2)
        )
        testthat::expect_identical(
          object = out$calibration,
          expected = "vector_projection"
        )
        d$gamma_adf <- 3 * d$gamma_n
        out <- betaLB:::.LBCalibration(
          data = d, target = target,
          type = "robust", alpha = 0.05
        )
        testthat::expect_equal(object = out$scale, expected = 3)
        d$gamma_adf[] <- 0
        out <- betaLB:::.LBCalibration(
          data = d, target = target,
          type = "robust", alpha = 0.05
        )
        testthat::expect_identical(
          object = out$status,
          expected = "degenerate_robust_scale"
        )
        testthat::expect_true(object = is.na(x = out$cutoff))
        testthat::expect_error(
          object = betaLB:::.LBCalibration(
            data = d, target = target,
            type = "mvn", alpha = NA_real_
          )
        )
      }
    )
  },
  text = "test-betaLB-calibration"
)
