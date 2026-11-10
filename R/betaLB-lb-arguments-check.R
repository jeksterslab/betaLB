#' Check Likelihood-Engine Options
#'
#' Validate all options before preparing native requests.
#' @author Ivan Jacob Agaloos Pesigan
#' @param type Character vector of calibration types.
#' @param alpha Distinct significance levels.
#' @param effects Requested effect families.
#' @param std_y Logical response-standardization flag.
#' @param std_x Logical flags or predictor names to standardize.
#' @param blocks Named list of predictor blocks.
#' @param control Named list of solver options.
#' @param data Analysis statistics from `.LBData()`.
#' @return Validated and normalized options.
#' @examples
#' d <- .LBData(object = stats::lm(formula = mpg ~ wt, data = mtcars))
#' .CheckLBArguments(
#'   type = "mvn", alpha = 0.05, effects = "rsq",
#'   std_y = TRUE, std_x = TRUE, blocks = list(),
#'   control = list(), data = d
#' )
#' @noRd
.CheckLBArguments <- function(type, alpha, effects, std_y, std_x, blocks,
                              control, data) {
  choices <- c("beta", "rsq", "scor", "pcor", "deltarsq", "diffbeta", "fsq")
  bad_type <- !is.character(x = type) || length(x = type) == 0L ||
    anyNA(x = type) || any(x = !type %in% c("mvn", "robust"))
  if (bad_type) {
    stop("type must contain mvn and/or robust.")
  }
  bad_alpha <- !is.numeric(x = alpha) || length(x = alpha) == 0L ||
    any(x = !is.finite(x = alpha)) || any(x = alpha <= 0 | alpha >= 1) ||
    anyDuplicated(x = alpha)
  if (bad_alpha) {
    stop("alpha must contain distinct finite significance levels in (0, 1).")
  }
  bad_effects <- !is.character(x = effects) || length(x = effects) == 0L ||
    anyNA(x = effects) || any(x = !effects %in% choices)
  if (bad_effects) {
    stop("effects contains an unsupported or missing family.")
  }
  if (!is.logical(x = std_y) || length(x = std_y) != 1L || is.na(x = std_y)) {
    stop("std_y must be a single nonmissing logical value.")
  }
  if (is.character(x = std_x)) {
    bad_std_x <- anyNA(x = std_x) || anyDuplicated(x = std_x) ||
      any(x = !std_x %in% data$xnames)
    if (bad_std_x) {
      stop("std_x contains unknown or repeated predictor names.")
    }
    std_x <- data$xnames %in% std_x
  } else {
    valid_std_x <- is.logical(x = std_x) && !anyNA(x = std_x) &&
      length(x = std_x) %in% c(1L, data$p)
    if (valid_std_x) {
      std_x <- rep(x = std_x, length.out = data$p)
    } else {
      stop("std_x must be a logical scalar/vector or predictor names.")
    }
  }
  bad_blocks <- !is.list(x = blocks)
  if (!bad_blocks && length(x = blocks) > 0L) {
    bad_blocks <- is.null(x = names(x = blocks)) ||
      anyNA(x = names(x = blocks)) ||
      any(x = !nzchar(x = names(x = blocks))) ||
      anyDuplicated(x = names(x = blocks))
  }
  if (bad_blocks) {
    stop("blocks must be a uniquely named list.")
  }
  blocks <- lapply(X = blocks, FUN = function(block) {
    if (is.character(x = block)) {
      block <- match(x = block, table = data$xnames)
    }
    bad_block <- !is.numeric(x = block) || length(x = block) == 0L ||
      anyNA(x = block) || any(x = !is.finite(x = block)) ||
      any(x = block != floor(x = block)) ||
      any(x = block < 1 | block > data$p) || anyDuplicated(x = block)
    if (bad_block) {
      stop("Each block must identify distinct existing predictor columns.")
    }
    as.integer(x = block)
  })
  control_names <- names(x = control)
  bad_control <- is.null(x = control_names) ||
    anyDuplicated(x = control_names) ||
    any(x = !control_names %in% c("maxeval", "tolerance"))
  bad_control <- !is.list(x = control) ||
    (length(x = control) > 0L && bad_control)
  if (bad_control) {
    stop("control permits only maxeval and tolerance.")
  }
  control <- utils::modifyList(
    x = list(maxeval = 10000L, tolerance = 1e-8),
    val = control
  )
  bad_solver <- !is.numeric(x = control$maxeval) ||
    length(x = control$maxeval) != 1L ||
    !is.finite(x = control$maxeval) || control$maxeval < 1 ||
    control$maxeval != floor(x = control$maxeval) ||
    control$maxeval > .Machine$integer.max ||
    !is.numeric(x = control$tolerance) ||
    length(x = control$tolerance) != 1L ||
    !is.finite(x = control$tolerance) || control$tolerance <= 0 ||
    control$tolerance > 1e-3
  if (bad_solver) {
    stop("Require positive integer maxeval and tolerance in (0, 0.001].")
  }
  list(
    type = unique(x = type), alpha = alpha, effects = unique(x = effects),
    std_y = std_y, std_x = std_x, blocks = blocks, control = control
  )
}
