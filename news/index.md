# Changelog

## betaLB 0.0.0.9001

### Added

- Added [`LB()`](https://jeksterslab.github.io/betaLB/reference/LB.md)
  with batched likelihood intervals and seven effect extractors.
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
