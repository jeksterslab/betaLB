# Estimate Cohen's f-Squared and Local f-Squared and the Corresponding Likelihood-Based Confidence Intervals

Estimate Cohen's f-Squared and Local f-Squared and the Corresponding
Likelihood-Based Confidence Intervals

## Usage

``` r
FSqLB(object, alpha = c(0.05, 0.01, 0.001), blocks = NULL)
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

  Vector of Cohen's f-squared (`fsq`) and local f-squared.

- intervals:

  Data frame of the estimates and the limits of each significance level.

- diagnostics:

  Solver diagnostics of each endpoint.

- fun:

  Function used ("FSqLB").

## Details

Cohen's f-squared is \\(f^{2} = R^{2} / ( 1 - R^{2} )\\). The local
f-squared of regressor \\(j\\) is \\(sr^{2}\_{j} / ( 1 - R^{2} )\\). The
limits of \\(f^{2}\\) are the transformed limits of \\(R^{2}\\). With
`blocks`, the local f-squared is that of a set of regressors; the
intervals are conservative (vector projection). The `type` and `control`
stored in `object` are used.

## References

Selya, A. S., Rose, J. S., Dierker, L. C., Hedeker, D., & Mermelstein,
R. J. (2012). A practical guide to calculating Cohen's f2, a measure of
local effect size, from PROC MIXED. *Frontiers in Psychology*, *3*, 111.
[doi:10.3389/fpsyg.2012.00111](https://doi.org/10.3389/fpsyg.2012.00111)

## See also

Other Beta Likelihood-Based Functions:
[`BetaLB()`](https://jeksterslab.github.io/betaLB/reference/BetaLB.md),
[`DeltaRSqLB()`](https://jeksterslab.github.io/betaLB/reference/DeltaRSqLB.md),
[`DiffBetaLB()`](https://jeksterslab.github.io/betaLB/reference/DiffBetaLB.md),
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

# FSqLB --------------------------------------------------------------------
out <- FSqLB(object = std, alpha = 0.05)

## Methods -----------------------------------------------------------------
print(x = out)
#> Call:
#> FSqLB(object = std, alpha = 0.05)
#> 
#> Cohen's f-squared (fsq) and local f-squared with MVN likelihood intervals:
#>            est   2.5%   97.5%
#> fsq     4.1158 1.5260 10.1244
#> NARTIC  0.9510 0.3655  2.0420
#> PCTGRT  0.6019 0.1896  1.3981
#> PCTSUPP 0.2909 0.0516  0.8059
summary(object = out)
#> Call:
#> FSqLB(object = std, alpha = 0.05)
#> 
#> Cohen's f-squared (fsq) and local f-squared with MVN likelihood intervals:
#>            est   2.5%   97.5%
#> fsq     4.1158 1.5260 10.1244
#> NARTIC  0.9510 0.3655  2.0420
#> PCTGRT  0.6019 0.1896  1.3981
#> PCTSUPP 0.2909 0.0516  0.8059
coef(object = out)
#>       fsq    NARTIC    PCTGRT   PCTSUPP 
#> 4.1157764 0.9509843 0.6018924 0.2909455 
confint(object = out, level = 0.95)
#>              2.5 %     97.5 %
#> fsq     1.52599068 10.1243572
#> NARTIC  0.36547815  2.0419906
#> PCTGRT  0.18955186  1.3981149
#> PCTSUPP 0.05156425  0.8058796
```
