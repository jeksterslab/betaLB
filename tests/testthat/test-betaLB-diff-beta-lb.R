## ---- test-betaLB-diff-beta-lb
lapply(X = 1, FUN = function(i, text) {
  testthat::skip_on_cran()
  testthat::test_that(
    desc = paste(text, "preserves the regression estimand"),
    code = {
      out <- betaLB::DiffBetaLB(object = .LBFixture())
      beta <- stats::coef(object = betaLB::BetaLB(object = .LBFixture()))
      testthat::expect_equal(
        object = unname(obj = stats::coef(object = out)),
        expected = unname(obj = beta[1L] - beta[2L])
      )
      small <- betaLB::LB(
        object = stats::lm(formula = mpg ~ wt, data = mtcars),
        effects = "rsq", type = "mvn", alpha = 0.05
      )
      testthat::expect_error(
        object = betaLB::DiffBetaLB(object = small),
        regexp = "not computed"
      )
    }
  )
}, text = "test-betaLB-diff-beta-lb")
