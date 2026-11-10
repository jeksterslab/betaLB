## ---- test-betaLB-s-cor-lb
lapply(X = 1, FUN = function(i, text) {
  testthat::skip_on_cran()
  testthat::test_that(
    desc = paste(text, "preserves the regression estimand"),
    code = {
      out <- betaLB::SCorLB(object = .LBFixture())
      fit <- stats::lm(formula = mpg ~ wt + hp, data = mtcars)
      full <- summary(object = fit)$r.squared
      increments <- full - c(
        summary(object = stats::lm(
          formula = mpg ~ hp,
          data = mtcars
        ))$r.squared,
        summary(object = stats::lm(
          formula = mpg ~ wt,
          data = mtcars
        ))$r.squared
      )
      expected <- sign(x = stats::coef(object = fit)[-1L]) *
        sqrt(x = increments)
      testthat::expect_equal(
        object = stats::coef(object = out), expected = expected
      )
    }
  )
}, text = "test-betaLB-s-cor-lb")
