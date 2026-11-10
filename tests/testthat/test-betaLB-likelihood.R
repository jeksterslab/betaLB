## ---- test-betaLB-likelihood
lapply(
  X = 1,
  FUN = function(i, text) {
    testthat::skip_on_cran()
    testthat::test_that(
      desc = paste(
        text, "uses ML moments and analytic likelihood derivatives"
      ),
      code = {
        fit <- stats::lm(formula = mpg ~ wt + hp, data = mtcars)
        d <- betaLB:::.LBData(object = fit)
        z <- cbind(mtcars$mpg, mtcars$wt, mtcars$hp)
        centered <- sweep(
          x = z, MARGIN = 2L,
          STATS = colMeans(x = z), FUN = "-"
        )
        testthat::expect_equal(
          object = unname(obj = d$sigma * tcrossprod(x = d$units)),
          expected = unname(obj = crossprod(x = centered) / nrow(x = z))
        )
        par <- betaLB:::.LBPack(sigma = d$sigma)
        testthat::expect_equal(
          object = betaLB:::.LBUnpack(par = par, k = 3)$sigma,
          expected = unname(obj = d$sigma)
        )
        testthat::expect_lt(
          object = abs(x = betaLB:::.LBLoss(par = par, data = d)$value),
          expected = 1e-10
        )
        par <- par + seq_along(along.with = par) / 50
        fd <- vapply(
          X = seq_along(along.with = par), FUN = function(j) {
            up <- down <- par
            up[j] <- up[j] + 1e-6
            down[j] <- down[j] - 1e-6
            loss_up <- betaLB:::.LBLoss(par = up, data = d)$value
            loss_down <- betaLB:::.LBLoss(par = down, data = d)$value
            (loss_up - loss_down) / 2e-6
          }, FUN.VALUE = numeric(length = 1)
        )
        testthat::expect_equal(
          object = betaLB:::.LBLoss(par = par, data = d)$gradient,
          expected = fd, tolerance = 1e-6
        )
        null <- betaLB:::.LBNull(data = d, index = 1L)
        reduced <- stats::lm(formula = mpg ~ hp, data = mtcars)
        loss_ratio <- sum(reduced$residuals^2) / sum(fit$residuals^2)
        testthat::expect_equal(
          object = null$loss,
          expected = nrow(x = z) * log(x = loss_ratio)
        )
        testthat::expect_equal(
          object = betaLB:::.LBLoss(par = null$par, data = d)$value,
          expected = null$loss
        )
        testthat::expect_error(
          object = betaLB:::.LBData(object = stats::lm(
            formula = mpg ~ wt - 1, data = mtcars
          )), regexp = "intercept"
        )
        testthat::expect_error(
          object = betaLB:::.LBData(object = stats::lm(
            formula = mpg ~ wt, data = mtcars, weights = rep(x = 1, times = 32)
          )), regexp = "Weights"
        )
        testthat::expect_error(
          object = betaLB:::.LBData(object = stats::lm(
            formula = y ~ x, data = data.frame(y = mtcars$wt, x = mtcars$wt)
          )), regexp = "rank|covariance|residual"
        )
      }
    )
  },
  text = "test-betaLB-likelihood"
)
