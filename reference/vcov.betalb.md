# Sampling Variance-Covariance Matrix Method for an Object of Class `betalb`

Sampling Variance-Covariance Matrix Method for an Object of Class
`betalb`

## Usage

``` r
# S3 method for class 'betalb'
vcov(object, ...)
```

## Arguments

- object:

  Object of class `betalb`.

- ...:

  Additional arguments.

## Value

Stops with an error because profile likelihood intervals do not define a
covariance matrix.

## Author

Ivan Jacob Agaloos Pesigan

## Examples

``` r
object <- structure(
  list(est = c(x = 0.5), args = list(type = "mvn", alpha = 0.05)),
  class = "betalb"
)
try(stats::vcov(object = object))
#> Error in vcov.betalb(object = object) : 
#>   A covariance matrix is not defined for likelihood-based intervals.
```
