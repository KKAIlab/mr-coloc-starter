# R/utils.R — shared helpers, sourced by the numbered scripts.

suppressMessages({
  library(data.table)
  library(dplyr)
})

# Resolve config relative to the project root, wherever the script is run from.
if (!exists("config")) source("config.R")

#' Read a summary-stats file and rename columns to the pipeline's standard names.
#'
#' @param path  file path (TSV/CSV, auto-detected by data.table::fread)
#' @param cols  named list mapping standard names -> your file's column names
#' @return data.table with standard columns
read_sumstats <- function(path, cols = config$cols) {
  if (!file.exists(path)) {
    stop("File not found: ", path,
         "\n  -> put your summary stats in data/ and update config.R", call. = FALSE)
  }
  dt <- data.table::fread(path)

  present <- unlist(cols) %in% names(dt)
  if (!all(present)) {
    missing <- unlist(cols)[!present]
    stop("These columns (from config$cols) are missing in ", path, ":\n  ",
         paste(missing, collapse = ", "),
         "\n  -> fix the mapping in config.R", call. = FALSE)
  }

  # Select + rename: standard_name <- your_name
  keep <- unlist(cols)
  dt <- dt[, ..keep]
  data.table::setnames(dt, unname(keep), names(cols))
  dt[]
}

#' Ensure the results directory exists; return the full path for a file.
result_path <- function(filename, dir = config$results_dir) {
  if (!dir.exists(dir)) dir.create(dir, recursive = TRUE)
  file.path(dir, filename)
}

#' Small logger so each step announces itself.
step <- function(...) message("\n[", format(Sys.time(), "%H:%M:%S"), "] ", ...)
