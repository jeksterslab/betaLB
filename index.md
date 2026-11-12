# betaLB

Ivan Jacob Agaloos Pesigan 2026-11-12

## Description

Generates profile likelihood confidence intervals for standardized
regression coefficients (beta) and other effect sizes, including
multiple correlation, semipartial correlations, improvement in
R-squared, squared partial correlations, differences in standardized
regression coefficients, and Cohen’s f-squared, for models fitted by
[`lm()`](https://rdrr.io/r/stats/lm.html).

## Installation

You can install the development version of `betaLB` from
[GitHub](https://github.com/jeksterslab/betaLB) with:

\
`if`` ``(``!`[`requireNamespace`](https://rdrr.io/r/base/ns-load.html)`(``package ``=`` ``"pak"``, quietly ``=`` ``TRUE``)``)`` ``{`\
`  ``utils``::`[`install.packages`](https://rdrr.io/r/utils/install.packages.html)`(``pkgs ``=`` ``"pak"``)`\
`}`\
`pak``::`[`pkg_install`](https://pak.r-lib.org/reference/pkg_install.html)`(``pkg ``=`` ``"jeksterslab/betaLB"``)`

## Likelihood intervals

Fit once for the effect families, calibration types and confidence
levels needed. Extractors select stored results without refitting.

\
`fit`` ``<-`` ``stats``::`[`lm`](https://rdrr.io/r/stats/lm.html)`(``formula ``=`` ``mpg`` ``~`` ``wt`` ``+`` ``hp``, data ``=`` ``mtcars``)`\
`out`` ``<-`` ``betaLB``::`[`LB`](https://jeksterslab.github.io/betaLB/reference/LB.md)`(`\
`  object ``=`` ``fit``,`\
`  effects ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"beta"``, ``"rsq"``)``,`\
`  type ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"mvn"``, ``"robust"``)``,`\
`  alpha ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``0.05``, ``0.10``)`\
`)`\
`betaLB``::`[`BetaLB`](https://jeksterslab.github.io/betaLB/reference/BetaLB.md)`(``object ``=`` ``out``)`\
`#> Call:`\
`#> betaLB::LB(object = fit, type = c("mvn", "robust"), alpha = c(0.05, `\
`#>     0.1), effects = c("beta", "rsq"))`\
`#> `\
`#> Likelihood intervals (vector projections are conservative)`\
`#> type = "mvn, robust"`\
`#>   effect   type alpha estimate   lower   upper lower_status upper_status`\
`#> 1     wt    mvn  0.05  -0.6296 -0.7934 -0.4347           ok           ok`\
`#> 2     wt    mvn  0.10  -0.6296 -0.7691 -0.4683           ok           ok`\
`#> 3     wt robust  0.05  -0.6296 -0.7579 -0.4831           ok           ok`\
`#> 4     wt robust  0.10  -0.6296 -0.7385 -0.5079           ok           ok`\
`#> 5     hp    mvn  0.05  -0.3615 -0.5538 -0.1628           ok           ok`\
`#> 6     hp    mvn  0.10  -0.3615 -0.5231 -0.1959           ok           ok`\
`#> 7     hp robust  0.05  -0.3615 -0.4911 -0.2297           ok           ok`\
`#> 8     hp robust  0.10  -0.3615 -0.4703 -0.2512           ok           ok`\
`#>      calibration dimension`\
`#> 1 scalar_profile         1`\
`#> 2 scalar_profile         1`\
`#> 3 scalar_profile         1`\
`#> 4 scalar_profile         1`\
`#> 5 scalar_profile         1`\
`#> 6 scalar_profile         1`\
`#> 7 scalar_profile         1`\
`#> 8 scalar_profile         1`\
`stats``::`[`confint`](https://rdrr.io/r/stats/confint.html)`(``object ``=`` ``betaLB``::`[`RSqLB`](https://jeksterslab.github.io/betaLB/reference/RSqLB.md)`(``object ``=`` ``out``)``, type ``=`` ``"robust"``)`\
`#>         lower     upper`\
`#> rsq 0.6661115 0.9146316`\
`#> adj 0.6430847 0.9087442`

Scalar targets use profile-likelihood regions. Multi-coefficient
R-squared and block effects use conservative vector projection; the
output identifies this calibration and its dimension. Robust calibration
assumes independently sampled random regressors and finite fourth
moments. It does not supply fixed-regressor or clustered-data inference.

`out$intervals` contains every computed band and its endpoint statuses.
`out$diagnostics` retains numerical verification details. An unverified
endpoint is `NA`; no Wald endpoint is substituted. Adjusted R-squared is
an explicitly sample-size-dependent transformation, and its interval can
have a negative lower bound.
