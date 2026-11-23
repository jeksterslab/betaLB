# Estimated Parameters Method for an Object of Class `betalb`

Estimated Parameters Method for an Object of Class `betalb`

## Usage

``` r
# S3 method for class 'betalb'
coef(object, ...)
```

## Arguments

- object:

  Object of class `betalb`.

- ...:

  additional arguments.

## Value

Returns a vector of standardized regression slopes.

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
coef(object = out)
#>    NARTIC    PCTGRT   PCTSUPP 
#> 0.4951451 0.3914887 0.2632477 
```
