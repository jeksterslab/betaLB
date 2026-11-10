## ---- test-betaLB-reference
lapply(
  X = 1,
  FUN = function(i, text) {
    testthat::skip_on_cran()
    testthat::skip_if_not_installed(pkg = "nloptr")
    testthat::test_that(
      desc = paste(
        text, "matches an independently inverted correlation profile"
      ),
      code = {
        d <- betaLB:::.LBData(
          object = stats::lm(formula = mpg ~ wt, data = mtcars)
        )
        sample_r <- d$sigma[1L, 2L]
        for (type in c("mvn", "robust")) {
          out <- .LBReference(
            data = d,
            target = list(family = "sr", index = 1L),
            type = type
          )
          a <- exp(x = out$calibration$cutoff / d$n) * (1 - sample_r^2)
          root <- sqrt(x = a * (a + sample_r^2 - 1))
          expected <- (sample_r + c(-1, 1) * root) / (sample_r^2 + a)
          testthat::expect_equal(
            object = unname(obj = out$interval),
            expected = expected, tolerance = 1e-7
          )
          for (endpoint in out$endpoints) {
            testthat::expect_lt(object = endpoint$constraint, expected = 1e-8)
            testthat::expect_lt(
              object = endpoint$stationarity, expected = 1e-8
            )
          }
        }
        out <- .LBReference(
          data = d, target = list(family = "sr", index = 1L),
          control = list(maxeval = 1L, starts = FALSE)
        )
        testthat::expect_true(object = all(x = is.na(x = out$interval)))
        testthat::expect_identical(object = out$status, expected = "failed")
      }
    )
  },
  text = "test-betaLB-reference"
)
