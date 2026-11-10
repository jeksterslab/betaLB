# Likelihood Intervals for R-Squared and Its Finite-Sample Adjustment

Extract already-computed point estimates and intervals from an LB
context. For multi-coefficient nonnegative effects, vector projection is
conservative.

## Usage

``` r
RSqLB(object)
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
[`DiffBetaLB()`](https://jeksterslab.github.io/betaLB/reference/DiffBetaLB.md),
[`FSqLB()`](https://jeksterslab.github.io/betaLB/reference/FSqLB.md),
[`PCorLB()`](https://jeksterslab.github.io/betaLB/reference/PCorLB.md),
[`SCorLB()`](https://jeksterslab.github.io/betaLB/reference/SCorLB.md)

## Author

Ivan Jacob Agaloos Pesigan

## Examples

``` r
fit <- stats::lm(formula = mpg ~ wt + hp, data = mtcars)
out <- LB(object = fit, effects = "rsq", type = "mvn", alpha = 0.05)
RSqLB(object = out)
#> Call:
#> LB(object = fit, type = "mvn", alpha = 0.05, effects = "rsq")
#> 
#> Likelihood intervals (vector projections are conservative)
#> type = "mvn"
#>   effect type alpha estimate  lower  upper lower_status upper_status
#> 1    rsq  mvn  0.05   0.8268 0.6314 0.9241           ok           ok
#> 2    adj  mvn  0.05   0.8148 0.6060 0.9189           ok           ok
#>         calibration dimension
#> 1 vector_projection         2
#> 2 vector_projection         2
```
