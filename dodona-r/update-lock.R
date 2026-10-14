# Regenerates renv.lock from the Package Manager CRAN snapshot of the given date; run it as the README says.

date <- commandArgs(trailingOnly = TRUE)[1]
if (is.na(date) || !grepl("^[0-9]{4}-[0-9]{2}-[0-9]{2}$", date))
  stop("usage: Rscript update-lock.R YYYY-MM-DD")
url <- paste0("https://packagemanager.posit.co/cran/", date)

package_names <- function(fields) {
  entries <- unlist(strsplit(fields[!is.na(fields)], ","))
  names <- sub("\\(.*", "", gsub("[[:space:]]", "", entries))
  sort(unique(names[nzchar(names)]), method = "radix")
}

lock_record <- function(fields) {
  requirements <- package_names(fields[c("Depends", "Imports", "LinkingTo")])
  record <- list(
    Package = unname(fields["Package"]),
    Version = unname(fields["Version"]),
    Source = "Repository",
    Repository = "CRAN"
  )
  if (length(requirements)) record$Requirements <- requirements
  record
}

lock <- renv::lockfile_read("renv.lock")
description <- read.dcf("DESCRIPTION")
imports <- trimws(strsplit(description[, "Imports"], ",")[[1]])
remotes <- trimws(strsplit(description[, "Remotes"], ",")[[1]])

# Packages pinned with `==` (archived on CRAN) or installed from a remote keep their current lock record.
pins <- grep("==", imports, value = TRUE)
pinned <- c(sub("[[:space:]]*\\(.*", "", pins), sub("@.*", "", basename(remotes)))
expected <- c(sub(".*==[[:space:]]*([^)[:space:]]+).*", "\\1", pins), sub(".*@", "", remotes))
for (i in seq_along(pinned)) {
  entry <- lock$Packages[[pinned[i]]]
  if (!identical(entry$RemoteSha %||% entry$Version, expected[i]))
    stop("renv.lock has no record for ", pinned[i], " at ", expected[i], "; add it with renv::record()")
}

db <- available.packages(repos = c(CRAN = url), type = "source")
wanted <- setdiff(package_names(imports), pinned)
missing <- setdiff(wanted, rownames(db))
if (length(missing))
  stop("not in the ", date, " snapshot (pin them at their last release): ", paste(missing, collapse = ", "))

roots <- c(wanted, unlist(lapply(lock$Packages[pinned], `[[`, "Requirements")))
dependencies <- tools::package_dependencies(roots, db = db, which = c("Depends", "Imports", "LinkingTo"), recursive = TRUE)
resolved <- setdiff(intersect(c(roots, unlist(dependencies)), rownames(db)), pinned)

# The recommended packages and renv come with the image, so the lock holds the versions installed here.
installed <- installed.packages()
from_r <- c(intersect(resolved, rownames(installed.packages(.Library, priority = "recommended"))), "renv")

records <- c(
  lapply(setdiff(resolved, from_r), function(package) lock_record(db[package, ])),
  lapply(from_r, function(package) lock_record(installed[package, ])),
  lock$Packages[pinned]
)
names(records) <- vapply(records, `[[`, character(1), "Package")

base <- rownames(installed.packages(.Library, priority = "base"))
unresolved <- setdiff(unlist(lapply(records, `[[`, "Requirements")), c(names(records), base, "R"))
if (length(unresolved))
  stop("dependencies missing from the ", date, " snapshot: ", paste(unresolved, collapse = ", "))

lock$R$Version <- format(getRversion())
lock$R$Repositories <- list(CRAN = url)
lock$Packages <- records
invisible(renv::lockfile_write(lock, "renv.lock"))
