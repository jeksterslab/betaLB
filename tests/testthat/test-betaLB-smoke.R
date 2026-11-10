## ---- test-betaLB-smoke
# Fast engine checks run on CRAN without optional validation packages.
lapply(
  X = 1,
  FUN = function(i, text) {
    testthat::test_that(
      desc = paste(text, "fits and extracts finite likelihood intervals"),
      code = {
        fit <- stats::lm(formula = mpg ~ wt, data = mtcars)
        out <- betaLB::LB(
          object = fit, effects = c("beta", "rsq"),
          type = "mvn", alpha = 0.05
        )
        ci <- stats::confint(object = out)
        testthat::expect_true(object = all(x = is.finite(x = ci)))
        testthat::expect_true(
          object = all(x = ci[, "lower"] <= stats::coef(object = out))
        )
        testthat::expect_true(
          object = all(x = ci[, "upper"] >= stats::coef(object = out))
        )
        rsq <- stats::coef(object = betaLB::RSqLB(object = out))
        testthat::expect_equal(
          object = unname(obj = rsq["rsq"]),
          expected = summary(object = fit)$r.squared
        )
        testthat::expect_length(
          object = stats::coef(object = betaLB::BetaLB(object = out)), n = 1L
        )
      }
    )
  },
  text = "test-betaLB-smoke"
)
