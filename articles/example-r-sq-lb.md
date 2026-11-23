# betaLB: Example Using the RSqLB Function

In this example, a multiple regression model is fitted using program
quality ratings (`QUALITY`) as the regressand/outcome variable and
number of published articles attributed to the program faculty members
(`NARTIC`), percent of faculty members holding research grants
(`PCTGRT`), and percentage of program graduates who received support
(`PCTSUPP`) as regressor/predictor variables using a data set from 1982
ratings of 46 doctoral programs in psychology in the USA (National
Research Council, 1982).

\
[`library`](https://rdrr.io/r/base/library.html)`(``package ``=`` ``betaLB``)`

\
`df`` ``<-`` ``betaLB``::`[`nas1982`](https://jeksterslab.github.io/betaLB/reference/nas1982.md)

## Fit the regression model using the `lm()` function.

\
`object`` ``<-`` ``stats``::`[`lm`](https://rdrr.io/r/stats/lm.html)`(``formula ``=`` ``QUALITY`` ``~`` ``NARTIC`` ``+`` ``PCTGRT`` ``+`` ``PCTSUPP``, data ``=`` ``df``)`

## Estimate the standardized regression slopes.

\
`std`` ``<-`` `[`BetaLB`](https://jeksterslab.github.io/betaLB/reference/BetaLB.md)`(``object ``=`` ``object``, type ``=`` ``"robust"``, alpha ``=`` ``0.05``)`

## R-squared and adjusted R-squared

The interval of R-squared is a profile likelihood interval for a
nonnegative quantity that depends on all the standardized slopes (vector
projection, conservative). The limits of adjusted R-squared are the
transformed limits of R-squared, and the lower limit can be negative.

\
`rsq`` ``<-`` `[`RSqLB`](https://jeksterslab.github.io/betaLB/reference/RSqLB.md)`(``object ``=`` ``std``, alpha ``=`` ``0.05``)`\
[`summary`](https://rdrr.io/r/base/summary.html)`(``object ``=`` ``rsq``)`\
`#> Call:`\
`#> RSqLB(object = std, alpha = 0.05)`\
`#> `\
`#> R-squared and adjusted R-squared with ROBUST likelihood intervals:`\
`#>        est   2.5%  97.5%`\
`#> rsq 0.8045 0.5761 0.9174`\
`#> adj 0.7906 0.5459 0.9115`\
[`coef`](https://rdrr.io/r/stats/coef.html)`(``object ``=`` ``rsq``)`\
`#>       rsq       adj `\
`#> 0.8045263 0.7905638`\
[`confint`](https://rdrr.io/r/stats/confint.html)`(``object ``=`` ``rsq``, level ``=`` ``0.95``)`\
`#>         2.5 %    97.5 %`\
`#> rsq 0.5761482 0.9174272`\
`#> adj 0.5458731 0.9115292`

## References

Dudgeon, P. (2017). Some improvements in confidence intervals for
standardized regression coefficients. *Psychometrika*, *82*(4), 928–951.
<https://doi.org/10.1007/s11336-017-9563-z>

National Research Council. (1982). *An assessment of research-doctorate
programs in the United States: Social and behavioral sciences*. National
Academies Press. <https://doi.org/10.17226/9781>
