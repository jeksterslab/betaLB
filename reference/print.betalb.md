# Print Method for an Object of Class `betalb`

Print Method for an Object of Class `betalb`

## Usage

``` r
# S3 method for class 'betalb'
print(x, alpha = NULL, digits = 4, type = NULL, ...)
```

## Arguments

- x:

  Object of class `betalb`.

- alpha:

  Numeric vector. Significance level \\(\alpha\\). If `alpha = NULL`,
  show all stored significance levels.

- digits:

  Digits to print.

- type:

  Stored calibration type; `NULL` selects all for printing.

- ...:

  Additional arguments.

## Value

Prints a matrix of estimates and confidence intervals.

## Author

Ivan Jacob Agaloos Pesigan

## Examples

``` r
object <- structure(
  list(est = c(x = 0.5), args = list(type = "mvn", alpha = 0.05)),
  class = "betalb"
)
print(x = object)
#> Call:
#> NULL
#> 
#> Likelihood intervals (vector projections are conservative)
#> type = "mvn"
#>   est
#> x 0.5
```
