## ---- test-betaLB-semlbci
lapply(X = 1, FUN = function(i, text) {
  testthat::skip_on_cran()
  testthat::skip_if_not_installed(pkg = "lavaan")
  testthat::skip_if_not_installed(pkg = "semlbci")
  testthat::test_that(
    desc = paste(text, "matches independent scalar likelihood intervals"),
    code = {
      # mtcars, not nas1982: on nas1982 (QUALITY ~ NARTIC) semlbci 0.6.x stops
      # short of the cutoff at the upper bound (0.826 against the exact 0.860)
      fixture <- data.frame(y = mtcars$mpg, x = mtcars$wt)
      for (type in c("mvn", "robust")) {
        native <- betaLB::BetaLB(
          object = stats::lm(formula = y ~ x, data = fixture),
          type = type, alpha = 0.05
        )
        fit <- lavaan::sem(
          model = "y ~ x", data = fixture, fixed.x = FALSE,
          estimator = if (type == "mvn") {
            "ML"
          } else {
            "MLM"
          },
          meanstructure = FALSE
        )
        oracle <- semlbci::semlbci(
          sem_out = fit, pars = "y ~ x", standardized = TRUE,
          robust = if (type == "mvn") {
            "none"
          } else {
            "satorra.2000"
          },
          ciperc = 0.95, parallel = FALSE, use_pbapply = FALSE
        )
        row <- oracle[oracle$lhs == "y" & oracle$op == "~", ]
        bounds <- c(row$lbci_lb, row$lbci_ub)
        testthat::expect_equal(
          object = unname(obj = stats::confint(object = native)),
          expected = matrix(data = bounds, nrow = 1L), tolerance = 1e-5
        )
        r <- stats::cor(x = fixture$y, y = fixture$x)
        denominator <- (1 - r^2) * (1 - bounds^2)
        loss <- nrow(x = fixture) * log(x = (1 - r * bounds)^2 / denominator)
        cutoff <- native$intervals$cutoff
        testthat::expect_equal(
          object = loss, expected = rep(x = cutoff, times = 2L),
          tolerance = 1e-5
        )
      }
    }
  )
  testthat::test_that(
    desc = paste(text, "solves the closed-form profile on nas1982"),
    code = {
      fixture <- data.frame(
        y = betaLB::nas1982$QUALITY,
        x = betaLB::nas1982$NARTIC
      )
      r <- stats::cor(x = fixture$y, y = fixture$x)
      n <- nrow(x = fixture)
      for (type in c("mvn", "robust")) {
        native <- betaLB::BetaLB(
          object = stats::lm(formula = y ~ x, data = fixture),
          type = type, alpha = 0.05
        )
        cutoff <- native$intervals$cutoff
        loss <- function(rho) {
          n * log(x = (1 - r * rho)^2 / ((1 - r^2) * (1 - rho^2))) - cutoff
        }
        expected <- c(
          stats::uniroot(
            f = loss, interval = c(-0.999, r), tol = 1e-12
          )$root,
          stats::uniroot(
            f = loss, interval = c(r, 0.999), tol = 1e-12
          )$root
        )
        testthat::expect_equal(
          object = unname(obj = stats::confint(object = native)),
          expected = matrix(data = expected, nrow = 1L), tolerance = 1e-6
        )
      }
    }
  )
}, text = "test-betaLB-semlbci")
