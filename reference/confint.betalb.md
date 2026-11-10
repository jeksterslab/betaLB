# Confidence Intervals Method for an Object of Class `betalb`

Confidence Intervals Method for an Object of Class `betalb`

## Usage

``` r
# S3 method for class 'betalb'
confint(object, parm = NULL, level = 0.95, type = NULL, ...)
```

## Arguments

- object:

  Object of class `betalb`.

- parm:

  A specification of which parameters are to be given confidence
  intervals.

- level:

  Confidence level of stored intervals. Only already-computed levels are
  available.

- type:

  Stored calibration type; `NULL` selects the first type.

- ...:

  Additional arguments.

## Value

Returns a matrix of confidence intervals.

## Author

Ivan Jacob Agaloos Pesigan

## Examples

``` r
object <- structure(
  list(est = c(x = 0.5), args = list(type = "mvn", alpha = 0.05)),
  class = "betalb"
)
try(stats::confint(object = object))
#> Error in confint.betalb(object = object) : 
#>   Confidence intervals are not available.
```
