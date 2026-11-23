# Estimate Semipartial Correlation Coefficients and the Corresponding Likelihood-Based Confidence Intervals

Estimate Semipartial Correlation Coefficients and the Corresponding
Likelihood-Based Confidence Intervals

## Usage

``` r
SCorLB(object, alpha = c(0.05, 0.01, 0.001))
```

## Arguments

- object:

  Object of class `betalb`. The output of
  [`BetaLB()`](https://jeksterslab.github.io/betaLB/reference/BetaLB.md).

- alpha:

  Numeric vector. Significance level \\(\alpha\\).

## Value

Returns an object of class `eslb` which is a list with the following
elements:

- call:

  Function call.

- fit:

  The argument `object`.

- args:

  Function arguments.

- lm_process:

  Sample size, number of regressors, and regressor names.

- est:

  Vector of semipartial correlations.

- intervals:

  Data frame of the estimates and the limits of each significance level.

- diagnostics:

  Solver diagnostics of each endpoint.

- fun:

  Function used ("SCorLB").

## Details

The semipartial correlation of regressor \\(j\\) is \\(sr\_{j} =
\beta^{\ast}\_{j} \sqrt{1 - R^{2}\_{j \cdot -j}}\\), where \\(R^{2}\_{j
\cdot -j}\\) is the R-squared from regressing regressor \\(j\\) on the
other regressors. The intervals are signed profile likelihood intervals
of a scalar. The `type` and `control` stored in `object` are used.

## See also

Other Beta Likelihood-Based Functions:
[`BetaLB()`](https://jeksterslab.github.io/betaLB/reference/BetaLB.md),
[`DeltaRSqLB()`](https://jeksterslab.github.io/betaLB/reference/DeltaRSqLB.md),
[`DiffBetaLB()`](https://jeksterslab.github.io/betaLB/reference/DiffBetaLB.md),
[`FSqLB()`](https://jeksterslab.github.io/betaLB/reference/FSqLB.md),
[`PCorLB()`](https://jeksterslab.github.io/betaLB/reference/PCorLB.md),
[`RSqLB()`](https://jeksterslab.github.io/betaLB/reference/RSqLB.md),
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

# SCorLB -------------------------------------------------------------------
out <- SCorLB(object = std, alpha = 0.05)

## Methods -----------------------------------------------------------------
print(x = out)
#> Call:
#> SCorLB(object = std, alpha = 0.05)
#> 
#> Semipartial correlations with MVN likelihood intervals:
#>            est   2.5%  97.5%
#> NARTIC  0.4312 0.2882 0.5907
#> PCTGRT  0.3430 0.2055 0.4994
#> PCTSUPP 0.2385 0.1060 0.3880
summary(object = out)
#> Call:
#> SCorLB(object = std, alpha = 0.05)
#> 
#> Semipartial correlations with MVN likelihood intervals:
#>            est   2.5%  97.5%
#> NARTIC  0.4312 0.2882 0.5907
#> PCTGRT  0.3430 0.2055 0.4994
#> PCTSUPP 0.2385 0.1060 0.3880
coef(object = out)
#>    NARTIC    PCTGRT   PCTSUPP 
#> 0.4311525 0.3430075 0.2384789 
confint(object = out, level = 0.95)
#>             2.5 %    97.5 %
#> NARTIC  0.2882041 0.5906691
#> PCTGRT  0.2055141 0.4994235
#> PCTSUPP 0.1060208 0.3879997
```
