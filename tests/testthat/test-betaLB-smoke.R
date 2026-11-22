## ---- test-betaLB-smoke
# Fast engine checks run on CRAN without optional validation packages.
lapply(
  X = 1,
  FUN = function(i, text) {
    testthat::test_that(
      desc = paste(text, "fits and extracts finite likelihood intervals"),
      code = {
        fit <- stats::lm(formula = QUALITY ~ NARTIC, data = betaLB::nas1982)
        out <- betaLB::BetaLB(object = fit, type = "mvn", alpha = 0.05)
        ci <- stats::confint(object = out)
        testthat::expect_true(object = all(x = is.finite(x = ci)))
        testthat::expect_true(
          object = all(x = ci[, 1] <= stats::coef(object = out))
        )
        testthat::expect_true(
          object = all(x = ci[, 2] >= stats::coef(object = out))
        )
        rsq <- stats::coef(
          object = betaLB::RSqLB(object = out, alpha = 0.05)
        )
        testthat::expect_equal(
          object = unname(obj = rsq["rsq"]),
          expected = summary(object = fit)$r.squared
        )
        testthat::expect_length(object = stats::coef(object = out), n = 1L)
      }
    )
  },
  text = "test-betaLB-smoke"
)
