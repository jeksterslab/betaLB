## ---- test-betaLB-f-sq-lb
lapply(X = 1, FUN = function(i, text) {
  testthat::skip_on_cran()
  testthat::test_that(
    desc = paste(text, "preserves the regression estimand"),
    code = {
      out <- betaLB::FSqLB(
        object = .LBFixture(), alpha = 0.05,
        blocks = list(both = c("NARTIC", "PCTGRT"))
      )
      fit <- stats::lm(
        formula = QUALITY ~ NARTIC + PCTGRT,
        data = betaLB::nas1982
      )
      r2 <- summary(object = fit)$r.squared
      t_stat <- summary(object = fit)$coefficients[-1L, "t value"]
      expected <- c(
        fsq = r2 / (1 - r2), t_stat^2 / fit$df.residual, "block:both" =
          r2 / (1 - r2)
      )
      testthat::expect_equal(
        object = stats::coef(object = out), expected = expected
      )
      ci <- stats::confint(
        object = betaLB::RSqLB(object = .LBFixture(), alpha = 0.05),
        parm = "rsq"
      )
      testthat::expect_equal(
        object = unname(obj = stats::confint(
          object = out,
          parm = "fsq"
        )),
        expected = unname(obj = ci / (1 - ci))
      )
    }
  )
}, text = "test-betaLB-f-sq-lb")
