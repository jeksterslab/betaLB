# Estimate Squared Partial Correlation Coefficients and the Corresponding Likelihood-Based Confidence Intervals

Estimate Squared Partial Correlation Coefficients and the Corresponding
Likelihood-Based Confidence Intervals

## Usage

``` r
PCorLB(object, alpha = c(0.05, 0.01, 0.001))
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

  Vector of squared partial correlation coefficients.

- intervals:

  Data frame of the estimates and the limits of each significance level.

- diagnostics:

  Solver diagnostics of each endpoint.

- fun:

  Function used ("PCorLB").

## Details

The squared partial correlation of regressor \\(j\\) is \\(pr^{2}\_{j} =
sr^{2}\_{j} / ( 1 - R^{2} + sr^{2}\_{j} )\\), the proportion of the
variance in the outcome not explained by the other regressors that is
explained by regressor \\(j\\). The intervals are profile likelihood
intervals of a nonnegative quantity. The `type` and `control` stored in
`object` are used.

## See also

Other Beta Likelihood-Based Functions:
[`BetaLB()`](https://jeksterslab.github.io/betaLB/reference/BetaLB.md),
[`DeltaRSqLB()`](https://jeksterslab.github.io/betaLB/reference/DeltaRSqLB.md),
[`DiffBetaLB()`](https://jeksterslab.github.io/betaLB/reference/DiffBetaLB.md),
[`FSqLB()`](https://jeksterslab.github.io/betaLB/reference/FSqLB.md),
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

# PCorLB -------------------------------------------------------------------
out <- PCorLB(object = std, alpha = 0.05)

## Methods -----------------------------------------------------------------
print(x = out)
#> Call:
#> PCorLB(object = std, alpha = 0.05)
#> 
#> Squared partial correlations with MVN likelihood intervals:
#>            est   2.5%  97.5%
#> NARTIC  0.4874 0.2677 0.6713
#> PCTGRT  0.3757 0.1593 0.5830
#> PCTSUPP 0.2254 0.0490 0.4463
summary(object = out)
#> Call:
#> PCorLB(object = std, alpha = 0.05)
#> 
#> Squared partial correlations with MVN likelihood intervals:
#>            est   2.5%  97.5%
#> NARTIC  0.4874 0.2677 0.6713
#> PCTGRT  0.3757 0.1593 0.5830
#> PCTSUPP 0.2254 0.0490 0.4463
coef(object = out)
#>    NARTIC    PCTGRT   PCTSUPP 
#> 0.4874382 0.3757383 0.2253739 
confint(object = out, level = 0.95)
#>              2.5 %    97.5 %
#> NARTIC  0.26765580 0.6712679
#> PCTGRT  0.15934728 0.5830058
#> PCTSUPP 0.04903576 0.4462532
```
