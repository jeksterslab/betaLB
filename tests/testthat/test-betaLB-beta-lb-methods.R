## ---- test-betaLB-beta-lb-methods
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::skip_on_cran()
    testthat::test_that(
      desc = paste(text, "S3 methods"),
      code = {
        obj <- list(
          call = str2lang(s = "LB()"),
          args = list(type = "mvn"),
          est = c(x1 = 0.5, x2 = -0.3),
          ci = matrix(
            data = c(0.3, -0.5, 0.7, -0.1),
            nrow = 2,
            dimnames = list(c("x1", "x2"), c("2.5 %", "97.5 %"))
          )
        )
        class(x = obj) <- "betalb"
        testthat::expect_equal(
          object = stats::coef(object = obj),
          expected = obj$est
        )
        testthat::expect_equal(
          object = stats::confint(object = obj),
          expected = obj$ci
        )
        testthat::expect_equal(
          object = stats::confint(object = obj, parm = "x1"),
          expected = obj$ci["x1", , drop = FALSE]
        )
        testthat::expect_error(
          object = stats::vcov(object = obj)
        )
        testthat::expect_error(
          object = stats::confint(object = obj, level = 0.90),
          regexp = "stored confidence level"
        )
        testthat::expect_error(
          object = summary(object = obj, alpha = 0.10),
          regexp = "Selecting alpha"
        )
        obj$ci <- NULL
        testthat::expect_error(
          object = stats::confint(object = obj),
          regexp = "not available"
        )
        testthat::expect_equal(
          object = unname(obj = attr(
            x = summary(object = obj), which = "print_summary"
          )),
          expected = matrix(data = unname(obj = obj$est), ncol = 1)
        )
        summ <- summary(object = obj)
        testthat::expect_s3_class(
          object = summ,
          class = "summary.betalb"
        )
        testthat::expect_output(
          object = print(x = obj)
        )
      }
    )
  },
  text = "test-betaLB-beta-lb-methods"
)
