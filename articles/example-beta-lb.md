# betaLB: Example Using the BetaLB Function

In this example, a multiple regression model is fitted using program
quality ratings (`QUALITY`) as the regressand/outcome variable and
number of published articles attributed to the program faculty members
(`NARTIC`), percent of faculty members holding research grants
(`PCTGRT`), and percentage of program graduates who received support
(`PCTSUPP`) as regressor/predictor variables using a data set from 1982
ratings of 46 doctoral programs in psychology in the USA (National
Research Council, 1982). Profile likelihood confidence intervals for the
standardized regression coefficients are generated using the
[`BetaLB()`](https://jeksterslab.github.io/betaLB/reference/BetaLB.md)
function from the `betaLB` package.

\
[`library`](https://rdrr.io/r/base/library.html)`(``package ``=`` ``betaLB``)`

\
`df`` ``<-`` ``betaLB``::`[`nas1982`](https://jeksterslab.github.io/betaLB/reference/nas1982.md)

## Fit the regression model using the `lm()` function.

\
`object`` ``<-`` ``stats``::`[`lm`](https://rdrr.io/r/stats/lm.html)`(``formula ``=`` ``QUALITY`` ``~`` ``NARTIC`` ``+`` ``PCTGRT`` ``+`` ``PCTSUPP``, data ``=`` ``df``)`

## Estimate the standardized regression slopes and the likelihood intervals.

With `type = "mvn"`, the cutoff assumes multivariate normality. With
`type = "robust"`, the cutoff is scaled by the sample fourth moments and
the intervals do not require normality. The solver runs once per
significance level in `alpha`.

\
`std_mvn`` ``<-`` `[`BetaLB`](https://jeksterslab.github.io/betaLB/reference/BetaLB.md)`(``object ``=`` ``object``, type ``=`` ``"mvn"``, alpha ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``0.05``, ``0.01``)``)`\
`std_robust`` ``<-`` `[`BetaLB`](https://jeksterslab.github.io/betaLB/reference/BetaLB.md)`(``object ``=`` ``object``, type ``=`` ``"robust"``, alpha ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``0.05``, ``0.01``)``)`\
`std_robust`\
`#> Call:`\
`#> BetaLB(object = object, type = "robust", alpha = c(0.05, 0.01))`\
`#> `\
`#> Standardized regression slopes with ROBUST likelihood intervals:`\
`#>            est   0.5%   2.5%  97.5%  99.5%`\
`#> NARTIC  0.4951 0.3173 0.3611 0.6228 0.6611`\
`#> PCTGRT  0.3915 0.2083 0.2530 0.5294 0.5726`\
`#> PCTSUPP 0.2632 0.0670 0.1154 0.4175 0.4684`

## Methods

The [`print()`](https://rdrr.io/r/base/print.html),
[`summary()`](https://rdrr.io/r/base/summary.html),
[`coef()`](https://rdrr.io/r/stats/coef.html), and
[`confint()`](https://rdrr.io/r/stats/confint.html) methods are
available. The [`confint()`](https://rdrr.io/r/stats/confint.html)
method accepts only the levels (`1 - alpha`) that were computed. A
covariance matrix is not defined for likelihood-based intervals, so
[`vcov()`](https://rdrr.io/r/stats/vcov.html) stops with a message.

\
[`summary`](https://rdrr.io/r/base/summary.html)`(``object ``=`` ``std_robust``, alpha ``=`` ``0.05``)`\
`#> Call:`\
`#> BetaLB(object = object, type = "robust", alpha = c(0.05, 0.01))`\
`#> `\
`#> Standardized regression slopes with ROBUST likelihood intervals:`\
`#>            est   2.5%  97.5%`\
`#> NARTIC  0.4951 0.3611 0.6228`\
`#> PCTGRT  0.3915 0.2530 0.5294`\
`#> PCTSUPP 0.2632 0.1154 0.4175`\
[`coef`](https://rdrr.io/r/stats/coef.html)`(``object ``=`` ``std_robust``)`\
`#>    NARTIC    PCTGRT   PCTSUPP `\
`#> 0.4951451 0.3914887 0.2632477`\
[`confint`](https://rdrr.io/r/stats/confint.html)`(``object ``=`` ``std_robust``, level ``=`` ``0.95``)`\
`#>             2.5 %    97.5 %`\
`#> NARTIC  0.3610731 0.6227540`\
`#> PCTGRT  0.2530089 0.5294304`\
`#> PCTSUPP 0.1153935 0.4174637`

## Selective standardization

Use `std_y` and `std_x` to standardize only the outcome or only some of
the regressors. `std_x = NULL` standardizes all regressors and
`std_x = character(0)` standardizes none.

\
[`BetaLB`](https://jeksterslab.github.io/betaLB/reference/BetaLB.md)`(`\
`  object ``=`` ``object``,`\
`  type ``=`` ``"mvn"``,`\
`  alpha ``=`` ``0.05``,`\
`  std_y ``=`` ``TRUE``,`\
`  std_x ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"NARTIC"``, ``"PCTGRT"``)`\
`)`\
`#> Call:`\
`#> BetaLB(object = object, type = "mvn", alpha = 0.05, std_y = TRUE, `\
`#>     std_x = c("NARTIC", "PCTGRT"))`\
`#> `\
`#> Standardized regression slopes with MVN likelihood intervals:`\
`#>            est   2.5%  97.5%`\
`#> NARTIC  0.4951 0.3423 0.6394`\
`#> PCTGRT  0.3915 0.2395 0.5426`\
`#> PCTSUPP 0.0113 0.0051 0.0176`

## Comparing calibrations

\
[`confint`](https://rdrr.io/r/stats/confint.html)`(``object ``=`` ``std_mvn``, level ``=`` ``0.95``)`\
`#>             2.5 %    97.5 %`\
`#> NARTIC  0.3423306 0.6394250`\
`#> PCTGRT  0.2395150 0.5426127`\
`#> PCTSUPP 0.1178587 0.4148453`\
[`confint`](https://rdrr.io/r/stats/confint.html)`(``object ``=`` ``std_robust``, level ``=`` ``0.95``)`\
`#>             2.5 %    97.5 %`\
`#> NARTIC  0.3610731 0.6227540`\
`#> PCTGRT  0.2530089 0.5294304`\
`#> PCTSUPP 0.1153935 0.4174637`

## References

Dudgeon, P. (2017). Some improvements in confidence intervals for
standardized regression coefficients. *Psychometrika*, *82*(4), 928–951.
<https://doi.org/10.1007/s11336-017-9563-z>

National Research Council. (1982). *An assessment of research-doctorate
programs in the United States: Social and behavioral sciences*. National
Academies Press. <https://doi.org/10.17226/9781>
