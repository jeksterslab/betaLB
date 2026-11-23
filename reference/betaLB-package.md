# betaLB: Likelihood-Based Confidence Intervals for Regression Effect Sizes

Generates profile likelihood confidence intervals for standardized
regression coefficients and other effect sizes for models fitted by
[`stats::lm()`](https://rdrr.io/r/stats/lm.html) with independently
sampled random regressors. The functions and arguments follow the
`betaSandwich` package.

## Standardized regression coefficients

[`BetaLB()`](https://jeksterslab.github.io/betaLB/reference/BetaLB.md)
estimates the standardized regression coefficients and their likelihood
intervals. The argument `type` is `"mvn"` (multivariate normal theory)
or `"robust"` (empirical fourth moments).

## Functions of the standardized coefficients

[`RSqLB()`](https://jeksterslab.github.io/betaLB/reference/RSqLB.md)
(R-squared and adjusted R-squared),
[`DiffBetaLB()`](https://jeksterslab.github.io/betaLB/reference/DiffBetaLB.md)
(differences of standardized slopes),
[`SCorLB()`](https://jeksterslab.github.io/betaLB/reference/SCorLB.md)
and
[`SCorSqLB()`](https://jeksterslab.github.io/betaLB/reference/SCorSqLB.md)
(semipartial correlations),
[`PCorLB()`](https://jeksterslab.github.io/betaLB/reference/PCorLB.md)
(squared partial correlations),
[`DeltaRSqLB()`](https://jeksterslab.github.io/betaLB/reference/DeltaRSqLB.md)
(improvement in R-squared), and
[`FSqLB()`](https://jeksterslab.github.io/betaLB/reference/FSqLB.md)
(Cohen's f-squared and local f-squared). These functions take the output
of
[`BetaLB()`](https://jeksterslab.github.io/betaLB/reference/BetaLB.md).

## Methods

The [`coef()`](https://rdrr.io/r/stats/coef.html),
[`confint()`](https://rdrr.io/r/stats/confint.html),
[`summary()`](https://rdrr.io/r/base/summary.html), and
[`print()`](https://rdrr.io/r/base/print.html) methods are available for
objects of class `betalb` and `eslb`. A covariance matrix is not defined
for likelihood intervals, so
[`vcov()`](https://rdrr.io/r/stats/vcov.html) stops with a message.

## References

Dudgeon, P. (2017). Some improvements in confidence intervals for
standardized regression coefficients. *Psychometrika*, *82*(4), 928–951.
[doi:10.1007/s11336-017-9563-z](https://doi.org/10.1007/s11336-017-9563-z)

## See also

Useful links:

- <https://github.com/jeksterslab/betaLB>

- <https://jeksterslab.github.io/betaLB/>

- Report bugs at <https://github.com/jeksterslab/betaLB/issues>

## Author

**Maintainer**: Ivan Jacob Agaloos Pesigan <r.jeksterslab@gmail.com>
([ORCID](https://orcid.org/0000-0003-4818-8420)) \[copyright holder\]

Authors:

- Ivan Jacob Agaloos Pesigan <r.jeksterslab@gmail.com>
  ([ORCID](https://orcid.org/0000-0003-4818-8420)) \[copyright holder\]
