# Estimate Standardized Regression Coefficients and the Corresponding Likelihood-Based Confidence Intervals

Estimates the standardized regression coefficients and their profile
likelihood confidence intervals for independently sampled random
regressors.

## Usage

``` r
BetaLB(
  object,
  type = "mvn",
  alpha = c(0.05, 0.01, 0.001),
  std_y = TRUE,
  std_x = NULL,
  control = list()
)
```

## Arguments

- object:

  Object of class `lm`. Unweighted, full-rank, scalar-response fit with
  an intercept, a stored model frame, no offsets, and a positive
  residual variance.

- type:

  Character string. Calibration of the likelihood-ratio cutoff. `"mvn"`
  (default) assumes multivariate normality. `"robust"` uses the
  empirical fourth moments.

- alpha:

  Numeric vector. Significance level \\(\alpha\\).

- std_y:

  Logical. Standardize \\(y\\). With `std_y = FALSE`, \\(y\\) is left in
  its original units (\\(b_j \sigma\_{x_j}\\)).

- std_x:

  Character vector or `NULL`. Names of the regressors to standardize.
  `NULL` (default) standardizes all regressors; `character(0)`
  standardizes none (\\(b_j / \sigma_y\\)). Leaving a dummy variable out
  keeps its 0-1 contrast.

- control:

  Named list. `maxeval` is the evaluation budget per endpoint (default
  `10000L`); `tolerance` is the normalized verification tolerance
  (default `1e-8`).

## Value

Returns an object of class `betalb` which is a list with the following
elements:

- call:

  Function call.

- args:

  Function arguments.

- lm_process:

  Sample size, number of regressors, and regressor names of the `lm`
  object.

- data:

  Sample covariance matrix, units, and the estimated asymptotic
  covariance matrices of its elements.

- est:

  Vector of standardized slopes.

- intervals:

  Data frame with one row per slope and significance level: the
  estimate, the lower and upper limits, the status of each endpoint, and
  the calibration used.

- diagnostics:

  Solver diagnostics of each endpoint.

## Details

Partition the covariance matrix of the outcome and the regressors as
\$\$\boldsymbol{\Sigma} = \begin{pmatrix} \sigma^{2}\_{y} &
\boldsymbol{\sigma}\_{yx}^{\prime} \\\\ \boldsymbol{\sigma}\_{yx} &
\boldsymbol{\Sigma}\_{x} \end{pmatrix}.\$\$ The standardized regression
slopes are \$\$\beta^{\ast}\_{j} = \beta\_{j}
\frac{\sigma\_{x\_{j}}}{\sigma\_{y}}, \quad \boldsymbol{\beta} =
\boldsymbol{\Sigma}\_{x}^{-1} \boldsymbol{\sigma}\_{yx}.\$\$ Let
\\(\tilde{\boldsymbol{S}}\\) be the sample covariance matrix with
divisor \\(n\\), \\(q\\) the number of variables, and \$\$F \left(
\boldsymbol{\Sigma} \right) = n \left\[ \log \left\| \boldsymbol{\Sigma}
\right\| - \log \left\| \tilde{\boldsymbol{S}} \right\| +
\operatorname{tr} \left( \tilde{\boldsymbol{S}} \boldsymbol{\Sigma}^{-1}
\right) - q \right\]\$\$ the Gaussian likelihood-ratio statistic of
\\(\boldsymbol{\Sigma}\\) against \\(\tilde{\boldsymbol{S}}\\). For a
target \\(\theta = g \left( \boldsymbol{\Sigma} \right)\\), here
\\(\beta^{\ast}\_{j}\\), the \\(100 \left( 1 - \alpha \right) \\%\\)
interval is \$\$\left\\{ \theta\_{0} : \min\_{\boldsymbol{\Sigma} : g
\left( \boldsymbol{\Sigma} \right) = \theta\_{0}} F \left(
\boldsymbol{\Sigma} \right) \leq c \\, \chi^{2}\_{1, 1 - \alpha}
\right\\}.\$\$ With `type = "mvn"`, \\(c = 1\\). With `type = "robust"`,
\$\$c = \frac{\boldsymbol{b}^{\prime}
\hat{\boldsymbol{\Gamma}}\_{\mathrm{ADF}}
\boldsymbol{b}}{\boldsymbol{b}^{\prime}
\hat{\boldsymbol{\Gamma}}\_{\mathrm{N}} \boldsymbol{b}}, \quad
\boldsymbol{b} = \frac{\partial g}{\partial \operatorname{vech} \left(
\boldsymbol{\Sigma} \right)},\$\$ evaluated at
\\(\tilde{\boldsymbol{S}}\\), where
\\(\hat{\boldsymbol{\Gamma}}\_{\mathrm{N}}\\) and
\\(\hat{\boldsymbol{\Gamma}}\_{\mathrm{ADF}}\\) are the normal-theory
and the fourth-moment estimates of the asymptotic covariance matrix of
\\(\sqrt{n} \operatorname{vech} \left( \tilde{\boldsymbol{S}}
\right)\\). For a vector target of dimension \\(r\\), \\(c\\) is the
largest generalized eigenvalue of \\(\boldsymbol{B}
\hat{\boldsymbol{\Gamma}}\_{\mathrm{ADF}} \boldsymbol{B}^{\prime}\\)
relative to \\(\boldsymbol{B} \hat{\boldsymbol{\Gamma}}\_{\mathrm{N}}
\boldsymbol{B}^{\prime}\\) and the cutoff has \\(r\\) degrees of
freedom. The effect size functions use the same statistic with their own
\\(g\\).

