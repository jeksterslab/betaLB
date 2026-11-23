# Print Method for an Object of Class `summary.eslb`

Print Method for an Object of Class `summary.eslb`

## Usage

``` r
# S3 method for class 'summary.eslb'
print(x, ...)
```

## Arguments

- x:

  Object of class `summary.eslb`.

- ...:

  additional arguments.

## Value

Prints the matrix returned by
[`summary.eslb()`](https://jeksterslab.github.io/betaLB/reference/summary.eslb.md).

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
print(x = summary(object = out))
#> Call:
#> RSqLB(object = std, alpha = 0.05)
#> 
#> R-squared and adjusted R-squared with MVN likelihood intervals:
#>        est   2.5%  97.5%
#> rsq 0.8045 0.6041 0.9101
#> adj 0.7906 0.5758 0.9037
```
