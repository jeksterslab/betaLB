## ---- test-betaLB-semlbci
lapply(X = 1, FUN = function(i, text) {
  testthat::skip_on_cran()
  testthat::skip_if_not_installed(pkg = "lavaan")
  testthat::skip_if_not_installed(pkg = "semlbci")
  testthat::test_that(
    desc = paste(text, "matches independent scalar likelihood intervals"),
    code = {
      fixture <- data.frame(y = mtcars$mpg, x = mtcars$wt)
      native <- betaLB::LB(
        object = stats::lm(formula = y ~ x, data = fixture),
        effects = "beta", alpha = 0.05
      )
      for (type in c("mvn", "robust")) {
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
          object = unname(obj = stats::confint(object = native, type = type)),
          expected = matrix(data = bounds, nrow = 1L), tolerance = 1e-5
        )
        r <- stats::cor(x = fixture$y, y = fixture$x)
        denominator <- (1 - r^2) * (1 - bounds^2)
        loss <- nrow(x = fixture) * log(x = (1 - r * bounds)^2 / denominator)
        cutoff <- native$intervals$cutoff[native$intervals$type == type]
        testthat::expect_equal(
          object = loss, expected = rep(x = cutoff, times = 2L),
          tolerance = 1e-5
        )
      }
    }
  )
}, text = "test-betaLB-semlbci")
