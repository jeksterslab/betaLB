# Estimate Squared Semipartial Correlation Coefficients and the Corresponding Confidence Intervals From the Signed Intervals

Square the signed interval as a set, with lower limit zero if it
contains zero. This differs from an interval of squared draws. No draws
are generated and no endpoints are clipped to one. Failed signed
endpoints remain missing.

## Usage

``` r
SCorSqLB(object, level = 0.95)
```

## Arguments

- object:

  Object of class `betalb`. The output of
  [`BetaLB()`](https://jeksterslab.github.io/betaLB/reference/BetaLB.md).

- level:

  Single confidence level in (0, 1).

## Value

Data frame with est, lower and upper columns and predictor row names.
The point estimate is the squared signed estimate. No standard error is
implied by this interval transformation.

## Details

The semipartial correlation \\(sr\_{j}\\) (see
[`SCorLB()`](https://jeksterslab.github.io/betaLB/reference/SCorLB.md))
is signed, and its confidence interval \\(\left\[ l, u \right\]\\) may
contain zero. The interval for \\(sr^{2}\_{j}\\) is the image of that
interval under squaring. The squared interval is \\(\left\[ l^{2}, u^{2}
\right\]\\) if \\(0 \< l\\), \\(\left\[ u^{2}, l^{2} \right\]\\) if \\(u
\< 0\\), and \\(\left\[ 0, \max \left( l^{2}, u^{2} \right) \right\]\\)
if the signed interval contains zero. This is not a likelihood interval
for \\(sr^{2}\_{j}\\), and it is not an interval for
[`DeltaRSqLB()`](https://jeksterslab.github.io/betaLB/reference/DeltaRSqLB.md).

## See also

Other Beta Likelihood-Based Functions:
[`BetaLB()`](https://jeksterslab.github.io/betaLB/reference/BetaLB.md),
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
# Data ---------------------------------------------------------------------
data("nas1982", package = "betaLB")

# Fit Model in lm ----------------------------------------------------------
object <- stats::lm(
  formula = QUALITY ~ NARTIC + PCTGRT + PCTSUPP,
  data = nas1982
)

# BetaLB -------------------------------------------------------------------
std <- BetaLB(object = object, alpha = 0.05)

# SCorSqLB -----------------------------------------------------------------
SCorSqLB(object = std, level = 0.95)
#>               est      lower     upper
#> NARTIC  0.1858925 0.08306159 0.3488900
#> PCTGRT  0.1176542 0.04223605 0.2494239
#> PCTSUPP 0.0568722 0.01124041 0.1505438
```
