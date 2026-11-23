# Estimated Parameters Method for an Object of Class `eslb`

Estimated Parameters Method for an Object of Class `eslb`

## Usage

``` r
# S3 method for class 'eslb'
coef(object, ...)
```

## Arguments

- object:

  Object of class `eslb`.

- ...:

  additional arguments.

## Value

Returns a vector of effect sizes.

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
coef(object = out)
#>       rsq       adj 
#> 0.8045263 0.7905638 
```
