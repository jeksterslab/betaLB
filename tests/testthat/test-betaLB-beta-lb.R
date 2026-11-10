## ---- test-betaLB-beta-lb
lapply(X = 1, FUN = function(i, text) {
  testthat::skip_on_cran()
  testthat::test_that(
    desc = paste(text, "preserves the regression estimand"),
    code = {
      out <- betaLB::BetaLB(object = .LBFixture())
      fit <- stats::lm(formula = mpg ~ wt + hp, data = mtcars)
      expected <- stats::coef(object = fit)[-1L] *
        c(stats::sd(x = mtcars$wt), stats::sd(x = mtcars$hp)) /
        stats::sd(x = mtcars$mpg)
      testthat::expect_equal(
        object = stats::coef(object = out), expected = expected
      )
      raw <- betaLB::LB(
        object = fit, effects = "beta", type = "mvn", alpha = 0.05,
        std_y = FALSE, std_x = FALSE
      )
      testthat::expect_equal(
        object = stats::coef(object = betaLB::BetaLB(object = raw)),
        expected = stats::coef(object = fit)[-1L]
      )
      testthat::expect_true(object = all(x = grepl(
        pattern = "|std_y=0|std_x=0", x = names(x = stats::coef(object = raw)),
        fixed = TRUE
      )))
    }
  )
}, text = "test-betaLB-beta-lb")
