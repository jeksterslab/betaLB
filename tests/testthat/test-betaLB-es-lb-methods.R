## ---- test-betaLB-es-lb-methods
lapply(X = 1, FUN = function(i, text) {
  testthat::skip_on_cran()
  testthat::test_that(
    desc = paste(text, "S3 methods use the stored intervals"),
    code = {
      fit <- .LBFixture(type = "robust")
      out <- betaLB::RSqLB(object = fit, alpha = c(0.05, 0.10))
      testthat::expect_s3_class(object = out, class = "eslb")
      ci <- stats::confint(object = out, parm = "rsq", level = 0.90)
      testthat::expect_equal(object = dim(x = ci), expected = c(1L, 2L))
      testthat::expect_equal(
        object = colnames(x = ci), expected = c("5 %", "95 %")
      )
      row <- out$intervals[
        out$intervals$alpha == 0.1 & out$intervals$effect == "rsq",
      ]
      testthat::expect_equal(
        object = unname(obj = ci),
        expected = matrix(data = c(row$lower, row$upper), nrow = 1L)
      )
      testthat::expect_equal(
        object = stats::coef(object = out), expected = out$est
      )
      summ <- summary(object = out, alpha = 0.10)
      testthat::expect_s3_class(object = summ, class = "summary.eslb")
      testthat::expect_equal(object = ncol(x = summ), expected = 3L)
      testthat::expect_output(
        object = print(x = out), regexp = "R-squared"
      )
      testthat::expect_output(
        object = print(x = summ), regexp = "likelihood intervals"
      )
      testthat::expect_error(
        object = stats::vcov(object = out), regexp = "not defined"
      )
      testthat::expect_error(
        object = stats::confint(object = out, level = 0.8),
        regexp = "not computed"
      )
      testthat::expect_error(
        object = stats::confint(object = out, level = 2),
        regexp = "confidence level"
      )
      testthat::expect_error(
        object = stats::confint(object = out, parm = "bad")
      )
      testthat::expect_error(
        object = summary(object = out, alpha = 0.2), regexp = "not computed"
      )
      testthat::expect_error(
        object = summary(object = out, digits = -1), regexp = "digits"
      )
      testthat::expect_error(object = betaLB::RSqLB(object = out))
    }
  )
}, text = "test-betaLB-es-lb-methods")
