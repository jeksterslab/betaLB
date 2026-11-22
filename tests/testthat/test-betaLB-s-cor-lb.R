## ---- test-betaLB-s-cor-lb
lapply(X = 1, FUN = function(i, text) {
  testthat::skip_on_cran()
  testthat::test_that(
    desc = paste(text, "preserves the regression estimand"),
    code = {
      out <- betaLB::SCorLB(object = .LBFixture(), alpha = 0.05)
      fit <- stats::lm(
        formula = QUALITY ~ NARTIC + PCTGRT,
        data = betaLB::nas1982
      )
      full <- summary(object = fit)$r.squared
      increments <- full - c(
        summary(object = stats::lm(
          formula = QUALITY ~ PCTGRT,
          data = betaLB::nas1982
        ))$r.squared,
        summary(object = stats::lm(
          formula = QUALITY ~ NARTIC,
          data = betaLB::nas1982
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
