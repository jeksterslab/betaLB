## ---- test-betaLB-effects
lapply(
  X = 1,
  FUN = function(i, text) {
    testthat::skip_on_cran()
    testthat::test_that(
      desc = paste(
        text, "matches regression identities and finite differences"
      ),
      code = {
        fit <- stats::lm(formula = mpg ~ wt + hp + qsec, data = mtcars)
        d <- betaLB:::.LBData(object = fit)
        for (family in c(
          "beta", "diff", "sr", "pr", "local_f",
          "rsq", "delta", "block_f"
        )) {
          target <- list(
            family = family,
            index = if (family %in% c("diff", "delta", "block_f")) {
              c(1L, 2L)
            } else {
              1L
            }
          )
          effect <- betaLB:::.LBEffect(
            sigma = d$sigma, target = target,
            units = d$units
          )
          fd <- vapply(
            X = seq_len(length.out = nrow(x = d$ij)), FUN = function(j) {
              up <- down <- d$sigma
              row <- d$ij[j, 1L]
              col <- d$ij[j, 2L]
              up[row, col] <- up[col, row] <- up[row, col] + 1e-6
              down[row, col] <- down[col, row] <- down[row, col] - 1e-6
              (betaLB:::.LBEffect(
                sigma = up, target = target,
                units = d$units
              )$value -
                betaLB:::.LBEffect(
                  sigma = down, target = target,
                  units = d$units
                )$value) / 2e-6
            }, FUN.VALUE = numeric(length = length(x = effect$value))
          )
          testthat::expect_equal(
            object = effect$jacobian,
            expected = matrix(
              data = fd,
              nrow = length(x = effect$value)
            ),
            tolerance = 1e-6
          )
        }
        slope <- betaLB:::.LBEffect(
          sigma = d$sigma, target = list(family = "beta", index = 1L),
          units = d$units
        )$value
        testthat::expect_equal(
          object = slope,
          expected = unname(obj = stats::coef(object = fit)[2L]) *
            stats::sd(x = mtcars$wt) / stats::sd(x = mtcars$mpg)
        )
        block <- betaLB:::.LBEffect(
          sigma = d$sigma, target = list(family = "delta", index = c(1L, 2L)),
          units = d$units
        )$value
        reduced <- stats::lm(formula = mpg ~ qsec, data = mtcars)
        testthat::expect_equal(
          object = sum(block^2),
          expected = summary(object = fit)$r.squared -
            summary(object = reduced)$r.squared
        )
        pr <- betaLB:::.LBEffect(
          sigma = d$sigma, target = list(family = "pr", index = 1L),
          units = d$units
        )$value
        t_stat <- summary(object = fit)$coefficients[2L, "t value"]
        testthat::expect_equal(
          object = pr^2,
          expected = t_stat^2 / (t_stat^2 + fit$df.residual)
        )
        for (family in c("rsq", "delta", "block_f")) {
          effect <- betaLB:::.LBEffect(
            sigma = diag(x = 4),
            target = list(family = family, index = c(1L, 2L))
          )
          testthat::expect_true(
            object = all(x = is.finite(x = effect$jacobian))
          )
          testthat::expect_equal(
            object = effect$value,
            expected = rep(x = 0, times = nrow(x = effect$jacobian))
          )
        }
      }
    )
  },
  text = "test-betaLB-effects"
)
