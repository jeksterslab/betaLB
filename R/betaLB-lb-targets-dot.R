#' Enumerate Targets for a Batched Likelihood Call
#'
#' Separate smooth target coordinates from reported transformations.
#' @author Ivan Jacob Agaloos Pesigan
#' @param data Analysis covariance statistics.
#' @param args Validated engine options.
#' @return Named target descriptors including block and adjusted outputs.
#' @examples
#' d <- .LBData(object = stats::lm(formula = mpg ~ wt, data = mtcars))
#' .LBTargets(data = d, args = list(
#'   effects = "rsq", std_y = TRUE,
#'   std_x = TRUE, blocks = list()
#' ))
#' @noRd
.LBTargets <- function(data, args) {
  store <- new.env(parent = emptyenv())
  store$targets <- list()
  .Add <- function(kind, label, family, index = integer(length = 0),
                   image = "identity") {
    id <- paste(kind, label, sep = ":")
    if (kind %in% c("beta", "diffbeta")) {
      id <- paste0(
        id, "|std_y=", as.integer(x = args$std_y),
        "|std_x=", paste(as.integer(x = args$std_x[index]), collapse = "")
      )
    }
    if (id %in% names(x = store$targets)) {
      stop("Duplicate effect labels; rename the predictor blocks.")
    }
    store$targets[[id]] <- list(
      id = id, kind = kind, label = label, family = family,
      index = index, image = image, std_y = args$std_y,
      std_x = args$std_x
    )
  }
  for (kind in args$effects) {
    if (kind == "rsq") {
      .Add(kind = kind, label = "rsq", family = "rsq", image = "square")
      .Add(kind = kind, label = "adj", family = "rsq", image = "adjusted")
    } else if (kind == "diffbeta") {
      if (data$p > 1L) {
        pairs <- utils::combn(x = seq_len(length.out = data$p), m = 2L)
        for (j in seq_len(length.out = ncol(x = pairs))) {
          index <- pairs[, j]
          .Add(
            kind = kind, label = paste(data$xnames[index], collapse = " - "),
            family = "diff", index = index
          )
        }
      }
    } else {
      if (kind == "fsq") {
        .Add(kind = kind, label = "fsq", family = "rsq", image = "fsq")
      }
      family <- switch(EXPR = kind,
        beta = "beta",
        scor = "sr",
        pcor = "pr",
        deltarsq = "delta",
        fsq = "local_f"
      )
      image <- if (kind %in% c("beta", "scor")) {
        "identity"
      } else {
        "square"
      }
      for (j in seq_len(length.out = data$p)) {
        .Add(
          kind = kind, label = data$xnames[j], family = family,
          index = j, image = image
        )
      }
      if (kind %in% c("deltarsq", "fsq")) {
        for (name in names(x = args$blocks)) {
          .Add(
            kind = kind, label = paste0("block:", name),
            family = if (kind == "fsq") {
              "block_f"
            } else {
              "delta"
            }, index = args$blocks[[name]], image = "square"
          )
        }
      }
    }
  }
  if (length(x = store$targets) == 0L) {
    stop("Difference targets require at least two predictors.")
  }
  store$targets
}
