## ---- test-betaLB-roots
lapply(X = 1, FUN = function(i, text) {
  testthat::skip_on_cran()
  testthat::test_that(
    desc = paste(text, "differentiates repeated predictor eigenvalues"),
    code = {
      sigma <- diag(x = 4L)
      sigma[1L, -1L] <- sigma[-1L, 1L] <- c(0.1, 0.2, -0.3)
      target <- list(family = "rsq", index = 1:3)
      expected <- betaLB:::.LBEffect(sigma = sigma, target = target)
      native <- betaLB:::.LBInspectCpp(
        par = betaLB:::.LBPack(sigma = sigma), sample = sigma,
        units = rep(x = 1, times = 4L), n = 100,
        family = 5L, index = 0:2, std_x = rep(x = 1, times = 3L),
        std_y = TRUE, squared = TRUE
      )
      testthat::expect_equal(
        object = native$jacobian, expected = expected$jacobian,
        tolerance = 1e-8
      )
      ij <- which(x = lower.tri(x = sigma, diag = TRUE), arr.ind = TRUE)
      for (j in seq_len(length.out = nrow(x = ij))) {
        up <- down <- sigma
        row <- ij[j, 1L]
        col <- ij[j, 2L]
        up[row, col] <- up[col, row] <- up[row, col] + 1e-6
        down[row, col] <- down[col, row] <- down[row, col] - 1e-6
        effect_up <- betaLB:::.LBEffect(sigma = up, target = target)$value
        effect_down <- betaLB:::.LBEffect(sigma = down, target = target)$value
        fd <- (effect_up - effect_down) / 2e-6
        testthat::expect_equal(
          object = native$jacobian[, j], expected = fd, tolerance = 1e-6
        )
      }
    }
  )
}, text = "test-betaLB-roots")
