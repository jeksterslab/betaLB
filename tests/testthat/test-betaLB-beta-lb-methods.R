## ---- test-betaLB-beta-lb-methods
lapply(X = 1, FUN = function(i, text) {
  testthat::skip_on_cran()
  testthat::test_that(
    desc = paste(text, "S3 methods"),
    code = {
      out <- .LBFixture()
      testthat::expect_equal(
        object = stats::coef(object = out), expected = out$est
      )
      ci <- stats::confint(object = out, parm = "NARTIC", level = 0.90)
      testthat::expect_equal(object = dim(x = ci), expected = c(1L, 2L))
      row <- out$intervals[
        out$intervals$alpha == 0.1 & out$intervals$effect == "NARTIC",
      ]
      testthat::expect_equal(
        object = unname(obj = ci),
        expected = matrix(data = c(row$lower, row$upper), nrow = 1L)
      )
      testthat::expect_equal(
        object = dim(x = stats::confint(object = out)), expected = c(2L, 2L)
      )
      summ <- summary(object = out)
      testthat::expect_s3_class(object = summ, class = "summary.betalb")
      testthat::expect_equal(object = ncol(x = summ), expected = 5L)
      testthat::expect_output(object = print(x = out), regexp = "Call")
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
    }
  )
}, text = "test-betaLB-beta-lb-methods")
