# R/02_mr.R
# Two-sample Mendelian randomization on the harmonised data.
# Runs the standard estimators plus sensitivity analyses, and saves plots.
#
# Input:  results/harmonised.rds  (from 01_harmonise.R)
# Output: results/mr_results.csv, results/mr_scatter.png, results/mr_forest.png

source("config.R")
source("R/utils.R")
suppressMessages({ library(TwoSampleMR); library(ggplot2) })

harmonised_file <- result_path("harmonised.rds")
if (!file.exists(harmonised_file)) {
  stop("Run R/01_harmonise.R first — ", harmonised_file, " not found.", call. = FALSE)
}
dat <- readRDS(harmonised_file)

# --- Main MR estimates ------------------------------------------------------
# IVW is the primary estimate; Egger / weighted median / mode are sensitivity
# analyses that make different assumptions about pleiotropy.
step("Running MR (IVW, Egger, weighted median, weighted mode)")
res <- mr(dat, method_list = c(
  "mr_ivw",
  "mr_egger_regression",
  "mr_weighted_median",
  "mr_weighted_mode"
))
res_or <- generate_odds_ratios(res)   # adds OR + 95% CI (useful for binary outcomes)

write.csv(res_or, result_path("mr_results.csv"), row.names = FALSE)
step("Saved -> ", result_path("mr_results.csv"))
print(res_or[, c("method", "nsnp", "b", "se", "pval", "or", "or_lci95", "or_uci95")])

# --- Sensitivity analyses ---------------------------------------------------
step("Heterogeneity (Cochran's Q) and pleiotropy (Egger intercept)")
het  <- mr_heterogeneity(dat)
pleio <- mr_pleiotropy_test(dat)
write.csv(het,   result_path("mr_heterogeneity.csv"), row.names = FALSE)
write.csv(pleio, result_path("mr_pleiotropy.csv"),    row.names = FALSE)

# --- Plots ------------------------------------------------------------------
step("Writing plots")
p_scatter <- mr_scatter_plot(res, dat)[[1]]
ggsave(result_path("mr_scatter.png"), p_scatter, width = 7, height = 6, dpi = 150)

res_single <- mr_singlesnp(dat)
p_forest <- mr_forest_plot(res_single)[[1]]
ggsave(result_path("mr_forest.png"), p_forest, width = 7, height = 6, dpi = 150)

step("Done. MR outputs in ", config$results_dir, "/")
