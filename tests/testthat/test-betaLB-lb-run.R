## ---- test-betaLB-lb-run
lapply(X = 1, FUN = function(i, text) {
  testthat::skip_on_cran()
  testthat::test_that(
    desc = paste(text, "batches levels with diagnostics"),
    code = {
      out <- .LBFixture(type = "robust")
      testthat::expect_s3_class(object = out, class = "betalb")
      testthat::expect_equal(
        object = nrow(x = out$intervals),
        expected = length(x = out$est) * 2L
      )
      testthat::expect_true(
        object = all(x = is.finite(x = out$intervals$lower))
      )
      testthat::expect_true(
        object = all(x = is.finite(x = out$intervals$upper))
      )
      testthat::expect_true(
        object = all(x = out$intervals$lower <= out$intervals$estimate)
      )
      testthat::expect_true(
        object = all(x = out$intervals$upper >= out$intervals$estimate)
      )
      testthat::expect_equal(
        object = length(x = out$diagnostics),
        expected = nrow(x = out$intervals)
      )
      for (row in seq_len(length.out = nrow(x = out$intervals))) {
        intervals <- out$intervals[row, ]
        for (endpoint in out$diagnostics[[intervals$diagnostic_id]]) {
          testthat::expect_true(
            object = endpoint$status %in% c("ok", "boundary_zero")
          )
          testthat::expect_lte(object = endpoint$constraint, expected = 1e-8)
          testthat::expect_lte(object = endpoint$stationarity, expected = 1e-8)
          testthat::expect_gte(object = endpoint$iterations, expected = 0)
          testthat::expect_gte(object = endpoint$retries, expected = 0)
          testthat::expect_equal(
            object = endpoint$cutoff, expected = intervals$cutoff
          )
          testthat::expect_length(
            object = endpoint$eigenvalues, n = intervals$dimension
          )
        }
      }
      failed <- betaLB::BetaLB(
        object = stats::lm(formula = QUALITY ~ NARTIC, data = betaLB::nas1982),
        type = "mvn", alpha = 0.05,
        control = list(maxeval = 1L)
      )
      testthat::expect_true(
        object = all(x = is.na(x = failed$intervals$lower))
      )
      testthat::expect_true(
        object = all(x = is.na(x = failed$intervals$upper))
      )
      testthat::expect_match(
        object = failed$intervals$lower_status,
        regexp = "failed"
      )
      testthat::expect_output(object = print(x = failed), regexp = "status")
      object <- stats::lm(formula = QUALITY ~ NARTIC, data = betaLB::nas1982)
      for (args in list(
        list(alpha = c(0.05, 0.05)),
        list(alpha = 1),
        list(type = c("mvn", "robust")),
        list(type = "bad"),
        list(std_x = "missing"),
        list(std_x = TRUE),
        list(std_y = NA),
        list(control = list(unknown = 1))
      )) {
        args$object <- object
        testthat::expect_error(
          object = do.call(what = betaLB::BetaLB, args = args)
        )
      }
      testthat::expect_error(
        object = betaLB::DeltaRSqLB(
          object = .LBFixture(), alpha = 0.05,
          blocks = list(bad = c(1L, 1L))
        )
      )
    }
  )
}, text = "test-betaLB-lb-run")
