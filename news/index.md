# Changelog

## betaLB 0.1.0

### Major

- The design follows betaSandwich. `LB()` and the `lb` context are
  removed.
  [`BetaLB()`](https://jeksterslab.github.io/betaLB/reference/BetaLB.md)
  takes an `lm` object and returns the standardized slopes and their
  likelihood intervals (class `betalb`).
  [`RSqLB()`](https://jeksterslab.github.io/betaLB/reference/RSqLB.md),
  [`SCorLB()`](https://jeksterslab.github.io/betaLB/reference/SCorLB.md),
  [`SCorSqLB()`](https://jeksterslab.github.io/betaLB/reference/SCorSqLB.md),
  [`PCorLB()`](https://jeksterslab.github.io/betaLB/reference/PCorLB.md),
  [`DeltaRSqLB()`](https://jeksterslab.github.io/betaLB/reference/DeltaRSqLB.md),
  [`FSqLB()`](https://jeksterslab.github.io/betaLB/reference/FSqLB.md),
  and
  [`DiffBetaLB()`](https://jeksterslab.github.io/betaLB/reference/DiffBetaLB.md)
  take that object and return class `eslb`, with the arguments `object`
  and `alpha = c(0.05, 0.01, 0.001)`.
- `type` is one value (`"mvn"` or `"robust"`) of
  [`BetaLB()`](https://jeksterslab.github.io/betaLB/reference/BetaLB.md)
  and is inherited by the effect size functions; `std_x` takes `NULL`
  (all), names, or `character(0)` (none), as in betaSandwich; `effects`
  is removed; `blocks` moves to
  [`DeltaRSqLB()`](https://jeksterslab.github.io/betaLB/reference/DeltaRSqLB.md)
  and
  [`FSqLB()`](https://jeksterslab.github.io/betaLB/reference/FSqLB.md);
  `control` stays on
  [`BetaLB()`](https://jeksterslab.github.io/betaLB/reference/BetaLB.md).
- [`coef()`](https://rdrr.io/r/stats/coef.html),
  [`confint()`](https://rdrr.io/r/stats/confint.html),
  [`summary()`](https://rdrr.io/r/base/summary.html),
  [`print()`](https://rdrr.io/r/base/print.html), and
  [`vcov()`](https://rdrr.io/r/stats/vcov.html) methods for both
  classes. [`confint()`](https://rdrr.io/r/stats/confint.html) accepts
  the levels that were computed;
  [`vcov()`](https://rdrr.io/r/stats/vcov.html) stops with a message (no
  covariance matrix is defined).

### Minor

- Examples use the `nas1982` data, named arguments, and `pkg::fn()`
  calls, as in the other beta packages;
  [`DeltaRSqLB()`](https://jeksterslab.github.io/betaLB/reference/DeltaRSqLB.md)
  and
  [`FSqLB()`](https://jeksterslab.github.io/betaLB/reference/FSqLB.md)
  give references.
- The internal copies from linearAlgebra 0.0.5 (a faster duplication
  matrix and its exact inverse), nBootstrap 0.1.0 (quantiles in C++),
  strRegression 0.0.2, and processLM 0.0.11 are current.

## betaLB 0.0.0.9002

- Add SCorSqLB() for the image of a signed-semipartial interval under
  squaring.

## betaLB 0.0.0.9001

### Added

- Added `LB()` with batched likelihood intervals and seven effect
  extractors.
- Added normal-theory and target-specific robust scalar calibration.
- Added conservative vector-projection intervals for multi-coefficient
  nonnegative effects, with explicit calibration dimensions and
  diagnostics.
- Added signed-square interval images and independent zero-null checks.
- Added an independent test-only R reference and a native optimizer with
  analytic gradients, deterministic starts and endpoint verification.
- Added confidence-level/type selection and explicit failed-endpoint
  statuses.
- Retained adjusted R-squared as a labelled finite-sample
  transformation.

## betaLB 0.0.0.9000

### Major

- Initial scaffold of `betaLB` converted from rProject template.
- Removed Monte Carlo simulation routines from `betaMC`.
- Kept regression input checks and effect-size method infrastructure.
