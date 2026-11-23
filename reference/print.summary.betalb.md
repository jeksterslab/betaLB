# Print Method for an Object of Class `summary.betalb`

Print Method for an Object of Class `summary.betalb`

## Usage

``` r
# S3 method for class 'summary.betalb'
print(x, ...)
```

## Arguments

- x:

  Object of class `summary.betalb`.

- ...:

  additional arguments.

## Value

Prints the matrix returned by
[`summary.betalb()`](https://jeksterslab.github.io/betaLB/reference/summary.betalb.md).

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
out <- BetaLB(object = object, alpha = 0.05)

## Methods -----------------------------------------------------------------
print(x = summary(object = out))
#> Call:
#> BetaLB(object = object, alpha = 0.05)
#> 
#> Standardized regression slopes with MVN likelihood intervals:
#>            est   2.5%  97.5%
#> NARTIC  0.4951 0.3423 0.6394
#> PCTGRT  0.3915 0.2395 0.5426
#> PCTSUPP 0.2632 0.1179 0.4148
```
