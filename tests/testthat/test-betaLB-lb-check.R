## ---- test-betaLB-lb-check
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    testthat::skip_on_cran()
    testthat::test_that(
      desc = paste(text, "input validation"),
      code = {
        testthat::expect_error(
          object = betaLB:::.CheckLB(object = list())
        )
        testthat::expect_error(
          object = betaLB:::.CheckLB(
            object = structure(.Data = list(), class = "betalb")
          )
        )
        obj <- list(
          lm_process = list(p = 2)
        )
        class(x = obj) <- "betalb"
        testthat::expect_error(
          object = betaLB:::.CheckLB(object = obj, p_min = NA_real_)
        )
        testthat::expect_error(
          object = betaLB:::.CheckLB(object = obj, p_min = 1.5)
        )
        testthat::expect_true(
          object = betaLB:::.CheckLB(object = obj, p_min = 1)
        )
        testthat::expect_true(
          object = betaLB:::.CheckLB(object = obj, p_min = 2)
        )
        testthat::expect_error(
          object = betaLB:::.CheckLB(object = obj, p_min = 3)
        )
      }
    )
  },
  text = "test-betaLB-lb-check"
)
