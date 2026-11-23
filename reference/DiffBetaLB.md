# Estimate Differences of Standardized Regression Coefficients and the Corresponding Likelihood-Based Confidence Intervals

Estimate Differences of Standardized Regression Coefficients and the
Corresponding Likelihood-Based Confidence Intervals

## Usage

``` r
DiffBetaLB(object, alpha = c(0.05, 0.01, 0.001))
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

  Vector of differences of standardized slopes.

- intervals:

  Data frame of the estimates and the limits of each significance level.

- diagnostics:

  Solver diagnostics of each endpoint.

- fun:

  Function used ("DiffBetaLB").

## Details

Differences are taken over all pairs of standardized slopes,
\\(\beta^{\ast}\_{i} - \beta^{\ast}\_{j}\\). Two or more regressors are
required, and `object` must have fully standardized slopes
(`std_y = TRUE` and `std_x = NULL` in
[`BetaLB()`](https://jeksterslab.github.io/betaLB/reference/BetaLB.md)).
The `type` and `control` stored in `object` are used.

## See also

Other Beta Likelihood-Based Functions:
[`BetaLB()`](https://jeksterslab.github.io/betaLB/reference/BetaLB.md),
[`DeltaRSqLB()`](https://jeksterslab.github.io/betaLB/reference/DeltaRSqLB.md),
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

# DiffBetaLB ---------------------------------------------------------------
out <- DiffBetaLB(object = std, alpha = 0.05)

## Methods -----------------------------------------------------------------
print(x = out)
#> Call:
#> DiffBetaLB(object = std, alpha = 0.05)
#> 
#> Differences of standardized regression slopes with MVN likelihood intervals:
#>                     est    2.5%  97.5%
#> NARTIC - PCTGRT  0.1037 -0.1657 0.3654
#> NARTIC - PCTSUPP 0.2319 -0.0213 0.4713
#> PCTGRT - PCTSUPP 0.1282 -0.1171 0.3673
summary(object = out)
#> Call:
#> DiffBetaLB(object = std, alpha = 0.05)
#> 
#> Differences of standardized regression slopes with MVN likelihood intervals:
#>                     est    2.5%  97.5%
#> NARTIC - PCTGRT  0.1037 -0.1657 0.3654
#> NARTIC - PCTSUPP 0.2319 -0.0213 0.4713
#> PCTGRT - PCTSUPP 0.1282 -0.1171 0.3673
coef(object = out)
#>  NARTIC - PCTGRT NARTIC - PCTSUPP PCTGRT - PCTSUPP 
#>        0.1036564        0.2318974        0.1282410 
confint(object = out, level = 0.95)
#>                        2.5 %    97.5 %
#> NARTIC - PCTGRT  -0.16567259 0.3654049
#> NARTIC - PCTSUPP -0.02133054 0.4713237
#> PCTGRT - PCTSUPP -0.11709876 0.3673159
```
