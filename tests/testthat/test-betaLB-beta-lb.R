## ---- test-betaLB-beta-lb
lapply(X = 1, FUN = function(i, text) {
  testthat::skip_on_cran()
  testthat::test_that(
    desc = paste(text, "preserves the regression estimand"),
    code = {
      out <- .LBFixture()
      fit <- stats::lm(
        formula = QUALITY ~ NARTIC + PCTGRT,
        data = betaLB::nas1982
      )
      expected <- stats::coef(object = fit)[-1L] *
        c(
          stats::sd(x = betaLB::nas1982$NARTIC),
          stats::sd(x = betaLB::nas1982$PCTGRT)
        ) /
        stats::sd(x = betaLB::nas1982$QUALITY)
      testthat::expect_equal(
        object = stats::coef(object = out), expected = expected
      )
      testthat::expect_true(object = attributes(x = out)$std)
      raw <- betaLB::BetaLB(
        object = fit, alpha = 0.05, std_y = FALSE, std_x = character(0)
      )
      testthat::expect_equal(
        object = stats::coef(object = raw),
        expected = stats::coef(object = fit)[-1L]
      )
      testthat::expect_false(object = attributes(x = raw)$std)
      part <- betaLB::BetaLB(object = fit, alpha = 0.05, std_x = "NARTIC")
      quality <- betaLB::nas1982$QUALITY
      sd_y <- sqrt(x = mean(x = (quality - mean(x = quality))^2))
      testthat::expect_equal(
        object = stats::coef(object = part),
        expected = c(
          NARTIC = unname(obj = expected["NARTIC"]),
          PCTGRT = unname(obj = stats::coef(object = fit)["PCTGRT"]) / sd_y
        )
      )
    }
  )
}, text = "test-betaLB-beta-lb")
