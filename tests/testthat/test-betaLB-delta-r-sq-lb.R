## ---- test-betaLB-delta-r-sq-lb
lapply(X = 1, FUN = function(i, text) {
  testthat::skip_on_cran()
  testthat::test_that(
    desc = paste(text, "preserves the regression estimand"),
    code = {
      out <- betaLB::DeltaRSqLB(
        object = .LBFixture(), alpha = 0.05,
        blocks = list(both = c("NARTIC", "PCTGRT"))
      )
      sr <- stats::coef(
        object = betaLB::SCorLB(object = .LBFixture(), alpha = 0.05)
      )
      rsq <- stats::coef(
        object = betaLB::RSqLB(object = .LBFixture(), alpha = 0.05)
      )["rsq"]
      testthat::expect_equal(
        object = stats::coef(object = out)[c("NARTIC", "PCTGRT")],
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
          object = betaLB::RSqLB(object = .LBFixture(), alpha = 0.05),
          parm = "rsq"
        )),
        tolerance = 1e-6
      )
    }
  )
}, text = "test-betaLB-delta-r-sq-lb")
