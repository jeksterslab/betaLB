# Squared Signed-Semipartial Confidence Intervals

Square the signed interval as a set, with lower limit zero if it
contains zero. This differs from an interval of squared draws. No draws
are generated and no endpoints are clipped to one. Failed signed
endpoints remain missing.

## Usage

``` r
SCorSqLB(object, level = 0.95, type = NULL)
```

## Arguments

- object:

  Context accepted by
  [`SCorLB()`](https://jeksterslab.github.io/betaLB/reference/SCorLB.md).

- level:

  Single confidence level in (0, 1).

- type:

  Stored likelihood calibration, or NULL for the first.

## Value

Data frame with est, lower and upper columns and predictor row names.
The point estimate is the squared signed estimate. No standard error is
implied by this interval transformation.

## Author

Ivan Jacob Agaloos Pesigan

## Examples

``` r
fit <- stats::lm(formula = mpg ~ wt + hp, data = mtcars)
out <- LB(object = fit, effects = "scor", type = "mvn", alpha = 0.05)
SCorSqLB(object = out)
#>           est      lower     upper
#> wt 0.22434811 0.09380047 0.4397384
#> hp 0.07395266 0.01438553 0.2036039
```
