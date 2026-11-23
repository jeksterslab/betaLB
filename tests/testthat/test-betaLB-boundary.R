## ---- test-betaLB-boundary
lapply(
  X = 1,
  FUN = function(i, text) {
    testthat::skip_on_cran()
    testthat::skip_if_not_installed(pkg = "nloptr")
    testthat::test_that(
      desc = paste(text, "handles zero without a singular scalar scale"),
      code = {
        orthogonal <- qr.Q(qr = qr(x = cbind(
          1, betaLB::nas1982$NARTIC, betaLB::nas1982$PCTGRT,
          betaLB::nas1982$QUALITY
        )))
        fixture <- data.frame(
          y = orthogonal[, 4L], x1 = orthogonal[, 2L],
          x2 = orthogonal[, 3L]
        )
        d <- betaLB:::.LBData(object = stats::lm(
          formula = y ~ x1 + x2,
          data = fixture
        ))
        out <- .LBReference(data = d, target = list(family = "rsq"))
        testthat::expect_identical(object = out$status, expected = "ok")
        testthat::expect_identical(
          object = out$calibration$dimension,
          expected = 2L
        )
        testthat::expect_equal(
          object = unname(obj = out$interval[1L]),
          expected = 0
        )
        testthat::expect_equal(
          object = unname(obj = out$interval[2L]),
          expected = 1 - exp(x = -stats::qchisq(p = 0.95, df = 2) / d$n),
          tolerance = 1e-7
        )
        testthat::expect_identical(
          object = out$endpoints[[1L]]$status,
          expected = "boundary_zero"
        )
        testthat::expect_lt(
          object = out$endpoints[[1L]]$lr,
          expected = out$calibration$cutoff
        )
        out <- .LBReference(
          data = d, target = list(family = "pr", index = 1L),
          type = "robust"
        )
        testthat::expect_identical(object = out$status, expected = "ok")
        testthat::expect_equal(
          object = unname(obj = out$interval[1L]),
          expected = 0
        )
        testthat::expect_true(object = is.finite(x = out$calibration$scale))
        for (type in c("mvn", "robust")) {
          native <- betaLB::BetaLB(
            object = stats::lm(formula = y ~ x1 + x2, data = fixture),
            type = type, alpha = 0.05
          )
          rsq <- betaLB::RSqLB(object = native, alpha = 0.05)
          ci <- stats::confint(object = rsq, parm = "rsq")
          row <- rsq$intervals[rsq$intervals$effect == "rsq", ]
          testthat::expect_equal(object = ci[1L, 1L], expected = 0)
          testthat::expect_equal(
            object = ci[1L, 2L],
            expected = 1 - exp(x = -row$cutoff / d$n),
            tolerance = 1e-7
          )
          testthat::expect_lt(
            object = stats::confint(object = rsq, parm = "adj")[1L, 1L],
            expected = 0
          )
        }
      }
    )
  },
  text = "test-betaLB-boundary"
)
