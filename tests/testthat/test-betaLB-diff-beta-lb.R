## ---- test-betaLB-diff-beta-lb
lapply(X = 1, FUN = function(i, text) {
  testthat::skip_on_cran()
  testthat::test_that(
    desc = paste(text, "preserves the regression estimand"),
    code = {
      out <- betaLB::DiffBetaLB(object = .LBFixture(), alpha = 0.05)
      beta <- stats::coef(object = .LBFixture())
      testthat::expect_equal(
        object = unname(obj = stats::coef(object = out)),
        expected = unname(obj = beta[1L] - beta[2L])
      )
      small <- betaLB::BetaLB(
        object = stats::lm(formula = QUALITY ~ NARTIC, data = betaLB::nas1982),
        alpha = 0.05
      )
      testthat::expect_error(
        object = betaLB::DiffBetaLB(object = small),
        regexp = "At least 2 regressors"
      )
      partial <- betaLB::BetaLB(
        object = stats::lm(
          formula = QUALITY ~ NARTIC + PCTGRT,
          data = betaLB::nas1982
        ),
        alpha = 0.05, std_y = FALSE
      )
      testthat::expect_error(
        object = betaLB::DiffBetaLB(object = partial),
        regexp = "fully standardized"
      )
    }
  )
}, text = "test-betaLB-diff-beta-lb")
