# Estimate R-Squared and Adjusted R-Squared and the Corresponding Likelihood-Based Confidence Intervals

Estimate R-Squared and Adjusted R-Squared and the Corresponding
Likelihood-Based Confidence Intervals

## Usage

``` r
RSqLB(object, alpha = c(0.05, 0.01, 0.001))
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

  Vector of R-squared and adjusted R-squared.

- intervals:

  Data frame of the estimates and the limits of each significance level.

- diagnostics:

  Solver diagnostics of each endpoint.

- fun:

  Function used ("RSqLB").

## Details

Let \\(\boldsymbol{\beta}^{\ast}\\) be the vector of standardized slopes
and \\(\boldsymbol{R}\_{x}\\) the correlation matrix of the regressors.
The R-squared and the adjusted R-squared are \$\$R^{2} =
\boldsymbol{\beta}^{\ast\prime} \boldsymbol{R}\_{x}
\boldsymbol{\beta}^{\ast}, \quad \bar{R}^{2} = 1 - \left( 1 - R^{2}
\right) \frac{n - 1}{n - k},\$\$ where \\(n\\) is the sample size and
\\(k\\) is the number of parameters in the regression model, including
the intercept. The interval of \\(R^{2}\\) is the profile likelihood
interval of a nonnegative quantity; the limits of \\(\bar{R}^{2}\\) are
the transformed limits of \\(R^{2}\\). The `type` and `control` stored
in `object` are used.

## See also

Other Beta Likelihood-Based Functions:
[`BetaLB()`](https://jeksterslab.github.io/betaLB/reference/BetaLB.md),
[`DeltaRSqLB()`](https://jeksterslab.github.io/betaLB/reference/DeltaRSqLB.md),
[`DiffBetaLB()`](https://jeksterslab.github.io/betaLB/reference/DiffBetaLB.md),
[`FSqLB()`](https://jeksterslab.github.io/betaLB/reference/FSqLB.md),
[`PCorLB()`](https://jeksterslab.github.io/betaLB/reference/PCorLB.md),
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

# RSqLB --------------------------------------------------------------------
out <- RSqLB(object = std, alpha = 0.05)

## Methods -----------------------------------------------------------------
print(x = out)
#> Call:
#> RSqLB(object = std, alpha = 0.05)
#> 
#> R-squared and adjusted R-squared with MVN likelihood intervals:
#>        est   2.5%  97.5%
#> rsq 0.8045 0.6041 0.9101
#> adj 0.7906 0.5758 0.9037
summary(object = out)
#> Call:
#> RSqLB(object = std, alpha = 0.05)
#> 
#> R-squared and adjusted R-squared with MVN likelihood intervals:
#>        est   2.5%  97.5%
#> rsq 0.8045 0.6041 0.9101
#> adj 0.7906 0.5758 0.9037
coef(object = out)
#>       rsq       adj 
#> 0.8045263 0.7905638 
confint(object = out, level = 0.95)
#>         2.5 %    97.5 %
#> rsq 0.6041157 0.9101072
#> adj 0.5758383 0.9036862
```
