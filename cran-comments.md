## Release summary

This is a new submission.

- `BetaLB()` gives standardized regression coefficients with profile
  likelihood intervals (`type = "mvn"` or `"robust"`).
- `RSqLB()`, `SCorLB()`, `SCorSqLB()`, `PCorLB()`, `DeltaRSqLB()`,
  `FSqLB()`, and `DiffBetaLB()` take its output, as in betaSandwich.

## Test environments

- Linux (x86_64-pc-linux-gnu, Ubuntu 26.04.1 LTS, Apptainer image), R 4.6.2:
  `R CMD check`, Status: OK (2026-11-20).
- win-builder (R-devel): TODO (the maintainer runs this before submission).
- R-hub: TODO (the maintainer runs this before submission).

## R CMD check results

0 errors | 0 warnings | 0 notes (Linux, above). win-builder and R-hub: TODO.

## Reverse dependencies

None (new package).
