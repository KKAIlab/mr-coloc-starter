# install.R — install the R packages this starter kit needs.
# Run once:  source("install.R")

cran_pkgs <- c(
  "data.table",  # fast CSV/TSV reading
  "dplyr",       # data wrangling
  "ggplot2",     # plots
  "coloc"        # colocalization (coloc.abf)
)

# TwoSampleMR is not on CRAN — installed from GitHub via remotes.
to_install <- cran_pkgs[!(cran_pkgs %in% rownames(installed.packages()))]
if (length(to_install) > 0) {
  message("Installing from CRAN: ", paste(to_install, collapse = ", "))
  install.packages(to_install, repos = "https://cloud.r-project.org")
}

if (!requireNamespace("remotes", quietly = TRUE)) {
  install.packages("remotes", repos = "https://cloud.r-project.org")
}

if (!requireNamespace("TwoSampleMR", quietly = TRUE)) {
  message("Installing TwoSampleMR from GitHub (MRCIEU/TwoSampleMR)...")
  remotes::install_github("MRCIEU/TwoSampleMR")
}

message("\nDone. Packages ready:\n  ",
        paste(c(cran_pkgs, "TwoSampleMR"), collapse = "\n  "))
