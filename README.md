# docker-images
The docker images used by dodona

## dodona-python
* based on the python image
* includes pylint
* includes jsonschema

## dodona-r
* based on the r-base image
* `dodona-r/DESCRIPTION` lists the R packages the image provides, `dodona-r/renv.lock` pins them and their dependencies, and the build restores exactly that lock with renv
* judge-r and its test suite need base64enc, dplyr, ggplot2, jsonlite, knitr, processx, purrr, R6, rlang, testthat, tibble and withr; the other packages are for exercises
* R's recommended packages (MASS, Matrix, lattice, survival, ...) come from r-base, not from the lock
* coxed, polite, rtweet and vader are pinned at their last release because CRAN archived them
* bindrcpp, covr, maps, spelling, vcr and webshot stay listed because coxed's and rtweet's old `dependencies = TRUE` installs pulled them in

To add a package, add it to `Imports` in `dodona-r/DESCRIPTION`, then install it in the current image and regenerate the lock from there, so only the new package and its missing dependencies compile:

```sh
docker run --rm --platform linux/amd64 --user root \
  --env RENV_LOCKFILE_VERSION=1 \
  -v "$PWD/dodona-r:/requirements" -w /requirements \
  ghcr.io/dodona-edu/dodona-r:latest \
  Rscript -e 'renv::install("<package>", prompt = FALSE)' \
          -e 'renv::snapshot(library = .libPaths(), type = "explicit", prompt = FALSE)'
```

To bump a package, run the same command with `renv::install("<package>@<version>")`; that only changes `renv.lock`.
