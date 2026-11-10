## ---- test-betaLB-lb-methods
lapply(X = 1, FUN = function(i, text) {
  testthat::skip_on_cran()
  testthat::test_that(
    desc = paste(text, "selects stored results without refitting"),
    code = {
      out <- .LBFixture()
      effect <- betaLB::BetaLB(object = out)
      ci <- stats::confint(
        object = effect, parm = "wt", type = "robust",
        level = 0.90
      )
      testthat::expect_equal(object = dim(x = ci), expected = c(1L, 2L))
      selected <- effect$intervals$type == "robust" &
        effect$intervals$alpha == 0.1 & effect$intervals$effect == "wt"
      row <- effect$intervals[selected, ]
      testthat::expect_equal(
        object = unname(obj = ci),
        expected = matrix(
          data = c(row$lower, row$upper),
          nrow = 1L
        )
      )
      testthat::expect_equal(
        object = stats::confint(
          object = out, parm = "beta:wt|std_y=1|std_x=1", type = "robust",
          level = 0.90
        )[1L, ],
        expected = ci[1L, ]
      )
      testthat::expect_s3_class(
        object = summary(object = out),
        class = "summary.betalb"
      )
      testthat::expect_output(
        object = print(x = effect), regexp = "conservative"
      )
      testthat::expect_output(object = print(x = out), regexp = "Likelihood")
      testthat::expect_error(
        object = stats::vcov(object = out),
        regexp = "not defined"
      )
      testthat::expect_error(
        object = stats::confint(object = effect, level = 0.8),
        regexp = "not computed"
      )
      testthat::expect_error(
        object = stats::confint(object = effect, type = "bad"),
        regexp = "not computed"
      )
      testthat::expect_error(
        object = stats::confint(object = effect, parm = "bad"),
        regexp = "unknown"
      )
      testthat::expect_error(object = betaLB::BetaLB(object = effect))
      selected <- summary(object = effect, alpha = 0.1, type = "robust")
      testthat::expect_equal(object = nrow(x = selected), expected = 2L)
    }
  )
}, text = "test-betaLB-lb-methods")
