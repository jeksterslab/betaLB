# Summary Method for an Object of Class `betalb`

Summary Method for an Object of Class `betalb`

## Usage

``` r
# S3 method for class 'betalb'
summary(object, alpha = NULL, digits = 4, type = NULL, ...)
```

## Arguments

- object:

  Object of class `betalb`.

- alpha:

  Numeric vector. Significance level \\(\alpha\\). If `alpha = NULL`,
  show all stored significance levels.

- digits:

  Digits to print.

- type:

  Stored calibration type; `NULL` selects all.

- ...:

  Additional arguments.

## Value

Returns a matrix or list of estimates and confidence intervals.

## Author

Ivan Jacob Agaloos Pesigan

## Examples

``` r
object <- structure(
  list(est = c(x = 0.5), args = list(type = "mvn", alpha = 0.05)),
  class = "betalb"
)
summary(object = object)
#> Call:
#> NULL
#> 
#> Likelihood intervals (vector projections are conservative)
#> type = "mvn"
#>   est
#> x 0.5
```
