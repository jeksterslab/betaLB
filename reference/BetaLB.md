# Likelihood Intervals for Standardized Regression Slopes

Extract already-computed point estimates and intervals from an LB
context. For multi-coefficient nonnegative effects, vector projection is
conservative.

## Usage

``` r
BetaLB(object)
```

## Arguments

- object:

  Context returned by
  [`LB()`](https://jeksterslab.github.io/betaLB/reference/LB.md), with
  this family computed.

## Value

Object of class `betalb`; use
[`coef()`](https://rdrr.io/r/stats/coef.html),
[`confint()`](https://rdrr.io/r/stats/confint.html) or
[`summary()`](https://rdrr.io/r/base/summary.html).

## See also

Other Likelihood Effect Extractors:
[`DeltaRSqLB()`](https://jeksterslab.github.io/betaLB/reference/DeltaRSqLB.md),
[`DiffBetaLB()`](https://jeksterslab.github.io/betaLB/reference/DiffBetaLB.md),
[`FSqLB()`](https://jeksterslab.github.io/betaLB/reference/FSqLB.md),
[`PCorLB()`](https://jeksterslab.github.io/betaLB/reference/PCorLB.md),
[`RSqLB()`](https://jeksterslab.github.io/betaLB/reference/RSqLB.md),
[`SCorLB()`](https://jeksterslab.github.io/betaLB/reference/SCorLB.md)

## Author

Ivan Jacob Agaloos Pesigan

## Examples

``` r
fit <- stats::lm(formula = mpg ~ wt + hp, data = mtcars)
out <- LB(object = fit, effects = "beta", type = "mvn", alpha = 0.05)
BetaLB(object = out)
#> Call:
#> LB(object = fit, type = "mvn", alpha = 0.05, effects = "beta")
#> 
#> Likelihood intervals (vector projections are conservative)
#> type = "mvn"
#>   effect type alpha estimate   lower   upper lower_status upper_status
#> 1     wt  mvn  0.05  -0.6296 -0.7934 -0.4347           ok           ok
#> 2     hp  mvn  0.05  -0.3615 -0.5538 -0.1628           ok           ok
#>      calibration dimension
#> 1 scalar_profile         1
#> 2 scalar_profile         1
```
