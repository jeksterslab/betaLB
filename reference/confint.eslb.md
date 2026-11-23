# Confidence Intervals Method for an Object of Class `eslb`

Confidence Intervals Method for an Object of Class `eslb`

## Usage

``` r
# S3 method for class 'eslb'
confint(object, parm = NULL, level = 0.95, ...)
```

## Arguments

- object:

  Object of class `eslb`.

- parm:

  a specification of which parameters are to be given confidence
  intervals, either a vector of numbers or a vector of names. If
  missing, all parameters are considered.

- level:

  the confidence level required. The likelihood intervals are solved for
  the significance levels given in `alpha`, so `level` must equal
  `1 - alpha` for one of them.

- ...:

  additional arguments.

## Value

Returns a matrix of the lower and upper limits of the likelihood
intervals.

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
confint(object = out, level = 0.95)
#>         2.5 %    97.5 %
#> rsq 0.6041157 0.9101072
#> adj 0.5758383 0.9036862
```
