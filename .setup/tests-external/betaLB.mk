# Invoke inside the explicitly bound docs.sif image from the project root.
.PHONY: tests check
tests:
	Rscript -e 'devtools::test(pkg = getwd(), stop_on_failure = TRUE)'
check:
	Rscript -e 'rProject::Build(path = getwd(), vignettes = FALSE, dependencies = FALSE)'
