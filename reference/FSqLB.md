# Likelihood Intervals for Overall and Local F-Squared

Extract already-computed point estimates and intervals from an LB
context. For multi-coefficient nonnegative effects, vector projection is
conservative.

## Usage

``` r
FSqLB(object)
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
[`PCorLB()`](https://jeksterslab.github.io/betaLB/reference/PCorLB.md),
[`RSqLB()`](https://jeksterslab.github.io/betaLB/reference/RSqLB.md),
[`SCorLB()`](https://jeksterslab.github.io/betaLB/reference/SCorLB.md)

## Author

Ivan Jacob Agaloos Pesigan

## Examples

``` r
fit <- stats::lm(formula = mpg ~ wt + hp, data = mtcars)
out <- LB(object = fit, effects = "fsq", type = "mvn", alpha = 0.05)
FSqLB(object = out)
#> Call:
#> LB(object = fit, type = "mvn", alpha = 0.05, effects = "fsq")
#> 
#> Likelihood intervals (vector projections are conservative)
#> type = "mvn"
#>   effect type alpha estimate  lower   upper lower_status upper_status
#> 1    fsq  mvn  0.05   4.7732 1.7132 12.1764           ok           ok
#> 2     wt  mvn  0.05   1.2952 0.4454  3.0609           ok           ok
#> 3     hp  mvn  0.05   0.4269 0.0714  1.2554           ok           ok
#>         calibration dimension
#> 1 vector_projection         2
#> 2    scalar_profile         1
#> 3    scalar_profile         1
```
