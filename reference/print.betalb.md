# Print Method for an Object of Class `betalb`

Print Method for an Object of Class `betalb`

## Usage

``` r
# S3 method for class 'betalb'
print(x, alpha = NULL, digits = 4, ...)
```

## Arguments

- x:

  Object of class `betalb`.

- alpha:

  Numeric vector. Significance level \\(\alpha\\). If `alpha = NULL`,
  use the argument `alpha` used in `x`.

- digits:

  Digits to print.

- ...:

  additional arguments.

## Value

Prints a matrix of standardized regression slopes, and the lower and
upper limits of the likelihood intervals. Endpoints that the solver
could not verify are reported below the matrix.

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
print(x = out)
#> Call:
#> BetaLB(object = object, alpha = 0.05)
#> 
#> Standardized regression slopes with MVN likelihood intervals:
#>            est   2.5%  97.5%
#> NARTIC  0.4951 0.3423 0.6394
#> PCTGRT  0.3915 0.2395 0.5426
#> PCTSUPP 0.2632 0.1179 0.4148
```
