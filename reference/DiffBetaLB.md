# Likelihood Intervals for Differences of Standardized Slopes

Extract already-computed point estimates and intervals from an LB
context. For multi-coefficient nonnegative effects, vector projection is
conservative.

## Usage

``` r
DiffBetaLB(object)
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
[`BetaLB()`](https://jeksterslab.github.io/betaLB/reference/BetaLB.md),
[`DeltaRSqLB()`](https://jeksterslab.github.io/betaLB/reference/DeltaRSqLB.md),
[`FSqLB()`](https://jeksterslab.github.io/betaLB/reference/FSqLB.md),
[`PCorLB()`](https://jeksterslab.github.io/betaLB/reference/PCorLB.md),
[`RSqLB()`](https://jeksterslab.github.io/betaLB/reference/RSqLB.md),
[`SCorLB()`](https://jeksterslab.github.io/betaLB/reference/SCorLB.md)

## Author

Ivan Jacob Agaloos Pesigan

## Examples

``` r
fit <- stats::lm(formula = mpg ~ wt + hp, data = mtcars)
out <- LB(object = fit, effects = "diffbeta", type = "mvn", alpha = 0.05)
DiffBetaLB(object = out)
#> Call:
#> LB(object = fit, type = "mvn", alpha = 0.05, effects = "diffbeta")
#> 
#> Likelihood intervals (vector projections are conservative)
#> type = "mvn"
#>    effect type alpha estimate   lower  upper lower_status upper_status
#> 1 wt - hp  mvn  0.05  -0.2681 -0.6241 0.1126           ok           ok
#>      calibration dimension
#> 1 scalar_profile         1
```
