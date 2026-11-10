# Likelihood Intervals for Regression Effect Sizes

Fit covariance-likelihood regions for independently sampled random
regressors. Compute requested effects, types and confidence levels in
one native batch, then use the effect extractors to select stored
results.

## Usage

``` r
LB(
  object,
  type = c("mvn", "robust"),
  alpha = c(0.05, 0.01, 0.001),
  effects = c("beta", "rsq", "scor", "pcor", "deltarsq", "diffbeta", "fsq"),
  std_y = TRUE,
  std_x = TRUE,
  blocks = list(),
  control = list()
)
```

## Arguments

- object:

  Unweighted, full-rank scalar-response `lm` fit with an intercept,
  stored model frame, no offsets and positive residual variance.

- type:

  Character vector containing `mvn`, `robust`, or both.

- alpha:

  Distinct significance levels in (0, 1).

- effects:

  Requested families: `beta`, `rsq`, `scor`, `pcor`, `deltarsq`,
  `diffbeta`, and `fsq`.

- std_y:

  Whether to standardize the response for slope targets.

- std_x:

  Logical flags or names of model-matrix predictors to standardize for
  slope targets. Other effects keep their definitions.

- blocks:

  Named list of additional predictor blocks, identified by model-matrix
  column names or indices, for increments and local f-squared.

- control:

  Named list: `maxeval` is the native evaluation budget per endpoint;
  `tolerance` is its normalized verification tolerance.

## Value

Context of class `lb`, containing named point estimates, a long
`intervals` table and per-row endpoint `diagnostics`. Failed endpoints
are `NA` with a specific status. Extractors return `betalb` objects.
Slope/contrast target IDs retain their standardization flags.

## Details

Normal theory uses divisor-n Gaussian covariance likelihood. Robust
calibration uses empirical fourth moments. Signed scalar targets use a
target-specific variance ratio; multi-coefficient nonnegative effects
use conservative vector projection and a largest-eigenvalue robust
cutoff. These are asymptotic procedures, without a finite-sample
coverage guarantee.

## Author

Ivan Jacob Agaloos Pesigan

## Examples

``` r
fit <- stats::lm(formula = mpg ~ wt, data = mtcars)
out <- LB(object = fit, type = "mvn", alpha = 0.05, effects = "rsq")
RSqLB(object = out)
#> Call:
#> LB(object = fit, type = "mvn", alpha = 0.05, effects = "rsq")
#> 
#> Likelihood intervals (vector projections are conservative)
#> type = "mvn"
#>   effect type alpha estimate  lower  upper lower_status upper_status
#> 1    rsq  mvn  0.05   0.7528 0.5629 0.8686           ok           ok
#> 2    adj  mvn  0.05   0.7446 0.5483 0.8643           ok           ok
#>      calibration dimension
#> 1 scalar_profile         1
#> 2 scalar_profile         1
```