The intervals are the sets of parameter values that a likelihood-ratio
test of the covariance matrix of the response and the regressors does
not reject at the significance level `alpha`. With `type = "mvn"`, the
divisor-\\(n\\) Gaussian covariance likelihood and its chi-square cutoff
are used. With `type = "robust"`, the cutoff is scaled by the sample
fourth moments of the data, so that the intervals are robust to
non-normality. These are asymptotic procedures, without a finite-sample
coverage guarantee. The solver runs once per significance level. The
effect size functions
([`RSqLB()`](https://jeksterslab.github.io/betaLB/reference/RSqLB.md),
[`SCorLB()`](https://jeksterslab.github.io/betaLB/reference/SCorLB.md),
[`PCorLB()`](https://jeksterslab.github.io/betaLB/reference/PCorLB.md),
[`DeltaRSqLB()`](https://jeksterslab.github.io/betaLB/reference/DeltaRSqLB.md),
[`FSqLB()`](https://jeksterslab.github.io/betaLB/reference/FSqLB.md),
and
[`DiffBetaLB()`](https://jeksterslab.github.io/betaLB/reference/DiffBetaLB.md))
take the object returned by this function and use its `type` and
`control`.

## References

Dudgeon, P. (2017). Some improvements in confidence intervals for
standardized regression coefficients. *Psychometrika*, *82*(4), 928–951.
[doi:10.1007/s11336-017-9563-z](https://doi.org/10.1007/s11336-017-9563-z)

## See also

Other Beta Likelihood-Based Functions:
[`DeltaRSqLB()`](https://jeksterslab.github.io/betaLB/reference/DeltaRSqLB.md),
[`DiffBetaLB()`](https://jeksterslab.github.io/betaLB/reference/DiffBetaLB.md),
[`FSqLB()`](https://jeksterslab.github.io/betaLB/reference/FSqLB.md),
[`PCorLB()`](https://jeksterslab.github.io/betaLB/reference/PCorLB.md),
[`RSqLB()`](https://jeksterslab.github.io/betaLB/reference/RSqLB.md),
[`SCorLB()`](https://jeksterslab.github.io/betaLB/reference/SCorLB.md),
[`SCorSqLB()`](https://jeksterslab.github.io/betaLB/reference/SCorSqLB.md)

## Author

Ivan Jacob Agaloos Pesigan

## Examples

``` r
# Data ---------------------------------------------------------------------
data("nas1982", package = "betaLB")

# Fit Model in lm ----------------------------------------------------------
object <- stats::lm(
  formula = QUALITY ~ NARTIC + PCTGRT + PCTSUPP,
  data = nas1982
)

# BetaLB -------------------------------------------------------------------
std <- BetaLB(object = object, alpha = 0.05)

## Methods -----------------------------------------------------------------
print(x = std)
#> Call:
#> BetaLB(object = object, alpha = 0.05)
#> 
#> Standardized regression slopes with MVN likelihood intervals:
#>            est   2.5%  97.5%
#> NARTIC  0.4951 0.3423 0.6394
#> PCTGRT  0.3915 0.2395 0.5426
#> PCTSUPP 0.2632 0.1179 0.4148
summary(object = std)
#> Call:
#> BetaLB(object = object, alpha = 0.05)
#> 
#> Standardized regression slopes with MVN likelihood intervals:
#>            est   2.5%  97.5%
#> NARTIC  0.4951 0.3423 0.6394
#> PCTGRT  0.3915 0.2395 0.5426
#> PCTSUPP 0.2632 0.1179 0.4148
coef(object = std)
#>    NARTIC    PCTGRT   PCTSUPP 
#> 0.4951451 0.3914887 0.2632477 
confint(object = std, level = 0.95)
#>             2.5 %    97.5 %
#> NARTIC  0.3423306 0.6394250
#> PCTGRT  0.2395150 0.5426127
#> PCTSUPP 0.1178587 0.4148453
```
