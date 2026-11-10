## ---- test-betaLB-p-cor-lb
lapply(X = 1, FUN = function(i, text) {
  testthat::skip_on_cran()
  testthat::test_that(
    desc = paste(text, "preserves the regression estimand"),
    code = {
      out <- betaLB::PCorLB(object = .LBFixture())
      fit <- stats::lm(formula = mpg ~ wt + hp, data = mtcars)
      t_stat <- summary(object = fit)$coefficients[-1L, "t value"]
      expected <- t_stat^2 / (t_stat^2 + fit$df.residual)
      testthat::expect_equal(
        object = stats::coef(object = out), expected = expected
      )
      testthat::expect_true(object = all(x = out$intervals$lower >= 0))
    }
  )
}, text = "test-betaLB-p-cor-lb")
