## ---- test-betaLB-invariance
lapply(X = 1, FUN = function(i, text) {
  testthat::skip_on_cran()
  testthat::test_that(
    desc = paste(text, "preserves units and predictor equivariance"),
    code = {
      original <- data.frame(y = mtcars$mpg, a = mtcars$wt, b = mtcars$hp)
      transformed <- data.frame(
        y = 100 * original$y + 7,
        a = -0.01 * original$a + 2, b = 10 * original$b
      )
      one <- betaLB::LB(
        object = stats::lm(formula = y ~ a + b, data = original),
        effects = c("rsq", "beta"), alpha = 0.05
      )
      two <- betaLB::LB(
        object = stats::lm(formula = y ~ b + a, data = transformed),
        effects = c("rsq", "beta"), alpha = 0.05
      )
      for (type in c("mvn", "robust")) {
        testthat::expect_equal(
          object = stats::confint(
            object = betaLB::RSqLB(object = one),
            type = type
          ),
          expected = stats::confint(
            object = betaLB::RSqLB(object = two),
            type = type
          ), tolerance = 1e-6
        )
        first <- stats::confint(
          object = betaLB::BetaLB(object = one),
          type = type
        )
        second <- stats::confint(
          object = betaLB::BetaLB(object = two),
          type = type
        )
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
