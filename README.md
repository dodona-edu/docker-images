# docker-images
The docker images used by dodona

## dodona-python
* based on the python image
* includes pylint
* includes jsonschema
* shared by judge-pythia and judge-turtle: each judge's packages are in `dodona-python/<judge>.txt`, exercise packages in `exercises.txt`, and every pull request that changes the image runs both judges' suites against the candidate

## dodona-r
* based on the r-base image
* `dodona-r/DESCRIPTION` lists the R packages the image provides, `dodona-r/renv.lock` pins them and their dependencies, and the build restores exactly that lock with renv
* the lock takes every CRAN package from one dated [Posit Package Manager](https://packagemanager.posit.co) snapshot, the date in its repository URL
* judge-r and its test suite need base64enc, dplyr, ggplot2, jsonlite, knitr, processx, purrr, R6, rlang, testthat, tibble and withr; the other packages are for exercises
* R's recommended packages (MASS, Matrix, lattice, survival, ...) come from r-base: the lock holds them at r-base's versions
* coxed, polite, rtweet and vader are pinned (`==` in `DESCRIPTION`) at their last release because CRAN archived them; they and UserNetR (a GitHub commit in `Remotes`) keep their lock record when the lock is regenerated
* bindrcpp, covr, maps, spelling, vcr and webshot stay listed because coxed's and rtweet's old `dependencies = TRUE` installs pulled them in

To add, remove or bump packages, edit `dodona-r/DESCRIPTION` if needed, then regenerate the lock from a snapshot date (usually today's) without installing anything:

```sh
docker run --rm -v "$PWD/dodona-r:/requirements" -w /requirements \
  "$(docker build -q --target renv -f dodona-r.dockerfile .)" \
  Rscript update-lock.R 2026-10-13
```

A new date bumps every package to its version on that day. If CRAN archived a package since the last date, the script stops: pin it at the version the lock holds.
