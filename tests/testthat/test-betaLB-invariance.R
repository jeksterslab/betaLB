## ---- test-betaLB-invariance
lapply(X = 1, FUN = function(i, text) {
  testthat::skip_on_cran()
  testthat::test_that(
    desc = paste(text, "preserves units and predictor equivariance"),
    code = {
      original <- data.frame(
        y = betaLB::nas1982$QUALITY,
        a = betaLB::nas1982$NARTIC,
        b = betaLB::nas1982$PCTGRT
      )
      transformed <- data.frame(
        y = 100 * original$y + 7,
        a = -0.01 * original$a + 2, b = 10 * original$b
      )
      for (type in c("mvn", "robust")) {
        one <- betaLB::BetaLB(
          object = stats::lm(formula = y ~ a + b, data = original),
          type = type, alpha = 0.05
        )
        two <- betaLB::BetaLB(
          object = stats::lm(formula = y ~ b + a, data = transformed),
          type = type, alpha = 0.05
        )
        testthat::expect_equal(
          object = stats::confint(
            object = betaLB::RSqLB(object = one, alpha = 0.05)
          ),
          expected = stats::confint(
            object = betaLB::RSqLB(object = two, alpha = 0.05)
          ), tolerance = 1e-6
        )
        first <- stats::confint(object = one)
        second <- stats::confint(object = two)
        testthat::expect_equal(
          object = unname(obj = first["a", ]),
          expected = -rev(x = unname(obj = second["a", ])), tolerance = 1e-6
        )
        testthat::expect_equal(
          object = unname(obj = first["b", ]),
          expected = unname(obj = second["b", ]), tolerance = 1e-6
        )
      }
    }
  )
}, text = "test-betaLB-invariance")
