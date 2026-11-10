## ---- test-betaLB-delta-r-sq-lb
lapply(X = 1, FUN = function(i, text) {
  testthat::skip_on_cran()
  testthat::test_that(
    desc = paste(text, "preserves the regression estimand"),
    code = {
      out <- betaLB::DeltaRSqLB(object = .LBFixture())
      sr <- stats::coef(object = betaLB::SCorLB(object = .LBFixture()))
      rsq <- stats::coef(object = betaLB::RSqLB(object = .LBFixture()))["rsq"]
      testthat::expect_equal(
        object = stats::coef(object = out)[c("wt", "hp")],
        expected = sr^2
      )
      testthat::expect_equal(
        object = unname(obj = stats::coef(object = out)["block:both"]),
        expected = unname(obj = rsq)
      )
      testthat::expect_equal(
        object = unname(obj = stats::confint(
          object = out,
          parm = "block:both"
        )),
        expected = unname(obj = stats::confint(
          object = betaLB::RSqLB(object = .LBFixture()), parm = "rsq"
        )),
        tolerance = 1e-6
      )
    }
  )
}, text = "test-betaLB-delta-r-sq-lb")
