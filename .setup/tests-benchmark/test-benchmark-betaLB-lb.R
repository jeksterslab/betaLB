## ---- test-benchmark-betaLB-lb
# Explicit opt-in: the default n=1000, p=5 comparison belongs on compute/local.
if (identical(x = Sys.getenv(x = "BETALB_RUN_BENCHMARK"), y = "true")) {
  rProject::LibPaths(path = getwd())
  sys.source(file = "tests/testthat/helper-betaLB.R", envir = environment())
  n <- as.integer(x = Sys.getenv(x = "BETALB_BENCH_N", unset = "1000"))
  p <- as.integer(x = Sys.getenv(x = "BETALB_BENCH_P", unset = "5"))
  iterations <- as.integer(x = Sys.getenv(
    x = "BETALB_BENCH_ITERATIONS",
    unset = "3"
  ))
  stopifnot(n > p + 1L, p >= 1L, iterations >= 1L)
  set.seed(seed = 20261108)
  predictors <- matrix(data = stats::rnorm(n = n * p), nrow = n)
  colnames(x = predictors) <- paste0("x", seq_len(length.out = p))
  fixture <- data.frame(y = rowSums(x = predictors) / sqrt(x = p) +
    stats::rnorm(n = n), predictors)
  fit <- stats::lm(formula = y ~ ., data = fixture)
  effects <- strsplit(x = Sys.getenv(
    x = "BETALB_BENCH_EFFECTS", unset =
      "beta,rsq,scor,pcor,deltarsq,diffbeta,fsq"
  ), split = ",", fixed = TRUE)[[1L]]
  types <- c("mvn", "robust")
  alpha <- c(0.05, 0.01, 0.001)
  data <- betaLB:::.LBData(object = fit)
  args <- betaLB:::.CheckLBArguments(
    type = "mvn", alpha = alpha,
    std_y = TRUE, std_x = NULL, blocks = NULL,
    control = list(), data = data
  )
  args$effects <- effects
  targets <- betaLB:::.LBTargets(data = data, args = args)
  keys <- vapply(X = targets, FUN = function(x) {
    paste(x$family, paste(x$index, collapse = ","), sep = ":")
  }, FUN.VALUE = character(length = 1))
  targets <- targets[!duplicated(x = keys)]
  .Reference <- function() {
    lapply(X = targets, FUN = function(target) {
      lapply(X = types, FUN = function(type) {
        lapply(X = alpha, FUN = function(level) {
          .LBReference(data = data, target = target, type = type, alpha = level)
        })
      })
    })
  }
  reference_check <- .Reference()
  reference_status <- character(length = 0)
  for (target in reference_check) {
    for (type in target) {
      for (level in type) {
        reference_status <- c(reference_status, level$status)
      }
    }
  }
  .Native <- function() {
    funs <- list(
      beta = NULL, rsq = betaLB::RSqLB, scor = betaLB::SCorLB,
      pcor = betaLB::PCorLB, deltarsq = betaLB::DeltaRSqLB,
      diffbeta = betaLB::DiffBetaLB, fsq = betaLB::FSqLB
    )
    out <- lapply(X = types, FUN = function(type) {
      std <- betaLB::BetaLB(object = fit, type = type, alpha = alpha)
      c(
        list(std),
        lapply(X = funs[setdiff(x = effects, y = "beta")], FUN = function(f) {
          f(object = std, alpha = alpha)
        })
      )
    })
    unlist(x = out, recursive = FALSE)
  }
  native_check <- .Native()
  native_status <- unlist(x = lapply(X = native_check, FUN = function(x) {
    c(x$intervals$lower_status, x$intervals$upper_status)
  }))
  stopifnot(
    all(x = reference_status == "ok"),
    all(x = native_status %in% c("ok", "boundary_zero"))
  )
  print(x = table(reference_status))
  print(x = table(native_status))
  result <- bench::mark(
    R_reference = .Reference(),
    Cpp = .Native(),
    iterations = iterations, check = FALSE, memory = FALSE
  )
  print(x = result)
  artifact <- list(
    n = n, p = p, effects = effects, type = types, alpha = alpha,
    seed = 20261108, package = utils::packageVersion(pkg = "betaLB"),
    timings = result, reference_status = reference_status,
    native_status = native_status, session = utils::sessionInfo()
  )
  dir.create(
    path = ".setup/data-cache/betaLB", recursive = TRUE,
    showWarnings = FALSE
  )
  saveRDS(
    object = artifact,
    file = ".setup/data-cache/betaLB/benchmark.rds", compress = "xz"
  )
} else {
  message("Set BETALB_RUN_BENCHMARK=true on compute/local to run timings.")
}
