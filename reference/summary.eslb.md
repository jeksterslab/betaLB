# Summary Method for an Object of Class `eslb`

Summary Method for an Object of Class `eslb`

## Usage

``` r
# S3 method for class 'eslb'
summary(object, alpha = NULL, digits = 4, ...)
```

## Arguments

- object:

  Object of class `eslb`.

- alpha:

  Numeric vector. Significance level \\(\alpha\\). If `alpha = NULL`,
  use the argument `alpha` used in `object`. Only significance levels
  that were computed are available.

- digits:

  Digits to print.

- ...:

  additional arguments.

## Value

Returns a matrix of effect sizes, and the lower and upper limits of the
likelihood intervals.

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
summary(object = out)
#> Call:
#> RSqLB(object = std, alpha = 0.05)
#> 
#> R-squared and adjusted R-squared with MVN likelihood intervals:
#>        est   2.5%  97.5%
#> rsq 0.8045 0.6041 0.9101
#> adj 0.7906 0.5758 0.9037
```
