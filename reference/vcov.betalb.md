# Sampling Covariance Matrix Method for an Object of Class `betalb`

Likelihood intervals do not come from a sampling covariance matrix.

## Usage

``` r
# S3 method for class 'betalb'
vcov(object, ...)
```

## Arguments

- object:

  Object of class `betalb`.

- ...:

  additional arguments.

## Value

Stops with an error.

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

# try ----------------------------------------------------------------------
try(vcov(object = out))
#> Error in vcov.betalb(object = out) : 
#>   A covariance matrix is not defined for likelihood-based intervals.
```
