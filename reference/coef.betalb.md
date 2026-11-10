# Estimated Parameter Method for an Object of Class `betalb`

Estimated Parameter Method for an Object of Class `betalb`

## Usage

``` r
# S3 method for class 'betalb'
coef(object, ...)
```

## Arguments

- object:

  Object of class `betalb`.

- ...:

  Additional arguments.

## Value

Returns a vector of estimated parameters.

## Author

Ivan Jacob Agaloos Pesigan

## Examples

``` r
object <- structure(
  list(est = c(x = 0.5), args = list(type = "mvn", alpha = 0.05)),
  class = "betalb"
)
stats::coef(object = object)
#>   x 
#> 0.5 
```
