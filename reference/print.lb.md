# Methods for a Batched Likelihood Context

Display or select already-computed results without running the solver.

## Usage

``` r
# S3 method for class 'lb'
print(x, alpha = NULL, digits = 4, type = NULL, ...)

# S3 method for class 'lb'
summary(object, alpha = NULL, digits = 4, type = NULL, ...)

# S3 method for class 'lb'
coef(object, ...)

# S3 method for class 'lb'
confint(object, parm = NULL, level = 0.95, type = NULL, ...)

# S3 method for class 'lb'
vcov(object, ...)
```

## Arguments

- x:

  Object of class `lb`.

- alpha:

  Stored significance levels; NULL selects all.

- digits:

  Digits displayed by print methods.

- type:

  Stored calibration type; `NULL` selects the first type.

- ...:

  Arguments forwarded to the corresponding effect method.

- object:

  Object of class `lb`.

- parm:

  Parameter names or positive row indices; `NULL` selects all.

- level:

  Confidence level already computed by
  [`LB()`](https://jeksterslab.github.io/betaLB/reference/LB.md).

## Value

Print methods invisibly return their input; summary returns stored
interval rows; coef returns point estimates; confint returns a
two-column matrix. vcov stops because likelihood intervals do not define
a covariance.

## Author

Ivan Jacob Agaloos Pesigan

## Examples

``` r
fit <- stats::lm(formula = mpg ~ wt, data = mtcars)
out <- LB(object = fit, effects = "rsq", type = "mvn", alpha = 0.05)
stats::coef(object = out)
#>   rsq:rsq   rsq:adj 
#> 0.7528328 0.7445939 
stats::confint(object = out)
#>             lower     upper
#> rsq:rsq 0.5629093 0.8686440
#> rsq:adj 0.5483396 0.8642655
```
