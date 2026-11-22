#' Estimate Standardized Regression Coefficients
#' and the Corresponding Likelihood-Based Confidence Intervals
#'
#' Estimates the standardized regression coefficients
#' and their profile likelihood confidence intervals
#' for independently sampled random regressors.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @details
#' Partition the covariance matrix of the outcome and the regressors as
#' \deqn{\boldsymbol{\Sigma} = \begin{pmatrix} \sigma^{2}_{y} &
#' \boldsymbol{\sigma}_{yx}^{\prime} \\ \boldsymbol{\sigma}_{yx} &
#' \boldsymbol{\Sigma}_{x} \end{pmatrix}.}
#' The standardized regression slopes are
#' \deqn{\beta^{\ast}_{j} = \beta_{j} \frac{\sigma_{x_{j}}}{\sigma_{y}},
#' \quad \boldsymbol{\beta} = \boldsymbol{\Sigma}_{x}^{-1}
#' \boldsymbol{\sigma}_{yx}.}
#' Let \eqn{\tilde{\boldsymbol{S}}} be the sample covariance matrix with
#' divisor \eqn{n}, \eqn{q} the number of variables, and
#' \deqn{F \left( \boldsymbol{\Sigma} \right) = n \left[ \log \left|
#' \boldsymbol{\Sigma} \right| - \log \left| \tilde{\boldsymbol{S}} \right| +
#' \operatorname{tr} \left( \tilde{\boldsymbol{S}} \boldsymbol{\Sigma}^{-1}
#' \right) - q \right]}
#' the Gaussian likelihood-ratio statistic of \eqn{\boldsymbol{\Sigma}}
#' against \eqn{\tilde{\boldsymbol{S}}}.
#' For a target \eqn{\theta = g \left( \boldsymbol{\Sigma} \right)},
#' here \eqn{\beta^{\ast}_{j}},
#' the \eqn{100 \left( 1 - \alpha \right) \%} interval is
#' \deqn{\left\{ \theta_{0} : \min_{\boldsymbol{\Sigma} : g \left(
#' \boldsymbol{\Sigma} \right) = \theta_{0}} F \left( \boldsymbol{\Sigma}
#' \right) \leq c \, \chi^{2}_{1, 1 - \alpha} \right\}.}
#' With `type = "mvn"`, \eqn{c = 1}.
#' With `type = "robust"`,
#' \deqn{c = \frac{\boldsymbol{b}^{\prime}
#' \hat{\boldsymbol{\Gamma}}_{\mathrm{ADF}}
#' \boldsymbol{b}}{\boldsymbol{b}^{\prime}
#' \hat{\boldsymbol{\Gamma}}_{\mathrm{N}} \boldsymbol{b}},
#' \quad \boldsymbol{b} =
#' \frac{\partial g}{\partial \operatorname{vech} \left( \boldsymbol{\Sigma}
#' \right)},}
#' evaluated at \eqn{\tilde{\boldsymbol{S}}}, where
#' \eqn{\hat{\boldsymbol{\Gamma}}_{\mathrm{N}}} and
#' \eqn{\hat{\boldsymbol{\Gamma}}_{\mathrm{ADF}}} are the normal-theory and
#' the fourth-moment estimates of the asymptotic covariance matrix of
#' \eqn{\sqrt{n} \operatorname{vech} \left( \tilde{\boldsymbol{S}} \right)}.
#' For a vector target of dimension \eqn{r},
#' \eqn{c} is the largest generalized eigenvalue of
#' \eqn{\boldsymbol{B} \hat{\boldsymbol{\Gamma}}_{\mathrm{ADF}}
#' \boldsymbol{B}^{\prime}} relative to
#' \eqn{\boldsymbol{B} \hat{\boldsymbol{\Gamma}}_{\mathrm{N}}
#' \boldsymbol{B}^{\prime}} and the cutoff has \eqn{r} degrees of freedom.
#' The effect size functions use the same statistic with their own
#' \eqn{g}.
#'
#' @details
#' The intervals are the sets of parameter values that a likelihood-ratio
#' test of the covariance matrix of the response and the regressors
#' does not reject at the significance level `alpha`.
#' With `type = "mvn"`, the divisor-\eqn{n} Gaussian covariance likelihood
#' and its chi-square cutoff are used.
#' With `type = "robust"`, the cutoff is scaled by the sample fourth moments
#' of the data, so that the intervals are robust to non-normality.
#' These are asymptotic procedures,
#' without a finite-sample coverage guarantee.
#' The solver runs once per significance level.
#' The effect size functions ([RSqLB()], [SCorLB()], [PCorLB()],
#' [DeltaRSqLB()], [FSqLB()], and [DiffBetaLB()]) take the object returned
#' by this function and use its `type` and `control`.
#'
#' @return Returns an object
#'   of class `betalb` which is a list with the following elements:
#'   \describe{
#'     \item{call}{Function call.}
#'     \item{args}{Function arguments.}
#'     \item{lm_process}{Sample size, number of regressors,
#'       and regressor names of the `lm` object.}
#'     \item{data}{Sample covariance matrix, units, and the estimated
#'       asymptotic covariance matrices of its elements.}
#'     \item{est}{Vector of standardized slopes.}
#'     \item{intervals}{Data frame with one row per slope and significance
#'       level: the estimate, the lower and upper limits,
#'       the status of each endpoint, and the calibration used.}
#'     \item{diagnostics}{Solver diagnostics of each endpoint.}
#'   }
#'
#' @param object Object of class `lm`.
#'   Unweighted, full-rank, scalar-response fit with an intercept,
#'   a stored model frame, no offsets, and a positive residual variance.
#' @param type Character string.
#'   Calibration of the likelihood-ratio cutoff.
#'   `"mvn"` (default) assumes multivariate normality.
#'   `"robust"` uses the empirical fourth moments.
#' @param alpha Numeric vector.
#'   Significance level \eqn{\alpha}.
#' @param std_y Logical.
#'   Standardize \eqn{y}.
#'   With `std_y = FALSE`, \eqn{y} is left in its original units
#'   (\eqn{b_j \sigma_{x_j}}).
#' @param std_x Character vector or `NULL`.
#'   Names of the regressors to standardize.
#'   `NULL` (default) standardizes all regressors;
#'   `character(0)` standardizes none (\eqn{b_j / \sigma_y}).
#'   Leaving a dummy variable out keeps its 0-1 contrast.
#' @param control Named list.
#'   `maxeval` is the evaluation budget per endpoint
#'   (default `10000L`);
#'   `tolerance` is the normalized verification tolerance
#'   (default `1e-8`).
#'
#' @references
#' Dudgeon, P. (2017).
#' Some improvements in confidence intervals
#' for standardized regression coefficients.
#' *Psychometrika*, *82*(4), 928--951.
#' \doi{10.1007/s11336-017-9563-z}
#'
#' @examples
#' # Data ---------------------------------------------------------------------
#' data("nas1982", package = "betaLB")
#'
#' # Fit Model in lm ----------------------------------------------------------
#' object <- stats::lm(
#'   formula = QUALITY ~ NARTIC + PCTGRT + PCTSUPP,
#'   data = nas1982
#' )
#'
#' # BetaLB -------------------------------------------------------------------
#' std <- BetaLB(object = object, alpha = 0.05)
#'
#' ## Methods -----------------------------------------------------------------
#' print(x = std)
#' summary(object = std)
#' coef(object = std)
#' confint(object = std, level = 0.95)
#'
#' @family Beta Likelihood-Based Functions
#' @keywords betaLB std
#' @export
BetaLB <- function(object,
                   type = "mvn",
                   alpha = c(0.05, 0.01, 0.001),
                   std_y = TRUE,
                   std_x = NULL,
                   control = list()) {
  data <- .LBData(object = object)
  args <- .CheckLBArguments(
    type = type,
    alpha = alpha,
    std_y = std_y,
    std_x = std_x,
    blocks = NULL,
    control = control,
    data = data
  )
  args$effects <- "beta"
  run <- .LBRun(
    data = data,
    args = args
  )
  out <- list(
    call = match.call(),
    args = list(
      object = object,
      type = type,
      alpha = alpha,
      std_y = std_y,
      std_x = std_x,
      control = args$control
    ),
    lm_process = list(
      n = data$n,
      p = data$p,
      xnames = data$xnames,
      rows = data$rows
    ),
    data = data,
    est = run$est,
    intervals = run$intervals,
    diagnostics = run$diagnostics
  )
  attributes(x = out)$std <- std_y && all(args$std_x)
  class(x = out) <- c(
    "betalb",
    class(x = out)
  )
  out
}
