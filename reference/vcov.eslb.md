# Sampling Covariance Matrix Method for an Object of Class `eslb`

Likelihood intervals do not come from a sampling covariance matrix.

## Usage

``` r
# S3 method for class 'eslb'
vcov(object, ...)
```

## Arguments

- object:

  Object of class `eslb`.

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
std <- BetaLB(object = object, alpha = 0.05)

# RSqLB --------------------------------------------------------------------
out <- RSqLB(object = std, alpha = 0.05)

# try ----------------------------------------------------------------------
try(vcov(object = out))
#> Error in vcov.eslb(object = out) : 
#>   A covariance matrix is not defined for likelihood-based intervals.
```
