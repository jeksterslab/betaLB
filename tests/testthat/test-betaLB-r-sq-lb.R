## ---- test-betaLB-r-sq-lb
lapply(X = 1, FUN = function(i, text) {
  testthat::skip_on_cran()
  testthat::test_that(
    desc = paste(text, "preserves the regression estimand"),
    code = {
      out <- betaLB::RSqLB(object = .LBFixture())
      fit <- stats::lm(formula = mpg ~ wt + hp, data = mtcars)
      expected <- c(
        rsq = summary(object = fit)$r.squared,
        adj = summary(object = fit)$adj.r.squared
      )
      testthat::expect_equal(
        object = stats::coef(object = out), expected = expected
      )
      testthat::expect_true(object = all(x = out$intervals$dimension == 2L))
      testthat::expect_true(
        object = all(x = out$intervals$calibration == "vector_projection")
      )
    }
  )
}, text = "test-betaLB-r-sq-lb")
