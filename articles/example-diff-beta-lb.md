# betaLB: Example Using the DiffBetaLB Function

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

[`DiffBetaLB()`](https://jeksterslab.github.io/betaLB/reference/DiffBetaLB.md)
needs fully standardized slopes (`std_y = TRUE` and `std_x = NULL`).

\
`std`` ``<-`` `[`BetaLB`](https://jeksterslab.github.io/betaLB/reference/BetaLB.md)`(``object ``=`` ``object``, type ``=`` ``"robust"``, alpha ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``0.05``, ``0.01``)``)`

## Differences of standardized slopes

The likelihood intervals of the differences \beta^{\ast}\_{i} -
\beta^{\ast}\_{j} are solved for every pair of regressors.

\
`diff`` ``<-`` `[`DiffBetaLB`](https://jeksterslab.github.io/betaLB/reference/DiffBetaLB.md)`(``object ``=`` ``std``, alpha ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``0.05``, ``0.01``)``)`\
[`summary`](https://rdrr.io/r/base/summary.html)`(``object ``=`` ``diff``, alpha ``=`` ``0.05``)`\
`#> Call:`\
`#> DiffBetaLB(object = std, alpha = c(0.05, 0.01))`\
`#> `\
`#> Differences of standardized regression slopes with ROBUST likelihood intervals:`\
`#>                     est    2.5%  97.5%`\
`#> NARTIC - PCTGRT  0.1037 -0.1345 0.3358`\
`#> NARTIC - PCTSUPP 0.2319 -0.0040 0.4557`\
`#> PCTGRT - PCTSUPP 0.1282 -0.1118 0.3623`\
[`coef`](https://rdrr.io/r/stats/coef.html)`(``object ``=`` ``diff``)`\
`#>  NARTIC - PCTGRT NARTIC - PCTSUPP PCTGRT - PCTSUPP `\
`#>        0.1036564        0.2318974        0.1282410`\
[`confint`](https://rdrr.io/r/stats/confint.html)`(``object ``=`` ``diff``, level ``=`` ``0.99``)`\
`#>                        0.5 %    99.5 %`\
`#> NARTIC - PCTGRT  -0.21026750 0.4074141`\
`#> NARTIC - PCTSUPP -0.08126166 0.5244509`\
`#> PCTGRT - PCTSUPP -0.18999595 0.4361053`

## References

Dudgeon, P. (2017). Some improvements in confidence intervals for
standardized regression coefficients. *Psychometrika*, *82*(4), 928–951.
<https://doi.org/10.1007/s11336-017-9563-z>

National Research Council. (1982). *An assessment of research-doctorate
programs in the United States: Social and behavioral sciences*. National
Academies Press. <https://doi.org/10.17226/9781>
