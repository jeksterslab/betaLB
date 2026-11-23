# Confidence Intervals Method for an Object of Class `betalb`

Confidence Intervals Method for an Object of Class `betalb`

## Usage

``` r
# S3 method for class 'betalb'
confint(object, parm = NULL, level = 0.95, ...)
```

## Arguments

- object:

  Object of class `betalb`.

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
out <- BetaLB(object = object, alpha = 0.05)

## Methods -----------------------------------------------------------------
confint(object = out, level = 0.95)
#>             2.5 %    97.5 %
#> NARTIC  0.3423306 0.6394250
#> PCTGRT  0.2395150 0.5426127
#> PCTSUPP 0.1178587 0.4148453
```
