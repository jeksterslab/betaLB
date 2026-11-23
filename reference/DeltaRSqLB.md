# Estimate Improvement in R-Squared and the Corresponding Likelihood-Based Confidence Intervals

Estimate Improvement in R-Squared and the Corresponding Likelihood-Based
Confidence Intervals

## Usage

``` r
DeltaRSqLB(object, alpha = c(0.05, 0.01, 0.001), blocks = NULL)
```

## Arguments

- object:

  Object of class `betalb`. The output of
  [`BetaLB()`](https://jeksterslab.github.io/betaLB/reference/BetaLB.md).

- alpha:

  Numeric vector. Significance level \\(\alpha\\).

- blocks:

  `NULL` or a named list of additional predictor blocks, given by
  regressor names or column indices. Each block adds an element named
  `block:<name>` to the output. The default `NULL` gives one element per
  regressor.

## Value

Returns an object of class `eslb` which is a list with the following
elements:

- call:

  Function call.

- fit:

  The argument `object`.

- args:

  Function arguments.

- lm_process:

  Sample size, number of regressors, and regressor names.

- est:

  Vector of improvements in R-squared.

- intervals:

  Data frame of the estimates and the limits of each significance level.

- diagnostics:

  Solver diagnostics of each endpoint.

- fun:

  Function used ("DeltaRSqLB").

## Details

The improvement in R-squared of regressor \\(j\\) is \\(sr^{2}\_{j}\\),
the change in \\(R^{2}\\) when regressor \\(j\\) is added last. The
intervals are profile likelihood intervals of a nonnegative quantity.
With `blocks`, the improvement is that of a set of regressors; the
intervals are conservative (vector projection). The `type` and `control`
stored in `object` are used.

## References

Algina, J., Keselman, H. J., & Penfield, R. D. (2007). Confidence
intervals for an effect size measure in multiple linear regression.
*Educational and Psychological Measurement*, *67*(2), 207–218.
[doi:10.1177/0013164406292030](https://doi.org/10.1177/0013164406292030)

Algina, J., Keselman, H. J., & Penfield, R. D. (2008a). Confidence
intervals for the squared multiple semipartial correlation coefficient.
*Journal of Modern Applied Statistical Methods*, *7*(1), 2–10.
[doi:10.22237/jmasm/1209614460](https://doi.org/10.22237/jmasm/1209614460)

Algina, J., Keselman, H. J., & Penfield, R. D. (2008b). Note on a
confidence interval for the squared semipartial correlation coefficient.
*Educational and Psychological Measurement*, *68*(5), 734–741.
[doi:10.1177/0013164407313371](https://doi.org/10.1177/0013164407313371)

Algina, J., Keselman, H. J., & Penfield, R. D. (2010). Confidence
intervals for squared semipartial correlation coefficients: The effect
of nonnormality. *Educational and Psychological Measurement*, *70*(6),
926–940.
[doi:10.1177/0013164410379335](https://doi.org/10.1177/0013164410379335)

## See also

Other Beta Likelihood-Based Functions:
[`BetaLB()`](https://jeksterslab.github.io/betaLB/reference/BetaLB.md),
[`DiffBetaLB()`](https://jeksterslab.github.io/betaLB/reference/DiffBetaLB.md),
[`FSqLB()`](https://jeksterslab.github.io/betaLB/reference/FSqLB.md),
[`PCorLB()`](https://jeksterslab.github.io/betaLB/reference/PCorLB.md),
[`RSqLB()`](https://jeksterslab.github.io/betaLB/reference/RSqLB.md),
[`SCorLB()`](https://jeksterslab.github.io/betaLB/reference/SCorLB.md),
[`SCorSqLB()`](https://jeksterslab.github.io/betaLB/reference/SCorSqLB.md)

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

# DeltaRSqLB ---------------------------------------------------------------
out <- DeltaRSqLB(object = std, alpha = 0.05)

## Methods -----------------------------------------------------------------
print(x = out)
#> Call:
#> DeltaRSqLB(object = std, alpha = 0.05)
#> 
#> Improvement in R-squared with MVN likelihood intervals:
#>            est   2.5%  97.5%
#> NARTIC  0.1859 0.0831 0.3489
#> PCTGRT  0.1177 0.0422 0.2494
#> PCTSUPP 0.0569 0.0112 0.1505
summary(object = out)
#> Call:
#> DeltaRSqLB(object = std, alpha = 0.05)
#> 
#> Improvement in R-squared with MVN likelihood intervals:
#>            est   2.5%  97.5%
#> NARTIC  0.1859 0.0831 0.3489
#> PCTGRT  0.1177 0.0422 0.2494
#> PCTSUPP 0.0569 0.0112 0.1505
coef(object = out)
#>    NARTIC    PCTGRT   PCTSUPP 
#> 0.1858925 0.1176542 0.0568722 
confint(object = out, level = 0.95)
#>              2.5 %    97.5 %
#> NARTIC  0.08306159 0.3488900
#> PCTGRT  0.04223605 0.2494239
#> PCTSUPP 0.01124041 0.1505438
```
